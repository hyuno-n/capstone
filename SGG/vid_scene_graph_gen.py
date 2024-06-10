import cv2
import subprocess
import os,sys

def extract_frames(video_path, output_folder, fps=25):
    # 비디오 읽기
    video = cv2.VideoCapture(video_path)
    video_fps = video.get(cv2.CAP_PROP_FPS)

    frame_count = 0
    while True:
        ret, frame = video.read()
        if not ret:
            break

        # 지정된 fps에 맞게 프레임 저장
        if frame_count % int(video_fps / fps) == 0:
            frame_path = os.path.join(output_folder, f'video_frame/frame_{frame_count:04d}.jpg')
            cv2.imwrite(frame_path, frame)
            process_frame(frame_path)

        frame_count += 1

    video.release()

def process_frame(frame_path):
    # `scene_graph_gen.py` 스크립트 실행
    command = [
        'python', 'scene_graph_gen.py',
        '--config', 'GroundingDINO/groundingdino/config/GroundingDINO_SwinT_OGC.py',
        '--grounded_checkpoint', 'groundingdino_swint_ogc.pth',
        '--sam_checkpoint', 'sam_vit_h_4b8939.pth',
        '--input_image', frame_path,
        '--output_dir', output_folder,
        '--box_threshold', '0.25',
        '--text_threshold', '0.2',
        '--iou_threshold', '0.5',
        '--device', 'cpu'
    ]
    subprocess.run(command)

# 비디오 경로 및 출력 폴더 설정do
video_path = 'assets/video/test.mp4'
output_folder = 'outputs/video_output'

# 프레임 추출 및 처리
extract_frames(video_path, output_folder, fps=25)