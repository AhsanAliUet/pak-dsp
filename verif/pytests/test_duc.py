# ============= Imports ===================

from math import floor, pi, cos, sin
import matplotlib.pyplot as plt
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Join

# =========== Parameters ==================

# ========== ENUMS ==========

# ========== Driver/Monitor ===============

clk_cycles = 500

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
    dut.bypass.value          = int(0) 
    dut.src_valid_in.value    = int(1)
    dut.src_data_in.value     = to_fixed(data, 15)
    await RisingEdge(dut.src_ready_out)
    await RisingEdge(dut.clk)
    dut.src_valid_in.value    <= int(0)

data_out_i = []
data_out_q = []

async def monitor(dut):
    count = 0
    c     = 0
    dut.dst_ready_in.value = int(1)
    while(count < (clk_cycles)):
        await RisingEdge(dut.clk)
        dut.dst_ready_in.value = int(c%35 < 3)
        c = c + 1
        if(int(dut.dst_valid_out.value) != 0 and int(dut.dst_ready_in.value) != 0):
            data_out_i.append(to_float(int(dut.dst_data_out.value), 21, 1))
            count = count + 1

# ============ Main Test ==================

@cocotb.test()
async def test_duc(dut):
    clock = Clock(dut.clk, 2, units="ns") # create 2ns period clock on port clk
    cocotb.start_soon(clock.start()) # start the clock

    # Reset
    await RisingEdge(dut.clk)
    dut.arst_n.value = 0

    # Set Reset to Low
    await RisingEdge(dut.clk)
    dut.arst_n.value = 1

    await RisingEdge(dut.clk)

    cos_data = []
    sin_data = []
    f = 0.01        # frequency of sine or cosine
    w = 2*pi*f      # omega
    A = 0.9999      # Maximum Amplitude of sine or cosine

    for t in range(clk_cycles):
        cos_data.append(A*cos(w*t))
    for t in range(clk_cycles):
        sin_data.append(A*sin(w*t))

    wave_in = sin_data
    print(wave_in)
    monitor_task = cocotb.start_soon(monitor(dut))
    for i in range (len(wave_in)):
        driver_task = cocotb.start_soon(driver(dut, wave_in[i]))
        await RisingEdge(dut.clk)

    await Join(driver_task)
    
    await Join(monitor_task)

    # fp = open("data_in.txt", "w")
    # for i in wave_in:
    #     fp.writelines(str(i) + "\n")

    # rs_data = open("data_out.txt", "w")
    # for i in data_out_i:
    #     rs_data.writelines(str(i))
    #     rs_data.writelines("\n")

    # fp.close()
    # rs_data.close()
    # plt.subplot(3, 1, 1)
    # plt.title("Input")
    # plt.plot(wave_in, label = "input")
    # plt.grid(True)

    # plt.subplot(3, 1, 2)
    # plt.title("Output from duc channel i")
    # plt.plot(data_out_i, label = "out_ch_i")
    # plt.grid(True)

    # plt.subplot(3, 1, 3)
    # plt.title("Output from duc channel q")
    # plt.plot(data_out_q, label = "out_ch_q")
    # plt.grid(True)

    # plt.tight_layout(pad=1.8)

    # plt.savefig("plot.png")
