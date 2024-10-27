from flask import Blueprint, render_template, request, jsonify, current_app, Flask
from flask_socketio import emit, SocketIO
from werkzeug.security import generate_password_hash, check_password_hash
from .models import User, EventLog
from . import db, socketio
from datetime import datetime
from dotenv import load_dotenv
import os
import requests
from flask_cors import CORS

load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv("SECRET_KEY", "your_secret_key")
socketio = SocketIO(app, cors_allowed_origins="*")

DL_MODEL_IP = os.getenv("DL_MODEL_IP")
DL_MODEL_PORT = os.getenv("DL_MODEL_PORT")

bp = Blueprint('main', __name__)
CORS(app)

app.register_blueprint(bp, url_prefix='/')  # Blueprint 등록

# 홈 엔드포인트
@bp.route('/')
def index():
    return render_template('index.html')

# add_user 엔드포인트
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
    new_user.set_password(password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "User added"}), 200

# login 엔드포인트
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

# log_event 엔드포인트
@bp.route('/log_event', methods=['POST'])
def log_event():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data received"}), 400

    user_id = data.get('user_id')
    timestamp_str = data.get('timestamp')
    eventname = data.get('eventname')
    camera_number = data.get('camera_number')  # camera_number를 포함시키는 경우

    # user_id가 없는 경우 오류 처리
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    try:
        timestamp = datetime.fromisoformat(timestamp_str)
    except ValueError:
        return jsonify({"error": "Invalid timestamp format"}), 400

    # EventLog에 user_id를 포함하여 생성
    new_event = EventLog(user_id=user_id, timestamp=timestamp, eventname=eventname, camera_number=camera_number)
    db.session.add(new_event)
    db.session.commit()

    # SocketIO를 통해 이벤트 푸시
    socketio.emit('push_message', {
        'user_id': user_id,
        'timestamp': timestamp_str,
        'eventname': eventname,
    })
    return jsonify({"message": "Event logged"}), 200

# get_user_events 엔드포인트
@bp.route('/get_user_events/<user_id>', methods=['GET'])
def get_user_events(user_id):
    events = EventLog.query.filter_by(user_id=user_id).all()
    event_list = [
        {"user_id": event.user_id, "timestamp": event.timestamp.isoformat(), "eventname": event.eventname, "camera_number": event.camera_number}
        for event in events
    ]
    return jsonify(event_list), 200

# get_users 엔드포인트
@bp.route('/get_users', methods=['GET'])
def get_users():
    users = User.query.all()
    user_list = [
        {"id": user.id, "email": user.email, "phone": user.phone, "address": user.address, "detailed_address": user.detailed_address}
        for user in users
    ]
    return jsonify(user_list), 200

# delete_user_events 엔드포인트
@bp.route('/delete_user_events', methods=['POST'])
def delete_user_events():
    data = request.get_json()
    if not data or 'user_id' not in data:
        return jsonify({"error": "Missing user_id"}), 400

    user_id = data['user_id']
    EventLog.query.filter_by(user_id=user_id).delete()
    db.session.commit()

    return jsonify({"message": "User events deleted"}), 200

# logs 엔드포인트
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

# 모델 서버로 이벤트 전송하는 receive_event 엔드포인트
@bp.route('/receive_event', methods=['POST'])
def receive_event():
    data = request.get_json()
    
    # 클라이언트로부터 전송된 감지 상태 값들
    fall_detection = data.get('fall_detection', False)
    fire_detection = data.get('fire_detection', False)
    movement_detection = data.get('movement_detection', False)
    user_id = data.get('user_id', 'Unknown')

    model_server_url = f"http://{DL_MODEL_IP}:{DL_MODEL_PORT}/event_update"
    payload = {
        'fall_detection_on': fall_detection,
        'fire_detection_on': fire_detection,
        'movement_detection_on': movement_detection,
        'user_id': user_id
    }
    
    try:
        response = requests.post(model_server_url, json=payload, timeout=10)
        if response.status_code == 200:
            print("서버에 신호 전송 완료.")
        else:
            print("서버 신호 전송 실패:", response.status_code)
        
    except requests.exceptions.RequestException as e:
        print("오류 발생:", e)

    return jsonify({"message": "Event transmitted successfully"}), 200

if __name__ == '__main__':
    socketio.run(app, host=os.getenv("FLASK_APP_IP", "0.0.0.0"), port=int(os.getenv("FLASK_APP_PORT", 5000)))
