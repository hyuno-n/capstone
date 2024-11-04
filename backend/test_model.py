from flask import Flask, request, jsonify
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'

@app.route('/event_update', methods=['POST'])
def event_update():
    data = request.get_json()
    
    print(data['camera_info'])
    print("")
    print("")
    return jsonify({"message": "Event received by model server"}), 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=False)