from flask import Blueprint, render_template, request, jsonify, current_app, Flask
from flask_socketio import emit, SocketIO
from werkzeug.security import generate_password_hash, check_password_hash
from .models import User, EventLog, CameraInfo, DetectionStatus
from . import db, socketio
from datetime import datetime, timedelta
import os
import requests
from flask_cors import CORS
import boto3
from sqlalchemy.orm import sessionmaker

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

    camera_infos = CameraInfo.query.filter_by(user_id=id).all()
    cameras = []
    for camera in camera_infos:
        detection_status = DetectionStatus.query.filter_by(user_id=id,camera_number=camera.camera_number).first()

        cameras.append({
            'camera_number': camera.camera_number,
            'rtsp_url': camera.rtsp_url,
            'fall_detection_on': detection_status.fall_detection_on if detection_status else False,
            'fire_detection_on': detection_status.fire_detection_on if detection_status else False,
            'movement_detection_on': detection_status.movement_detection_on if detection_status else False,
            'roi_detection_on': detection_status.roi_detection_on if detection_status else False,
            'roi': {
                'x1': detection_status.roi_x1 if detection_status else 0,
                'y1': detection_status.roi_y1 if detection_status else 0,
                'x2': detection_status.roi_x2 if detection_status else 1920,
                'y2': detection_status.roi_y2 if detection_status else 1080, 
            }
        })

    print(cameras)


    return jsonify({"message" : "Login successful",
                    "email" : user.email,
                    "cameras": cameras}), 200

@bp.route('/get_max_camera_number',methods = ['GET'])
def get_max_camera_number():
    max_camera_number = db.session.query(db.func.max(CameraInfo.camera_number)).scalar()
    return jsonify({"max_camera_number":max_camera_number})

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

    try:
        # 먼저 기존 형식 ('%Y-%m-%d %H:%M:%S') 시도
        timestamp = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S')
    except ValueError:
        try:
            # 실패하면 새로운 형식 ('%Y%m%d_%H%M%S') 시도
            timestamp = datetime.strptime(timestamp_str, '%Y%m%d_%H%M%S')
        except ValueError:
            return jsonify({"error": "Invalid timestamp format"}), 400
        

    formatted_timestamp = timestamp.strftime('%Y%m%d_%H%M%S')
    key_name = f"saved_clips/{eventname}_{formatted_timestamp}.mp4"

    # 최종 URL 생성
    event_url = f"https://{bucket_name}.s3.{region_name}.amazonaws.com/{key_name}"

    # user_id가 없는 경우 오류 처리
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    # EventLog에 user_id를 포함하여 생성
    new_event = EventLog(user_id=user_id, timestamp=timestamp, eventname=eventname, camera_number=camera_number,event_url = event_url)
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

@bp.route('/receive_event', methods=['POST'])
def receive_event():
    data = request.get_json()
    if data is None:
        return jsonify({"error": "No JSON received"}), 400

    # 클라이언트로부터 전송된 감지 상태 값들
    fall_detection = data.get('fall_detection', False)
    fire_detection = data.get('fire_detection', False)
    movement_detection = data.get('movement_detection', False)
    user_id = data.get('user_id', 'Unknown')
    camera_number = data.get('camera_number', 1)  # 카메라 번호 추가
    roi_detection = data.get('roi_detection', False)
    roi_values = data.get('roi_values', {})

    # 카메라 번호가 제공되지 않은 경우 오류 반환
    if camera_number is None:
        return jsonify({"error": "Camera number is required"}), 400

    # DetectionStatus 테이블에서 해당 사용자와 카메라 번호에 해당하는 레코드 조회
    detection_status = DetectionStatus.query.filter_by(user_id=user_id, camera_number=camera_number).first()
    if detection_status is None:
        return jsonify({"error": "DetectionStatus not found for the specified user_id and camera_number"}), 404

    # 감지 상태 값 업데이트
    detection_status.fall_detection_on = fall_detection
    detection_status.fire_detection_on = fire_detection
    detection_status.movement_detection_on = movement_detection
    detection_status.roi_detection_on = roi_detection
    detection_status.roi_x1 = roi_values.get('roi_x1', detection_status.roi_x1)
    detection_status.roi_y1 = roi_values.get('roi_y1', detection_status.roi_y1)
    detection_status.roi_x2 = roi_values.get('roi_x2', detection_status.roi_x2)
    detection_status.roi_y2 = roi_values.get('roi_y2', detection_status.roi_y2)

    # 데이터베이스에 변경 사항 커밋
    db.session.commit()

    # CameraInfo에서 해당 camera_number에 맞는 정보를 가져옴
    camera = CameraInfo.query.filter_by(user_id=user_id, camera_number=camera_number).first()

    # 모델 서버에 전송할 데이터 준비
    if camera:
        camera_info = {
            camera_number: {
                'rtsp_url': camera.rtsp_url,
                'fall_detection_on': detection_status.fall_detection_on,
                'fire_detection_on': detection_status.fire_detection_on,
                'movement_detection_on': detection_status.movement_detection_on,
                'roi_detection_on': detection_status.roi_detection_on,
                'roi_values': {
                    'roi_x1': detection_status.roi_x1,
                    'roi_y1': detection_status.roi_y1,
                    'roi_x2': detection_status.roi_x2,
                    'roi_y2': detection_status.roi_y2
                }
            }
        }
        
    payload = {
        'user_id': user_id,
        'camera_id': camera_number,
        'camera_info': camera_info
    }


    # 모델 서버 URL
    dl_model_ip = current_app.config['DL_MODEL_IP']
    dl_model_port = current_app.config['DL_MODEL_PORT']
    model_server_url = f"http://{dl_model_ip}:{dl_model_port}/event_update"

    # 모델 서버에 payload 전송
    try:
        response = requests.post(model_server_url, json=payload, timeout=10)
        if response.status_code == 200:
            print("모델 서버에 이벤트 전송 완료.")
        else:
            print("모델 서버 이벤트 전송 실패:", response.status_code)
    except requests.exceptions.RequestException as e:
        print("오류 발생:", e)

    return jsonify({"message": "Detection status updated and event transmitted successfully"}), 200

@bp.route('/add_camera', methods=['POST'])
def add_camera():
    data = request.get_json()
    if not data or 'user_id' not in data or 'rtsp_url' not in data:
        return jsonify({"error": "Missing user_id or rtsp_url"}), 400

    user_id = data['user_id']
    rtsp_url = data['rtsp_url']
    camera_number = data['camera_number']

    # 새로운 카메라와 감지 상태 추가
    new_camera = CameraInfo(user_id=user_id, camera_number=camera_number, rtsp_url=rtsp_url)
    db.session.add(new_camera)

    new_detection_status = DetectionStatus(
        user_id=user_id,
        camera_number=camera_number,
        fall_detection_on=False,
        fire_detection_on=False,
        movement_detection_on=False,
        roi_detection_on=False,
        roi_x1=0,
        roi_y1=0,
        roi_x2=1920,
        roi_y2=1080
    )
    db.session.add(new_detection_status)
    db.session.commit()

    # 모델 서버에 전송할 데이터 준비
    camera_info = {
        camera_number: {
            'rtsp_url': rtsp_url,
            'fall_detection_on': new_detection_status.fall_detection_on,
            'fire_detection_on': new_detection_status.fire_detection_on,
            'movement_detection_on': new_detection_status.movement_detection_on,
            'roi_detection_on': new_detection_status.roi_detection_on,
            'roi_values': {
                'roi_x1': new_detection_status.roi_x1,
                'roi_y1': new_detection_status.roi_y1,
                'roi_x2': new_detection_status.roi_x2,
                'roi_y2': new_detection_status.roi_y2
            }
        }
    }
    
    payload = {
        'user_id': user_id,
        'camera_id' : camera_number,
        'rtsp_url' : rtsp_url,
        'camera_info': camera_info
    }

    # 모델 서버 URL
    dl_model_ip = current_app.config['DL_MODEL_IP']
    dl_model_port = current_app.config['DL_MODEL_PORT']
    model_server_url = f"http://{dl_model_ip}:{dl_model_port}/add_camera"

    response = requests.post(model_server_url, json=payload, timeout=10)
    if response.status_code == 200:
        print("모델 서버에 이벤트 전송 완료.")
    else:
        print("모델 서버 이벤트 전송 실패:", response.status_code)

    return jsonify({"message": "Camera added", "camera_number": camera_number}), 200


# 카메라 삭제 엔드포인트
@bp.route('/delete_camera/<int:camera_number>', methods=['DELETE'])
def delete_camera(camera_number):
    camera = CameraInfo.query.filter_by(camera_number=camera_number).first()
    if not camera:
        return jsonify({"error": "Camera not found"}), 404

    user_id = camera.user_id

    # CameraInfo와 DetectionStatus에서 해당 카메라 정보 삭제
    db.session.delete(camera)
    detection_status = DetectionStatus.query.filter_by(user_id=user_id, camera_number=camera_number).first()
    if detection_status:
        db.session.delete(detection_status)
    db.session.commit()

    # 모델 서버에 전송할 데이터 준비
    payload = {
        'user_id': user_id,
        'camera_id': camera_number
    }
    dl_model_ip = current_app.config['DL_MODEL_IP']
    dl_model_port = current_app.config['DL_MODEL_PORT']
    model_server_url = f"http://{dl_model_ip}:{dl_model_port}/remove_camera"

    response = requests.post(model_server_url, json=payload, timeout=10)
    if response.status_code == 200:
        print("모델 서버에 이벤트 전송 완료.")
    else:
        print("모델 서버 이벤트 전송 실패:", response.status_code)

    return jsonify({"message": "Camera deleted and numbers reordered"}), 200
