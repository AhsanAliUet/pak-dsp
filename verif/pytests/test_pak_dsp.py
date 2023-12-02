
# ============= Imports ===================

from math import floor
import numpy as np
import cocotb
from   cocotb.clock import Clock
from   cocotb.triggers import FallingEdge, RisingEdge, Join, ClockCycles

# =========== Parameters ==================

# ========== ENUMS ==========

# ========== Driver/Monitor ===============
cycles = 3000

async def driver(dut, data):
    pass

async def monitor(dut):
    pass

# ============ Main Test ==================

@cocotb.test()
async def test_pak_dsp(dut):
    clock = Clock(dut.clk, 1, units="ns") # create 2ns period clock on port clk
    cocotb.start_soon(clock.start()) # start the clock

    # Reset
    await RisingEdge(dut.clk)
    dut.arst_n.value = 0

    # Set Reset to Low
    await RisingEdge(dut.clk)
    dut.arst_n.value = 1

    await RisingEdge(dut.clk)

    monitor_task = cocotb.start_soon(monitor(dut))
    for i in range (cycles):
        await RisingEdge(dut.clk)

    await Join(monitor_task)
    await RisingEdge(dut.clk)
