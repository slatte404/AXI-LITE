// axi_lite_slave_assertions.sv
`timescale 1ns/1ps
module axi_lite_slave_assertions #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 64,
    parameter REG_NUM    = 6
)(
    input  logic                     aclk,
    input  logic                     aresetn,
    // Write address channel
    input  logic [ADDR_WIDTH-1:0]    s_axi_awaddr,
    input  logic                     s_axi_awvalid,
    input  logic                     s_axi_awready,
    // Write data channel
    input  logic [DATA_WIDTH-1:0]    s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0]  s_axi_wstrb,
    input  logic                     s_axi_wvalid,
    input  logic                     s_axi_wready,
    // Write response channel
    input  logic [1:0]               s_axi_bresp,
    input  logic                     s_axi_bvalid,
    input  logic                     s_axi_bready,
    // Read address channel
    input  logic [ADDR_WIDTH-1:0]    s_axi_araddr,
    input  logic                     s_axi_arvalid,
    input  logic                     s_axi_arready,
    // Read data channel
    input  logic [DATA_WIDTH-1:0]    s_axi_rdata,
    input  logic [1:0]               s_axi_rresp,
    input  logic                     s_axi_rvalid,
    input  logic                     s_axi_rready
);

/////////////////////////////////////////////////
// WRITE CHANNEL ASSERTIONS
/////////////////////////////////////////////////

/* 
 * [DISABLED] 以下断言严重违背了 AMBA AXI 协议规范，已被废弃：
 * 1. AXI 明确允许接收方在 VALID 拉高之前提前拉高 READY（高性能 0-wait-state 设计）。
 * 2. AXI 明确允许接收方在握手后保持 READY 为高电平（支持背靠背传输）。
 *
// AWREADY only asserted when AWVALID
property awready_only_with_awvalid;
    @(posedge aclk) s_axi_awready |-> s_axi_awvalid;
endproperty
assert property (awready_only_with_awvalid)
    else $error("AWREADY asserted without AWVALID");

// AWREADY goes low after handshake
property awready_down_after_handshake;
    @(posedge aclk) (s_axi_awready && s_axi_awvalid) |-> !s_axi_awready;
endproperty
assert property (awready_down_after_handshake)
    else $error("AWREADY did not go low after handshake");

// WREADY only asserted when WVALID
property wready_only_with_wvalid;
    @(posedge aclk) s_axi_wready |-> s_axi_wvalid;
endproperty
assert property (wready_only_with_wvalid)
    else $error("WREADY asserted without WVALID");

// WREADY goes low after handshake
property wready_down_after_handshake;
    @(posedge aclk) (s_axi_wready && s_axi_wvalid) |-> !s_axi_wready;
endproperty
assert property (wready_down_after_handshake)
    else $error("WREADY did not go low after handshake");
*/

// BVALID waits for BREADY
property bvalid_wait_bready;
    @(posedge aclk) (s_axi_bvalid && !s_axi_bready) |=> s_axi_bvalid throughout s_axi_bready[->1];
endproperty
assert property (bvalid_wait_bready)
    else $error("BVALID changed before BREADY");

// BVALID goes low after handshake
property bvalid_down_after_handshake;
    @(posedge aclk) (s_axi_bvalid && s_axi_bready) |=> !s_axi_bvalid;
endproperty
assert property (bvalid_down_after_handshake)
    else $error("BVALID did not go low after handshake");

// BRESP stable when BVALID asserted and BREADY low
property bresp_stable;
    @(posedge aclk) (s_axi_bvalid && !s_axi_bready) |-> $stable(s_axi_bresp);
endproperty
assert property (bresp_stable)
    else $error("BRESP changed while BVALID high and BREADY low");

// BRESP legal values (AXI-Lite: 00, 10, 11)
property write_resp_valid;
    @(posedge aclk) s_axi_bvalid |-> (s_axi_bresp != 2'b01);
endproperty
assert property (write_resp_valid)
    else $error("AXI-Lite Write Response invalid (2'b01)");

/////////////////////////////////////////////////
// READ CHANNEL ASSERTIONS
/////////////////////////////////////////////////

/* 
 * [DISABLED] 以下断言严重违背了 AMBA AXI 协议规范，已被废弃。
 * 
// ARREADY only asserted when ARVALID
property arready_only_with_arvalid;
    @(posedge aclk) s_axi_arready |-> s_axi_arvalid;
endproperty
assert property (arready_only_with_arvalid)
    else $error("ARREADY asserted without ARVALID");

// ARREADY goes low after handshake
property arready_down_after_handshake;
    @(posedge aclk) (s_axi_arready && s_axi_arvalid) |-> !s_axi_arready;
endproperty
assert property (arready_down_after_handshake)
    else $error("ARREADY did not go low after handshake");
*/

// RVALID waits for RREADY
property rvalid_wait_rready;
    @(posedge aclk) (s_axi_rvalid && !s_axi_rready) |=> s_axi_rvalid throughout s_axi_rready[->1];
endproperty
assert property (rvalid_wait_rready)
    else $error("RVALID changed before RREADY");

// RVALID goes low after handshake
property rvalid_down_after_handshake;
    @(posedge aclk) (s_axi_rvalid && s_axi_rready) |=> !s_axi_rvalid;
endproperty
assert property (rvalid_down_after_handshake)
    else $error("RVALID did not go low after handshake");

// RDATA stable when RVALID high and RREADY low
property rdata_stable;
    @(posedge aclk) (s_axi_rvalid && !s_axi_rready) |=> $stable(s_axi_rdata);
endproperty
assert property (rdata_stable)
    else $error("RDATA changed while RVALID high and RREADY low");

// RRESP stable when RVALID high and RREADY low
property rresp_stable;
    @(posedge aclk) (s_axi_rvalid && !s_axi_rready) |=> $stable(s_axi_rresp);
endproperty
assert property (rresp_stable)
    else $error("RRESP changed while RVALID high and RREADY low");

// RRESP legal values (AXI-Lite: 00, 10, 11)
property read_resp_valid;
    @(posedge aclk) s_axi_rvalid |-> (s_axi_rresp != 2'b01);
endproperty
assert property (read_resp_valid)
    else $error("AXI-Lite Read Response invalid (2'b01)");

    
// AW handshake
property aw_handshake;
  @(posedge aclk) (s_axi_awvalid && s_axi_awready);
endproperty
cover property (aw_handshake);

// W handshake
property w_handshake;
  @(posedge aclk) (s_axi_wvalid && s_axi_wready);
endproperty
cover property (w_handshake);

// B handshake
property b_handshake;
  @(posedge aclk) (s_axi_bvalid && s_axi_bready);
endproperty
cover property (b_handshake);

// AR handshake
property ar_handshake;
  @(posedge aclk) (s_axi_arvalid && s_axi_arready);
endproperty
cover property (ar_handshake);

// R handshake
property r_handshake;
  @(posedge aclk) (s_axi_rvalid && s_axi_rready);
endproperty
cover property (r_handshake);

// B response OKAY
property b_resp_okay;
  @(posedge aclk) (s_axi_bvalid |-> (s_axi_bresp == 2'b00));
endproperty
cover property (b_resp_okay);

// B response SLVERR
property b_resp_slverr;
  @(posedge aclk) (s_axi_bvalid |-> (s_axi_bresp == 2'b10));
endproperty
cover property (b_resp_slverr);

// R response OKAY
property r_resp_okay;
  @(posedge aclk) (s_axi_rvalid |-> (s_axi_rresp == 2'b00));
endproperty
cover property (r_resp_okay);


endmodule
 

