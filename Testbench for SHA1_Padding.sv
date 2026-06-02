Testbench for SHA1_Padding:

module tb_sha1_padding;
reg clk, rst_n, start;
reg [1023:0] data_in;
reg [31:0] msg_len;
wire [511:0] block_out;
wire valid, done;
// Instantiate the padding module - matching exact ports from sha1_padding.sv
sha1_padding uut (
.clk(clk),
.rst_n(rst_n),
.start(start),
.data_in(data_in),
.msg_len(msg_len),
.block_out(block_out),
.valid(valid),
.done(done)
);
initial clk = 0;
always #5 clk = ~clk;
// Task to load a string into data_in
task load_string;
input [1023:0] str;
input integer str_len;
integer i;
reg [7:0] c;
begin
data_in = 1024'h0;
for (i = 0; i < str_len; i = i + 1) begin
c = (str >> ((str_len - 1 - i) * 8)) & 8'hFF;
data_in[1023 - i*8 -: 8] = c;
end
end
endtask
// Task to display block_out in hex format (16 words of 32-bits each)
task display_block;
integer i;
begin
$display("Padded block (512 bits / 64 bytes / 16 words):");
for (i = 0; i < 16; i = i + 1) begin
$display(" W[%2d] = %08h", i, block_out[511 - i*32 -: 32]);
end

end
endtask
// Task to display block_out as bytes
task display_bytes;
integer i;
begin
$display("Padded block (as bytes):");
$write(" ");
for (i = 0; i < 64; i = i + 1) begin
$write("%02h ", block_out[511 - i*8 -: 8]);
if ((i + 1) % 16 == 0 && i != 63) $write("\n ");
end
$display("");
end
endtask
// Task to test padding
task test_padding;
input [127*8:0] msg_str;
input integer str_len;
begin
$display("\n========================================");
$display("Test: '%0s' (%0d bytes = %0d bits)", msg_str, str_len, str_len * 8);
$display("========================================");
load_string(msg_str, str_len);
msg_len = str_len * 8;
@(posedge clk);
start = 1;
@(posedge clk);
start = 0;
wait(valid);
@(posedge clk);
display_block();
$display("");
display_bytes();
// Verify padding structure
$display("\nVerification:");
$display(" Message length field (last 8 bytes): %016h", block_out[63:0]);
$display(" Expected bit length: %0d (0x%0h)", str_len * 8, str_len * 8);
repeat(5) @(posedge clk);
end
endtask
initial begin
$dumpfile("sha1_padding.vcd");
$dumpvars(0, tb_sha1_padding);
rst_n = 0;
start = 0;
data_in = 0;
msg_len = 0;
repeat(5) @(posedge clk);
rst_n = 1;
repeat(5) @(posedge clk);
$display("\n");
$display("====================================================");
$display(" SHA-1 Padding Module Test Bench");
$display("====================================================");
// Test 1: "abc" - Standard test vector
test_padding("abc", 3);
// Test 2: Empty string
test_padding("", 0);
// Test 3: Single character
test_padding("a", 1);
// Test 4: Two characters
test_padding("ab", 2);
// Test 5: "message digest"
test_padding("message digest", 14);
// Test 6: Longer message
test_padding("The quick brown fox jumps over the lazy dog", 44);
// Test 7: 55 bytes (just fits in one block with padding)
test_padding("This is exactly fifty-five bytes for padding test!!", 55);
// Test 8: 56 bytes (requires second block in real implementation)
test_padding("This message is exactly fifty-six bytes for test case!!", 56);
$display("\n====================================================");
$display(" All Tests Completed");
$display("====================================================\n");
repeat(10) @(posedge clk);
$finish;
end
// Timeout watchdog
initial begin
#100000;
$display("\nERROR: Timeout!");
$finish;
end
endmodule


