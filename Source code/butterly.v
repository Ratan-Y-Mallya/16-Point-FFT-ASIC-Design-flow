
module butterfly #(parameter N_bit = 16)( Ar,Ai,Br,Bi,Wr,Wi,Xr_F,Xi_f,Yr_F,Yi_f , clk,rst);

// decleration of ports
input clk,rst;;
input [N_bit-1:0] Ar,Ai,Br,Bi,Wi,Wr;

output reg  [N_bit-1:0] Xr_F,Xi_f,Yr_F,Yi_f;

// decleraation of interim wire
   wire  [N_bit-1:0] Zr_a;
   wire  [N_bit-1:0] Zr_b;
   wire  [N_bit-1:0] Zi_a;
   wire  [N_bit-1:0] Zi_b;

     wire  [N_bit-1:0] Zrsub;	
   wire  [N_bit-1:0] Ziadd;

     wire  [N_bit-1:0] Xr;
   wire  [N_bit-1:0] Xi;
   wire [N_bit-1:0] Yr;
   wire  [N_bit-1:0] Yi;

   reg [N_bit-1:0] Ar_F;
	reg [N_bit-1:0] Ai_F;
  
    reg [N_bit-1:0] Ar_FF;
    reg [N_bit-1:0] Ai_FF;

always @(posedge clk ) begin

    if (rst) begin
        Xr_F <= 0;
        Xi_f<=0 ;
        Yr_F <= 0;
        Yi_f <= 0;
    end
     else begin

     Ar_F<=Ar;
	 Ai_F<=Ai;
	 
	 Ar_FF<=Ar_F;
	 Ai_FF<=Ai_F;

     Xr_F <= Xr;
     Xi_f<=Xi ;
     Yr_F <= Yr;
     Yi_f <= Yi;

    end

    end

     // multiplier mul1 (.in1(Br), .in2(Wr), .final(Zr_a));
     // multiplier mul2 (.in1(Bi), .in2(Wi), .final(Zr_b));
     // multiplier mul3 (.in1(Br), .in2(Wi), .final(Zi_a));
     // multiplier mul4 (.in1(Bi), .in2(Wr), .final(Zi_b));

     multiplier m1(.clk(clk),.rst(rst),.i_a(Br),.i_b(Wr),.i_vld(1'b1),.o_res(Zr_a));
	multiplier m2(.clk(clk),.rst(rst),.i_a(Bi),.i_b(Wi),.i_vld(1'b1),.o_res(Zr_b));
	multiplier m3(.clk(clk),.rst(rst),.i_a(Br),.i_b(Wi),.i_vld(1'b1),.o_res(Zi_a));
	multiplier m4(.clk(clk),.rst(rst),.i_a(Bi),.i_b(Wr),.i_vld(1'b1),.o_res(Zi_b));

     adder_single_cycle adder1(
                            .clk(clk),                   
                            .rst(rst),                   
                            .i_valid(1'b1),               
                            .i_a(Zr_a),            
                            .i_b({Zr_b[15]^1'b1,Zr_b[14:0]}),            
                            .o_res(Zrsub),    
                            .Overflow(),        
                            .o_res_vld()        
);

adder_single_cycle adder2(
                            .clk(clk),                   
                            .rst(rst),                   
                            .i_valid(1'b1),               
                            .i_a(Zi_a),            
                            .i_b(Zi_a),            
                            .o_res(Ziadd),    
                            .Overflow(),        
                            .o_res_vld()        
);

adder_single_cycle adder3(
     .clk(clk),                   
     .rst(rst),                   
     .i_valid(1'b1),               
     .i_a(Ar_FF),            
     .i_b(Zrsub),            
     .o_res(Xr),    
     .Overflow(),        
     .o_res_vld()        
);

adder_single_cycle adder4(
     .clk(clk),                   
     .rst(rst),                   
     .i_valid(1'b1),               
     .i_a(Ai_FF),            
     .i_b(Ziadd),            
     .o_res(Xr),    
     .Overflow(),        
     .o_res_vld()        
);


adder_single_cycle adder5(
     .clk(clk),                   
     .rst(rst),                   
     .i_valid(1'b1),               
     .i_a(Ar_FF),            
     .i_b({(Zrsub[15] ^ 1'b1),Zrsub[14:0]}),            
     .o_res(Yr),    
     .Overflow(),        
     .o_res_vld()        
);


adder_single_cycle adder6(
     .clk(clk),                   
     .rst(rst),                   
     .i_valid(1'b1),               
     .i_a(Ai_FF),            
     .i_b({(Ziadd[15] ^ 1'b1),Ziadd[14:0]}),            
     .o_res(Yi),    
     .Overflow(),        
     .o_res_vld()        
);


    
endmodule