
# ============= Imports ===================

from math import floor
import numpy as np
import matplotlib.pyplot as plt
import cocotb
from   cocotb.clock import Clock
from   cocotb.triggers import FallingEdge, RisingEdge, Join, ClockCycles

# =========== Parameters ==================

# ========== ENUMS ==========

# ========== Driver/Monitor ===============
data_out_i = []
data_out_q = []
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
    dut.bypass        <= int(7)
    dut.src_valid_in  <= int(1)
    dut.src_data_in   <= to_fixed(data, 15)
    await RisingEdge(dut.clk)
    dut.src_valid_in  <= int(0)

async def monitor(dut):
    count = 0
    while(count < (cycles/32)):
        await RisingEdge(dut.clk)
        if(int(dut.dst_valid_out) != 0):
            count = count + 1
            data_out_i.append(to_float(int(dut.dst_data_out), 21, 1))

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
        if i==0:
            cocotb.fork(driver(dut, cos_data[i]))
        else:
            cocotb.fork(driver(dut, cos_data[i]))

    await Join(monitor_task)

    # plt.subplot(2, 1, 1)
    # plt.title("input")
    # plt.plot(cos_data, label = "input")

    # plt.subplot(2, 1, 2)
    # plt.title("output channel i")
    # plt.plot(data_out_i, label = "output channel i")

    # plt.tight_layout(pad=1.08)

    # plt.savefig("plot.png")

    await RisingEdge(dut.clk)
