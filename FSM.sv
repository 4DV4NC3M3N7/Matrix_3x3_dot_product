

module ff_(Q,Q_,D,clear,clk);//flip_flop_cell,add "enable" if need a tristate lock at the output. 
		input D;
		input clear,clk;//add "enable" if need a tristate lock at the output.
		output reg Q,Q_;
		generate 
		always @ ( posedge clk or posedge clear)
			begin
				if(clear)
				begin
					Q = 1'b0;
				end
				else 
				begin
					Q = D;
				end
			end
		assign Q_=~Q;
		//bufif1 TB(Q[i],q[i],enable);
		endgenerate
endmodule 

module FSM(clk,reset,d,sel,en);//sel is fot number 0->4'b1000
input   clk,reset,en;
output [3:0] d,sel;
wire [3:0] Q,Q_,b;
wire clear;
		ff_ b1(Q[0],Q_[0],Q_[0],reset|clear,clk&en);
		ff_ b2(Q[1],Q_[1],Q_[1],reset|clear,Q_[0]);
		ff_ b3(Q[2],Q_[2],Q_[2],reset|clear,Q_[1]);
		ff_ b4(Q[3],Q_[3],Q_[3],reset|clear,Q_[2]);
		assign clear = Q[3]&~Q[2]&~Q[1]&Q[0]&~clk;
		assign sel=Q;
		assign b=Q;
		//assign clear = ~b[3]&b[2]&b[1]&b[0];
		assign d[3]=(b[3]&~b[2]&~b[1]&~b[0])|(~b[3]&b[2]&b[1]);
		assign d[2]=(~b[3]&~b[2]&b[1]&b[0])|(~b[3]&b[2]&~b[1]);
		assign d[1]=(~b[3]&~b[2]&b[1]&~b[0])|(~b[3]&b[2]&~b[1]&b[0])|(b[3]&~b[2]&~b[1]&~b[0]);
		assign d[0]=(~b[3]&~b[2]&~b[1]&b[0])|(~b[3]&b[2]&~b[1]&~b[0])|(~b[3]&b[2]&b[1]&b[0]);
endmodule 

module 	one_hot(clk,reset,en,state);//startup bit is reset = 1 and clk = 1 => state = 01; => next clock is 10;
input 	clk,reset,en;
output 	[1:0]state;
wire clear;
wire [1:0] Q,Q_;
	
		ff_ b1(Q[0],Q_[0],Q_[0]&~clear,reset,clk);
		ff_ b2(Q[1],Q_[1],Q_[1],reset|~clear,Q_[0]);
		assign clear = Q[1]&~Q[0]&clk;
		assign state[0] = ~Q[1]&~Q[0];
		assign state[1] = ~Q[1]&Q[0];
endmodule 
