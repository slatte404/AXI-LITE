module register_file #(
    parameter int DATA_WIDTH = 64,
    parameter int REG_NUM = 6
) (
    input logic aclk,
    input logic aresetn,
    input logic write_enable,
    input logic [$clog2(REG_NUM)-1:0] wr_index,
    input logic [DATA_WIDTH-1:0] write_data,
    input logic [DATA_WIDTH/8-1:0] write_strb,
    output logic [DATA_WIDTH-1:0] reg_file [REG_NUM],
    output logic [DATA_WIDTH-1:0] regs_out [REG_NUM]
);

    // Register file
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            for (int i = 0; i < REG_NUM; i++) begin
                reg_file[i] <= '0;
            end
        end else begin
            if (write_enable) begin
                for (int byte_index = 0; byte_index < DATA_WIDTH/8; byte_index++) begin
                    if (write_strb[byte_index]) begin
                        reg_file[wr_index][byte_index*8 +: 8] <= write_data[byte_index*8 +: 8];
                    end
                end
            end
        end
    end

    // Output assignment
    always_comb begin
        for (int i = 0; i < REG_NUM; i++) begin
            regs_out[i] = reg_file[i];
        end
    end

endmodule