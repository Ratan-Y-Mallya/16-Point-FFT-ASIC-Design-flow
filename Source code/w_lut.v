module w_lut (
   input wire [2:0] addr,
   output reg [31:0] W
);

   always @(*) begin

      case (addr)
         0: W = {16'h3C00,16'h0000} ;
         
         1: W = {16'h3B64 ,16'hB61F};

         2: W = {16'h39A8,16'hB9A8};

         3:W = {16'h361F ,16'hBB64};

         4:W = {16'h0000 ,16'hBC00}; 
         
         5:W = {16'hB61F,16'hBB64}; 

         6:W = {16'hB9A8 ,16'hB9A8};

         7:W = {16'hBB64 ,16'hB61F}; 

      endcase

   end

endmodule