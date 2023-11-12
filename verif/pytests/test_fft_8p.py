
# ============= Imports ===================

from math import floor
import numpy as np
import cocotb
from   cocotb.clock import Clock
from   cocotb.triggers import FallingEdge, RisingEdge, Join, ClockCycles
import random
from numpy.fft import fft

# =========== Parameters ==================

# ========== ENUMS ==========

# ========== Driver/Monitor ===============
data_out_real = []
data_out_imag = []
cycles = 3000
N = 8
NUM_TESTS = 10

def to_fixed(f,e):
    a = f* (2**e)
    b = int(floor(a))
    if a < 0:
        # next three lines turns b into it's 2's complement.
        b = abs(b)
        b = ~b
        b = b + 1
    return b

def to_float(f, e, int_width=1):
    if f > 2**(e+int_width-1):
        f = f - (2**(e + int_width))
    res = f/(2**e)
    return res

def merge_data(data_real, data_imag):
    pass

async def driver(dut, data_real, data_imag):
    dut.x_real.value = data_real
    dut.x_imag.value = data_imag

async def monitor(dut):
    pass
# ============ Main Test ==================

@cocotb.test()
async def test_fft_8p(dut):
    clock = Clock(dut.clk, 2, units="ns") # create 2ns period clock on port clk
    cocotb.start_soon(clock.start()) # start the clock

    # Reset
    await RisingEdge(dut.clk)
    dut.arst_n.value = 0

    # Set Reset to Low
    await RisingEdge(dut.clk)
    dut.arst_n.value = 1

    await RisingEdge(dut.clk)

    monitor_task = cocotb.start_soon(monitor(dut))
    for i in range (NUM_TESTS):
        await RisingEdge(dut.clk)
        data_real = [random.randint(-NUM_TESTS*N, NUM_TESTS*N) for j in range(N)]
        data_imag = [random.randint(-NUM_TESTS*N, NUM_TESTS*N) for j in range(N)]
        data_cmpl = [complex(real, imag) for real, imag in zip(data_real, data_imag)]
        driver_task = cocotb.start_soon(driver(dut, data_real, data_imag))
        X         = fft(data_cmpl, 8)
        print("\n\n==============Expected real part is:=======================", np.real(X))
        print("\n\n==============Expected imag part is:=======================", np.imag(X))
        print(dut.X_real.value)
        print(dut.X_imag.value)

    await Join(driver_task)
    await Join(monitor_task)

    await RisingEdge(dut.clk)
