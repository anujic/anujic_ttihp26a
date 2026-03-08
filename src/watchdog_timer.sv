/*******************************************************************************
 * Module: watchdog_timer
 * Project: Tiny Tapeout TRNG
 * * Description:
 * A digital failsafe mechanism designed to detect and recover from 
 * entropy starvation or ring oscillator lock-up. When enabled, the 
 * internal counter increments on every system clock cycle. If the 
 * counter reaches the predefined timeout threshold (e.g., 1024 cycles), 
 * it asserts the abort_o signal to flush the whitener state machine 
 * and restart the generation process.
 * * I/O Interface:
 * Inputs:
 * - clk_i   : System clock
 * - rst_ni  : Active-low system reset
 * - pet_i   : Resets the Watchdog counter
 * - en_i    : Enables the watchdog counter. When LOW, the counter is paused.
 * * Outputs:
 * - timeout_o : Triggers HIGH for one clock cycle when the timeout is reached, 
 * indicating a stall in the entropy generation pipeline.
 ******************************************************************************/

module watchdog_timer #(parameter TIMEOUT = 1024) (
    input logic clk_i,
    input logic rst_ni, 
    input logic en_i,  // enables the watchdog
    input logic pet_i, // resets the watchdog counter (the "pet")

    output logic timeout_o // is triggered for one cycle once timeout is reached
);

    logic [$clog2(TIMEOUT)-1 : 0] timer_d, timer_q;

    always_comb begin
        timer_d   = timer_q;
        timeout_o = 1'b0;

        if (en_i) begin
            if (pet_i) begin
                timer_d = '0; 
            end else if (timer_q >= (TIMEOUT - 1)) begin
                timeout_o = 1'b1;
                timer_d   = '0; 
            end else begin
                timer_d = timer_q + 1'b1;
            end
        end        
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            timer_q <= '0;
        end else begin
            timer_q <= timer_d;
        end   
    end

endmodule