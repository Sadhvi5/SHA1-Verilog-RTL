RTL Design code for SHA_TOP_Module:
module sha1_top1 (
input wire clk,
input wire rst_n,
input wire start,
input wire [1023:0] data_in,
input wire [31:0] msg_len,
output wire [159:0] hash_out,
output wire done
);
wire [511:0] padded_block;
wire pad_valid, pad_done;
reg sha_start;
wire sha_ready;
wire [159:0] sha_hash;
reg [1:0] state;
reg [159:0] hash_reg;
reg done_reg;
localparam IDLE = 2'd0, WAIT_PAD = 2'd1, WAIT_SHA = 2'd2;
sha1_padding u_padding (
.clk(clk), .rst_n(rst_n), .start(start),
.data_in(data_in), .msg_len(msg_len),
.block_out(padded_block), .valid(pad_valid), .done(pad_done)
);

sha_design u_sha_core (
.clk(clk), .rst(rst_n), .start(sha_start),
.block_in(padded_block),
.hash_out(sha_hash), .ready(sha_ready)
);
assign hash_out = hash_reg;
assign done = done_reg;
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
state <= IDLE;
sha_start <= 0;
hash_reg <= 0;
done_reg <= 0;
end else begin
sha_start <= 0;
done_reg <= 0;
case (state)
IDLE: if (start) state <= WAIT_PAD;
WAIT_PAD: begin
if (pad_valid) begin
sha_start <= 1;
state <= WAIT_SHA;
end
end
WAIT_SHA: begin
if (sha_ready) begin
hash_reg <= sha_hash;
done_reg <= 1;
state <= IDLE;
end
end
endcase
end
end
endmodule



