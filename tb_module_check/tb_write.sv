`timescale 1ns/1ps

module tb_write_channel;

    // Parameters
    parameter ADDR_WIDTH = 6;
    parameter DATA_WIDTH = 64;
    parameter REG_NUM    = 6;

    // Clock and reset
    logic aclk;
    logic aresetn;

    // AXI write interface
    logic [ADDR_WIDTH-1:0]   s_axi_awaddr;
    logic                    s_axi_awvalid;
    logic                    s_axi_awready;
    logic [DATA_WIDTH-1:0]   s_axi_wdata;
    logic [DATA_WIDTH/8-1:0] s_axi_wstrb;
    logic                    s_axi_wvalid;
    logic                    s_axi_wready;
    logic [1:0]              s_axi_bresp;
    logic                    s_axi_bvalid;
    logic                    s_axi_bready;

    // Register file interface
    logic [$clog2(REG_NUM)-1:0] wr_index;
    logic wr_index_valid;
    logic [DATA_WIDTH-1:0] reg_file [REG_NUM];
    logic write_enable;
    logic [DATA_WIDTH-1:0] write_data;
    logic [DATA_WIDTH/8-1:0] write_strb;

    // DUT
    write_channel #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .REG_NUM(REG_NUM)
    ) dut (
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

    // Clock generation
    initial aclk = 0;
    always #5 aclk = ~aclk;

    // FSDB waveform
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0, tb_write_channel);
        //$fsdbDumpMDA();
        //$display("FSDB waveform generation started...");
    end

    // Initialize signals
    initial begin
        aresetn = 0;
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wstrb = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        wr_index = 0;
        wr_index_valid = 1; // default valid
        #20;
        aresetn = 1;
    end

    // Task: issue a write transaction
    task automatic write_transaction(input logic [$clog2(REG_NUM)-1:0] index,
                                     input logic [DATA_WIDTH-1:0] data,
                                     input logic [DATA_WIDTH/8-1:0] strb,
                                     input logic valid);
        begin
            wr_index = index;
            wr_index_valid = valid;
            s_axi_awaddr = index * (DATA_WIDTH/8);
            s_axi_awvalid = 1;
            s_axi_wdata = data;
            s_axi_wstrb = strb;
            s_axi_wvalid = 1;
            s_axi_bready = 1;

            // Wait for bvalid
            wait(s_axi_bvalid);
            #1;

            // Check response
            if (valid) begin
                if (s_axi_bresp !== 2'b00)
                    $error("ERROR: Write to index %0d failed, bresp=%0b", index, s_axi_bresp);
                else
                    $display("PASS: Write to index %0d succeeded, bresp=%0b", index, s_axi_bresp);
            end else begin
                if (s_axi_bresp !== 2'b10)
                    $error("ERROR: Invalid write to index %0d, bresp=%0b", index, s_axi_bresp);
                else
                    $display("PASS: Invalid write to index %0d, bresp=%0b", index, s_axi_bresp);
            end

            s_axi_awvalid = 0;
            s_axi_wvalid = 0;
            //s_axi_bready = 0;
            #10;
        end
    endtask

    // Test sequence
    initial begin
        #30;

        // Test valid writes
        write_transaction(0, 64'hA5A5A5A5A5A5A5A5, 8'hFF, 1);
        write_transaction(3, 64'h123456789ABCDEF0, 8'hFF, 1);
        write_transaction(REG_NUM-1, 64'h0F0F0F0F0F0F0F0F, 8'hFF, 1);

        // Test invalid write
        write_transaction(REG_NUM, 64'hDEADBEEFDEADBEEF, 8'hFF, 0);

        $display("All write tests completed.");
        $stop;
    end

endmodule
