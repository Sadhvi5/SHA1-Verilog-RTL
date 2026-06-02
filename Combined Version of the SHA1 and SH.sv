Combined Version of the SHA1 and SHA256:
//==========================================
// Unified SHA Core Design Module (SHA-1 & SHA-256)
//==========================================
module parametrised_sha_design #(
parameter BLOCK_WIDTH = 512,
parameter HASH_WIDTH = 160, // 160 for SHA-1, 256 for SHA-256
parameter WORD_WIDTH = 32,
parameter NUM_ROUNDS = 80, // 80 for SHA-1, 64 for SHA-256
parameter ROUND_WIDTH = 7,
parameter STATE_WIDTH = 3,
parameter ALGORITHM = "SHA1" // "SHA1" or "SHA256"
)(
input wire clk,
input wire rst_n,
input wire start,
input wire [BLOCK_WIDTH-1:0] block_in,
output reg [HASH_WIDTH-1:0] hash_out,
output reg ready
);
localparam NUM_WORDS = BLOCK_WIDTH / WORD_WIDTH;
localparam NUM_HASH_WORDS = HASH_WIDTH / WORD_WIDTH;
// SHA-1 Constants
localparam [WORD_WIDTH-1:0] K1_0 = 32'h5a827999;
localparam [WORD_WIDTH-1:0] K1_1 = 32'h6ed9eba1;
localparam [WORD_WIDTH-1:0] K1_2 = 32'h8f1bbcdc;
localparam [WORD_WIDTH-1:0] K1_3 = 32'hca62c1d6;
// SHA-256 K constants - using function instead of array for Verilog compatibility
function [WORD_WIDTH-1:0] get_K256;
input [5:0] index;
begin
case (index)
6'd0: get_K256 = 32'h428a2f98;
6'd1: get_K256 = 32'h71374491;
6'd2: get_K256 = 32'hb5c0fbcf;
6'd3: get_K256 = 32'he9b5dba5;
6'd4: get_K256 = 32'h3956c25b;
6'd5: get_K256 = 32'h59f111f1;
6'd6: get_K256 = 32'h923f82a4;
6'd7: get_K256 = 32'hab1c5ed5;
6'd8: get_K256 = 32'hd807aa98;
6'd9: get_K256 = 32'h12835b01;
6'd10: get_K256 = 32'h243185be;
6'd11: get_K256 = 32'h550c7dc3;
6'd12: get_K256 = 32'h72be5d74;
6'd13: get_K256 = 32'h80deb1fe;
6'd14: get_K256 = 32'h9bdc06a7;
6'd15: get_K256 = 32'hc19bf174;
6'd16: get_K256 = 32'he49b69c1;
6'd17: get_K256 = 32'hefbe4786;
6'd18: get_K256 = 32'h0fc19dc6;
6'd19: get_K256 = 32'h240ca1cc;
6'd20: get_K256 = 32'h2de92c6f;
6'd21: get_K256 = 32'h4a7484aa;
6'd22: get_K256 = 32'h5cb0a9dc;
6'd23: get_K256 = 32'h76f988da;
6'd24: get_K256 = 32'h983e5152;
6'd25: get_K256 = 32'ha831c66d;
6'd26: get_K256 = 32'hb00327c8;
6'd27: get_K256 = 32'hbf597fc7;
6'd28: get_K256 = 32'hc6e00bf3;
6'd29: get_K256 = 32'hd5a79147;
6'd30: get_K256 = 32'h06ca6351;
6'd31: get_K256 = 32'h14292967;
6'd32: get_K256 = 32'h27b70a85;
6'd33: get_K256 = 32'h2e1b2138;
6'd34: get_K256 = 32'h4d2c6dfc;
6'd35: get_K256 = 32'h53380d13;
6'd36: get_K256 = 32'h650a7354;
6'd37: get_K256 = 32'h766a0abb;
6'd38: get_K256 = 32'h81c2c92e;
6'd39: get_K256 = 32'h92722c85;
6'd40: get_K256 = 32'ha2bfe8a1;
6'd41: get_K256 = 32'ha81a664b;
6'd42: get_K256 = 32'hc24b8b70;
6'd43: get_K256 = 32'hc76c51a3;
6'd44: get_K256 = 32'hd192e819;
6'd45: get_K256 = 32'hd6990624;
6'd46: get_K256 = 32'hf40e3585;
6'd47: get_K256 = 32'h106aa070;
6'd48: get_K256 = 32'h19a4c116;
6'd49: get_K256 = 32'h1e376c08;
6'd50: get_K256 = 32'h2748774c;
6'd51: get_K256 = 32'h34b0bcb5;
6'd52: get_K256 = 32'h391c0cb3;
6'd53: get_K256 = 32'h4ed8aa4a;
6'd54: get_K256 = 32'h5b9cca4f;
6'd55: get_K256 = 32'h682e6ff3;
6'd56: get_K256 = 32'h748f82ee;
6'd57: get_K256 = 32'h78a5636f;
6'd58: get_K256 = 32'h84c87814;
6'd59: get_K256 = 32'h8cc70208;
6'd60: get_K256 = 32'h90befffa;
6'd61: get_K256 = 32'ha4506ceb;
6'd62: get_K256 = 32'hbef9a3f7;
6'd63: get_K256 = 32'hc67178f2;
default: get_K256 = 32'h00000000;
endcase
end
endfunction
// SHA-1 Initial Hash Values
localparam [WORD_WIDTH-1:0] H1_0_INIT = 32'h67452301;
localparam [WORD_WIDTH-1:0] H1_1_INIT = 32'hefcdab89;
localparam [WORD_WIDTH-1:0] H1_2_INIT = 32'h98badcfe;
localparam [WORD_WIDTH-1:0] H1_3_INIT = 32'h10325476;
localparam [WORD_WIDTH-1:0] H1_4_INIT = 32'hc3d2e1f0;
// SHA-256 Initial Hash Values
localparam [WORD_WIDTH-1:0] H256_0_INIT = 32'h6a09e667;
localparam [WORD_WIDTH-1:0] H256_1_INIT = 32'hbb67ae85;
localparam [WORD_WIDTH-1:0] H256_2_INIT = 32'h3c6ef372;
localparam [WORD_WIDTH-1:0] H256_3_INIT = 32'ha54ff53a;
localparam [WORD_WIDTH-1:0] H256_4_INIT = 32'h510e527f;
localparam [WORD_WIDTH-1:0] H256_5_INIT = 32'h9b05688c;
localparam [WORD_WIDTH-1:0] H256_6_INIT = 32'h1f83d9ab;
localparam [WORD_WIDTH-1:0] H256_7_INIT = 32'h5be0cd19;
localparam [STATE_WIDTH-1:0] IDLE = 3'd0;
localparam [STATE_WIDTH-1:0] EXPAND = 3'd1;
localparam [STATE_WIDTH-1:0] COMPUTE = 3'd2;
localparam [STATE_WIDTH-1:0] FINALIZE = 3'd3;
reg [STATE_WIDTH-1:0] state;
reg [ROUND_WIDTH-1:0] round;
// Working variables (SHA-256 uses A-H, SHA-1 uses A-E)
reg [WORD_WIDTH-1:0] A, B, C, D, E, F, G, H;
reg [WORD_WIDTH-1:0] H0, H1, H2, H3, H4, H5, H6, H7;
reg [WORD_WIDTH-1:0] W [0:NUM_ROUNDS-1];
reg [WORD_WIDTH-1:0] temp1, temp2;
integer i;
// SHA-1 ROTL function
function [WORD_WIDTH-1:0] ROTL;
input [WORD_WIDTH-1:0] x;
input [4:0] n;
begin
ROTL = (x << n) | (x >> (WORD_WIDTH - n));
end
endfunction
// SHA-256 ROTR function
function [WORD_WIDTH-1:0] ROTR;
input [WORD_WIDTH-1:0] x;
input [4:0] n;
begin
ROTR = (x >> n) | (x << (WORD_WIDTH - n));
end
endfunction
// SHA-256 functions
function [WORD_WIDTH-1:0] Ch;
input [WORD_WIDTH-1:0] x, y, z;
begin
Ch = (x & y) ^ ((~x) & z);
end
endfunction
function [WORD_WIDTH-1:0] Maj;
input [WORD_WIDTH-1:0] x, y, z;
begin
Maj = (x & y) ^ (x & z) ^ (y & z);
end
endfunction
function [WORD_WIDTH-1:0] Sigma0;
input [WORD_WIDTH-1:0] x;
begin
Sigma0 = ROTR(x, 5'd2) ^ ROTR(x, 5'd13) ^ ROTR(x, 5'd22);
end
endfunction
function [WORD_WIDTH-1:0] Sigma1;
input [WORD_WIDTH-1:0] x;
begin
Sigma1 = ROTR(x, 5'd6) ^ ROTR(x, 5'd11) ^ ROTR(x, 5'd25);
end
endfunction
function [WORD_WIDTH-1:0] sigma0;
input [WORD_WIDTH-1:0] x;
begin
sigma0 = ROTR(x, 5'd7) ^ ROTR(x, 5'd18) ^ (x >> 3);
end
endfunction
function [WORD_WIDTH-1:0] sigma1;
input [WORD_WIDTH-1:0] x;
begin
sigma1 = ROTR(x, 5'd17) ^ ROTR(x, 5'd19) ^ (x >> 10);
end
endfunction
// SHA-1 f function
function [WORD_WIDTH-1:0] f_func;
input [ROUND_WIDTH-1:0] t;
input [WORD_WIDTH-1:0] b, c, d;
begin
if (t < 20)
f_func = (b & c) | ((~b) & d);
else if (t < 40)
f_func = b ^ c ^ d;
else if (t < 60)
f_func = (b & c) | (b & d) | (c & d);
else
f_func = b ^ c ^ d;
end
endfunction
// SHA-1 k constant
function [WORD_WIDTH-1:0] k_const;
input [ROUND_WIDTH-1:0] t;
begin
if (t < 20)
k_const = K1_0;
else if (t < 40)
k_const = K1_1;
else if (t < 60)
k_const = K1_2;
else
k_const = K1_3;
end
endfunction
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
state <= IDLE;
ready <= 1'b0;
round <= 0;
A <= 0; B <= 0; C <= 0; D <= 0;
E <= 0; F <= 0; G <= 0; H <= 0;
H0 <= 0; H1 <= 0; H2 <= 0; H3 <= 0;
H4 <= 0; H5 <= 0; H6 <= 0; H7 <= 0;
hash_out <= 0;
for (i = 0; i < NUM_ROUNDS; i = i + 1)
W[i] <= 0;
end else begin
case (state)
IDLE: begin
ready <= 1'b0;
if (start) begin
// Initialize hash values based on algorithm
if (ALGORITHM == "SHA1") begin
H0 <= H1_0_INIT;
H1 <= H1_1_INIT;
H2 <= H1_2_INIT;
H3 <= H1_3_INIT;
H4 <= H1_4_INIT;
A <= H1_0_INIT;
B <= H1_1_INIT;
C <= H1_2_INIT;
D <= H1_3_INIT;
E <= H1_4_INIT;
end else begin // SHA256
H0 <= H256_0_INIT;
H1 <= H256_1_INIT;
H2 <= H256_2_INIT;
H3 <= H256_3_INIT;
H4 <= H256_4_INIT;
H5 <= H256_5_INIT;
H6 <= H256_6_INIT;
H7 <= H256_7_INIT;
A <= H256_0_INIT;
B <= H256_1_INIT;
C <= H256_2_INIT;
D <= H256_3_INIT;
E <= H256_4_INIT;
F <= H256_5_INIT;
G <= H256_6_INIT;
H <= H256_7_INIT;
end
// Load 16 words
for (i = 0; i < NUM_WORDS; i = i + 1) begin
W[i] <= block_in[BLOCK_WIDTH-1 - i*WORD_WIDTH -:
WORD_WIDTH];
end
round <= NUM_WORDS;
state <= EXPAND;
end
end
EXPAND: begin
if (round < NUM_ROUNDS) begin
if (ALGORITHM == "SHA1") begin
// SHA-1 message schedule
W[round] <= ROTL(W[round-3] ^ W[round-8] ^ W[round-14] ^ W[round55
16], 5'd1);
W[round-16];
end else begin
// SHA-256 message schedule
W[round] <= sigma1(W[round-2]) + W[round-7] + sigma0(W[round-15]) +
end
round <= round + 1;
end else begin
round <= 0;
state <= COMPUTE;
end
end
COMPUTE: begin
if (ALGORITHM == "SHA1") begin
// SHA-1 compression
temp1 = ROTL(A, 5'd5) + f_func(round, B, C, D) + E + k_const(round) +
W[round];
E <= D;
D <= C;
C <= ROTL(B, 5'd30);
B <= A;
A <= temp1;
end else begin
// SHA-256 compression
temp1 = H + Sigma1(E) + Ch(E, F, G) + get_K256(round[5:0]) + W[round];
temp2 = Sigma0(A) + Maj(A, B, C);
H <= G;
G <= F;
F <= E;
E <= D + temp1;
D <= C;
C <= B;
B <= A;
A <= temp1 + temp2;
end
if (round == NUM_ROUNDS - 1) begin
state <= FINALIZE;
end else begin
round <= round + 1;
end
end
+ H};
FINALIZE: begin
if (ALGORITHM == "SHA1") begin
H0 <= H0 + A;
H1 <= H1 + B;
H2 <= H2 + C;
H3 <= H3 + D;
H4 <= H4 + E;
hash_out <= {H0 + A, H1 + B, H2 + C, H3 + D, H4 + E};
end else begin
H0 <= H0 + A;
H1 <= H1 + B;
H2 <= H2 + C;
H3 <= H3 + D;
H4 <= H4 + E;
H5 <= H5 + F;
H6 <= H6 + G;
H7 <= H7 + H;
hash_out <= {H0 + A, H1 + B, H2 + C, H3 + D, H4 + E, H5 + F, H6 + G, H7
end
ready <= 1'b1;
state <= IDLE;
end
default: state <= IDLE;
endcase
end
end
endmodule
//==========================================
// Unified SHA Testbench with DEBUG
//==========================================
module tb_sha_debug;
parameter CLK_PERIOD = 10;
parameter HASH_WIDTH = 160; // 160 for SHA-1, 256 for SHA-256
parameter DATA_WIDTH = 1024;
parameter NUM_ROUNDS = 80; // 80 for SHA-1, 64 for SHA-256
reg clk, rst_n;
reg start;
wire [HASH_WIDTH-1:0] hash_out;
wire done;
integer test_count = 0;
integer pass_count = 0;
integer fail_count = 0;
// Test configuration
localparam TEST_STRING = "Baranika";
localparam TEST_LEN = 8;
localparam ALGORITHM = "SHA1"; // "SHA1" or "SHA256"
function [DATA_WIDTH-1:0] string_to_hex;
input [1024*8-1:0] str;
input integer len;
integer i;
reg [DATA_WIDTH-1:0] result;
begin
result = {DATA_WIDTH{1'b0}};
for (i = 0; i < len; i = i + 1) begin
result[DATA_WIDTH-1 - i*8 -: 8] = str[(len-1-i)*8 +: 8];
end
string_to_hex = result;
end
endfunction
localparam [DATA_WIDTH-1:0] TEST_DATA = string_to_hex(TEST_STRING,
TEST_LEN);
initial begin
clk = 0;
forever #(CLK_PERIOD/2) clk = ~clk;
end
parametrised_sha_top #(
.MSG_LEN(TEST_LEN),
.MESSAGE_DATA(TEST_DATA),
.HASH_WIDTH(HASH_WIDTH),
.NUM_ROUNDS(NUM_ROUNDS),
.ALGORITHM(ALGORITHM)
) dut (
.clk(clk),
.rst_n(rst_n),
.start(start),
.hash_out(hash_out),
.done(done)
);
initial begin
$monitor("Time=%0t | start=%b | state=%0d | pad_valid=%b | sha_ready=%b |
done=%b",
$time, start, dut.state, dut.pad_valid, dut.sha_ready, done);
end
initial begin
wait(dut.pad_valid);
@(posedge clk);
$display("\n=== PADDING BLOCK DEBUG ===");
$display("Algorithm: %s", ALGORITHM);
$display("Test string: '%s'", TEST_STRING);
$display("Padded block (hex): %h", dut.padded_block);
$display("===========================\n");
end
initial begin
$dumpfile("sha_debug.vcd");
$dumpvars(0, tb_sha_debug);
$display("\n=========================================================
=======================");
$display("%s Test: '%s' (%0d bytes)", ALGORITHM, TEST_STRING, TEST_LEN);
$display("==========================================================
======================\n");
rst_n = 1'b0;
start = 1'b0;
repeat(5) @(posedge clk);
rst_n = 1'b1;
repeat(5) @(posedge clk);
$display("Starting test...\n");
start = 1'b1;
@(posedge clk);
start = 1'b0;
repeat(500) begin
@(posedge clk);
if (done) begin
test_count = test_count + 1;
$display("\nTest completed!");
$display("Input String: '%s'", TEST_STRING);
$display("%s Hash: %h", ALGORITHM, hash_out);
pass_count = pass_count + 1;
$display("\n=========================================================
=======================");
$display("Test Summary: %0d total, %0d passed, %0d failed", test_count,
pass_count, fail_count);
$display("==========================================================
======================\n");
$finish;
end
end
$display("\n TIMEOUT - Test did not complete");
fail_count = fail_count + 1;
$finish;
end
initial begin
#50000;
$display(“/n Global Timeout”);
$finish;
end
endmodule
//==========================================
// Unified SHA Padding Module
//==========================================
module parametrised_sha_padding #(
parameter DATA_WIDTH = 1024,
parameter BLOCK_WIDTH = 512,
parameter MSG_LEN_WIDTH = 80,
parameter BLOCK_NUM_WIDTH = 20,
parameter LEN_FIELD_BITS = 64
)(
input wire clk,
input wire rst_n,
input wire start,
input wire [DATA_WIDTH-1:0] data_in,
input wire [MSG_LEN_WIDTH-1:0] msg_len,
output reg [BLOCK_WIDTH-1:0] block_out,
output reg valid,
output reg done,
output reg [BLOCK_NUM_WIDTH-1:0] block_num,
output reg [BLOCK_NUM_WIDTH-1:0] total_blocks
);
localparam BYTES_PER_BLOCK = BLOCK_WIDTH / 8;
reg [2:0] state;
localparam IDLE = 3'd0;
localparam CALC = 3'd1;
localparam OUTPUT = 3'd2;
localparam DONE_STATE = 3'd3;
reg [MSG_LEN_WIDTH-1:0] byte_len;
reg [LEN_FIELD_BITS-1:0] bit_len;
integer i;
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
state <= IDLE;
block_out <= {BLOCK_WIDTH{1'b0}};
valid <= 1'b0;
done <= 1'b0;
block_num <= {BLOCK_NUM_WIDTH{1'b0}};
total_blocks <= {BLOCK_NUM_WIDTH{1'b0}};
byte_len <= {MSG_LEN_WIDTH{1'b0}};
bit_len <= {LEN_FIELD_BITS{1'b0}};
end else begin
case (state)
IDLE: begin
valid <= 1'b0;
done <= 1'b0;
block_num <= {BLOCK_NUM_WIDTH{1'b0}};
if (start) begin
byte_len <= msg_len >> 3;
bit_len <= msg_len[LEN_FIELD_BITS-1:0];
total_blocks <= 1;
state <= CALC;
end
end
i*8 -: 8];
CALC: begin
// Copy message and add padding (same for both SHA-1 and SHA-256)
for (i = 0; i < 56; i = i + 1) begin
if (i < byte_len)
block_out[BLOCK_WIDTH-1 - i*8 -: 8] <= data_in[DATA_WIDTH-1 -
else if (i == byte_len)
block_out[BLOCK_WIDTH-1 - i*8 -: 8] <= 8'h80;
else
block_out[BLOCK_WIDTH-1 - i*8 -: 8] <= 8'h00;
end
// Add 64-bit length at end (big-endian)
block_out[63:56] <= bit_len[63:56];
block_out[55:48] <= bit_len[55:48];
block_out[47:40] <= bit_len[47:40];
block_out[39:32] <= bit_len[39:32];
block_out[31:24] <= bit_len[31:24];
block_out[23:16] <= bit_len[23:16];
block_out[15:8] <= bit_len[15:8];
block_out[7:0] <= bit_len[7:0];
block_num <= {BLOCK_NUM_WIDTH{1'b0}};
state <= OUTPUT;
end
OUTPUT: begin
valid <= 1'b1;
state <= DONE_STATE;
end
DONE_STATE: begin
valid <= 1'b0;
done <= 1'b1;
if (!start) begin
state <= IDLE;
end
end
default: state <= IDLE;
endcase
end
end
endmodule
//==========================================
// Unified SHA Top Module
//==========================================
module parametrised_sha_top #(
parameter DATA_WIDTH = 1024,
parameter BLOCK_WIDTH = 512,
parameter HASH_WIDTH = 160, // 160 for SHA-1, 256 for SHA-256
parameter MSG_LEN_WIDTH = 80,
parameter BLOCK_NUM_WIDTH = 20,
parameter WORD_WIDTH = 32,
parameter NUM_ROUNDS = 80, // 80 for SHA-1, 64 for SHA-256
parameter ROUND_WIDTH = 7,
parameter STATE_WIDTH = 3,
parameter MSG_LEN = 3,
parameter [DATA_WIDTH-1:0] MESSAGE_DATA = 1024'h616263,
parameter ALGORITHM = "SHA1" // "SHA1" or "SHA256"
)(
input wire clk,
input wire rst_n,
input wire start,
output reg [HASH_WIDTH-1:0] hash_out,
output reg done
);
wire [DATA_WIDTH-1:0] data_in = MESSAGE_DATA;
wire [MSG_LEN_WIDTH-1:0] msg_len = MSG_LEN * 8;
wire [BLOCK_WIDTH-1:0] padded_block;
wire pad_valid;
wire pad_done;
wire [BLOCK_NUM_WIDTH-1:0] block_num;
wire [BLOCK_NUM_WIDTH-1:0] total_blocks;
reg sha_start;
wire [HASH_WIDTH-1:0] sha_hash;
wire sha_ready;
reg [HASH_WIDTH-1:0] hash_reg;
reg [BLOCK_WIDTH-1:0] captured_block;
reg [2:0] state;
localparam IDLE = 3'd0;
localparam WAIT_VALID = 3'd1;
localparam START_SHA = 3'd2;
localparam WAIT_SHA = 3'd3;
localparam DONE_STATE = 3'd4;
parametrised_sha_padding #(
.DATA_WIDTH(DATA_WIDTH),
.BLOCK_WIDTH(BLOCK_WIDTH),
.MSG_LEN_WIDTH(MSG_LEN_WIDTH),
.BLOCK_NUM_WIDTH(BLOCK_NUM_WIDTH),
.LEN_FIELD_BITS(64)
) u_padding (
.clk(clk),
.rst_n(rst_n),
.start(start),
.data_in(data_in),
.msg_len(msg_len),
.block_out(padded_block),
.valid(pad_valid),
.done(pad_done),
.block_num(block_num),
.total_blocks(total_blocks)
66
);
parametrised_sha_design #(
.BLOCK_WIDTH(BLOCK_WIDTH),
.HASH_WIDTH(HASH_WIDTH),
.WORD_WIDTH(WORD_WIDTH),
.NUM_ROUNDS(NUM_ROUNDS),
.ROUND_WIDTH(ROUND_WIDTH),
.STATE_WIDTH(STATE_WIDTH),
.ALGORITHM(ALGORITHM)
) u_sha_core (
.clk(clk),
.rst_n(rst_n),
.start(sha_start),
.block_in(captured_block),
.hash_out(sha_hash),
.ready(sha_ready)
);
always @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
state <= IDLE;
sha_start <= 1'b0;
done <= 1'b0;
hash_out <= {HASH_WIDTH{1'b0}};
hash_reg <= {HASH_WIDTH{1'b0}};
captured_block <= {BLOCK_WIDTH{1'b0}};
end else begin
case (state)
IDLE: begin
sha_start <= 1'b0;
done <= 1'b0;
if (start) begin
state <= WAIT_VALID;
end
end
WAIT_VALID: begin
if (pad_valid) begin
captured_block <= padded_block;
state <= START_SHA;
end
end
START_SHA: begin
sha_start <= 1'b1;
state <= WAIT_SHA;
end
WAIT_SHA: begin
sha_start <= 1'b0;
if (sha_ready) begin
hash_reg <= sha_hash;
hash_out <= sha_hash;
state <= DONE_STATE;
end
end
DONE_STATE: begin
done <= 1'b1;
if (!start) begin
state <= IDLE;
end
end
default: state <= IDLE;
endcase
end
end
endmodule
//
==================================================================
==============
// HOW TO USE THIS UNIFIED SHA MODULE
//
==================================================================
==============
//
// To switch between SHA-1 and SHA-256, change these parameters:
//
// FOR SHA-1:
// parameter HASH_WIDTH = 160
// parameter NUM_ROUNDS = 80
// parameter ALGORITHM = "SHA1"
//
// FOR SHA-256:
// parameter HASH_WIDTH = 256
// parameter NUM_ROUNDS = 64
// parameter ALGORITHM = "SHA256"
//
// Example test for "abc":
// SHA-1: a9993e364706816aba3e25717850c26c9cd0d89d
// SHA-256: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
//
//
===========================================================================
=====

