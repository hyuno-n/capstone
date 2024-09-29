from ultralytics import YOLO
import numpy as np
import cv2
import tensorflow as tf
from tensorflow.keras.models import load_model


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
cap = cv2.VideoCapture('video/제조현장_넘어짐-02.mp4')

# 기본값으로 설정할 키포인트와 클래스
default_keypoints = np.zeros((12, 2))  # (12, 2) 형태로, 0,0으로 초기화
default_class = 'Normal'

# 출력 해상도 설정
output_width = 1920
output_height = 1080

# 비디오 저장 초기화
fourcc = cv2.VideoWriter_fourcc(*'mp4v') 
out = cv2.VideoWriter('output_video.mp4', fourcc, 30.0, (output_width, output_height))

def detect_people_and_keypoints(frame):
    try:
        results = yolo_model(frame, persist=True)
        keypoints = results[0].keypoints
        boxes = results[0].boxes.xyxy.cpu().numpy()  # 경계 상자 정보
        track_ids = results[0].boxes.id.int().cpu().tolist()
    except AttributeError as e:
        print(e)
    keypoints_list = []

    if keypoints is not None and len(keypoints) > 0:
        for kp in keypoints:
            kps = kp.xy[0].cpu().numpy()  # (17, 2) 형태의 numpy 배열
            keypoints_list.append(kps)
    else:
        print("No keypoints detected.")

    return keypoints_list, boxes

def preprocess_keypoints(keypoints):
    if keypoints.shape[0] == 0:
        # 키포인트가 없을 때 기본값 사용
        return default_keypoints

    body_keypoints_indices = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
    if keypoints.shape[0] <= max(body_keypoints_indices):
        raise ValueError("body_keypoints_indices contains indices out of bounds.")

    filtered_keypoints = keypoints[body_keypoints_indices, :2]
    return filtered_keypoints

def draw_skeletons(frame, keypoints_list, boxes):
    # 경계 상자 그리기
    for box in boxes:
        x1, y1, x2, y2 = map(int, box)
        cv2.rectangle(frame, (x1, y1), (x2, y2), GREEN, 2)

    # 스켈레톤 그리기
    for keypoints in keypoints_list:
        for (x, y) in keypoints:
            cv2.circle(frame, (int(x), int(y)), 3, GREEN, -1)
    return frame

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    
    # 프레임을 1920x1080으로 리사이즈
    frame = cv2.resize(frame, (output_width, output_height))

    keypoints_list, boxes = detect_people_and_keypoints(frame)

    predicted_label = default_class

    for keypoints in keypoints_list:
        preprocessed_keypoints = preprocess_keypoints(keypoints)
        preprocessed_keypoints = preprocessed_keypoints.reshape(1, 12, 2)
        predictions = lstm_model.predict(preprocessed_keypoints)
        predicted_class = np.argmax(predictions, axis=1)[0]
        predicted_label = classes[predicted_class]

    # 예측 결과 표시
    cv2.putText(frame, predicted_label, (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)

    # 스켈레톤 및 경계 상자 그리기
    frame = draw_skeletons(frame, keypoints_list, boxes)
    
    # 프레임을 비디오 파일에 기록
    out.write(frame)
    
    # 프레임 표시
    # cv2.imshow('Video', frame)

    # if cv2.waitKey(1) & 0xFF == ord('q'):
    #     break

cap.release()
out.release()  # 비디오 저장 객체 해제
cv2.destroyAllWindows()
