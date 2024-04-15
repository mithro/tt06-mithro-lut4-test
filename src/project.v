/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module mux_prog (
    input wire a,
    input wire b,
    output wire o,
    input wire config_clk,
    input wire config_in_,
    output wire config_out
);

  // sky130_fd_sc_hd__mux2
  // https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/mux2/README.html
  sky130_fd_sc_hd__mux2_1 mux2(
      .a0(a),
      .a1(b),
      .x(o),
      .s(config_out)
  );

  // sky130_fd_sc_hd__dfxtp
  // https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/dfxtp/README.html
  sky130_fd_sc_hd__dfxtp_1 config_data(
      .d(config_in_),
      .q(config_out),
      .clk(config_clk)
  );

endmodule

module tt_um_mithro_lut4_test (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire config_dat_clk;
  wire config_dat_in_;
  wire config_dat_out;

  // First row of muxes -- 8 inputs, 4 outputs
  wire mux_a1_out;
  wire mux_a1_config_out;
  mux_prog mux_a1(
    .a(ui_in[0]),
    .b(ui_in[1]),
    .o(mux_a1_out),
    .config_clk(config_dat_clk),
    .config_in_(config_dat_in_),
    .config_out(mux_a1_config_out)
  );

  wire mux_a2_out;
  wire mux_a2_config_out;
  mux_prog mux_a2(
    .a(ui_in[2]),
    .b(ui_in[3]),
    .o(mux_a2_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_a1_config_out),
    .config_out(mux_a2_config_out)
  );

  wire mux_a3_out;
  wire mux_a3_config_out;
  mux_prog mux_a3(
    .a(ui_in[4]),
    .b(ui_in[5]),
    .o(mux_a3_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_a2_config_out),
    .config_out(mux_a3_config_out)
  );

  wire mux_a4_out;
  wire mux_a4_config_out;
  mux_prog mux_a4(
    .a(ui_in[6]),
    .b(ui_in[7]),
    .o(mux_a4_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_a3_config_out),
    .config_out(mux_a4_config_out)
  );

  // Second row of muxes -- 4 inputs, 2 outputs
  wire mux_b1_out;
  wire mux_b1_config_out;
  mux_prog mux_b1(
    .a(mux_a1_out),
    .b(mux_a2_out),
    .o(mux_b1_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_a4_config_out),
    .config_out(mux_b1_config_out)
  );

  wire mux_b2_out;
  wire mux_b2_config_out;
  mux_prog mux_b2(
    .a(mux_a3_out),
    .b(mux_a4_out),
    .o(mux_b2_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_b1_config_out),
    .config_out(mux_b2_config_out)
  );

  // Third row of muxes -- 2 inputs, 1 outputs
  wire mux_c1_out;
  wire mux_c1_config_out;
  mux_prog mux_c1(
    .a(mux_b1_out),
    .b(mux_b2_out),
    .o(mux_c1_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_b2_config_out),
    .config_out(mux_c1_config_out)
  );

  // Input and output...
  assign uo_out[0] = mux_a1_out;
  assign uo_out[1] = mux_a2_out;
  assign uo_out[2] = mux_a3_out;
  assign uo_out[3] = mux_a4_out;

  assign uo_out[4] = mux_b1_out;
  assign uo_out[5] = mux_b1_out;

  assign uo_out[6] = mux_c1_out;
  assign uo_out[7] = config_dat_out;

  // Configuration stuff
  assign config_dat_clk = uio_in[0];
  assign config_dat_in_ = uio_in[1];
  assign config_dat_out = mux_c1_config_out;

  assign uio_oe  = 0; // Always inputs
  assign uio_out = 0; // Not used...

endmodule
