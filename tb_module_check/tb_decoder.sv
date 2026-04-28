`timescale 1ns/1ps

module tb_address_decoder;

    // Parameters
    parameter ADDR_WIDTH = 6;
    parameter DATA_WIDTH = 64;
    parameter REG_NUM    = 6;

    // Local signals
    logic [ADDR_WIDTH-1:0] s_axi_awaddr;
    logic [ADDR_WIDTH-1:0] s_axi_araddr;
    logic [$clog2(REG_NUM)-1:0] wr_index;
    logic [$clog2(REG_NUM)-1:0] rd_index;
    logic wr_index_valid;
    logic rd_index_valid;

    // Instantiate the DUT
    address_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .REG_NUM(REG_NUM)
    ) dut (
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_araddr(s_axi_araddr),
        .wr_index(wr_index),
        .rd_index(rd_index),
        .wr_index_valid(wr_index_valid),
        .rd_index_valid(rd_index_valid)
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        s_axi_awaddr = 0;
        s_axi_araddr = 0;

        // Display header
        $display("Time\tAWADDR\tWR_IDX\tWR_VALID\tARADDR\tRD_IDX\tRD_VALID");
        $display("---------------------------------------------------------------");

        // Apply a series of test addresses
        repeat (8) begin
            #5;
            s_axi_awaddr = $urandom_range(0, 2**ADDR_WIDTH-1);
            s_axi_araddr = $urandom_range(0, 2**ADDR_WIDTH-1);
            #1; // small delay for combinational logic
            $display("%0t\t%0h\t%0d\t%b\t\t%0h\t%0d\t%b", 
                      $time, s_axi_awaddr, wr_index, wr_index_valid, 
                      s_axi_araddr, rd_index, rd_index_valid);
        end

        // Test boundary conditions
        s_axi_awaddr = (REG_NUM * (DATA_WIDTH/8)) - 1;
        s_axi_araddr = (REG_NUM * (DATA_WIDTH/8));
        #1;
        $display("%0t\t%0h\t%0d\t%b\t\t%0h\t%0d\t%b", 
                  $time, s_axi_awaddr, wr_index, wr_index_valid, 
                  s_axi_araddr, rd_index, rd_index_valid);

        $stop;
    end

endmodule
