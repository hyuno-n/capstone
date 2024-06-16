from flask import Blueprint, render_template, request, jsonify, current_app
from flask_socketio import emit
from .models import User, EventLog
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

@bp.route('/add_user', methods=['POST'])
def add_user():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data received"}), 400

    id = data.get('id')
    email = data.get('email')
    phone = data.get('phone')
    address = data.get('address')
    detailed_address = data.get('detailed_address')

    if not id or not email or not phone or not address or not detailed_address:
        return jsonify({"error": "Missing user information"}), 400

    new_user = User(id=id, email=email, phone=phone, address=address, detailed_address=detailed_address)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "User added"}), 200

@bp.route('/log_event', methods=['POST'])
def log_event():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data received"}), 400

    user_id = data.get('user_id')
    timestamp_str = data.get('timestamp')
    eventname = data.get('eventname')
    camera_number = data.get('camera_number')

    if not user_id or not eventname or not camera_number:
        return jsonify({"error": "Missing event information"}), 400

    try:
        timestamp = datetime.fromisoformat(timestamp_str)
    except ValueError:
        return jsonify({"error": "Invalid timestamp format"}), 400

    new_event = EventLog(user_id=user_id, timestamp=timestamp, eventname=eventname, camera_number=camera_number)
    db.session.add(new_event)
    db.session.commit()

    current_app.logger.info(f"Received event log via HTTP POST: {data}")
    socketio.emit('push_message', {
        'user_id': user_id,
        'timestamp': timestamp_str,
        'eventname': eventname,
        'camera_number': camera_number
    })
    return jsonify({"message": "Event logged"}), 200

@bp.route('/get_user_events/<user_id>', methods=['GET'])
def get_user_events(user_id):
    events = EventLog.query.filter_by(user_id=user_id).all()
    event_list = [
        {"id": event.id, "timestamp": event.timestamp.isoformat(), "eventname": event.eventname, "camera_number": event.camera_number}
        for event in events
    ]
    return jsonify(event_list), 200

@bp.route('/get_users', methods=['GET'])
def get_users():
    users = User.query.all()
    user_list = [
        {"id": user.id, "email": user.email, "phone": user.phone, "address": user.address, "detailed_address": user.detailed_address}
        for user in users
    ]
    return jsonify(user_list), 200
