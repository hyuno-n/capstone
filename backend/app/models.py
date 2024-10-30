from . import db
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.String(50), primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20), nullable=False)
    address = db.Column(db.String(255), nullable=False)
    detailed_address = db.Column(db.String(255), nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)  # 비밀번호 해시 필드 추가
    event_logs = db.relationship('EventLog', backref='user', lazy=True)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class EventLog(db.Model):
    __tablename__ = 'event_logs'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(50), db.ForeignKey('users.id'), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    eventname = db.Column(db.String(50), nullable=False)
    camera_number = db.Column(db.Integer, nullable=False)
    event_url = db.Column(db.String(255), nullable=True)

class Camera(db.Model):
    __tablename__ = 'cameras'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(50), db.ForeignKey('users.id'), nullable=False)
    camera_number = db.Column(db.Integer, nullable=False)
    rtsp_url = db.Column(db.String(255), nullable=False)

    user = db.relationship('User', backref='cameras', lazy=True)
