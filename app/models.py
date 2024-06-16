from . import db
from datetime import datetime

class ExampleModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    eventname = db.Column(db.String(50), nullable=False)
    camera_number = db.Column(db.Integer, nullable=False)

    
