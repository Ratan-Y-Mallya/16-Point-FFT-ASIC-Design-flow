

module adder_single_cycle (
    input clk,                   
    input rst,                   
    input i_valid,               
    input [15:0] i_a,            
    input [15:0] i_b,            
    output reg [15:0] o_res,    
    output reg Overflow,        
    output reg o_res_vld        
);

    // Internal wires
    wire [12:0] mantisa1_w, mantisa2_w;
    wire [4:0] exp1_w, exp2_w;
    wire [12:0] mantisa1_new_w, mantisa2_new_w;
    wire [4:0] new_exp_w, exp_out_w; 
    wire [13:0] mantisa_out_w;
    wire sign_out_w, overflow_flag_w;
    wire [10:0] mantisa_out;
    wire zero_a, zero_b, infinity_a, infinity_b, nan_a, nan_b, zero_ip;
    wire [15:0] res;

    // Register outputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_res <= 16'b0;
            o_res_vld <= 1'b0;
            Overflow <= 1'b0;
        end else begin
            o_res <= res;
            o_res_vld <= i_valid;
            Overflow <= overflow_flag_w;
        end
    end

    // Extract exponent and special cases
    assign exp1_w = i_a[14:10];
    assign exp2_w = i_b[14:10];

    assign zero_a = (i_a[14:0] == 15'd0);  // All zero = true zero
    assign zero_b = (i_b[14:0] == 15'd0);
    assign zero_ip = zero_a && zero_b;

    assign infinity_a = (exp1_w == 5'b11111) && (i_a[9:0] == 10'd0);
    assign infinity_b = (exp2_w == 5'b11111) && (i_b[9:0] == 10'd0);
    assign nan_a = (exp1_w == 5'b11111) && (i_a[9:0] != 10'd0);
    assign nan_b = (exp2_w == 5'b11111) && (i_b[9:0] != 10'd0);

    // Proper mantissa extraction (Handling normalized and denormalized numbers)
    assign mantisa1_w = {3'b001, i_a[9:0]};
    assign mantisa2_w =  {3'b001, i_b[9:0]};

    // Submodule instances
    compare_and_shift u_compare_and_shift (
        .mantisa1(mantisa1_w),
        .mantisa2(mantisa2_w),
        .exp1(exp1_w),
        .exp2(exp2_w),
        .mantisa1_new(mantisa1_new_w),
        .mantisa2_new(mantisa2_new_w),
        .new_exp(new_exp_w)
    );

    addition_s u_addition_s (
        .mantisa1(mantisa1_new_w),
        .mantisa2(mantisa2_new_w),
        .sign1(i_a[15]),
        .sign2(i_b[15]),
        .mantisa_out(mantisa_out_w)
    );

    normalization u_normalisation (
        .mantisa(mantisa_out_w),
        .exp(new_exp_w),
        .mantisa_out(mantisa_out),
        .exp_out(exp_out_w),
        .overflow_flag(overflow_flag_w),
        .sign_res(sign_out_w)
    );

    // Final result assignment (Handling special cases)
    assign res = (nan_a || nan_b) ? {1'b0, 5'b11111, 10'b0000000001} :  // NaN
                 (infinity_a && infinity_b && i_a[15] != i_b[15]) ? {1'b0, 5'b11111, 10'b0000000001} :  // Inf - Inf = NaN
                 (infinity_a) ? i_a :  // Infinity cases
                 (infinity_b) ? i_b :  
                 (overflow_flag_w) ? {1'b0, 5'b11111, 10'b0} :  // Overflow case
                 (zero_ip) ? {sign_out_w, 15'd0} :  // Both zero
                 (zero_a) ? i_b :  
                 (zero_b) ? i_a :  
                 {sign_out_w, exp_out_w, mantisa_out[9:0]};  

endmodule
