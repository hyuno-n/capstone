import cv2
from datetime import datetime

def detect_motion(video_source, min_contour_area=20000):
    cap = cv2.VideoCapture(video_source)
    bg_subtractor = cv2.createBackgroundSubtractorMOG2()

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Failed to grab frame")
            break
        
        fg_mask = bg_subtractor.apply(frame)
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, None, iterations=2)
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, None, iterations=2)
        frame_ = cv2.resize(fg_mask, (640, 480))
        cv2.imshow('Mask', frame_)
        contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        motion_detected = False
        for contour in contours:
            area = cv2.contourArea(contour)
            if area > min_contour_area:
                x, y, w, h = cv2.boundingRect(contour)
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
                motion_detected = True
        
        frame = cv2.resize(frame, (640, 480))
        cv2.imshow('Motion Detection', frame)
        
        if motion_detected:  # 움직임 감지 시 신호 전송
            detected_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            print('detected_time:',detected_time)
        if cv2.waitKey(1) == 27:
            break

    cap.release()
    cv2.destroyAllWindows()
    return False

if __name__ == "__main__":
    # RTSP 스트림 URL
    rtsp_url = "rtsp://jaehoon010:asdang22@123.212.88.101:554/stream1"
    test_vid = "test.mp4"
    motion_detected = detect_motion(test_vid)