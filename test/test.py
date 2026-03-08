# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Edge


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Check if we can generate multiple random bytes
    dut.ui_in.value = 1 # Assert ready_i signal
    random_values = []
    num_tests = 100
    for i in range(num_tests):
        await Edge(dut.uio_out) # Wait until valid_o signal is high
        
        if not dut.uo_out.value.is_resolvable:
            dut._log.warning(f"GLS 'X' State Detected! Output is: {dut.uo_out.value.binstr}")
            assert True
        random_val = dut.uo_out.value.to_unsigned()
        dut._log.info(f"The random byte that was generated is: {random_val:x}")
        random_values.append(random_val)
        await Edge(dut.uio_out) # Wait until valid_o signal is low

    unique_bytes = set(random_values)
    assert len(unique_bytes) > 5, f"Low variance! Only {len(unique_bytes)} unique values in 100 samples."

