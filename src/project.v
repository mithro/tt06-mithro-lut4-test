/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module progobj_mux (
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
      .A0(a),
      .A1(b),
      .X(o),
      .S(config_out)
  );

  // sky130_fd_sc_hd__dfxtp
  // https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/dfxtp/README.html
  sky130_fd_sc_hd__dfxtp_1 config_data(
      .D(config_in_),
      .Q(config_out),
      .CLK(config_clk)
  );

endmodule


module progobj_mux8 (
    input  wire [7:0] i,
    output wire       o,
    input  wire       config_dat_clk,
    input  wire       config_dat_in_,
    output wire       config_dat_out,
    output wire [6:0] debug
);

  // First row of muxes -- 8 inputs, 4 outputs
  wire mux_a1_out;
  wire mux_a1_config_out;
  progobj_mux mux_a1(
    .a(i[0]),
    .b(i[1]),
    .o(mux_a1_out),
    .config_clk(config_dat_clk),
    .config_in_(config_dat_in_),
    .config_out(mux_a1_config_out)
  );

  wire mux_a2_out;
  wire mux_a2_config_out;
  progobj_mux mux_a2(
    .a(i[2]),
    .b(i[3]),
    .o(mux_a2_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_a1_config_out),
    .config_out(mux_a2_config_out)
  );

  wire mux_a3_out;
  wire mux_a3_config_out;
  progobj_mux mux_a3(
    .a(i[4]),
    .b(i[5]),
    .o(mux_a3_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_a2_config_out),
    .config_out(mux_a3_config_out)
  );

  wire mux_a4_out;
  wire mux_a4_config_out;
  progobj_mux mux_a4(
    .a(i[6]),
    .b(i[7]),
    .o(mux_a4_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_a3_config_out),
    .config_out(mux_a4_config_out)
  );

  // Second row of muxes -- 4 inputs, 2 outputs
  wire mux_b1_out;
  wire mux_b1_config_out;
  progobj_mux mux_b1(
    .a(mux_a1_out),
    .b(mux_a2_out),
    .o(mux_b1_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_a4_config_out),
    .config_out(mux_b1_config_out)
  );

  wire mux_b2_out;
  wire mux_b2_config_out;
  progobj_mux mux_b2(
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
  progobj_mux mux_c1(
    .a(mux_b1_out),
    .b(mux_b2_out),
    .o(mux_c1_out),
    .config_clk(config_dat_clk),
    .config_in_(mux_b2_config_out),
    .config_out(config_dat_out)
  );

  assign o = mux_c1_out;

  // Debugging
  assign debug[0] = mux_a1_out;
  assign debug[1] = mux_a2_out;
  assign debug[2] = mux_a3_out;
  assign debug[3] = mux_a4_out;

  assign debug[4] = mux_b1_out;
  assign debug[5] = mux_b1_out;

  assign debug[6] = mux_c1_out;

endmodule


module tt_um_mithro_progobj_test (
    input  wire [7:0] ui_in,    // Dedicated inputs connected to progobj_mux8
    output wire [7:0] uo_out,   // Dedicated outputs

    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)

    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // Unused: clock
    input  wire       rst_n     // Unused: reset_n - low to reset
);

  wire [6:0] debug;
  wire       config_dat_clk;
  wire       config_dat_in_;
  wire       config_dat_out;

  assign uio_oe  = 0; // Always inputs
  assign uio_out = 0;

  progobj_mux8 obj_mux8(
    .i(ui_in),
    .o(uo_out[0]),
    .config_dat_clk(config_dat_clk),
    .config_dat_in_(config_dat_in_),
    .config_dat_out(config_dat_out),
    .debug(debug)
  );

  // Configuration scan chain
  assign config_dat_clk = uio_in[0];
  assign config_dat_in_ = uio_in[1];
  assign uo_out[7] = config_dat_out;

  // Debugging info
  assign uo_out[1] = debug[0]; // mux_a1_out
  assign uo_out[2] = debug[1]; // mux_a2_out
  assign uo_out[3] = debug[2]; // mux_a3_out
  assign uo_out[4] = debug[3]; // mux_a4_out

  assign uo_out[5] = debug[4]; // mux_b1_out
  assign uo_out[6] = debug[5]; // mux_b1_out

  //assign uio_out[7] = debug[6]; // mux_c1_out


endmodule
