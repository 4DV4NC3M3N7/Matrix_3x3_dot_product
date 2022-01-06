module connect_tb
();

reg 			clk,clr;
wire	[31:0]	ram_output,ram_input;
wire    [6:0]   ram_addr,
wire            ready,busy,done,ram_we


connect a( .clk(clk), .clr(clr), .ram_output(ram_output), .ram_input(ram_input), .ram_addr(ram_addr), .ready(ready), .busy(busy), .done(done), .ram_we(ram_we));

initial begin
clk='b1;
repeat(4) #10 clk = ~clk;
forever #10 clk = ~clk;
end

initial begin
#10 reset='b0;
#10 reset='b1;
//#10 reset='b1;
#10 reset='b0;
//$finish;
end



endmodule


module connect
(
    input           clk,clr,
    output [31:0]   ram_output,ram_input,
    output [6:0]    ram_addr,
    output          ready,busy,done,ram_we
);
controller a( .clr(clr), .clk(clr), .ready(ready), .busy(busy), .done(done), .we(ram_we), .pc(ram_addr));

single_port_ram b( .data(ram_input), .addr(ram_addr), .we(ram_we), .clk(clk), .q(ram_output))

matrix c()//input a ,b = ram_output; ready=ready; busy=busy; done=done; output matrix=ram_input


endmodule


module single_port_ram
(
	input [31:0]   data,
	input [6:0]    addr,
	input          we, clk,
	output [31:0]  q
);

	// Declare the RAM variable
	reg [31:0] ram[127:0];

	// Variable to hold the registered read address


	always @ (posedge clk)
	begin
	// Write
		if (we)
			ram[addr] <= data;

	end

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.
	assign q = ram[addr];


	initial begin
		ram[0]=32'hA1EE0007; ///load r1 7
		ram[1]=32'hA2EE0003; ///load r2 3
		ram[2]=32'h30120000; ///add  r0 r1 r2
		ram[3]=32'h13FE0002; ///input r3=M[6]
		ram[4]=32'h44030000;	///sub r4 r0 r3
		ram[5]=32'h7FFE0002; ///j_z pc=pc+2
		ram[6]=32'h0000000A; ///M[6]=10
		ram[7]=32'h20FE0001;	///output M[9]=r0
		ram[8]=32'hA5EE0007; ///load r5 7
	end


endmodule


module controller
(
    input							clr,clk,ready,busy,done,
    output                          we,
    output              [6:0]       pc
);

wire            en_input,en_output,select_pc;
wire    [6:0]   pc_in,pc_out,pc_in_temp,pc_out_temp,pc_in_increment,pc_out_increment;
wire            limit,op;

assign en_input=ready;
assign en_output=done;

general_register IN ( .D(pc_in), .clr('b0), .clk(clk), .en(en_input),  .Q(pc_in_temp));				     //PC_input
general_register OUT( .D(pc_out), .clr('b0), .clk(clk), .en(en_output), .Q(pc_out_temp));			    //PC_output


adder_7bit in ( .a(pc_in_temp),  .b(ready), .cin('b0), .sum(pc_in_increment));
adder_7bit out( .a(pc_out_temp), .b(done), .cin('b0), .sum(pc_out_increment));

assign limit    =(pc_in_increment&'b1000000)|(pc_out_increment&'b0)|clr;

assign pc_in    =limit?('b0:pc_in_increment);
assign pc_out   =limit?('b1000000:pc_out_increment);

assign op=ready;

assign pc=op?(pc_in_temp:pc_out_temp);

endmodule

module general_register
(
	input					[31:0]		D,
	input								clr,clk,en,
	output	reg		       [31:0]		Q
);

always @ (posedge clk or posedge clr) begin
if(clr) Q<='b0;
else begin
	if (en==1) Q<=D;
end
end

endmodule

///////////////////////FULL ADDER////////////////////////////

module adder_7bit
(
	input		[6:0]		a,b,
	input					cin,
	output	    [6:0]		sum
);
wire			[6:0]		cout;

adder a0  (.a(a[0]),  .b(b[0]),  .cin(cin),      .sum(sum[0]),  .cout(cout[0]));
adder a1  (.a(a[1]),  .b(b[1]),  .cin(cout[0]),  .sum(sum[1]),  .cout(cout[1]));
adder a2  (.a(a[2]),  .b(b[2]),  .cin(cout[1]),  .sum(sum[2]),  .cout(cout[2]));
adder a3  (.a(a[3]),  .b(b[3]),  .cin(cout[2]),  .sum(sum[3]),  .cout(cout[3]));
adder a4  (.a(a[4]),  .b(b[4]),  .cin(cout[3]),  .sum(sum[4]),  .cout(cout[4]));
adder a5  (.a(a[5]),  .b(b[5]),  .cin(cout[4]),  .sum(sum[5]),  .cout(cout[5]));
adder a6  (.a(a[6]),  .b(b[6]),  .cin(cout[5]),  .sum(sum[6]),  .cout(cout[6]));

endmodule

/////////////half adder//////////////////////

module adder
(
	input				a,b,cin,
	output			sum,cout
);

assign sum=(a^b)^cin;
assign cout=((a^b)&cin)|a&b;

endmodule
