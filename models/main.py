from ultralytics import YOLO
import numpy as np
import cv2
import os
import datetime
from tensorflow.keras.models import load_model
from collections import defaultdict, deque

# 전역 상수 정의
CONFIDENCE_THRESHOLD = 0.6
GREEN = (0, 255, 0)
WHITE = (255, 255, 255)

# LSTM 모델 및 YOLO 모델 불러오기
lstm_model = load_model('model/lstm_keypoints_model.h5')
yolo_model = YOLO("model/yolov8s-pose.pt")

# 클래스 레이블 설정
classes = ['Fall', 'Fall_down', 'Normal']

# RTSP 스트림 주소 설정
rtsp_url = "rtsp://username:password@camera_ip_address/stream"
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

# 탐지 기능 온오프 설정 및 저장 경로 초기화
motion_on = False
detection_on, output_dir = False, "saved_clips"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# ** ROI 좌표값 (앱에서 받은 값으로 대체 예정) **
roi_x1, roi_y1, roi_x2, roi_y2 = 0, 0, 1920, 1080  # 초기 값
roi_apply_signal = False  # ROI 적용 신호 (앱에서 받아옴)

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

def toggle_detection():
    """탐지 기능을 온오프하는 함수"""
    global detection_on
    detection_on = not detection_on
    print(f"탐지 기능이 {'ON' if detection_on else 'OFF'} 상태입니다.")

def save_event_clip(event_name, frame):
    """이벤트가 발생하면 영상을 저장하는 함수"""
    global out
    if out is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        clip_filename = os.path.join(output_dir, f"{event_name}_{timestamp}.mp4")
        out = cv2.VideoWriter(clip_filename, fourcc, fps, (frame_width, frame_height))

        buffer_size = len(pre_event_buffer)
        if buffer_size > 0:
            print(f"이벤트 발생 전 {buffer_size}개의 프레임을 저장합니다.")
            for buffered_frame in pre_event_buffer:
                out.write(buffered_frame)
        else:
            print("이벤트 발생 전 저장할 프레임이 충분하지 않습니다.")
    
    out.write(frame)

def send_alert(event_name):
    """이벤트 발생 시 알림을 보내는 함수"""
    print(f"경고: {event_name} 발생! 알림 전송 중...")

def handle_event_detection(frame, predicted_label):
    """이벤트 발생 감지 후 처리"""
    global event_detected, frames_after_event
    if predicted_label in ['Fall', 'Fall_down', 'Movement'] and not event_detected:
        event_detected = True
        frames_after_event = 0
        print(f"{predicted_label} detected!")
        send_alert(predicted_label)
    
    if event_detected:
        pre_event_buffer.append(frame)
        save_event_clip(predicted_label, frame)
        frames_after_event += 1

        if frames_after_event >= post_event_length:
            event_detected = False
            out.release()
            out = None
            print("이벤트 클립 저장 완료.")

def detect_movement(frame, min_contour_area = 20000):
    bg_subtractor = cv2.createBackgroundSubtractorMOG2()
    fg_mask = bg_subtractor.apply(frame)
    fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, None, iterations=2)
    fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, None, iterations=2)
    contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    motion_detected = False
    for contour in contours:
        area = cv2.contourArea(contour)
        if area > min_contour_area:
            x, y, w, h = cv2.boundingRect(contour)
            if (roi_x1 <= x <= roi_x2) and (roi_y1 <= y <= roi_y2):
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
                motion_detected = True
            
    return frame, motion_detected

def draw_detection_area(frame):
    """탐지할 영역(ROI)을 프레임에 그리는 함수"""
    cv2.rectangle(frame, (roi_x1, roi_y1), (roi_x2, roi_y2), (0, 0, 255), 2)  # 빨간색 사각형 그리기

def is_in_detection_area(x, y):
    """좌표가 탐지 범위(ROI) 내에 있는지 확인"""
    return (roi_x1 <= x <= roi_x2) and (roi_y1 <= y <= roi_y2)

def main():
    """비디오 프로세싱 메인 루프"""
    global frames_after_event
    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            break

        frame = cv2.resize(frame, (output_width, output_height))
        
        if roi_apply_signal:
            # 탐지할 영역 그리기
            draw_detection_area(frame)

        if detection_on:
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
                    if is_in_detection_area(x, y):  # ROI 내에 있는지 확인
                        detected_in_roi = True  # ROI 내에서 감지됨
                        break  # 한 번이라도 ROI 안에 있는 점이 있으면 감지 성공으로 처리
                    
            if detected_in_roi:
                handle_event_detection(frame, predicted_label)
                frame = draw_skeletons_and_boxes(frame, keypoints_list, boxes)
                for track_id, track in track_history.items():
                    if track:
                        points = np.hstack(track).astype(np.int32).reshape((-1, 1, 2))
                        cv2.polylines(frame, [points], isClosed=False, color=WHITE, thickness=10)
                    if track_id in object_predictions:
                        cv2.putText(frame, object_predictions[track_id], (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)
                        
        if motion_on:
            frame, motion_detected = detect_movement(frame)
            if motion_detected:
                handle_event_detection(frame, 'Movement')
            
        if out:
            out.write(frame)
        
        cv2.imshow('Video', frame)

        # 모션 감지 토글 on/off 추후 변경
        key = cv2.waitKey(1)
        if key == ord('t'):
            toggle_detection()
        elif key == ord('q'):
            break

    cap.release()
    if out:
        out.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
