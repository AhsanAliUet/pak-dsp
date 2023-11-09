
# ============= Imports ===================

from math import floor
import numpy as np
import cocotb
from   cocotb.clock import Clock
from   cocotb.triggers import FallingEdge, RisingEdge, Join, ClockCycles

# =========== Parameters ==================

# ========== ENUMS ==========

# ========== Driver/Monitor ===============
data_out = []
cycles = 3000

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

async def driver(dut, data):
    dut.en_in       <= int(1)
    dut.src_data_in <= to_fixed(data, 15)

async def monitor(dut):
    count = 0
    while(count < cycles):
        await RisingEdge(dut.clk)
        count = count + 1
        data_out.append(to_float(int(dut.dst_data_out), 15, 1))

# ============ Main Test ==================

@cocotb.test()
async def test_ddc(dut):
    clock = Clock(dut.clk, 2, units="ns") # create 2ns period clock on port clk
    cocotb.fork(clock.start()) # start the clock

    # Reset
    await RisingEdge(dut.clk)
    dut.arst_n <=+ 0

    # Set Reset to Low
    await RisingEdge(dut.clk)
    dut.arst_n <= 1

    await RisingEdge(dut.clk)

    cos_data = []
    
    for i in range(cycles):
        cos_data.append(0.99*np.cos(int(i)*2*np.pi*0.01))

    monitor_task = cocotb.fork(monitor(dut))
    for i in range (len(cos_data)):
        await RisingEdge(dut.clk)
        cocotb.fork(driver(dut, cos_data[i]))

    await Join(monitor_task)

    await RisingEdge(dut.clk)
