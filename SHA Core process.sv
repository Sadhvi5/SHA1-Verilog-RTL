    SHA Core process : 
module sha_design (
input wire clk,
input wire rst,
input wire start,
input wire [511:0] block_in,
output reg [159:0] hash_out,
output reg ready
);
localparam [31:0] K0 = 32'h5a827999;
localparam [31:0] K1 = 32'h6ed9eba1;
localparam [31:0] K2 = 32'h8f1bbcdc;
localparam [31:0] K3 = 32'hca62c1d6;
localparam [31:0] H0_INIT = 32'h67452301;
localparam [31:0] H1_INIT = 32'hefcdab89;
localparam [31:0] H2_INIT = 32'h98badcfe;
localparam [31:0] H3_INIT = 32'h10325476;
localparam [31:0] H4_INIT = 32'hc3d2e1f0;
localparam [1:0] IDLE = 2'd0, EXPAND = 2'd1, COMPUTE = 2'd2, FINALIZE = 2'd3;
reg [1:0] state;
reg [6:0] round;
reg [31:0] A, B, C, D, E;
reg [31:0] H0, H1, H2, H3, H4;
reg [31:0] W [0:79];
// Declare temp variables at module level for Verilog compatibility
reg [31:0] temp, f, k;
integer i;
function [31:0] ROTL;
input [31:0] x;
input [4:0] n;
ROTL = (x << n) | (x >> (32 - n));
endfunction
always @(posedge clk or negedge rst) begin
if (!rst) begin
state <= IDLE;
ready <= 0;
round <= 0;
A <= 0; B <= 0; C <= 0; D <= 0; E <= 0;
H0 <= H0_INIT;
H1 <= H1_INIT;
H2 <= H2_INIT;
H3 <= H3_INIT;
H4 <= H4_INIT;
hash_out <= 160'h0;
for (i = 0; i < 80; i = i + 1) W[i] <= 32'h0;
end else begin
case (state)
IDLE: begin
ready <= 0;
if (start) begin
// Load W[0..15] from input block
W[0] <= block_in[511:480];
W[1] <= block_in[479:448];
W[2] <= block_in[447:416];
W[3] <= block_in[415:384];
W[4] <= block_in[383:352];
W[5] <= block_in[351:320];
W[6] <= block_in[319:288];
W[7] <= block_in[287:256];
W[8] <= block_in[255:224];
W[9] <= block_in[223:192];
W[10] <= block_in[191:160];
W[11] <= block_in[159:128];
W[12] <= block_in[127:96];
W[13] <= block_in[95:64];
W[14] <= block_in[63:32];
W[15] <= block_in[31:0];
// Initialize hash values
H0 <= H0_INIT;
H1 <= H1_INIT;
H2 <= H2_INIT;
H3 <= H3_INIT;
H4 <= H4_INIT;
// Initialize working variables
A <= H0_INIT;
B <= H1_INIT;
C <= H2_INIT;
29
D <= H3_INIT;
E <= H4_INIT;
round <= 16;
state <= EXPAND;
end
end
1);
EXPAND: begin
if (round < 80) begin
W[round] <= ROTL(W[round-3] ^ W[round-8] ^ W[round-14] ^ W[round-16],
round <= round + 1;
end else begin
round <= 0;
state <= COMPUTE;
end
end
COMPUTE: begin
// Compression function - calculate f and k based on round
if (round < 20) begin
f = (B & C) | ((~B) & D);
k = K0;
end else if (round < 40) begin
f = B ^ C ^ D;
k = K1;
end else if (round < 60) begin
f = (B & C) | (B & D) | (C & D);
k = K2;
end else begin
f = B ^ C ^ D;
k = K3;
end
temp = ROTL(A, 5) + f + E + k + W[round];
// Update working variables
E <= D;
D <= C;
C <= ROTL(B, 30);
B <= A;
A <= temp;
if (round == 79) begin
// Move to finalization state after last round
state <= FINALIZE;
end else begin
round <= round + 1;
end
end
FINALIZE: begin
// Add working variables to hash values
H0 <= H0 + A;
H1 <= H1 + B;
H2 <= H2 + C;
H3 <= H3 + D;
H4 <= H4 + E;
hash_out <= {H0 + A, H1 + B, H2 + C, H3 + D, H4 + E};
ready <= 1;
state <= IDLE;
end
endcase
end
end
endmodule

