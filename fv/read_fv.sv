`timescale 1ns/1ps

module read_fv (
    input logic aclk,
    input logic aresetn,
    
    // AXI signals
    input logic s_axi_arvalid,
    input logic s_axi_arready,
    input logic s_axi_rvalid,
    input logic s_axi_rready,
    input logic [1:0] s_axi_rresp,
    input logic [63:0] s_axi_rdata,
    
    // Register file interface
    input logic rd_index_valid,
    input logic [2:0] rd_index,           // 支持 REG_NUM=6
    input logic [63:0] reg_file [6]
);

    // -----------------------------
    // ARREADY handshake: ARREADY eventually high after ARVALID
    // -----------------------------
    property arready_handshake;
        @(posedge aclk) disable iff (!aresetn)
        s_axi_arvalid |-> ##[0:$] s_axi_arready;
    endproperty
    assert property (arready_handshake);

    // -----------------------------
    // RVALID handshake: RVALID only when read is enabled
    // -----------------------------
    property rvalid_handshake;
        @(posedge aclk) disable iff (!aresetn)
        (s_axi_arvalid && rd_index_valid) |-> s_axi_rvalid;
    endproperty
    assert property (rvalid_handshake);

    // -----------------------------
    // RREADY / RVALID handshake
    // -----------------------------
    property rready_response;
        @(posedge aclk) disable iff (!aresetn)
        (s_axi_rvalid && s_axi_rready) |-> ##1 (!s_axi_rvalid);
    endproperty
    assert property (rready_response);

    // -----------------------------
    // RRESP correct
    // -----------------------------
    property rresp_correct;
        @(posedge aclk) disable iff (!aresetn)
        s_axi_rvalid |-> (s_axi_rresp == 2'b00 || s_axi_rresp == 2'b10);
    endproperty
    assert property (rresp_correct);

    // -----------------------------
    // Data correctness
    // -----------------------------
    property data_correct;
        @(posedge aclk) disable iff (!aresetn)
        (s_axi_rvalid && rd_index_valid) |-> (s_axi_rdata == reg_file[rd_index]);
    endproperty
    assert property (data_correct);

    // -----------------------------
    // RRESP error on invalid index
    // -----------------------------
    property rd_index_invalid_check;
        @(posedge aclk) disable iff (!aresetn)
        (!rd_index_valid && s_axi_rvalid) |-> (s_axi_rresp == 2'b10);
    endproperty
    assert property (rd_index_invalid_check);

endmodule

