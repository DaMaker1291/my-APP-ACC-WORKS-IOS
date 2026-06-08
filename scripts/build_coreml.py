import numpy as np
import tensorflow as tf
from coremltools.models.neural_network import NeuralNetworkBuilder
from coremltools.models import datatypes, MLModel
import os, sys

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
COREML_PATH = os.path.join(PROJECT_ROOT, "ios/Momentum/MLModels/MomentumPredictor.mlmodel")
TFLITE_PATH = os.path.join(PROJECT_ROOT, "android/app/src/main/assets/momentum_predictor.tflite")
N_FEATURES = 15

np.random.seed(42)
tf.random.set_seed(42)

def gen_data(n=20000):
    X = np.column_stack([
        np.random.randint(0, 7, n).astype(np.float32),
        np.random.randint(6, 23, n).astype(np.float32),
        np.clip(np.random.normal(7.0, 1.2, n), 3.0, 12.0).astype(np.float32),
        np.clip(np.random.normal(55, 18, n), 20, 90).astype(np.float32),
        np.clip(np.random.normal(7000, 3000, n), 0, 30000).astype(np.float32),
        np.clip(np.random.normal(72, 10, n), 45, 150).astype(np.float32),
        np.clip(np.random.normal(42, 18, n), 10, 120).astype(np.float32),
        np.clip(np.random.normal(300, 120, n), 30, 720).astype(np.float32),
        np.random.randint(0, 4, n).astype(np.float32),
        np.random.randint(0, 5, n).astype(np.float32),
        np.random.randint(0, 4, n).astype(np.float32),
        np.clip(np.random.normal(60, 18, n), 0, 100).astype(np.float32),
        np.clip(np.random.normal(7.0, 0.5, n), 3.0, 12.0).astype(np.float32),
        np.clip(np.random.normal(7000, 1000, n), 0, 30000).astype(np.float32),
        np.clip(np.random.normal(60, 12, n), 0, 100).astype(np.float32),
    ])
    s = X.copy()
    sleep_ok = (s[:, 2] >= 7.0).astype(float)
    q_ok = (s[:, 3] >= 60).astype(float)
    hrv_ok = (s[:, 6] > 40).astype(float)
    hi_stress = (s[:, 10] >= 2).astype(float)
    hi_screen = (s[:, 7] > 480).astype(float)
    hi_cal = (s[:, 8] >= 2).astype(float)
    vhi_screen = (s[:, 7] > 600).astype(float)
    lo_sleep = (s[:, 2] < 6.0).astype(float)
    good_en = (s[:, 9] >= 3).astype(float)
    energy = np.clip(np.round(2.0 + 0.6*sleep_ok + 0.4*q_ok + 0.3*hrv_ok - 0.5*hi_stress - 0.2*hi_screen + 0.2*good_en + np.random.normal(0,0.3,n)), 0, 4)
    focus = np.clip(np.round(55.0 + 10*sleep_ok + 5*good_en - 15*vhi_screen - 10*hi_cal + 5*q_ok + np.random.normal(0,8,n)), 0, 100)
    stress = np.clip(np.round(1.0 + 0.8*hi_cal + 0.4*lo_sleep + 0.2*hi_screen - 0.4*hrv_ok - 0.3*sleep_ok + np.random.normal(0,0.3,n)), 0, 3)
    y = np.column_stack([energy, focus, stress]).astype(np.float32)
    return X, y

print("Generating 20K synthetic samples...")
X, y = gen_data()
split = int(len(X) * 0.8)
mean_ = X[:split].mean(axis=0).astype(np.float32)
std_ = X[:split].std(axis=0).astype(np.float32)
std_[std_ == 0] = 1.0

Xn = (X - mean_) / std_

print("Building and training Keras model...")
i = tf.keras.Input(shape=(N_FEATURES,))
x = tf.keras.layers.Dense(32, activation='relu')(i)
x = tf.keras.layers.BatchNormalization()(x)
x = tf.keras.layers.Dense(16, activation='relu')(x)
x = tf.keras.layers.BatchNormalization()(x)
o = tf.keras.layers.Dense(3, activation='linear', name='output')(x)
m = tf.keras.Model(i, o)
m.compile(optimizer='adam', loss='mse')
m.fit(Xn[:split], y[:split], epochs=50, batch_size=64, verbose=2,
      validation_data=(Xn[split:], y[split:]),
      callbacks=[tf.keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True)])
loss = m.evaluate(Xn[split:], y[split:], verbose=0)
print(f"Test MSE: {loss:.4f}")

w = m.get_weights()
W1 = w[0] / std_.reshape(-1, 1)
b1 = w[1] - (w[0].T @ (mean_ / std_))

print("Building CoreML model via NeuralNetworkBuilder...")
builder = NeuralNetworkBuilder(
    input_features=[("features", datatypes.Array(N_FEATURES))],
    output_features=[("output", datatypes.Array(3))]
)
builder.add_inner_product(
    name="dense1", W=W1.T.astype(np.float32), b=b1.astype(np.float32),
    input_channels=N_FEATURES, output_channels=32,
    input_name="features", output_name="dense1_out", has_bias=True)
builder.add_batchnorm(
    name="bn1", channels=32,
    gamma=w[2].astype(np.float32), beta=w[3].astype(np.float32),
    mean=w[4].astype(np.float32), variance=w[5].astype(np.float32),
    input_name="dense1_out", output_name="bn1_out")
builder.add_activation(name="relu1", non_linearity="RELU",
    input_name="bn1_out", output_name="relu1_out")
builder.add_inner_product(
    name="dense2", W=w[6].T.astype(np.float32), b=w[7].astype(np.float32),
    input_channels=32, output_channels=16,
    input_name="relu1_out", output_name="dense2_out", has_bias=True)
builder.add_batchnorm(
    name="bn2", channels=16,
    gamma=w[8].astype(np.float32), beta=w[9].astype(np.float32),
    mean=w[10].astype(np.float32), variance=w[11].astype(np.float32),
    input_name="dense2_out", output_name="bn2_out")
builder.add_activation(name="relu2", non_linearity="RELU",
    input_name="bn2_out", output_name="relu2_out")
builder.add_inner_product(
    name="output_dense", W=w[12].T.astype(np.float32), b=w[13].astype(np.float32),
    input_channels=16, output_channels=3,
    input_name="relu2_out", output_name="output", has_bias=True)

mlmodel = MLModel(builder.spec)
mlmodel.author = "Momentum"
mlmodel.short_description = "Predicts energy (0-4), focus (0-100), and stress (0-3)"
mlmodel.version = "1.0"
os.makedirs(os.path.dirname(COREML_PATH), exist_ok=True)
mlmodel.save(COREML_PATH)
size = sum(os.path.getsize(os.path.join(dirpath, f)) for dirpath, _, filenames in os.walk(COREML_PATH) for f in filenames) if os.path.isdir(COREML_PATH) else os.path.getsize(COREML_PATH)
print(f"CoreML saved: {COREML_PATH} ({size / 1024:.1f} KB)")

print("Converting to TFLite...")
inp = tf.keras.Input(shape=(N_FEATURES,), dtype=tf.float32)
norm = tf.keras.layers.Lambda(lambda x: (x - mean_) / std_)(inp)
out = m(norm)
export = tf.keras.Model(inp, out)
export.compile(optimizer='adam', loss='mse')
conv = tf.lite.TFLiteConverter.from_keras_model(export)
conv.optimizations = [tf.lite.Optimize.DEFAULT]
tflite = conv.convert()
os.makedirs(os.path.dirname(TFLITE_PATH), exist_ok=True)
with open(TFLITE_PATH, 'wb') as f:
    f.write(tflite)
print(f"TFLite saved: {TFLITE_PATH} ({len(tflite) / 1024:.1f} KB)")

# Verify
print("\nVerifying TFLite inference...")
i2 = tf.lite.Interpreter(model_path=TFLITE_PATH)
i2.allocate_tensors()
i2.set_tensor(i2.get_input_details()[0]['index'], X[split:split+1])
i2.invoke()
o2 = i2.get_tensor(i2.get_output_details()[0]['index'])
print(f"  Sample: Energy={o2[0][0]:.2f} Focus={o2[0][1]:.2f} Stress={o2[0][2]:.2f}")
print(f"  Target: Energy={y[split][0]:.0f} Focus={y[split][1]:.0f} Stress={y[split][2]:.0f}")
print("\nDone!")
