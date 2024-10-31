from flask import Blueprint, render_template, request, jsonify, current_app, Flask
from flask_socketio import emit, SocketIO
from werkzeug.security import generate_password_hash, check_password_hash
from .models import User, EventLog, Camera
from . import db, socketio
from datetime import datetime
import os
import requests
from flask_cors import CORS
import boto3

bp = Blueprint('main', __name__)

def get_s3_client():
    return boto3.client(
        's3',
        aws_access_key_id = current_app.config['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key=current_app.config['AWS_SECRET_ACCESS_KEY'],
        region_name=current_app.config['AWS_REGION']
    )

def delete_file_from_s3(file_key):
    s3 = get_s3_client()
    bucket_name = current_app.config['S3_BUCKET_NAME']
    print(f"Attempting to delete {file_key} from bucket {bucket_name}")
    try:
        s3.delete_object(Bucket=bucket_name, Key=file_key)
        print(f"Deleted {file_key} from s3 bucket {bucket_name}")
    except Exception as e:
        print(f"Falied to delete {file_key} from s3: {e}")

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
    camera_number = data.get('camera_number')
    
    bucket_name = current_app.config['S3_BUCKET_NAME']
    region_name = current_app.config['AWS_REGION']

    formatted_timestamp = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S').strftime('%Y%m%d_%H%M%S')
    key_name = f"saved_clips/{eventname}_{formatted_timestamp}.mp4"

    # 최종 URL 생성
    event_url = f"https://{bucket_name}.s3.{region_name}.amazonaws.com/{key_name}"

    # user_id가 없는 경우 오류 처리
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    # EventLog에 user_id를 포함하여 생성
    new_event = EventLog(user_id=user_id, timestamp=timestamp_str, eventname=eventname, camera_number=camera_number,event_url = event_url)
    db.session.add(new_event)
    db.session.commit()

    # SocketIO를 통해 이벤트 푸시
    socketio.emit('push_message', {
        'user_id': user_id,
        'timestamp': timestamp_str,
        'eventname': eventname,
        'camera_number':camera_number,
        'event_url':event_url
    })

    return jsonify({"message": "Event logged"}), 200

# get_user_events 엔드포인트
@bp.route('/get_user_events/<user_id>', methods=['GET'])
def get_user_events(user_id):
    events = EventLog.query.filter_by(user_id=user_id).all()
    event_list = [
        {"user_id": event.user_id, "timestamp": event.timestamp.isoformat(), "eventname": event.eventname, "camera_number": event.camera_number, "event_url": event.event_url}
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
    events = EventLog.query.filter_by(user_id=user_id).all()

    for event in events:
        if event.event_url:
            file_key = event.event_url.split('/')[-1]
            delete_file_from_s3(file_key)

    EventLog.query.filter_by(user_id=user_id).delete()
    db.session.commit()

    return jsonify({"message": "User events deleted"}), 200

@bp.route('/delete_log', methods=['POST'])
def delete_log():
    data = request.get_json()
    if not data or 'user_id' not in data or 'timestamp' not in data:
        return jsonify({"error": "Missing user_id or timestamp"}), 400

    user_id = data['user_id']
    timestamp_str = data['timestamp']
    try:
        timestamp = datetime.fromisoformat(timestamp_str)
    except ValueError:
        return jsonify({"error": "Invalid timestamp format"}), 400

    event = EventLog.query.filter_by(user_id=user_id, timestamp=timestamp).first()

    if event:
        # S3 파일 삭제
        if event.event_url:
            file_key = event.event_url.split('/')[-1]
            delete_file_from_s3(file_key)

        # 데이터베이스에서 로그 삭제
        db.session.delete(event)
        db.session.commit()
        return jsonify({"message": "Log deleted"}), 200
    else:
        return jsonify({"error": "Log not found"}), 404
    
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

    roi_values = data.get('roi_values',{})
    dl_model_ip = current_app.config['DL_MODEL_IP']
    dl_model_port = current_app.config['DL_MODEL_PORT']
    model_server_url = f"http://{dl_model_ip}:{dl_model_port}/event_update"
    payload = {
        'fall_detection_on': fall_detection,
        'fire_detection_on': fire_detection,
        'movement_detection_on': movement_detection,
        'user_id': user_id,
        'roi_values' : roi_values,
    }
    
    try:
        response = requests.post(model_server_url, json=payload, timeout=10)
        if response.status_code == 200:
            print("모델에 신호 전송 완료.")
        else:
            print("모델 신호 전송 실패:", response.status_code)
        
    except requests.exceptions.RequestException as e:
        print("오류 발생:", e)

    return jsonify({"message": "Event transmitted successfully"}), 200

# 카메라 추가 엔드포인트
@bp.route('/add_camera', methods=['POST'])
def add_camera():
    data = request.get_json()
    if not data or 'user_id' not in data or 'rtsp_url' not in data:
        return jsonify({"error": "Missing user_id or rtsp_url"}), 400

    user_id = data['user_id']
    rtsp_url = data['rtsp_url']

    # 카메라 번호 할당
    last_camera = Camera.query.filter_by(user_id=user_id).order_by(Camera.camera_number.desc()).first()
    camera_number = 1 if not last_camera else last_camera.camera_number + 1

    new_camera = Camera(user_id=user_id, camera_number=camera_number, rtsp_url=rtsp_url)
    db.session.add(new_camera)
    db.session.commit()

    dl_model_ip = current_app.config['DL_MODEL_IP']
    dl_model_port = current_app.config['DL_MODEL_PORT']
    model_server_url = f"http://{dl_model_ip}:{dl_model_port}/add_camera_info"  # DL 모델 서버의 엔드포인트

    payload = {
        'user_id' : user_id,
        'camera_number': camera_number,
        'rtsp_url' : rtsp_url
    }
    try:
        response = requests.post(model_server_url, json=payload, timeout=10)
        if response.status_code == 200:
            print("DL 모델 서버에 카메라 정보 전송 완료.")
        else:
            print("DL 모델 서버 전송 실패:", response.status_code)
    except requests.exceptions.RequestException as e:
        print("오류 발생:", e)

    return jsonify({"message": "Camera added", "camera_number": camera_number}), 200

# 카메라 삭제 엔드포인트
@bp.route('/delete_camera/<int:camera_number>', methods=['DELETE'])
def delete_camera(camera_number):
    camera = Camera.query.filter_by(camera_number=camera_number).first()
    if not camera:
        return jsonify({"error": "Camera not found"}), 404

    user_id = camera.user_id

    # 삭제
    db.session.delete(camera)
    db.session.commit()

    dl_model_ip = current_app.config['DL_MODEL_IP']
    dl_model_port = current_app.config['DL_MODEL_PORT']
    model_server_url = f"http://{dl_model_ip}:{dl_model_port}/remove_camera_info"  # DL 모델 서버의 엔드포인트

    payload = {
        'user_id': user_id,
        'camera_number': camera_number
    }

    try:
        response = requests.post(model_server_url, json=payload, timeout=10)
        if response.status_code == 200:
            print("DL 모델 서버에 카메라 삭제 요청 전송 완료.")
        else:
            print("DL 모델 서버 삭제 요청 실패:", response.status_code)
    except requests.exceptions.RequestException as e:
        print("오류 발생:", e)

    # 카메라 번호 재정렬
    cameras = Camera.query.filter_by(user_id=user_id).order_by(Camera.camera_number).all()
    for i, cam in enumerate(cameras):
        cam.camera_number = i + 1
    db.session.commit()

    return jsonify({"message": "Camera deleted and numbers reordered"}), 200
