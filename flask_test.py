from flask import Flask, render_template, request, jsonify
from flask_socketio import SocketIO, emit
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='eventlet')

# 직접 설정된 IP와 포트
FLASK_IP = '0.0.0.0'
FLASK_PORT = 5000

@app.route('/')
def index():
    return render_template('index.html')

@socketio.on('connect')
def handle_connect():
    print('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

@socketio.on('push_message')
def handle_message(data):
    print(f"Received message: {data}")
    emit('response', {'message': f"Server received: {data}"})

@app.route('/set_message', methods=['POST'])
def set_message():
    data = request.json
    if not data:
        return jsonify({"error": "No data received"}), 400
    
    timestamp = data.get('timestamp', 'No timestamp')
    action_name = data.get('action_name', 'No action name')
    camera_number = data.get('camera_number', 'No camera number')

    print(f"Received message via HTTP POST: {data}")
    socketio.emit('push_message', {
        'timestamp': timestamp,
        'action_name': action_name,
        'camera_number': camera_number
    })
    return jsonify({"message": "Message received"}), 200

if __name__ == '__main__':
    print(f"Starting server on {FLASK_IP}:{FLASK_PORT}")
    socketio.run(app, host=FLASK_IP, port=FLASK_PORT)
