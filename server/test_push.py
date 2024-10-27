# push_flask.py
import requests
import datetime

def push_to_flask():
    flask_ip = "http://127.0.0.1:5000"  # Flask 서버 IP와 포트
    url = f"{flask_ip}/receive_event"
    data = {
        "event_type": "fire_detection",
        "status": "activated",
        "timestamp": datetime.datetime.now().isoformat()
    }

    try:
        response = requests.post(url, json=data)
        if response.status_code == 200:
            print("Event pushed to Flask server successfully:", response.json())
        else:
            print("Failed to push event to Flask server:", response.status_code)
    except requests.exceptions.RequestException as e:
        print("Error pushing event to Flask server:", e)

if __name__ == '__main__':
    push_to_flask()
