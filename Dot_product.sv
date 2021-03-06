

//3x3 dot 3x3 matrix operation
/*
|a1 b1 c1| |d1 e1 f1|	|(a1.d1+b1.d2+c1.d3) (a1.e1+b1.e2+c1.e3) (a1.f1+b1.f2+c1.f3)|
|a2 b2 c2|.|d2 e2 f2|= 	|(a2.d1+b2.d2+c2.d3) (a2.e1+b2.e2+c2.e3) (a2.f1+b2.f2+c2.f3)|
|a3 b3 c3| |d3 e3 f3|	|(a3.d1+b3.d2+c3.d3) (a3.e1+b3.e2+c3.e3) (a3.f1+b3.f2+c3.f3)|
*/

module Dot_product(in,clk,reset,en,out,sel,done,ready);         //reset=reset the counter,data_RW= enabling data to be write into memory or not
	input clk,reset,en;
	input [31:0]in;
	wire 	[3:0]d,sel_wire,d_wire;
	output [3:0]sel;
	wire fsm_done;
	output [31:0] out;
	output ready,done;
	wire data_RW;
	wire [1:0]state_temp;

	assign data_RW=ready;
		assign sel_wire[0] = sel[0]&data_RW;
		assign sel_wire[1] = sel[1]&data_RW;
		assign sel_wire[2] = sel[2]&data_RW;
		assign sel_wire[3] = sel[3]&data_RW;
		//================================== 
		assign d_wire[3]=d[3]&~data_RW;
		assign d_wire[2]=d[2]&~data_RW;
		assign d_wire[1]=d[1]&~data_RW;
		assign d_wire[0]=d[0]&~data_RW;
		assign fsm_done = sel[3]&~sel[2]&~sel[1]&sel[0];
		assign ready=state_temp[0];
		assign done=state_temp[1];
		FSM fsm(
									.clk(clk),
									.reset(reset),
									.d(d),
									.sel(sel),
									.en(en)
				 ); 
		one_hot one( 
					.clk(fsm_done),
					.reset(reset),
					.state(state_temp)
				 );
		Dot_product_ dot(
									.in(in),
									.sel(d_wire),
									.mem_sel(sel_wire),
									.data_RW(data_RW),
									.clk(clk),
									.out(out)
						     );
endmodule  

//-------------------------------------------------------------------------------------------
 module Dot_product_(
									in,
									sel,
									mem_sel,
									data_RW,
									clk,
									out
						      );
	input [31:0]in;							
	wire  [1:0][15:0]			data_in;
	input 						data_RW,clk;//read is 1/ write is 0
	wire  [8:0][15:0]			left_data_out,right_data_out;
	input [3:0] 				sel;// selection  sel[1:0] for first 3x3 matrix sel[3:2] for second 3x3 matrix
	input [3:0] 				mem_sel;
	output[31:0]				out;
	wire  [5:0][15:0]			transfer;
	wire  [15:0][5:0]			transfer_rev;
	wire 	[15:0][17:0]		in_wire_rev;
	wire 	[17:0][15:0]		in_wire;

//-------------------------------------------------------------------------------------------
		assign data_in[1][15:0]=in[31:16];
		assign data_in[0][15:0]=in[15:0];
      Register left(//16bits input to memory
								.D(data_in[1][15:0]),
								.Data_RW(data_RW),
								.data_out(left_data_out),
								.select(mem_sel),
								.clk(clk)
						 ); 
		Register right(//16bits input to memory
								.D(data_in[0][15:0]),
								.Data_RW(data_RW),
								.data_out(right_data_out),
								.select(mem_sel),
								.clk(clk)
						  );
//-------------------------------------------------------------------------------------------	
		genvar i,j;
		generate
//-------------------------------------------------------------------------------------------
// interchange the wire inside to transfer from module to module 
//	or
// transpose wiring matrices
		for(j=0;j<16;j++)
		begin : block_rev
				for(i=0;i<6;i++)
				begin : block
					assign transfer[i][j] = transfer_rev[j][i];
				end
		end
		for(j=0;j<18;j++)
		begin : block_rev_
				for(i=0;i<16;i++)
				begin : block_
					assign in_wire_rev[i][j] = in_wire[j][i];
				end
		end
//-------------------------------------------------------------------------------------------
		for(j=0;j<16;j++)
		begin : block
				//for(i=0;i<9;i++)
				//begin : block
					slot_scan slot(
											.in(in_wire_rev[j][17:0]),
											.out(transfer_rev[j][5:0]),
											.sel(sel)
									  );
				//end
		end
			for(j=0;j<9;j++)
			begin : wiring
				assign in_wire[j][15:0]=left_data_out[j][15:0];
				assign in_wire[j+9][15:0]=right_data_out[j][15:0];
		end
		endgenerate
		
		Dot_product_single_slot S_1(	
												.a(transfer[5][15:0]),
												.b(transfer[2][15:0]),
												.c(transfer[4][15:0]),
												.d(transfer[1][15:0]),
												.e(transfer[3][15:0]),
												.f(transfer[0][15:0]),
												.x(out)
											
											);
		
endmodule  
//-----------------------------------------------------------------------------------------
module Dot_product_single_slot(a,b,c,d,e,f,x);
	input [15:0] a,b,c,d,e,f;//=  a  b  c  d  e  f
	output[31:0] x;//example:x = (a1.d1+b1.d2+c1.d3)
	wire 	[31:0] OUT_1,OUT_2,OUT_3,OUT_4,OUT_5;
			Multiplier M_1(.A(a),.B(b),.OUT(OUT_1));
			Multiplier M_2(.A(c),.B(d),.OUT(OUT_2));
			Multiplier M_3(.A(e),.B(f),.OUT(OUT_3));
			
			Adder A_1(.a(OUT_1),.b(OUT_2),.sum_dif(OUT_4),.carry_in(0),.C(),.V(),.add_sub(0));
			Adder A_2(.a(OUT_3),.b(OUT_4),.sum_dif(OUT_5),.carry_in(0),.C(),.V(),.add_sub(0));
	
	assign x = OUT_5;		
endmodule
//------------------------------------------------------------------------------------------
	module mux_ALU_select_3_to_1_functions(slot,out,sel);
//--------------------------------------------------------------------------------------------------------------------------------------------------				
		input [2:0] slot;
		input [1:0] sel;
		wire [2:0]outlet;
		output out;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				assign outlet[2] 	= slot[2] & (~sel[1]) & (~sel[0]);                 
				assign outlet[1] 	= slot[1] & (~sel[1]) & (sel[0]);
				assign outlet[0] 	= slot[0] & (sel[1]) & (~sel[0]);
				assign out = outlet[0]|outlet[1]|outlet[2];
//--------------------------------------------------------------------------------------------------------------------------------------------------			
	endmodule

	module	slot_scan(in,out,sel);
	
		input [17:0]in;
		input [3:0]sel;
		output[5:0]out;
		wire [17:0]in_wire;
		assign in_wire[17]=in[17]; 
		assign in_wire[16]=in[14]; 
		assign in_wire[15]=in[11];
		assign in_wire[14]=in[16]; 
		assign in_wire[13]=in[13]; 
		assign in_wire[12]=in[10]; 
		assign in_wire[11]=in[15]; 
		assign in_wire[10]=in[12]; 
		assign in_wire[9]=in[9]; 
		
		assign in_wire[8]=in[8]; 
		assign in_wire[7]=in[7]; 
		assign in_wire[6]=in[6];
		assign in_wire[5]=in[5]; 
		assign in_wire[4]=in[4]; 
		assign in_wire[3]=in[3]; 
		assign in_wire[2]=in[2]; 
		assign in_wire[1]=in[1]; 
		assign in_wire[0]=in[0]; 
		genvar i,j;
			generate
			for(j=0;j<2;j++)
				begin : matrix_
					mux_ALU_select_3_to_1_functions Mux_1(.slot(in_wire[8+(j*9):6+(j*9)]),.out(out[2+(j*3)]),.sel(sel[(j*2)+1:(j*2)]));
					mux_ALU_select_3_to_1_functions Mux_2(.slot(in_wire[5+(j*9):3+(j*9)]),.out(out[1+(j*3)]),.sel(sel[(j*2)+1:(j*2)]));
					mux_ALU_select_3_to_1_functions Mux_3(.slot(in_wire[2+(j*9):0+(j*9)]),.out(out[0+(j*3)]),.sel(sel[(j*2)+1:(j*2)]));
				end
			endgenerate
	endmodule
	
	
