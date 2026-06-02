 RTL Design code for SHA1_Padding:

module sha1_padding (
input wire clk,
input wire rst_n,
input wire start,
input wire [1023:0] data_in,
input wire [31:0] msg_len,
output reg [511:0] block_out,
output reg valid,
output reg done
);
//FSM Starts:
reg [1:0] state;
localparam IDLE = 2'd0, PROCESS = 2'd1, DONE_STATE = 2'd2;
integer i;
reg [31:0] byte_len; //message length in bytes
reg [63:0] bit_len;  //message length
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
state <= IDLE;
block_out <= 512'h0;
valid <= 0;
done <= 0;
end else begin
case (state)
//Idle state
IDLE: begin
valid <= 0;
done <= 0;
if (start) begin
byte_len <= msg_len >> 3; //convert bits to byte
bit_len <= {32'h0, msg_len}; // convert bit-len to 64 bits
state <= PROCESS;
end
End
//Process state
PROCESS: begin
// Initialize block to all zeros
block_out <= 512'h0;
// Copy message bytes - data_in is MSB first (big-endian layout)
for (i = 0; i < 64; i = i + 1) begin // 512 to bytes
if (i < byte_len) begin
// Copy byte from data_in to block_out
// data_in[1023:1016] is first byte, data_in[1015:1008] is second byte, etc.
// block_out[511:504] is first byte, block_out[503:496] is second byte, etc.
block_out[511 - i*8 -: 8] <= data_in[1023 - i*8 -: 8];
end
end
// Add padding bit(1) 0x80 immediately after message
if (byte_len < 64) begin
block_out[511 - byte_len*8 -: 8] <= 8'h80;
end
// Add message length in bits as 64-bit big-endian integer at the end
// Last 8 bytes 64 bits(bits 63:0) contain the length in big-endian format
// bit_len[63:56] goes to block_out[63:56] (most significant byte first)
block_out[63:56] <= bit_len[63:56];
block_out[55:48] <= bit_len[55:48];
block_out[47:40] <= bit_len[47:40];
block_out[39:32] <= bit_len[39:32];
block_out[31:24] <= bit_len[31:24];
block_out[23:16] <= bit_len[23:16];
block_out[15:8] <= bit_len[15:8];
block_out[7:0] <= bit_len[7:0];
valid <= 1;
done <= 1;
state <= DONE_STATE;
end
DONE_STATE: begin
valid <= 0;
if (!start) begin
done <= 0;
state <= IDLE;
end
end
endcase
end
end
endmodule

