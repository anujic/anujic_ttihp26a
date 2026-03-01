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
  localparam NUM_INVS = (2 * DEPTH) + 1;

  (* keep = "true" *) logic [NUM_INVS-1:0] inv_array;

  genvar i;
  generate
    for (i = 0; i < NUM_INVS; i = i + 1) begin
      if (i == 0) begin
        (* keep = "true" *) sg13g2_inv_1 inv (
          .Y(inv_array[0]),
          .A(inv_array[NUM_INVS-1])
          );
      end else begin
      (* keep = "true" *) sg13g2_inv_1 inv (
          .Y(inv_array[i]),
          .A(inv_array[i-1])
          );
      end
    end
  endgenerate

  assign bit_o = inv_array[0];

endmodule