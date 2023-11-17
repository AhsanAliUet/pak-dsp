
def cmul(a_real, a_imag, b_real, b_imag):
    y_real = a_real*b_real - a_imag*b_imag
    y_imag = a_real*b_imag + a_imag*b_real
    return y_real, y_imag

def cadd(a_real, a_imag, b_real, b_imag):
    y_real = a_real - b_real
    y_imag = a_imag + b_imag
    return y_real, y_imag

def bfly(a_real, a_imag, b_real, b_imag, w_real, w_imag):
    mult_real, mult_imag = cmul(b_real, b_imag, w_real, w_imag)
    y0_real, y0_imag = cadd(a_real, a_imag, mult_real, mult_imag)
    y1_real, y1_imag = cadd(a_real, a_imag, ~mult_real + 1, ~mult_imag + 1)
    return y0_real, y0_imag, y1_real, y1_imag

x = [1, 1, 1, 1, 1, 1, 1, 1]
N = 8
for i in range(0, N, 2):
    bfly()
