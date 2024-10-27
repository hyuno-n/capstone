# test_model.py
import socketio

# Flask 서버의 Socket.IO 클라이언트
sio = socketio.Client()

@sio.event
def connect():
    print("Connected to Flask server via Socket.IO")

@sio.event
def disconnect():
    print("Disconnected from Flask server")

@sio.on('event_update', namespace='/model')
def on_event_update(data):
    event_type = data.get('event_type')
    status = data.get('status')
    timestamp = data.get('timestamp')
    print(f"Model server received event: {event_type}, Status: {status}, Timestamp: {timestamp}")

if __name__ == '__main__':
    # Flask 서버와 지속적인 연결 유지
    sio.connect('http://127.0.0.1:5000', namespaces=['/model'])
    sio.wait()  # 계속 대기하여 이벤트 수신
