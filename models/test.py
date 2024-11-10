from IPython import display
display.clear_output()

import ultralytics
ultralytics.checks()

import torch
torch.cuda.is_available()

import tensorflow as tf

if tf.test.is_gpu_available():
    print("GPU 사용 가능")
    # GPU 장치 목록 확인
    print("사용 가능한 GPU 장치 목록:")
    for device in tf.config.experimental.list_physical_devices('GPU'):
        print(device)
else:
    print("GPU 사용 불가능")
