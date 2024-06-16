import requests
import json
from dotenv import load_dotenv
import os
from datetime import datetime

# .env 파일에서 환경 변수 로드
load_dotenv()

def push_message(id, eventname, camera_number=1):
    url = f"http://{os.getenv('FLASK_APP_IP', '127.0.0.1')}:{os.getenv('FLASK_APP_PORT', '5000')}/set_message"
    headers = {'Content-Type': 'application/json'}
    data = {
        'id': id,
        'timestamp': datetime.now().isoformat(),
        'eventname': eventname,
        'camera_number': camera_number
    }

    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == 200:
        print('Message pushed successfully:', response.json())
    else:
        print('Failed to push message:', response.text)

if __name__ == '__main__':
    id = int(input("Enter the ID: "))
    eventname = input("Enter the event name: ")
    camera_number = int(input("Enter the camera number: "))
    push_message(id, eventname, camera_number)
