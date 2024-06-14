from flask import Flask, request, jsonify

app = Flask(__name__)

# 메시지를 저장할 변수
current_message = "Hello, World!"

@app.route('/get_message', methods=['GET'])
def get_message():
    return current_message

@app.route('/set_message', methods=['POST'])
def set_message():
    global current_message
    if 'message' in request.json:
        current_message = request.json['message']
        return jsonify({"status": "success", "message": current_message}), 200
    else:
        return jsonify({"status": "error", "message": "No message provided"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
