import json
import os

# 제외할 키포인트 인덱스
excluded_indexes = {0, 1, 2, 9}

# 입력 폴더와 출력 폴더 경로 설정
input_folder = './dataset/train/떨어짐'
output_folder = '떨어짐_키포인트'
os.makedirs(output_folder, exist_ok=True)

# 폴더 내의 모든 JSON 파일 처리
for filename in os.listdir(input_folder):
    if filename.endswith('.json'):
        input_path = os.path.join(input_folder, filename)
        
        # JSON 파일 읽기
        with open(input_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
        
        # 'annotations' 항목에서 키포인트를 추출하고, 'point'를 'keypoints'로 변경
        annotations = data.get('annotations', [])
        
        for annotation in annotations:
            img_no = annotation.get('data ID')
            points = annotation.get('point')
            
            if img_no is not None and points is not None:
                # 제외할 인덱스를 고려하여 새로운 키포인트 배열 생성
                filtered_keypoints = [
                    points[i]
                    for i in range(len(points))
                    if i not in excluded_indexes
                ]
                
                # 'point' 태그를 'keypoints'로 변경
                annotation['keypoints'] = filtered_keypoints
                del annotation['point']
        
        # JSON 파일로 저장
        output_filename = filename
        output_path = os.path.join(output_folder, output_filename)
        
        with open(output_path, 'w', encoding='utf-8') as outfile:
            json.dump(data, outfile, indent=4)
        
        print(f"Updated and saved file {filename} to {output_path}")

print("All files have been processed and saved successfully.")
