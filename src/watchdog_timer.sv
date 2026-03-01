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
 * - en_i    : Enables the watchdog counter. When LOW, the counter is paused.
 * * Outputs:
 * - abort_o : Triggers HIGH for one clock cycle when the timeout is reached, 
 * indicating a stall in the entropy generation pipeline.
 ******************************************************************************/

module watchdog_timer #(parameter TIMEOUT = 1024)n(
    input logic clk_i,
    input logic rst_ni, 
    input logic en_i, // enables the watchdog

    output logic abort_o // is triggered once timeout is reached
);
// TODO: implement module
endmodule