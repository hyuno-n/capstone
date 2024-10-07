import cv2
import numpy as np
import json
import os

# JSON 파일 경로 및 이미지 파일 경로
json_path = 'S2-N6001M00234.json'
image_path = 'S2-N6001M00234.jpg'

# COCO 키포인트 순서 (영어 레이블)
keypoint_labels = [
    '0', '1', '2', '3', '4',
    '5', '6', '7', '8',
    '9', '10', '11'
]

# 색상 설정
colors = {
    0: (0, 0, 0),       # 검정색 (보이지 않음)
    1: (0, 255, 255),   # 노란색 (부분적으로 보임)
    2: (0, 255, 0)      # 녹색 (완전히 보임)
}

# JSON 파일에서 키포인트 데이터 읽기
def load_keypoints_from_json(json_path):
    with open(json_path, 'r', encoding='utf-8') as file:
        data = json.load(file)
    
    # 'keypoints' 항목에서 키포인트 데이터를 추출
    annotations = data.get('annotations', [])
    if annotations:
        keypoints = annotations[0].get('keypoints', [])
        return keypoints
    return []

# 이미지 읽기
image = cv2.imread(image_path)

if image is None:
    print(f"Image file not found: {image_path}")
    exit()

# 이미지 크기 확인
height, width, _ = image.shape
print(f"Image size: {width}x{height}")

# JSON 파일에서 키포인트 가져오기
keypoints = load_keypoints_from_json(json_path)

# 키포인트 그리기
for i, (x, y, v) in enumerate(keypoints):
    if v != 0:  # 키포인트가 보이는 경우
        # 좌표가 이미지 크기 내에 있는지 확인
        if 0 <= x < width and 0 <= y < height:
            color = colors[v]
            cv2.circle(image, (int(x), int(y)), 5, color, -1)
            cv2.putText(image, f'{keypoint_labels[i]}', (int(x) + 5, int(y) - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1, cv2.LINE_AA)
        else:
            print(f"Coordinate ({x}, {y}) is out of image bounds.")

# 결과 이미지 저장 및 출력
output_image_path = 'output_image.jpg'
cv2.imwrite(output_image_path, image)
cv2.imshow('Keypoints', image)
cv2.waitKey(0)
cv2.destroyAllWindows()
