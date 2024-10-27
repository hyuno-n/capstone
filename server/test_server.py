# test_server.py
from flask import Flask, request, jsonify
from flask_socketio import SocketIO, emit
from flask_cors import CORS
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv("SECRET_KEY", "your_secret_key")
CORS(app)  # 모든 출처에서의 요청을 허용
socketio = SocketIO(app, cors_allowed_origins="*")

@app.route('/receive_event', methods=['POST'])
def receive_event():
    data = request.get_json()
    event_type = data.get('event_type')
    status = data.get('status')
    timestamp = data.get('timestamp')

    print(f"Received HTTP event: {event_type}, Status: {status}, Timestamp: {timestamp}")
    
    # 모델 서버로 Socket.IO 이벤트 전송
    socketio.emit('event_update', {
        'event_type': event_type,
        'status': status,
        'timestamp': timestamp
    }, namespace='/model')
    print("Event emitted to model server via Socket.IO")

    return jsonify({"message": "Event transmitted successfully"}), 200

if __name__ == '__main__':
    socketio.run(app, host="0.0.0.0", port=5000, debug=True)
