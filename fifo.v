// Code your design here
module fifo_sync
#(
    parameter FIFO_DEPTH = 8,
    parameter DATA_WIDTH = 32
)
(
    input clk,
    input rst_n,
    input cs,             // chip select
    input wr_en,
    input rd_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output empty,
    output full
);

    localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH); // FIFO_DEPTH_LOG = 3 (to represent 0 to 7)

    // Declare a bi-dimensional array to store the data
    reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1]; // 8 entries of 32-bit width

    // Wr/Rd pointers with 1 extra MSB bit
    reg [FIFO_DEPTH_LOG:0] write_pointer; // 4-bit pointer
    reg [FIFO_DEPTH_LOG:0] read_pointer;

    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_pointer <= 0;
        end
        else if (cs && wr_en && !full) begin
            fifo[write_pointer[FIFO_DEPTH_LOG-1:0]] <= data_in;
            write_pointer <= write_pointer + 1'b1;
        end
    end

    // Read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_pointer <= 0;
        end
        else if (cs && rd_en && !empty) begin
            data_out <= fifo[read_pointer[FIFO_DEPTH_LOG-1:0]];
            read_pointer <= read_pointer + 1'b1;
        end
    end

    // Empty and full logic
    assign empty = (read_pointer == write_pointer);
    assign full  = (read_pointer == {~write_pointer[FIFO_DEPTH_LOG], write_pointer[FIFO_DEPTH_LOG-1:0]});

endmodule
