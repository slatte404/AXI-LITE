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

    logic aw_done;
    logic w_done;

always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
        aw_done <= 1'b0;
        w_done  <= 1'b0;
        s_axi_awready <= 1'b0;
        s_axi_wready  <= 1'b0;
        s_axi_bvalid  <= 1'b0;
        write_enable  <= 1'b0;
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                // 如果该通道还没握手成功，就拉高 READY 准备接收
                s_axi_awready <= !aw_done;
                s_axi_wready  <= !w_done;

                // 独立捕获 AW 握手
                if (s_axi_awvalid && s_axi_awready) begin
                    aw_done <= 1'b1;
                    s_axi_awready <= 1'b0;
                end
                
                // 独立捕获 W 握手
                if (s_axi_wvalid && s_axi_wready) begin
                    w_done <= 1'b1;
                    s_axi_wready <= 1'b0;
                end

                // 只有当两个通道都“曾经”或者“正在”握手成功，才跳转
                if ((aw_done || (s_axi_awvalid && s_axi_awready)) && 
                    (w_done  || (s_axi_wvalid && s_axi_wready))) begin
                    state <= WRITE_DATA;
                    aw_done <= 1'b0;
                    w_done  <= 1'b0;
                    s_axi_awready <= 1'b0;
                    s_axi_wready  <= 1'b0;
                end
            end

            WRITE_DATA: begin
                write_enable <= 1'b1;
                write_data   <= s_axi_wdata;
                write_strb   <= s_axi_wstrb;
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