
module axi_lite_slave #(
    parameter int ADDR_WIDTH = 6,
    parameter int DATA_WIDTH = 64,
    parameter int REG_NUM = 6
) (
    input logic aclk,
    input logic aresetn,

    // Write address channel
    input logic [ADDR_WIDTH-1:0]   s_axi_awaddr,
    input logic                    s_axi_awvalid,
    output logic                   s_axi_awready,

    // Write data channel
    input logic [DATA_WIDTH-1:0]   s_axi_wdata,
    input logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input logic                    s_axi_wvalid,
    output logic                   s_axi_wready,

    // Write response channel
    output logic [1:0]             s_axi_bresp,
    output logic                   s_axi_bvalid,
    input logic                    s_axi_bready,

    // Read address channel
    input logic [ADDR_WIDTH-1:0]   s_axi_araddr,
    input logic                    s_axi_arvalid,
    output logic                   s_axi_arready,

    // Read data channel
    output logic [DATA_WIDTH-1:0]  s_axi_rdata,
    output logic [1:0]             s_axi_rresp,
    output logic                   s_axi_rvalid,
    input logic                    s_axi_rready,

    output logic [DATA_WIDTH-1:0]  regs_out [REG_NUM]
);

    // Internal signals
    logic [$clog2(REG_NUM)-1:0] wr_index;
    logic [$clog2(REG_NUM)-1:0] rd_index;
    logic wr_index_valid;
    logic rd_index_valid;
    
    logic [DATA_WIDTH-1:0] reg_file [REG_NUM];
    logic write_enable;
    logic [DATA_WIDTH-1:0] write_data;
    logic [DATA_WIDTH/8-1:0] write_strb;

    // Instantiate submodules
    address_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .REG_NUM(REG_NUM)
    ) addr_decoder_inst (
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_araddr(s_axi_araddr),
        .wr_index(wr_index),
        .rd_index(rd_index),
        .wr_index_valid(wr_index_valid),
        .rd_index_valid(rd_index_valid)
    );

    write_channel #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .REG_NUM(REG_NUM)
    ) write_channel_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .wr_index(wr_index),
        .wr_index_valid(wr_index_valid),
        .reg_file(reg_file),
        .write_enable(write_enable),
        .write_data(write_data),
        .write_strb(write_strb)
    );

    read_channel #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .REG_NUM(REG_NUM)
    ) read_channel_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .rd_index(rd_index),
        .rd_index_valid(rd_index_valid),
        .reg_file(reg_file)
    );

    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_NUM(REG_NUM)
    ) reg_file_inst (
        .aclk(aclk),
        .aresetn(aresetn),
        .write_enable(write_enable),
        .wr_index(wr_index),
        .write_data(write_data),
        .write_strb(write_strb),
        .reg_file(reg_file),
        .regs_out(regs_out)
    );

endmodule