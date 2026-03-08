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
 * ready_i - Handshake signal from the receiver indicating it is 
 * ready to accept a new random byte. When HIGH, oscillators and samplers are active.
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
    input logic ready_i, // Ready Handshake signal

    output logic [7:0] byte_o, // Random Byte
    output logic valid_o // Valid Handshake signal
);

// Watchdog signal
logic wd_timeout;

// Three different ring oscillators to prevent synchronization with clk
logic bit_3, bit_5, bit_7, random_oscillator_bit;

ring_oscillator #(.DEPTH(3)) i_ring_oscillator_3 (
    .bit_o(bit_3)
);
ring_oscillator #(.DEPTH(5)) i_ring_oscillator_5 (
    .bit_o(bit_5)
);
ring_oscillator #(.DEPTH(7)) i_ring_oscillator_7 (
    .bit_o(bit_7)
);

assign random_oscillator_bit = bit_3 ^ bit_5 ^ bit_7;

// Synchronize bit
logic sync_1, sync_2;

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        sync_1 <= 1'b0;
        sync_2 <= 1'b0;
    end else if (ready_i) begin
        sync_1 <= random_oscillator_bit;
        sync_2 <= sync_1;
    end
end

// Bit counter
logic [2:0] counter_d, counter_q;
logic counter_en, counter_rst;

assign counter_rst = wd_timeout;

always_comb begin
    counter_d = counter_q;
    if (counter_en) begin
        counter_d = counter_q + 1;
    end
    if (counter_rst) begin
        counter_d = 1'b0;
    end
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        counter_q <= '0;
    end else begin
        counter_q <= counter_d;
    end
end


// Von Neumann Whitener FSM:
typedef enum logic { 
    FIRST_BIT=0,
    SECOND_BIT=1
 } state_e;

 state_e state_d, state_q;
 logic first_bit_d, first_bit_q;
 logic clean_bit_d, clean_bit_q;
 logic valid_bit;

always_comb begin 
    state_d = state_q;
    first_bit_d = first_bit_q;
    counter_en = 1'b0;
    clean_bit_d = clean_bit_q;
    valid_bit = 1'b0;

    case (state_q)
        FIRST_BIT: begin
            if(ready_i) begin
                first_bit_d = sync_2;
                state_d = SECOND_BIT;
            end
        end
        SECOND_BIT: begin
            if(ready_i) begin
                if (sync_2 ^ first_bit_q) begin
                    clean_bit_d = sync_2;
                    counter_en = 1'b1;
                    valid_bit = 1'b1;
                end
                state_d = FIRST_BIT;
            end
            
        end
        default: begin
            state_d = FIRST_BIT;
        end
    endcase

    if(wd_timeout) begin
        state_d = FIRST_BIT;
    end
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        state_q <= FIRST_BIT;
        first_bit_q <= 1'b0;
        clean_bit_q <= 1'b0;
    end else begin
        state_q <= state_d;
        first_bit_q <= first_bit_d;
        clean_bit_q <= clean_bit_d;
    end
 end


// Byte assembler
logic [7:0] byte_q, byte_d;

genvar i;
generate 
    for (i = 0; i < 8 ;i++ ) begin
        assign byte_d[i] = (i == counter_q) ? clean_bit_q : byte_q[i];
    end
endgenerate

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        byte_q <= '0;
    end else begin
        byte_q <= byte_d;
    end
end

// Watchdog module

watchdog_timer #(.TIMEOUT(1024)) i_watchdog (
    .clk_i(clk_i),
    .rst_ni(rst_ni), 
    .en_i(ready_i),
    .pet_i(valid_bit),
    .timeout_o(wd_timeout)
);

assign valid_o = (counter_q == 7);

endmodule