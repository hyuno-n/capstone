from flask import Flask, render_template, request, jsonify
from flask_socketio import SocketIO, emit

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
    message = data['message']
    print(f"Received message: {message}")
    emit('response', {'message': f"Server received: {message}"})

@app.route('/set_message', methods=['POST'])
def set_message():
    message = request.json.get('message')
    print(f"Received message via HTTP POST: {message}")
    socketio.emit('push_message', {'message': f"Server received via HTTP POST: {message}"})
    return jsonify({"message": "Message received"}), 200

if __name__ == '__main__':
    print(f"Starting server on {FLASK_IP}:{FLASK_PORT}")
    socketio.run(app, host=FLASK_IP, port=FLASK_PORT)
