from flask import Flask, request, jsonify
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'

@app.route('/event_update', methods=['POST'])
def event_update():
    data = request.get_json()
    
    fall_detection = data.get('fall_detection_on', False)
    movement_detection = data.get('movement_detection_on', False)
    user_id = data.get('user_id', 'Unknown')
    
    # 이벤트 수신 시 콘솔에 출력
    print(f"Received event - Fall Detection: {fall_detection}, Movement Detection: {movement_detection}")
    
    return jsonify({"message": "Event received by model server"}), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=False)
