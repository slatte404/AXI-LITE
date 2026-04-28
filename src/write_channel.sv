module write_channel #(
    parameter int ADDR_WIDTH = 6,
    parameter int DATA_WIDTH = 64,
    parameter int REG_NUM = 6
) (
    input logic aclk,
    input logic aresetn,
    
    // AXI Write interface
    input logic [ADDR_WIDTH-1:0]   s_axi_awaddr,
    input logic                    s_axi_awvalid,
    output logic                   s_axi_awready,
    input logic [DATA_WIDTH-1:0]   s_axi_wdata,
    input logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input logic                    s_axi_wvalid,
    output logic                   s_axi_wready,
    output logic [1:0]             s_axi_bresp,//must wait until the write process have been done
    output logic                   s_axi_bvalid,
    input logic                    s_axi_bready, // master says i am ready to receive your bvalid
    
    // To register file
    input logic [$clog2(REG_NUM)-1:0] wr_index,
    input logic wr_index_valid,
    input logic [DATA_WIDTH-1:0] reg_file [REG_NUM],
    output logic write_enable,
    output logic [DATA_WIDTH-1:0] write_data,
    output logic [DATA_WIDTH/8-1:0] write_strb//按字节写入
);

    typedef enum logic [1:0] {
        IDLE,
        WRITE_DATA,
        SEND_RESPONSE
    } write_state_t;

    write_state_t state;

//logic aw_handshake_done;
//logic w_handshake_done;

always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        //aw_handshake_done <= 0;
        //w_handshake_done  <= 0;
        s_axi_awready <= 1'b0;  // IDLE READY 拉高
        s_axi_wready  <= 1'b0;
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                // READY 低，等待 VALID
                s_axi_awready <= 1'b0;
                s_axi_wready  <= 1'b0;

                if (s_axi_awvalid && !s_axi_awready) s_axi_awready <= 1;
                if (s_axi_wvalid && !s_axi_wready)   s_axi_wready  <= 1;

                // 捕获握手
                //if (s_axi_awvalid && s_axi_awready) aw_handshake_done <= 1;
                //if (s_axi_wvalid && s_axi_wready)   w_handshake_done  <= 1;

                // 同时收到地址和数据
                if (s_axi_awready && s_axi_wready) begin
                    state <= WRITE_DATA;
                    s_axi_awready <= 1'b0;
                    s_axi_wready  <= 1'b0;
                end
            end

            WRITE_DATA: begin
                write_enable <= 1'b1;
                write_data   <= s_axi_wdata;
                write_strb   <= s_axi_wstrb;

                // 清标志，为下一笔写准备
                //aw_handshake_done <= 0;
                //w_handshake_done  <= 0;

                state <= SEND_RESPONSE;
            end

            SEND_RESPONSE: begin
                write_enable <= 0;
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= wr_index_valid ? 2'b00 : 2'b10;

                if (s_axi_bready && s_axi_bvalid) begin
                    s_axi_bvalid <= 0;
                    write_data   <= '0;
                    state <= IDLE;
                end
            end
        endcase
    end
end


endmodule