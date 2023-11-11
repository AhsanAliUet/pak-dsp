
# ============= Imports ===================

from math import floor
import numpy as np
import cocotb
from   cocotb.clock import Clock
from   cocotb.triggers import FallingEdge, RisingEdge, Join, ClockCycles, Timer

# =========== Parameters ==================

# ========== ENUMS ==========

# ========== Driver/Monitor ===============
data_out = []
cycles   = 3000

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

async def driver(dut, A_real, A_imag, B_real, B_imag):
    dut.A_real.value = to_fixed(A_real, 15)
    dut.A_imag.value = to_fixed(A_imag, 15)
    dut.B_real.value = to_fixed(B_real, 15)
    dut.B_imag.value = to_fixed(B_imag, 15)

async def monitor(dut):
    pass

# ============ Main Test ==================

@cocotb.test()
async def test_cmul(dut):

    cos_data = []
    sin_data = []
    
    for i in range(cycles):
        cos_data.append(0.99*np.cos(int(i)*2*np.pi*0.01))
        sin_data.append(0.99*np.sin(int(i)*2*np.pi*0.01))

    monitor_task = cocotb.start_soon(monitor(dut))
    for i in range (cycles):
        cocotb.start_soon(driver(dut, cos_data[i], sin_data[i], cos_data[i], sin_data[i]))
        await Timer(2, units='ns')
    await Join(monitor_task)
