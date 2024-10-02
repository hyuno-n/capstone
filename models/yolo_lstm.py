from ultralytics import YOLO
import numpy as np
import cv2
import tensorflow as tf
from tensorflow.keras.models import load_model
from collections import defaultdict

# 전역 상수 정의
CONFIDENCE_THRESHOLD = 0.6
GREEN = (0, 255, 0)
WHITE = (255, 255, 255)

# LSTM 모델 불러오기
lstm_model = load_model('model/lstm_keypoints_model.h5')

# YOLO 모델 불러오기
yolo_model = YOLO("model/yolov8s-pose.pt")

# 클래스 레이블 설정
classes = ['Fall', 'Fall_down', 'Normal']

# 비디오 캡처 초기화
cap = cv2.VideoCapture('video/fall_down_test.mp4')

# 기본값으로 설정할 키포인트와 클래스
default_keypoints = np.zeros((12, 2))  # (12, 2) 형태로, 0,0으로 초기화
default_class = 'Normal'

# 출력 해상도 설정
output_width = 1920
output_height = 1080

# 비디오 저장 초기화
fourcc = cv2.VideoWriter_fourcc(*'mp4v') 
out = cv2.VideoWriter('output_video.mp4', fourcc, 30.0, (output_width, output_height))

# 객체 추적 이력을 저장하기 위한 defaultdict
track_history = defaultdict(lambda: [])

# 탐지 기능 온오프를 위한 변수
detection_on = False  # 기본적으로 탐지 비활성화 상태로 시작

def detect_people_and_keypoints(frame):
    """주어진 프레임에서 사람 및 키포인트 탐지"""
    track_ids = []
    keypoints_list = []
    
    try:
        results = yolo_model.track(frame, persist=True)
        keypoints = results[0].keypoints
        boxes = results[0].boxes.xyxy.cpu().numpy()  # 경계 상자 정보
        track_ids = results[0].boxes.id.int().cpu().tolist()
        
        # 객체 추적 이력 업데이트
        update_track_history(boxes, track_ids)
        
        if keypoints is not None and len(keypoints) > 0:
            for kp in keypoints:
                kps = kp.xy[0].cpu().numpy()  # (17, 2) 형태의 numpy 배열
                keypoints_list.append(kps)
    except AttributeError as e:
        print(e)
    
    return keypoints_list, boxes

def update_track_history(boxes, track_ids):
    """주어진 경계 상자와 트랙 ID를 사용하여 추적 이력 업데이트"""
    for box, track_id in zip(boxes, track_ids):
        x, y, _, _ = box
        track = track_history[track_id]
        track.append((float(x), float(y)))  # x, y center point
        if len(track) > 30:  # 30프레임 이상 보존
            track.pop(0)

def preprocess_keypoints(keypoints):
    """키포인트 전처리"""
    if keypoints.shape[0] == 0:
        return default_keypoints

    body_keypoints_indices = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
    if keypoints.shape[0] <= max(body_keypoints_indices):
        raise ValueError("body_keypoints_indices contains indices out of bounds.")

    filtered_keypoints = keypoints[body_keypoints_indices, :2]
    return filtered_keypoints

def draw_skeletons(frame, keypoints_list, boxes):
    """프레임에 스켈레톤과 경계 상자 그리기"""
    # 경계 상자 그리기
    for box in boxes:
        x1, y1, x2, y2 = map(int, box)
        cv2.rectangle(frame, (x1, y1), (x2, y2), GREEN, 2)

    # 스켈레톤 그리기
    for keypoints in keypoints_list:
        for (x, y) in keypoints:
            cv2.circle(frame, (int(x), int(y)), 3, GREEN, -1)
    
    return frame

def toggle_detection():
    """탐지 기능을 온오프하는 함수"""
    global detection_on
    detection_on = not detection_on
    status = "ON" if detection_on else "OFF"
    print(f"탐지 기능이 {status} 상태입니다.")

def main():
    """비디오 프로세싱 메인 루프"""
    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            break
        
        # 프레임을 1920x1080으로 리사이즈
        frame = cv2.resize(frame, (output_width, output_height))

        # 탐지 기능이 켜져 있는 경우에만 탐지 수행
        if detection_on:
            keypoints_list, boxes = detect_people_and_keypoints(frame)
            predicted_label = default_class

            # 각 객체의 키포인트로 예측 수행
            for keypoints in keypoints_list:
                preprocessed_keypoints = preprocess_keypoints(keypoints)
                preprocessed_keypoints = preprocessed_keypoints.reshape(1, 12, 2)
                predictions = lstm_model.predict(preprocessed_keypoints)
                predicted_class = np.argmax(predictions, axis=1)[0]
                predicted_label = classes[predicted_class]
            
            # 객체 추적 이력을 사용하여 추적선 그리기
            for track_id in track_history:
                track = track_history[track_id]
                if track: 
                    points = np.hstack(track).astype(np.int32).reshape((-1, 1, 2))
                    cv2.polylines(frame, [points], isClosed=False, color=WHITE, thickness=10)

            # 예측 결과 표시
            cv2.putText(frame, predicted_label, (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)

            # 스켈레톤 및 경계 상자 그리기
            frame = draw_skeletons(frame, keypoints_list, boxes)
        
        # 프레임을 비디오 파일에 기록
        out.write(frame)
        
        # 프레임 표시
        cv2.imshow('Video', frame)

        # 키보드 입력으로 탐지 기능 온오프 토글
        key = cv2.waitKey(1)
        if key == ord('t'):  # 't' 키를 눌러 탐지 기능 토글
            toggle_detection()
        elif key == ord('q'):  # 'q' 키를 눌러 종료
            break
        
    # 자원 해제
    cap.release()
    out.release()  # 비디오 저장 객체 해제
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
