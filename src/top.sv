/*******************************************************************************
 * Module: top
 * Project: Tiny Tapeout Hardware TRNG (1x1 Tile)
 * * Description:
 * Top-level module for a fully digital True Random Number Generator (TRNG).
 * This design harvests physical entropy from the phase noise (jitter) of 
 * multiple, mutually prime free-running ring oscillators. The raw 
 * asynchronous bitstream is sampled, de-biased using a Von Neumann 
 * whitener, and assembled into 8-bit words.
 * * Data is transferred downstream using a standard Valid/Ready handshake.
 * * I/O Interface:
 * Inputs:
 * clk_i   - System clock used for sampling and synchronous logic.
 * rst_ni  - Active-low system reset.
 * en_i    - Enable signal. When HIGH, oscillators and samplers are active.
 * ready_i - Handshake signal from the receiver indicating it is 
 * ready to accept a new random byte.
 * * Outputs:
 * byte_o  - 8-bit random data payload.
 * valid_o - Handshake signal indicating byte_o contains valid, 
 * fully-assembled entropy.
 * * Limitations & Constraints:
 * 1. Non-Deterministic Throughput: Because the Von Neumann extractor discards 
 * '00' and '11' pairs, the time required to generate a valid 8-bit word 
 * is completely non-deterministic and varies continuously.
 * 2. Simulation Behavior: Pure RTL simulators (Verilator, Icarus) cannot 
 * simulate physical phase noise. Testbenches must inject artificial 
 * delays or force pseudo-random data into the sampler to verify logic.
 * 3. Synthesis Constraints: The underlying ring oscillators utilize standard 
 * combinatorial loops. Synthesis tools (like Yosys) MUST be instructed 
 * to leave these loops intact via (* keep = "true" *) attributes or 
 * hard-macro instantiations.
 * 4. Entropy Starvation: While mitigated by an internal watchdog timer, 
 * prolonged injection-locking of the oscillators will trigger internal 
 * resets, temporarily halting output generation.
 ******************************************************************************/

module top (
    input logic clk_i,
    input logic rst_ni,
    input logic en_i,
    input logic ready_i, // Ready Handshake signal

    output logic [7:0] byte_o, // Random Byte
    output logic valid_o // Valid Handshake signal
);

// TODO: implement the module

// Three different ring oscillators to prevent synchronization with clk
logic bit_3, bit_5, bit_7, random_oscillator_bit;

ring_oscillator #(DEPTH=3) i_ring_oscillator_3 (
    .bit_o(bit_3)
)
ring_oscillator #(DEPTH=5) i_ring_oscillator_5 (
    .bit_o(bit_5)
)
ring_oscillator #(DEPTH=7) i_ring_oscillator_7 (
    .bit_o(bit_7)
)

assign random_oscillator_bit = bit_3 ^ bit_5 ^ bit_7;

// Von Neumann Whitener FSM:


endmodule