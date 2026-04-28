`timescale 1ns/1ps

module tb_read_channel;

    // Parameters
    parameter ADDR_WIDTH = 6;
    parameter DATA_WIDTH = 64;
    parameter REG_NUM    = 6;

    // Clock and reset
    logic aclk;
    logic aresetn;

    // AXI read interface
    logic [ADDR_WIDTH-1:0] s_axi_araddr;
    logic s_axi_arvalid;
    logic s_axi_arready;
    logic [DATA_WIDTH-1:0] s_axi_rdata;
    logic [1:0] s_axi_rresp;
    logic s_axi_rvalid;
    logic s_axi_rready;

    // Register file signals
    logic [$clog2(REG_NUM)-1:0] rd_index;
    logic rd_index_valid;
    logic [DATA_WIDTH-1:0] reg_file [REG_NUM];

    // Instantiate DUT
    read_channel #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .REG_NUM(REG_NUM)
    ) dut (
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

    // Clock generation: 10ns period
    initial aclk = 0;
    always #5 aclk = ~aclk;

    // FSDB waveform
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0, tb_read_channel);
        //$fsdbDumpMDA(); // optional for module hierarchy
        //$display("FSDB waveform generation started...");
    end

    // Task: issue a read request and check response
    task automatic read_request(input logic [$clog2(REG_NUM)-1:0] index,
                                input logic valid);
        begin
            rd_index = index;
            rd_index_valid = valid;
            s_axi_araddr = index * (DATA_WIDTH/8); // arbitrary address
            s_axi_arvalid = 1;
            s_axi_rready = 1;

            wait(s_axi_rvalid);
            #1;

            if (valid) begin
                if (s_axi_rdata !== reg_file[index] || s_axi_rresp !== 2'b00)
                    $error("ERROR: Expected rdata=%0d, rresp=00, got rdata=%0d, rresp=%0b",
                           reg_file[index], s_axi_rdata, s_axi_rresp);
                else
                    $display("PASS: rdata=%0d, rresp=%0b", s_axi_rdata, s_axi_rresp);
            end else begin
                if (s_axi_rdata !== 0 || s_axi_rresp !== 2'b10)
                    $error("ERROR: Expected invalid read rdata=0, rresp=10, got rdata=%0d, rresp=%0b",
                           s_axi_rdata, s_axi_rresp);
                else
                    $display("PASS (invalid read): rdata=%0d, rresp=%0b", s_axi_rdata, s_axi_rresp);
            end

            s_axi_arvalid = 0;
            #10;
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize signals
        aresetn = 0;
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        rd_index = 0;
        rd_index_valid = 0;

        // Initialize register file
        for (int i = 0; i < REG_NUM; i++)
            reg_file[i] = i * 100;

        // Apply reset
        #20;
        aresetn = 1;
        #10;

        // Run test cases
        read_request(0, 1);
        read_request(3, 1);
        read_request(5, 0); // invalid read
        read_request(REG_NUM-1, 1);
        read_request(REG_NUM, 0); // out of range invalid

        $display("All tests done.");
        $stop;
    end

endmodule

