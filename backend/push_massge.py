import requests
import json
from dotenv import load_dotenv
import os
from datetime import datetime

# .env 파일에서 환경 변수 로드
load_dotenv()

def push_message():
    url = f"http://{os.getenv('FLASK_APP_IP', '0.0.0.0')}:{os.getenv('FLASK_APP_PORT', '5000')}/log_event"
    data = {
        'user_id': 'qkreogus',
        'timestamp': '2024-11-04 02:55:00',
        'eventname': 'Movement',
        'camera_number': 1,
    }

    response = requests.post(url, json=data)

    if response.status_code == 200:
        print('Event logged successfully:', response.json())
    else:
        print('Failed to log event:', response.text)

if __name__ == '__main__':
    push_message()