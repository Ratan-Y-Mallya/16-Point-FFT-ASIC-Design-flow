

module addition_s (
   mantisa1,mantisa2,sign1,sign2,mantisa_out
);

    input [12:0] mantisa1,mantisa2;
    input sign1,sign2;
    output  [13:0] mantisa_out;
    

    wire [13:0] Mantisa_w1,Mantisa_w2 ;
   assign Mantisa_w1 = sign1 ? (-mantisa1): mantisa1;
   assign Mantisa_w2 = sign2 ? (-mantisa2): mantisa2;



    assign mantisa_out = Mantisa_w1 + Mantisa_w2;

    

endmodule
