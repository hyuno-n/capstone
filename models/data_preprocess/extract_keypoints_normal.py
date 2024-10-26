import json
import os

# COCO 데이터셋에서 제외할 키포인트 인덱스
excluded_indexes = {6, 7, 8, 9}

# 재배치할 순서 (왼쪽 어깨, 오른쪽 어깨, 왼쪽 팔꿈치, 오른쪽 팔꿈치, 왼쪽 손목, 오른쪽 손목, 왼쪽 둔부, 오른쪽 둔부, 왼쪽 무릎, 오른쪽 무릎, 왼쪽 발목, 오른쪽 발목)
desired_order = [9, 8, 10, 7, 11, 6, 3, 2, 4, 1, 5, 0]

# 입력 폴더와 출력 폴더 경로 설정
input_folder = 'data/train/정상'
output_folder = '정상 키포인트'
os.makedirs(output_folder, exist_ok=True)

# 폴더 내의 모든 JSON 파일 처리
for filename in os.listdir(input_folder):
    if filename.endswith('.json'):
        input_path = os.path.join(input_folder, filename)
        
        # JSON 파일 읽기
        with open(input_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
        
        # 'annotations' 항목에서 키포인트를 추출
        annotations = data.get('annotations', [])
        
        for annotation in annotations:
            img_no = annotation.get('img_no')
            keypoints = annotation.get('keypoints')
            
            if img_no is not None and keypoints is not None:
                # 6~9번 키포인트 제외
                filtered_keypoints = [
                    keypoints[i*3:i*3 + 3]
                    for i in range(len(keypoints) // 3)
                    if i not in excluded_indexes
                ]
                
                # 남은 키포인트를 원하는 순서로 재배치
                ordered_keypoints = [None] * len(desired_order)
                for new_index, old_index in enumerate(desired_order):
                    if old_index < len(filtered_keypoints):
                        ordered_keypoints[new_index] = filtered_keypoints[old_index]
                
                # 필요한 데이터 구조 설정
                output_data = {
                    'keypoints': ordered_keypoints
                }
                
                # JSON 파일로 저장
                output_filename = f'{img_no}.json'
                output_path = os.path.join(output_folder, output_filename)
                
                with open(output_path, 'w', encoding='utf-8') as outfile:
                    json.dump(output_data, outfile, indent=4)
                
                print(f"Saved keypoints for image {img_no} to {output_path}")

print("All keypoints have been saved successfully.")
