from flask import Blueprint, render_template, request, jsonify, current_app
from flask_socketio import emit
from werkzeug.security import generate_password_hash, check_password_hash
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
    password = data.get('password')

    if not id or not email or not phone or not address or not detailed_address or not password:
        return jsonify({"error": "Missing user information"}), 400

    new_user = User(id=id, email=email, phone=phone, address=address, detailed_address=detailed_address)
    new_user.set_password(password)  # 비밀번호 해시 설정
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "User added"}), 200

@bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data received"}), 400

    id = data.get('id')
    password = data.get('password')

    user = User.query.filter_by(id=id).first()

    if user is None or not user.check_password(password):
        return jsonify({"error": "Invalid credentials"}), 401

    return jsonify({"message": "Login successful"}), 200

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
        {"user_id": event.user_id, "timestamp": event.timestamp.isoformat(), "eventname": event.eventname, "camera_number": event.camera_number}
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

@bp.route('/delete_user_events', methods=['POST'])
def delete_user_events():
    data = request.get_json()
    if not data or 'user_id' not in data:
        return jsonify({"error": "Missing user_id"}), 400

    user_id = data['user_id']
    EventLog.query.filter_by(user_id=user_id).delete()
    db.session.commit()

    return jsonify({"message": "User events deleted"}), 200

@bp.route('/logs', methods=['GET'])
def get_logs():
    logs = EventLog.query.all()
    log_list = [
        {
            "user_id": log.user_id,
            "timestamp": log.timestamp.isoformat(),
            "eventname": log.eventname,
            "camera_number": log.camera_number
        }
        for log in logs
    ]
    return jsonify(log_list), 200
