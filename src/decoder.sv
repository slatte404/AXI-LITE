module address_decoder #(
    parameter int ADDR_WIDTH = 6,
    parameter int DATA_WIDTH = 64,
    parameter int REG_NUM = 6
) (
    input logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input logic [ADDR_WIDTH-1:0] s_axi_araddr,
    output logic [$clog2(REG_NUM)-1:0] wr_index,
    output logic [$clog2(REG_NUM)-1:0] rd_index,
    output logic wr_index_valid,
    output logic rd_index_valid
);

    always_comb begin
        // Write address decoding
        wr_index = s_axi_awaddr[ADDR_WIDTH-1:$clog2(DATA_WIDTH/8)];//lower bit be 3/2
        wr_index_valid = (wr_index < REG_NUM);
        
        // Read address decoding
        rd_index = s_axi_araddr[ADDR_WIDTH-1:$clog2(DATA_WIDTH/8)];
        rd_index_valid = (rd_index < REG_NUM);
    end

endmodule