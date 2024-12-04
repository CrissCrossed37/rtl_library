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

module up_sampler #(
  parameter I_FACTOR = 4,
  parameter ZERO_ORDER_HOLD = 0,
  parameter TDATA_WIDTH = 8
)(
  input wire aclk,
  input wire aresetn,

  input  wire                   s_axis_tvalid,
  output wire                   s_axis_tready,
  input  wire [TDATA_WIDTH-1:0] s_axis_tdata,

  output wire                   m_axis_tvalid,
  input  wire                   m_axis_tready,
  output wire [TDATA_WIDTH-1:0] m_axis_tdata
);


  // Shift Register
  localparam SHIFT_REG_WIDTH = I_FACTOR;

  reg  [SHIFT_REG_WIDTH-1:0] shift_reg;
  wire                       shift_reg_sload;
  wire                       shift_reg_en;
  
  always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      shift_reg <= {SHIFT_REG_WIDTH{1'b0}};
    end else if (shift_reg_sload) begin
      shift_reg <= {1'b1, {(SHIFT_REG_WIDTH - 1){1'b0}}};
    end else if (shift_reg_en) begin
      shift_reg <= {1'b0, shift_reg[SHIFT_REG_WIDTH-1:1]};
    end
  end

  assign shift_reg_sload = (s_axis_tvalid && s_axis_tready);

  assign shift_reg_en = (m_axis_tvalid && m_axis_tready);

  
  // Data Register
  reg  [TDATA_WIDTH-1:0] data_reg;
  wire                   data_reg_en;
  wire                   data_reg_sclr;
  
  always @(posedge aclk) begin
    if (data_reg_en) begin
      data_reg <= s_axis_tdata;
    end else if (data_reg_sclr) begin
      data_reg <= {TDATA_WIDTH{1'b0}};
    end
  end

  assign data_reg_en = (s_axis_tvalid && s_axis_tready);

  assign data_reg_sclr = !ZERO_ORDER_HOLD && (m_axis_tvalid && m_axis_tready);


  // AXIS Slave Interface
  assign s_axis_tready = ~|shift_reg[I_FACTOR-1:1] && (!m_axis_tvalid || m_axis_tready);


  // AXIS Master Interface
  assign m_axis_tvalid = |shift_reg;

  assign m_axis_tdata = data_reg;

endmodule
