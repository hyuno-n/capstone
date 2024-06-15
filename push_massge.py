import requests
import json
from dotenv import load_dotenv
import os
from datetime import datetime

# .env 파일에서 환경 변수 로드
load_dotenv()

def push_message(action_name, camera_number=1):
    url = f"http://{os.getenv('FLASK_APP_IP')}:{os.getenv('FLASK_APP_PORT')}/set_message"
    headers = {'Content-Type': 'application/json'}
    data = {
        'timestamp': datetime.now().isoformat(),
        'action_name': action_name,
        'camera_number': camera_number
    }

    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == 200:
        print('Message pushed successfully:', response.json())
    else:
        print('Failed to push message:', response.json())

if __name__ == '__main__':
    action_name = input("Enter the action name: ")
    camera_number = 1  # 카메라 번호를 1번으로 고정
    push_message(action_name, camera_number)
