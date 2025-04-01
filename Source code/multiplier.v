

// module multiplier (in1, in2, final);

// // Initialize I/O ports
// input [15:0] in1, in2;
// output reg [15:0] final;

// // Interim wires
// wire [9:0] M1, M2;
// wire [4:0] E1, E2;
// wire s1, s2;
// wire [5:0] exp_sum;
// wire [19:0] multi;
// wire normalize;

// // Extract fields
// assign M1 = {1'b1, in1[9:0]};
// assign M2 = {1'b1, in2[9:0]};
// assign E1 = in1[14:10];
// assign E2 = in2[14:10];
// assign s1 = in1[15];
// assign s2 = in2[15];

// // Mantissa multiplication
// assign multi = M1 * M2;
// assign normalize = multi[19]; // Check if normalization needed

// // Exponent calculation
// assign exp_sum = E1 + E2 - 5'b01111 + normalize;

// // Main logic
// always @(*) begin
//     // Check for special cases
//     if ((E1 == 5'b11111) || (E2 == 5'b11111)) begin
//         // Infinity or NaN
//         if ((E1 == 5'b11111 && in1[9:0] != 0) || (E2 == 5'b11111 && in2[9:0] != 0)) begin
//             // NaN
//             final = {1'b1, 5'b11111, 10'b1111111111};
//         end else begin
//             // Infinity
//             final = {s1^s2, 5'b11111, 10'b0000000000};
//         end
//     end
//     // Check for zero
//     else if ((E1 == 5'b00000) || (E2 == 5'b00000)) begin
//         final = 16'b0;
//     end
//     // Normal multiplication
//     else begin
//         // Check for overflow
//         if (exp_sum[5] || exp_sum >= 6'b111111) begin
//             // Overflow, return infinity
//             final = {s1^s2, 5'b11111, 10'b0000000000};
//         end
//         // Check for underflow
//         else if (exp_sum[5] || exp_sum == 0) begin
//             // Underflow, return zero
//             final = 16'b0;
//         end
//         else begin
//             final[15] = s1 ^ s2;  // Sign
//             final[14:10] = exp_sum[4:0];  // Exponent
//             final[9:0] = normalize ? multi[18:9] : multi[17:8];  // Mantissa with normalization
//         end
//     end
// end

// endmodule


module multiplier(clk,rst,i_a,i_b,i_vld,exception,overflow,underflow,o_res,o_res_vld);

input clk,rst;

input i_vld;
input [15:0] i_a,i_b;

output exception,overflow,underflow;
output reg [15:0] o_res;
output reg o_res_vld;

wire sign,round,normalised,zero;
wire [5:0] exponent,sum_exponent;
wire [9:0] product_mantissa;  ////
wire [10:0] op_a,op_b;
wire [21:0] product,product_normalised,res; 



wire [15:0] a,b;
assign zero= !(|i_a[14:0]  && |i_b[14:0]);

always @(posedge clk)
begin
	if(rst)
	begin
		o_res <= 16'd0;
		o_res_vld <= 1'b0;
	end
	
	else 
	begin
		o_res <= res;
		o_res_vld <= i_vld;
	end

end

assign a = i_a;
assign b = i_b;


assign sign = a[15] ^ b[15];

  													
assign exception = (&a[14:10]) | (&b[14:10]);								
																							
																																														
assign op_a = (|(a[14:10]) ? {1'b1,a[9:0]} : {1'b0,a[9:0]});		  
assign op_b = (|(b[14:10]) ? {1'b1,b[9:0]} : {1'b0,b[9:0]});


assign product = op_a * op_b ;	// can use modified booth recoding multiplier here instead of * operation
											
assign round = |product_normalised[9:0]; 
 							
assign normalised = product[21] ? 1'b1 : 1'b0;
	
assign product_normalised = normalised ? product : product << 1;								

assign product_mantissa = product_normalised[20:11] + ((&product_normalised[20:11])?1'b0:(product_normalised[10] & round)); 
					
//assign zero = exception ? 1'b0 : (product_mantissa == 10'b0) ? 1'b1 : 1'b0;

assign sum_exponent = a[14:10] + b[14:10];

assign exponent = sum_exponent - 5'd15 + normalised;

assign overflow =((exponent[5] & !exponent[4])) ;
									
assign underflow =((exponent[5] & exponent[4])); 							

assign res = (zero ?({sign,15'd0}): overflow ?({sign,5'b11111,10'b0}) : underflow ? ({sign,15'b0}) : exception ? 16'b0 : {sign,exponent[4:0],product_mantissa});

endmodule
