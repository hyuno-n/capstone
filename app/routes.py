from flask import render_template, request, jsonify, current_app
from flask_socketio import emit
from .models import ExampleModel
from . import db, socketio

@current_app.route('/')
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

@current_app.route('/set_message', methods=['POST'])
def set_message():
    data = request.json
    if not data:
        return jsonify({"error": "No data received"}), 400
    
    timestamp = data.get('timestamp', 'No timestamp')
    action_name = data.get('action_name', 'No action name')
    camera_number = data.get('camera_number', 'No camera number')

    new_entry = ExampleModel(name=action_name, timestamp=timestamp)
    db.session.add(new_entry)
    db.session.commit()

    print(f"Received message via HTTP POST: {data}")
    socketio.emit('push_message', {
        'timestamp': timestamp,
        'action_name': action_name,
        'camera_number': camera_number
    })
    return jsonify({"message": "Message received"}), 200
