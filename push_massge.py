import requests
import json
from dotenv import load_dotenv
import os

# .env 파일에서 환경 변수 로드
load_dotenv()

def push_message(message):
    url = f"http://{os.getenv('FLASK_APP_IP')}:{os.getenv('FLASK_APP_PORT')}/set_message"
    headers = {'Content-Type': 'application/json'}
    data = {'message': message}

    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == 200:
        print('Message pushed successfully:', response.json())
    else:
        print('Failed to push message:', response.json())

if __name__ == '__main__':
    message = input("Enter the message to push: ")
    push_message(message)
