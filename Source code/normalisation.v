

module normalization(
    input [13:0] mantisa,
    input [4:0] exp,
    output reg [10:0] mantisa_out,
    output reg [4:0] exp_out,
    output reg overflow_flag,
    output reg sign_res
);
    reg [12:0] normalized_mantissa;
    reg [4:0] temp_exp;
    
    wire sign_bit = mantisa[13];
    wire [12:0] abs_mantissa = sign_bit ? -mantisa[12:0] : mantisa[12:0];
    
    always @(*) begin
        // Default initializations
        mantisa_out = 11'd0;
        exp_out = exp;
        overflow_flag = 1'b0;
        sign_res = sign_bit;
        
        if (abs_mantissa == 13'd0) begin
            mantisa_out = 11'd0;
            exp_out = 5'd0;
        end else begin
            normalized_mantissa = abs_mantissa;
            temp_exp = exp;
            
            // Use for loop for better synthesis
            repeat(13) begin
                if (normalized_mantissa[12] == 1'b0 && temp_exp > 5'd0) begin
                    normalized_mantissa = normalized_mantissa << 1;
                    temp_exp = temp_exp - 1'b1;
                end
            end
            
            repeat(13) begin
                if (normalized_mantissa[12:11] > 2'b01 && temp_exp < 5'b11111) begin
                    normalized_mantissa = normalized_mantissa >> 1;
                    temp_exp = temp_exp + 1'b1;
                end
            end
            
            // Unified overflow check
            if (temp_exp == 5'b11111 || normalized_mantissa[11:2] == 10'b1111111111) begin
                overflow_flag = 1'b1;
                mantisa_out = 11'd0;
                exp_out = 5'b11111;
            end else begin
                mantisa_out = normalized_mantissa[12:2];
                exp_out = temp_exp;
            end
        end
    end
endmodule