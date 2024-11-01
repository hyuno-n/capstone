from ultralytics import YOLO
import numpy as np
import cv2
import os
import datetime
from tensorflow.keras.models import load_model
from collections import defaultdict, deque
from flask import Flask, request, jsonify
import threading
from dotenv import load_dotenv
import boto3
import requests
from concurrent.futures import ThreadPoolExecutor

# 스레드 풀 생성
executor = ThreadPoolExecutor(max_workers=2)  

# 배경 제거
bg_subtractor = cv2.createBackgroundSubtractorMOG2()

# Flask 서버 설정
load_dotenv()
app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'

# AWS S3 설정
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION_NAME = os.getenv("AWS_REGION_NAME")
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME")
S3_FOLDER_NAME = "saved_clips"

# 전역 상수 정의
CONFIDENCE_THRESHOLD = 0.6
GREEN = (0, 255, 0)
WHITE = (255, 255, 255)

# LSTM 모델 및 YOLO 모델 불러오기
lstm_model = load_model('model/lstm_keypoints_model_improved1.h5')
yolo_model = YOLO("model/yolo11s-pose.pt")
fire_detect_model = YOLO("model/yolo11n-fire.pt")

# 클래스 레이블 설정
classes = ['Fall', 'Normal']

# RTSP 스트림 주소 설정
rtsp_url = "rtsp://210.99.70.120:1935/live/cctv008.stream"

cap = cv2.VideoCapture(rtsp_url)

# 기본값으로 설정할 키포인트와 클래스
default_keypoints = np.zeros((12, 2))  # (12, 2) 형태로, 0,0으로 초기화
default_class = 'Normal'

# 출력 해상도 및 비디오 저장 설정
output_width, output_height = 1920, 1080
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
fps = 30
frame_width, frame_height = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)), int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

# 클립 저장을 위한 버퍼 설정
buffer_length, post_event_length = 10 * fps, 30 * fps
pre_event_buffer = deque(maxlen=buffer_length)
event_detected, frames_after_event, out = False, 0, None
track_history, object_predictions = defaultdict(list), {}

# 기본값으로 설정할 ROI 좌표
default_roi_x1, default_roi_y1, default_roi_x2, default_roi_y2 = 0, 0, 1920, 1080

# 탐지 기능 온오프 설정 및 저장 경로 초기화
output_dir = "saved_clips" 
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# 전역 변수 선언
roi_x1 = 0
roi_y1 = 0
roi_x2 = 1920
roi_y2 = 1080

def detect_people_and_keypoints(frame):
    """주어진 프레임에서 사람 및 키포인트 탐지"""
    track_ids, keypoints_list = [], []
    
    try:
        results = yolo_model.track(frame, persist=True)
        keypoints = results[0].keypoints
        boxes = results[0].boxes.xyxy.cpu().numpy()
        track_ids = results[0].boxes.id.int().cpu().tolist()
        
        update_track_history(boxes, track_ids)
        if keypoints is not None:
            for kp in keypoints:
                keypoints_list.append(kp.xy[0].cpu().numpy())
    except AttributeError as e:
        print(e)
    
    return keypoints_list, boxes, track_ids

def update_track_history(boxes, track_ids):
    """경계 상자와 트랙 ID를 사용하여 추적 이력 업데이트"""
    for box, track_id in zip(boxes, track_ids):
        x, y, _, _ = box
        track_history[track_id].append((float(x), float(y)))
        if len(track_history[track_id]) > 30:
            track_history[track_id].pop(0)

def preprocess_keypoints(keypoints):
    """키포인트 전처리"""
    if keypoints.shape[0] == 0:
        return default_keypoints

    body_keypoints_indices = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
    filtered_keypoints = keypoints[body_keypoints_indices, :2]
    return filtered_keypoints

def draw_skeletons_and_boxes(frame, keypoints_list, boxes):
    """프레임에 스켈레톤과 경계 상자 그리기"""
    for box in boxes:
        x1, y1, x2, y2 = map(int, box)
        cv2.rectangle(frame, (x1, y1), (x2, y2), GREEN, 2)

    for keypoints in keypoints_list:
        for (x, y) in keypoints:
            cv2.circle(frame, (int(x), int(y)), 3, GREEN, -1)
    
    return frame

def create_s3():
    try:
        s3_client = boto3.client(
        service_name = 's3',
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION_NAME
        )
        print("S3 클라이언트 생성 성공")
        return s3_client
    except Exception as e:
        print(f"S3 클라이언트 생성 중 오류 발생: {e}")
        return None

def save_event_clip(event_name, frame, timestamp):
    """이벤트가 발생하면 영상을 저장하는 함수"""
    global out, frames_after_event, local_filepath, s3_key
    
    if out is None:
        clip_filename = f"{event_name}_{timestamp}.mp4"
        local_filepath = os.path.join(output_dir, clip_filename)
        s3_key = f"{S3_FOLDER_NAME}/{clip_filename}"
        out = cv2.VideoWriter(local_filepath, fourcc, fps, (frame_width, frame_height))

        buffer_size = len(pre_event_buffer)
        if buffer_size > 0:
            print(f"이벤트 발생 전 {buffer_size}개의 프레임을 저장합니다.")
            for buffered_frame in pre_event_buffer:
                out.write(buffered_frame)
        else:
            print("이벤트 발생 전 저장할 프레임이 충분하지 않습니다.")
    
    out.write(frame)
    frames_after_event += 1

    # 이벤트 후 클립 저장이 완료되면 S3에 업로드
    if frames_after_event >= post_event_length:
        out.release()
        out = None
        print("이벤트 클립 저장 완료.")
        
        # 클립 파일을 S3에 업로드
        future = executor.submit(upload_to_s3, local_filepath, S3_BUCKET_NAME, s3_key)  # S3 업로드를 백그라운드 스레드로 수행
        try:
            future.result()  # 업로드 완료를 대기
        except Exception as e:
            print(f"S3 업로드 중 오류 발생: {e}")

        # 로컬 파일 삭제
        if os.path.exists(local_filepath):
            os.remove(local_filepath)
            print(f"로컬 파일 삭제: {local_filepath}")

def upload_to_s3(local_filepath, s3_bucket_name, s3_key):
    try:
        s3_client = create_s3()
        s3_client = boto3.client('s3')
        s3_client.upload_file(local_filepath, s3_bucket_name, s3_key)
        print(f"S3에 {local_filepath} 업로드 성공: {s3_key}")
    except Exception as e:
        print(f"S3 업로드 중 오류 발생: {e}")

def handle_event_detection(frame, predicted_label):
    """이벤트 발생 감지 후 처리"""
    global event_detected, frames_after_event
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    if predicted_label in ['Fall', 'Movement','Black_smoke','Gray_smoke','White_smoke','Fire'] and not event_detected:
        event_detected = True
        frames_after_event = 0
        print(f"{predicted_label} detected!")
        send_alert(predicted_label, timestamp)
    
    if event_detected:
        pre_event_buffer.append(frame)
        save_event_clip(predicted_label, frame, timestamp)
        if frames_after_event >= post_event_length:
            event_detected = False

def detect_movement(frame, min_contour_area = 10000):
    """영상처리를 이용한 움직임 감지"""
    fg_mask = bg_subtractor.apply(frame)
    fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, None, iterations=2)
    fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, None, iterations=2)
    contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    motion_detected = False
    for contour in contours:
        area = cv2.contourArea(contour)
        if area > min_contour_area:
            x, y, w, h = cv2.boundingRect(contour)
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
            motion_detected = True
            
    return frame, motion_detected

def draw_detection_area(frame, roi_x1, roi_y1, roi_x2, roi_y2):
    """탐지할 영역(ROI)을 프레임에 그리는 함수"""
    cv2.rectangle(frame, (roi_x1, roi_y1), (roi_x2, roi_y2), (0, 0, 255), 2)  # 빨간색 사각형 그리기

def is_in_detection_area(x, y, roi_x1, roi_y1, roi_x2, roi_y2):
    """좌표가 탐지 범위(ROI) 내에 있는지 확인"""
    return (roi_x1 <= x <= roi_x2) and (roi_y1 <= y <= roi_y2)
    
# ID별 탐지 상태를 저장하기 위한 딕셔너리 초기화
detection_status = {}

@app.route('/event_update', methods=['POST'])
def event_update():
    """서버에서 탐지 기능 상태 가져오기"""
    try:
        # request.get_json() 사용하여 POST 요청의 JSON 데이터 가져오기
        data = request.get_json()
        if data is None:
            return jsonify({"error": "No JSON received"}), 400
        
        # JSON 데이터에서 ID와 fall_detection, movement_detection, fire_detection 값을 가져오기
        camera_id = data.get('user_id')
        if not camera_id:
            return jsonify({"error": "camera_id is required"}), 400
        
        # 개별 ID에 대한 탐지 상태 업데이트
        detection_status[camera_id] = {
            'fall_detection_on': data.get('fall_detection_on', False),
            'movement_detection_on': data.get('movement_detection_on', False),
            'fire_detection_on': data.get('fire_detection_on', False),
            'roi_values' : data.get('roi_values', {}),
            'user_id' : data.get('user_id','unknown')
        }

        print(detection_status[camera_id]['roi_values']['roi_x1'])


        # 상태 확인을 위한 로그 출력
        print(f"Camera {camera_id} - Fall detection: {detection_status[camera_id]['fall_detection_on']}, "
              f"Movement detection: {detection_status[camera_id]['movement_detection_on']}, "
              f"Fire detection: {detection_status[camera_id]['fire_detection_on']}")
        
        return jsonify({"status": "Detection status updated", "camera_id": camera_id}), 200
    
    except Exception as e:
        print(f"서버 통신 중 오류 발생: {e}")
        return jsonify({"error": "Internal server error"}), 500
    
def send_alert(event_name, timestamp):
    """이벤트 발생 시 알림을 보내는 함수"""
    print(f"경고: {event_name} 발생! 알림 전송 중...")
    
    url = f"http://{os.getenv('FLASK_APP_IP', '127.0.0.1')}:{os.getenv('FLASK_APP_PORT', '5000')}/log_event"
    
    payload = {
        'user_id': "inyeoung",
        'timestamp': timestamp,
        'eventname': event_name,
        'camera_number' : 1,
        'eventurl' : ""
    }
    
    try:
        response = requests.post(url, headers = {'Content-Type': 'application/json'} ,json= payload)
        if response.status_code == 200:
            print("서버에 신호 전송 완료.")
        else:
            print("서버 신호 전송 실패:", response.status_code)
    except Exception as e:
        print("오류 발생:", e)

def process_video():
    """비디오 프로세싱 메인 루프"""
    global roi_apply_signal  

    fall_detection_on = False  
    movement_detection_on = False
    fire_detection_on = False
    roi_apply_signal = True  

    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            break

        roi_x1, roi_y1, roi_x2, roi_y2 = 0, 0, 1920, 1080

        frame = cv2.resize(frame, (output_width, output_height))
        
        if roi_apply_signal:
        # 탐지할 영역 그리기
           draw_detection_area(frame, roi_x1, roi_y1, roi_x2, roi_y2)

        # 넘어짐 감지 
        if fall_detection_on:
            keypoints_list, boxes, track_ids = detect_people_and_keypoints(frame)
            predicted_label = default_class
            detected_in_roi = False 
            
            for keypoints, track_id in zip(keypoints_list, track_ids):
                preprocessed_keypoints = preprocess_keypoints(keypoints)
                preprocessed_keypoints = preprocessed_keypoints.reshape(1, 12, 2)
                predictions = lstm_model.predict(preprocessed_keypoints)
                predicted_class = np.argmax(predictions, axis=1)[0]
                predicted_label = classes[predicted_class]
                object_predictions[track_id] = predicted_label
                
                for (x, y) in keypoints:
                    if is_in_detection_area(x, y, roi_x1, roi_y1, roi_x2, roi_y2):  # ROI 내에 있는지 확인
                        detected_in_roi = True  # ROI 내에서 감지됨
                        break  # 한 번이라도 ROI 안에 있는 점이 있으면 감지 성공으로 처리
                    
            if detected_in_roi:
                handle_event_detection(frame, predicted_label)
                frame = draw_skeletons_and_boxes(frame, preprocessed_keypoints, boxes)
                for track_id, track in track_history.items():
                    if track:
                        points = np.hstack(track).astype(np.int32).reshape((-1, 1, 2))
                        cv2.polylines(frame, [points], isClosed=False, color=WHITE, thickness=10)
                    if track_id in object_predictions:
                        cv2.putText(frame, object_predictions[track_id], (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)
        
        # 움직임 감지              
        if movement_detection_on:
            frame, motion_detected = detect_movement(frame)
            if motion_detected:
                handle_event_detection(frame, 'Movement')
        
        # 화재 감지
        if fire_detection_on:
            fire_predictions=fire_detect_model.predict(source=frame, stream=True)
            fire_detected_in_roi = False
            for fire_predictions.boxes in fire_predictions:
                for box in fire_predictions.boxes:
                    # 바운딩 박스 좌표 추출
                    x1, y1, x2, y2 = map(int, box.xyxy[0])
                    
                    # 클래스 이름과 점수 가져오기
                    class_id = int(box.cls[0])
                    class_name = fire_detect_model.names[class_id]
                    score = box.conf[0]

                     # ROI 내에 바운딩 박스가 완전히 포함되는지 확인
                    if is_in_detection_area(x1, y1, x2, y2):
                        fire_detected_in_roi = True  # ROI 내에서 감지됨
                        break 

            if fire_detected_in_roi:
                handle_event_detection(frame, class_name)
                # 바운딩 박스와 클래스 이름 및 점수 표시
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                label = f"{class_name}: {score:.2f}"
                cv2.putText(frame, label, (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

        if out:
            out.write(frame)
        
        cv2.imshow('Video', frame)

        key = cv2.waitKey(1)
        if key == ord('q'):
            break

    cap.release()
    if out:
        out.release()
    cv2.destroyAllWindows()

def main():
    video_thread = threading.Thread(target=process_video)
    video_thread.start()
    app.run(host="0.0.0.0", port=8000, debug=True)

if __name__ == "__main__":
    main()
