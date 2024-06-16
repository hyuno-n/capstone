from flasgger import swag_from
from flask import Blueprint, render_template, request, jsonify, current_app
from flask_socketio import emit
from .models import ExampleModel
from . import db, socketio
from datetime import datetime

bp = Blueprint('main', __name__)

@bp.route('/')
def index():
    return render_template('index.html')

@socketio.on('connect')
def handle_connect():
    current_app.logger.info('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    current_app.logger.info('Client disconnected')

@socketio.on('push_message')
def handle_message(data):
    current_app.logger.info(f"Received message: {data}")
    emit('response', {'message': f"Server received: {data}"})

@bp.route('/set_message', methods=['POST'])
@swag_from('../docs/set_message.yml')
def set_message():
    data = request.json
    if not data:
        return jsonify({"error": "No data received"}), 400

    id = data.get('id')
    timestamp_str = data.get('timestamp', 'No timestamp')
    eventname = data.get('eventname')
    camera_number = data.get('camera_number')

    if not id:
        return jsonify({"error": "No ID"}), 400
    if not eventname:
        return jsonify({"error": "No event name"}), 400
    if not camera_number:
        return jsonify({"error": "No camera number"}), 400

    try:
        timestamp = datetime.fromisoformat(timestamp_str)
    except ValueError:
        return jsonify({"error": "Invalid timestamp format"}), 400

    new_entry = ExampleModel(id=id, timestamp=timestamp, eventname=eventname, camera_number=camera_number)
    db.session.add(new_entry)
    db.session.commit()

    current_app.logger.info(f"Received message via HTTP POST: {data}")
    socketio.emit('push_message', {
        'id': id,
        'timestamp': timestamp_str,
        'eventname': eventname,
        'camera_number': camera_number
    })
    return jsonify({"message": "Message received"}), 200
