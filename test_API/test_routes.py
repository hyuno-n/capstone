import pytest
from app import create_app, db
from app.models import ExampleModel
from datetime import datetime

@pytest.fixture
def client():
    app = create_app()
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'

    with app.test_client() as client:
        with app.app_context():
            db.create_all()
        yield client

def test_set_message_success(client):
    response = client.post('/set_message', json={
        'id': 1,
        'timestamp': datetime.now().isoformat(),
        'eventname': 'Test Event',
        'camera_number': 1
    })
    assert response.status_code == 200
    assert response.json['message'] == 'Message received'

def test_set_message_invalid_data(client):
    response = client.post('/set_message', json={
        'id': 1,
        'timestamp': 'invalid_timestamp',
        'eventname': 'Test Event',
        'camera_number': 1
    })
    assert response.status_code == 400
    assert response.json['error'] == 'Invalid timestamp format'

def test_set_message_missing_fields(client):
    response = client.post('/set_message', json={
        'timestamp': datetime.now().isoformat(),
        # 'id' is missing
        'eventname': 'Test Event',
        'camera_number': 1
    })
    assert response.status_code == 400
    assert 'error' in response.json

def test_set_message_database(client):
    timestamp = datetime.now().isoformat()
    client.post('/set_message', json={
        'id': 1,
        'timestamp': timestamp,
        'eventname': 'Test Event',
        'camera_number': 1
    })
    
    entry = ExampleModel.query.filter_by(id=1).first()
    assert entry is not None
    assert entry.id == 1
    assert entry.eventname == 'Test Event'
    assert entry.timestamp.isoformat() == timestamp
    assert entry.camera_number == 1
