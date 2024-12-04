////////////////////////////////////////////////////////////////////////////////
//
//  Engineer       :  Fahad Haqique
//  Date created   :  10/11/2024
//  Last modified  :  04/12/2024
//  ------------------------------------------------------------------------
//  Dependencies   :  
//  ------------------------------------------------------------------------
//  Description    :
//  ------------------------------------------------------------------------
//  To do          :  
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module fs_4_mixer #(
  parameter DATA_WIDTH = 8
)(
  input  wire clk_i,
  input  wire reset_ni,

  input  wire                  valid_i,
  output wire                  ready_o,
  input  wire [DATA_WIDTH-1:0] I_i,
  input  wire [DATA_WIDTH-1:0] Q_i,
  input  wire                  dir_i,

  output wire                  valid_o,
  input  wire                  ready_i,
  output reg  [DATA_WIDTH-1:0] I_o,
  output reg  [DATA_WIDTH-1:0] Q_o
);


  // Counter
  reg [1:0] cntr = 0;
  wire      cntr_en;
  wire      cntr_dir;

  assign cntr_en = (valid_i && ready_o);

  assign cntr_dir = dir_i;

  always @(posedge clk_i) begin
    if (cntr_en) begin
      if (cntr_dir) begin
        cntr <= cntr + 1'd1;
      end else begin
        cntr <= cntr - 1'd1;
      end
    end
  end


  // AXIS Slave Interface
  assign ready_o = ready_i;


  // AXIS Master Interface
  assign valid_o = valid_i;

  always @(*) begin
    // fs/4 LUT
    case(cntr)
      2'd0 : {I_o, Q_o} = {+I_i, +Q_i};
      2'd1 : {I_o, Q_o} = {-Q_i, +I_i};
      2'd2 : {I_o, Q_o} = {-I_i, -Q_i};
      2'd3 : {I_o, Q_o} = {+Q_i, -I_i};
    endcase
  end

endmodule
