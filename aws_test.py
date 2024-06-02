import boto3
import cv2
import time
import os

def s3_connection():
    try:
        # s3 클라이언트 생성
        s3 = boto3.client(
            service_name="s3",
            region_name="eu-north-1",
            aws_access_key_id="",
            aws_secret_access_key="",
        )
    except Exception as e:
        print(e)
        return None
    else:
        print("s3 bucket connected!")
        return s3

def capture_video(rtsp_url, duration, output_file):
    cap = cv2.VideoCapture(rtsp_url)
    if not cap.isOpened():
        print("Error: Unable to open RTSP stream")
        return False 

    # 비디오 코덱 설정
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_file, fourcc, 20.0, (int(cap.get(3)), int(cap.get(4))))

    start_time = time.time()
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: Unable to read frame")
            break

        out.write(frame)

        if time.time() - start_time > duration:
            break

    cap.release()
    out.release()
    return True

def upload_to_s3(file_name, bucket_name, key_name, s3_client):
    try:
        s3_client.upload_file(file_name, bucket_name, key_name)
        print(f"Uploaded {file_name} to s3://{bucket_name}/{key_name}")
    except Exception as e:
        print(f"Failed to upload {file_name} to {bucket_name}/{key_name}: {e}")

# S3 연결
s3 = s3_connection()

if s3 is not None:
    # RTSP URL 및 저장할 파일 경로 설정
    rtsp_url = "rtsp://jaehoon010:asdang22@123.212.88.101:554/stream1"
    current_dir = os.path.dirname(os.path.abspath(__file__))
    output_file = os.path.join(current_dir, 'capture.mp4')
    duration = 20  # 비디오 캡처 시간 (초)
    bucket_name = "testawsipcamera"
    key_prefix = "greyhound.mp4"

    # 비디오 캡처
    if capture_video(rtsp_url, duration, output_file):
        print(f"Video saved successfully to {output_file}")
        
        # 비디오 파일을 S3에 업로드
        key_name = f"{key_prefix}/{int(time.time())}.mp4"
        upload_to_s3(output_file, bucket_name, key_name, s3)
    else:
        print("Failed to capture video")