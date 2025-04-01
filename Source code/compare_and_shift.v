module compare_and_shift (
    input [12:0] mantisa1,           
    input [12:0] mantisa2,           
    input [4:0] exp1,               
    input [4:0] exp2,               
    output reg [12:0] mantisa1_new, 
    output reg [12:0] mantisa2_new, 
    output reg [4:0] new_exp        
);

    wire [4:0] exp_dif;              
    

    // Calculate exponent difference
    assign exp_dif = (exp1 > exp2) ? (exp1 - exp2) : (exp2 - exp1);

    always @(*) begin
        // Initialize outputs to avoid latches
        mantisa1_new = 0;
        mantisa2_new = 0;
        new_exp = 0;

       
        // Align mantissas based on exponent difference
        if (exp1 > exp2) begin
            mantisa1_new = mantisa1;              
            mantisa2_new = mantisa2 >> exp_dif;   
            new_exp = exp1;                        
        end else if (exp1 < exp2) begin
            mantisa1_new = mantisa1 >> exp_dif;   
            mantisa2_new = mantisa2;             
            new_exp = exp2;                 
        end else begin
            mantisa1_new = mantisa1;              
            mantisa2_new = mantisa2;              
            new_exp = exp1;                   
        end
    end

endmodule


