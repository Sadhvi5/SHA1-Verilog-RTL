Testbench code for Overall SHA:
module tb_sha1_top1;
reg clk, rst_n, start;
reg [1023:0] data_in;
reg [31:0] msg_len;
wire [159:0] hash_out;
wire done;
sha1_top1 uut (.*);
initial clk = 0;
always #5 clk = ~clk;
task load_string;
input [1023:0] str;
input integer str_len;
integer i;
reg [7:0] c;
begin
data_in = 1024'h0;
for (i = 0; i < str_len; i = i + 1) begin
c = (str >> ((str_len - 1 - i) * 8)) & 8'hFF;
data_in = data_in | (c << (1016 - i*8));
end
end
endtask
task test_string;
input [1023:0] msg_str;
input integer str_len;
input [159:0] expected;
begin
$display("\nTest: %0s (%0d bytes)", msg_str, str_len);
load_string(msg_str, str_len);
msg_len = str_len * 8;
@(posedge clk); start = 1;
@(posedge clk); start = 0;
wait(done); @(posedge clk);
$display("Hash: %h", hash_out);
if (expected != 160'h0) begin
$display("Exp: %h", expected);
$display(hash_out == expected ? "PASS" : "FAIL");
end
repeat(10) @(posedge clk);
end
endtask
task hash_message;
input [1023:0] msg_str;
input integer str_len;
begin
test_string(msg_str, str_len, 160'h0);
end
endtask
initial begin
$dumpfile("sha1.vcd");
$dumpvars(0, tb_sha1_top1);
rst_n = 0; start = 0; data_in = 0; msg_len = 0;
repeat(5) @(posedge clk); rst_n = 1; repeat(5) @(posedge clk);
$display("\n======== SHA-1 Test Suite ========");
test_string("abc", 3, 160'ha9993e364706816aba3e25717850c26c9cd0d89d);
test_string("", 0, 160'hda39a3ee5e6b4b0d3255bfef95601890afd80709);
test_string("a", 1, 160'h86f7e437faa5a7fce15d1ddcb9eaeaea377667b8);
test_string("message digest", 14, 160'hc12252ceda8be8994d5fa0290a47231c1d16aae3);
$display("\n======== Custom Messages ========");
hash_message("Parvathavardhini Priya Sadhvi", 29);
hash_message("Baranika", 8);
$display("\n======== Done ========\n");
repeat(20) @(posedge clk);
$finish;
end
initial begin
#500000;
$display("\nTIMEOUT");
$finish;
end
endmodule

