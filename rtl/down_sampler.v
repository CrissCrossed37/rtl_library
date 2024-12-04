////////////////////////////////////////////////////////////////////////////////
//
//  Engineer       :  Fahad Haqique
//  Date created   :  24/11/2024
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

module down_sampler #(
  parameter D_FACTOR = 4,
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

  // Ring Counter
  reg  [D_FACTOR-1:0] ring_cntr;
  wire                ring_cntr_en;

  always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      ring_cntr <= 1;
    end else if (ring_cntr_en) begin
      ring_cntr <= {ring_cntr[D_FACTOR-2:0], ring_cntr[D_FACTOR-1]};
    end
  end

  assign ring_cntr_en = (s_axis_tvalid && s_axis_tready);


  // AXIS Slave Interface
  assign s_axis_tready = m_axis_tready;

  // AXIS Master Interface
  assign m_axis_tvalid = (s_axis_tvalid && s_axis_tready) && ring_cntr[0];
  
  assign m_axis_tdata = s_axis_tdata;

endmodule
