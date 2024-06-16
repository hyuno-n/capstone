import requests
import json
from dotenv import load_dotenv
import os

# .env 파일에서 환경 변수 로드
load_dotenv()

def add_user(id, email, phone, address, detailed_address):
    url = f"http://{os.getenv('FLASK_APP_IP', '127.0.0.1')}:{os.getenv('FLASK_APP_PORT', '5000')}/add_user"
    headers = {'Content-Type': 'application/json'}
    data = {
        'id': id,
        'email': email,
        'phone': phone,
        'address': address,
        'detailed_address': detailed_address
    }

    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == 200:
        print('User added successfully:', response.json())
    else:
        print('Failed to add user:', response.text)

if __name__ == '__main__':
    id = input("Enter the User ID: ")
    email = input("Enter the email: ")
    phone = input("Enter the phone number: ")
    address = input("Enter the address: ")
    detailed_address = input("Enter the detailed address: ")
    add_user(id, email, phone, address, detailed_address)
