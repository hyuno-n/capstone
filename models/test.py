import tensorflow as tf

print("Num GPUs Available: ", len(tf.config.list_physical_devices('GPU')))
print("TensorFlow version: ", tf.__version__)
print("CUDA version: ", tf.sysconfig.get_build_info())
print("cuDNN version: ", tf.sysconfig.get_build_info()['cudnn_version'])
