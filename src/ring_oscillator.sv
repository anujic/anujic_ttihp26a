/*******************************************************************************
 * Module: ring_oscillator
 * Project: Tiny Tapeout TRNG
 * * Description:
 * A free-running combinatorial ring oscillator used as the primary 
 * physical entropy source for the TRNG. It relies on the inherent phase 
 * noise (jitter) of standard logic gates to generate unpredictability.
 * * IMPORTANT SYNTHESIS NOTE: 
 * To prevent synthesis tools (like Yosys) from optimizing away the 
 * combinatorial loop, this module MUST manually instantiate foundry-specific 
 * standard cells (e.g., IHP inverters) and utilize synthesis 
 * compiler directives such as (* keep = "true" *).
 * * Parameters:
 * - DEPTH : Controls the length of the inverter chain. To maintain 
 * oscillation, the total number of instantiated inverters must 
 * always be odd (e.g., 2 * DEPTH + 1).
 * * I/O Interface:
 * Outputs:
 * - bit_o : The raw, asynchronous, high-frequency oscillating signal. 
 * (Note: This signal is highly unstable and must be routed into 
 * the D-input of a synchronous sampling flip-flop externally).
 ******************************************************************************/

module ring_oscillator #(parameter DEPTH = 3)(
    output logic bit_o // randomly sampled bit
);
// TODO: implement

endmodule