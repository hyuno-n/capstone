import cv2
import numpy as np
import tensorflow as tf
from tensorflow import keras
import joblib
import threading
from queue import Queue

# Constants
BODY_PARTS = {"Head": 0, "Neck": 1, "RShoulder": 2, "RElbow": 3, "RWrist": 4,
              "LShoulder": 5, "LElbow": 6, "LWrist": 7, "RHip": 8, "RKnee": 9,
              "RAnkle": 10, "LHip": 11, "LKnee": 12, "LAnkle": 13, "Chest": 14,
              "Background": 15}
POSE_PAIRS = [["Head", "Neck"], ["Neck", "RShoulder"], ["RShoulder", "RElbow"],
              ["RElbow", "RWrist"], ["Neck", "LShoulder"], ["LShoulder", "LElbow"],
              ["LElbow", "LWrist"], ["Neck", "Chest"], ["Chest", "RHip"], ["RHip", "RKnee"],
              ["RKnee", "RAnkle"], ["Chest", "LHip"], ["LHip", "LKnee"], ["LKnee", "LAnkle"]]
PROTO_FILE = "pose_deploy_linevec_faster_4_stages.prototxt"
WEIGHTS_FILE = "pose_iter_160000.caffemodel"
MAX_IMAGE_WIDTH = 320
MAX_IMAGE_HEIGHT = 180
MAX_IMAGE_SIZE = MAX_IMAGE_WIDTH * MAX_IMAGE_HEIGHT
MAX_SEQ_LENGTH = 20

# Load pre-trained model
c3d_model = tf.keras.models.load_model('./input_data/epoch10_temp_weights_c3d.h5')
sequence_model = keras.models.load_model('./input_data/seq_model.h5')
scaler = joblib.load('./input_data/Standard_Scaler.pkl')
svm_model = joblib.load('./input_data/SVM_Model.pkl')

# Load OpenPose network
net = cv2.dnn.readNetFromCaffe(PROTO_FILE, WEIGHTS_FILE)

# Queue for frames
frame_queue = Queue(maxsize=MAX_SEQ_LENGTH)

def predict_m1(frame_clip):
    frame_clip = np.array(frame_clip).astype(np.float32)
    frame_clip = np.expand_dims(frame_clip, axis=0)
    frame_clip[..., 0] -= 99.9
    frame_clip[..., 1] -= 92.1
    frame_clip[..., 2] -= 82.6
    frame_clip[..., 0] /= 65.8
    frame_clip[..., 1] /= 62.3
    frame_clip[..., 2] /= 60.3
    frame_clip = frame_clip[:, :, 8:120, 30:142, :]
    frame_clip = np.transpose(frame_clip, (0, 2, 3, 1, 4))

    predictions = c3d_model.predict(frame_clip)
    return np.argmax(predictions[0])


# M2 모델 초기화
def build_feature_extractor():
    feature_extractor = keras.applications.ResNet50(
        weights="imagenet",
        include_top=False,
        pooling="avg",
        input_shape=(MAX_IMAGE_HEIGHT, MAX_IMAGE_WIDTH, 3),
    )
    preprocess_input = keras.applications.resnet.preprocess_input

    inputs = keras.Input((MAX_IMAGE_HEIGHT, MAX_IMAGE_WIDTH, 3))
    preprocessed = preprocess_input(inputs)
    outputs = feature_extractor(preprocessed)
    return keras.Model(inputs, outputs, name="feature_extractor")


def prepare_single_frame(frame, feature_extractor):
    if not isinstance(frame, np.ndarray):
        raise ValueError("Input frame is not a valid numpy array")
    frame = cv2.resize(frame, (MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT))
    frame = np.expand_dims(frame, axis=0)
    frame = feature_extractor.predict(frame)
    return frame


def predict_m2(frames, sequence_model):
    frame_features = np.array([prepare_single_frame(frame, feature_extractor) for frame in frames])
    frame_features = np.squeeze(frame_features, axis=1)
    frame_features = np.expand_dims(frame_features, axis=0)  # (1, sequence_length, feature_dim) 모양으로 확장
    frame_mask = np.ones((frame_features.shape[0], MAX_SEQ_LENGTH))

    probabilities = sequence_model.predict([frame_features, frame_mask])[0]
    return np.argmax(probabilities)


def predict_m3(m1_output, m2_output):
    combined_input = np.array([[m1_output, m2_output]])
    combined_input = scaler.transform(combined_input)
    prediction = svm_model.predict(combined_input)
    return prediction[0]


# 스켈레톤 추출 및 비트맵 생성
def make_bitmap(a, b):
    targetList = [0] * MAX_IMAGE_SIZE
    for i in range(len(a)):
        setBoldPoint(targetList, a[i], b[i])
    targetArray = np.fromiter(targetList, dtype=np.uint8)
    targetArray = np.reshape(targetArray, (MAX_IMAGE_HEIGHT, MAX_IMAGE_WIDTH))
    return np.dstack([targetArray] * 3)  # 3채널로 확장하여 numpy 배열 반환


def setBoldPoint(targetList, x, y):
    if x < 0 or y < 0 or x >= MAX_IMAGE_WIDTH or y >= MAX_IMAGE_HEIGHT:
        return
    if y - 1 >= 0 and x - 1 >= 0:
        targetList[MAX_IMAGE_WIDTH * (y - 1) + (x - 1)] = 255
    if y - 1 >= 0:
        targetList[MAX_IMAGE_WIDTH * (y - 1) + (x)] = 255
    if y - 1 >= 0 and x + 1 < MAX_IMAGE_WIDTH:
        targetList[MAX_IMAGE_WIDTH * (y - 1) + (x + 1)] = 255
    if x - 1 >= 0:
        targetList[MAX_IMAGE_WIDTH * (y) + (x - 1)] = 255
    targetList[MAX_IMAGE_WIDTH * (y) + (x)] = 255
    if x + 1 < MAX_IMAGE_WIDTH:
        targetList[MAX_IMAGE_WIDTH * (y) + (x + 1)] = 255
    if y + 1 < MAX_IMAGE_HEIGHT and x - 1 >= 0:
        targetList[MAX_IMAGE_WIDTH * (y + 1) + (x - 1)] = 255
    if y + 1 < MAX_IMAGE_HEIGHT:
        targetList[MAX_IMAGE_WIDTH * (y + 1) + (x)] = 255
    if y + 1 < MAX_IMAGE_HEIGHT and x + 1 < MAX_IMAGE_WIDTH:
        targetList[MAX_IMAGE_WIDTH * (y + 1) + (x + 1)] = 255
    return targetList


def num_to_category(num):
    action_dict = {
        0: "아동학대-방임",
        1: "아동학대-신체학대",
        2: "주거침입-문",
        3: "폭행/강도-위협물체",
        4: "폭행/강도-위협행동",
        5: "절도-문앞",
        6: "절도-주차장"
    }
    return action_dict.get(num, "Unknown")


def start_camera_stream(ip_camera_url):
    cap = cv2.VideoCapture(ip_camera_url)
    if not cap.isOpened():
        print("Cannot open IP camera")
        exit()
    return cap


def extract_skeleton_from_frame(frame):
    # This function extracts the skeleton keypoints from a frame using OpenPose.
    inWidth = 368
    inHeight = 368
    inpBlob = cv2.dnn.blobFromImage(frame, 1.0 / 255, (inWidth, inHeight),
                                    (0, 0, 0), swapRB=False, crop=False)
    net.setInput(inpBlob)
    out = net.forward()

    H = out.shape[2]
    W = out.shape[3]

    points_x = []
    points_y = []
    for i in range(len(BODY_PARTS) - 1):
        heatMap = out[0, i, :, :]
        _, conf, _, point = cv2.minMaxLoc(heatMap)
        x = (frame.shape[1] * point[0]) / W
        y = (frame.shape[0] * point[1]) / H
        if conf > 0.1:
            points_x.append(int(x))
            points_y.append(int(y))
        else:
            points_x.append(-1)
            points_y.append(-1)
    return points_x, points_y

def process_frames():
    frames = []
    while True:
        frame = frame_queue.get()
        if frame is None:
            break
        frames.append(frame)
        if len(frames) == 16:
            m1_output = predict_m1(frames)
            frames.pop(0)

        keypoints_x, keypoints_y = extract_skeleton_from_frame(frame)
        if keypoints_x and keypoints_y:
            bitmap_frame = make_bitmap(keypoints_x, keypoints_y)
            frames.append(bitmap_frame)
            if len(frames) == MAX_SEQ_LENGTH:
                m2_output = predict_m2(frames, sequence_model)
                frames = []

        if 'm1_output' in locals() and 'm2_output' in locals():
            final_prediction = predict_m3(m1_output, m2_output)
            behavior = num_to_category(final_prediction)
            print(f"Predicted behavior: {behavior}")
            del m1_output, m2_output

def main():
    physical_devices = tf.config.list_physical_devices('GPU')
    if physical_devices:
        try:
            tf.config.experimental.set_memory_growth(physical_devices[0], True)
        except:
            pass

    ip_camera_url = 'test2.mp4'
    cap = start_camera_stream(ip_camera_url)

    # Start frame processing thread
    frame_processor = threading.Thread(target=process_frames)
    frame_processor.start()

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Failed to grab frame")
            break

        if frame_queue.full():
            frame_queue.get()

        frame_queue.put(frame)

        display_frame = cv2.resize(frame, (640, 480))
        cv2.imshow('IP Camera Stream', display_frame)
        if cv2.waitKey(1) == 27:
            break

    frame_queue.put(None)
    frame_processor.join()
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()