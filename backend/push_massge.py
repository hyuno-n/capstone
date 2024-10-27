import requests
import json
from dotenv import load_dotenv
import os
from datetime import datetime

# .env 파일에서 환경 변수 로드
load_dotenv()

def push_message(user_id, eventname, camera_number=1):
    url = f"http://{os.getenv('FLASK_APP_IP', '127.0.0.1')}:{os.getenv('FLASK_APP_PORT', '5000')}/log_event"
    headers = {'Content-Type': 'application/json'}
    data = {
        'user_id': user_id,
        'timestamp': datetime.now().isoformat(),
        'eventname': eventname,
        'camera_number': camera_number
    }

    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == 200:
        print('Event logged successfully:', response.json())
    else:
        print('Failed to log event:', response.text)

if __name__ == '__main__':
    user_id = input("Enter the User ID: ")  # User ID를 문자열로 받습니다.
    eventname = input("Enter the event name: ")
    camera_number = input("Enter the camera number: ")
    push_message(user_id, eventname, int(camera_number))
