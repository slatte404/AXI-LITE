`timescale 1ns/1ps

module read_channel #(
    parameter int ADDR_WIDTH = 6,
    parameter int DATA_WIDTH = 64,
    parameter int REG_NUM = 6
) (
    input logic aclk,
    input logic aresetn,
    
    // AXI Read interface
    input logic [ADDR_WIDTH-1:0]   s_axi_araddr,
    input logic                    s_axi_arvalid,
    output logic                   s_axi_arready,
    output logic [DATA_WIDTH-1:0]  s_axi_rdata,
    output logic [1:0]             s_axi_rresp,
    output logic                   s_axi_rvalid,
    input logic                    s_axi_rready,
    
    // From register file
    input logic [$clog2(REG_NUM)-1:0] rd_index,
    input logic rd_index_valid,
    input logic [DATA_WIDTH-1:0] reg_file [REG_NUM]
);

    typedef enum logic [1:0] {
        IDLE,
        READ_DATA,
        SEND_DATA
    } read_state_t;

    read_state_t state;

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state <= IDLE;
            s_axi_arready <= 1'b0;
            s_axi_rvalid <= 1'b0;
            s_axi_rdata <= '0;
            s_axi_rresp <= 2'b00;
        end else begin
            case (state)
                IDLE: begin
                    s_axi_rvalid <= 1'b0;
                    
                    if (s_axi_arvalid && !s_axi_arready) begin
                        s_axi_arready <= 1'b1;
                    end
                    
                    if (s_axi_arready && s_axi_arvalid) begin
                        state <= READ_DATA;
                        s_axi_arready <= 1'b0;
                    end
                end
                
                READ_DATA: begin
                    s_axi_rdata <= rd_index_valid ? reg_file[rd_index] : '0;
                    s_axi_rresp <= rd_index_valid ? 2'b00 : 2'b10;
                    state <= SEND_DATA;
                end
                
                SEND_DATA: begin
                    s_axi_rvalid <= 1'b1;
                    
                    if (s_axi_rready && s_axi_rvalid) begin
                        s_axi_rvalid <= 1'b0;
                        s_axi_rdata <= '0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule