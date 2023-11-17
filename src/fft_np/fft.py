import numpy as np

signal = np.array([64/128, 83/128, 96/128, 42/128])
fft_result = np.fft.fft(signal)

print(np.int8(fft_result))
