import os
import json
import numpy as np

# 데이터 경로 설정
data_dir = 'dataset'
output_file = 'keypoints_data.npz'

# 클래스 레이블 설정
classes = ['넘어짐', '떨어짐', '정상']

# 데이터 로드 함수
def load_data(data_dir, classes):
    data = []
    labels = []
    for label, class_name in enumerate(classes):
        class_dir = os.path.join(data_dir, class_name)
        for filename in os.listdir(class_dir):
            if filename.endswith('.json'):
                file_path = os.path.join(class_dir, filename)
                with open(file_path, 'r', encoding='utf-8') as file:
                    json_data = json.load(file)
                    keypoints_found = False

                    # 'annotations' 태그가 있을 경우
                    if 'annotations' in json_data:
                        for annotation in json_data['annotations']:
                            keypoints = annotation.get('keypoints', [])
                            if len(keypoints) == 12:  # 12개의 키포인트만 사용
                                flat_keypoints = [val for sublist in keypoints for val in sublist]
                                data.append(flat_keypoints)
                                labels.append(label)
                                keypoints_found = True

                    # 'annotations' 태그가 없고, 'keypoints' 태그가 최상위에 있을 경우
                    if not keypoints_found and 'keypoints' in json_data:
                        keypoints = json_data['keypoints']
                        if len(keypoints) == 12:  # 12개의 키포인트만 사용
                            flat_keypoints = [val for sublist in keypoints for val in sublist]
                            data.append(flat_keypoints)
                            labels.append(label)

    return np.array(data), np.array(labels)

# 훈련 및 검증 데이터 로드
train_data, train_labels = load_data(os.path.join(data_dir, 'train'), classes)
valid_data, valid_labels = load_data(os.path.join(data_dir, 'valid'), classes)

# 넘파이 파일로 저장
np.savez(output_file, train_data=train_data, train_labels=train_labels, valid_data=valid_data, valid_labels=valid_labels)

print(f"Data saved to {output_file}")
