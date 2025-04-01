

module new_tb;

   reg                clk;
   reg                reset;

   reg                in_push;
   reg signed [15:0]  in_real;
   reg signed [15:0]  in_imag;
   wire               in_stall;

   wire               out_push;
   wire signed [15:0] out_real;
   wire signed [15:0] out_imag;
   reg                out_stall;
   
   reg [31:0]data [0:15];   /// the memory that will hold the input data
   integer i,j;

   /****************************************************************************
    * Instantiate Module
    ***************************************************************************/

   fft_top fft_top_0 (
      .clk        (clk),
      .reset      (reset),
      .in_push    (in_push),
      .in_real    (in_real),
      .in_imag    (in_imag),
      .in_stall   (in_stall),
      .out_push_F (out_push),
      .out_real_F (out_real),
      .out_imag_F (out_imag),
      .out_stall  (out_stall)
   );

   // 250 MHz clock and store the input file into temporary memory
   initial begin: read_input
   integer f,fh;
   clk = 1'b0;
   fh= $fopen("/home/aniket/Documents/college_files/iitr/vivado_projects/fft/data_in.txt","r");
   j=0;
   while ( !$feof(fh))
   begin
    f= $fscanf(fh,"%b\n",data[j]);
    j=j+1;
    end
    $fclose(fh);
   end
   
   always #5 clk = ~clk;
   
   integer count,output_file;
   
   initial 
   begin
   
      output_file = $fopen("/home/aniket/Documents/college_files/iitr/vivado_projects/fft/o_data.txt","w");
      
      
   reset=1'b1;
   repeat(2) @(posedge clk);
   in_push=1'b1;
   out_stall=1'b0;
   reset=1'b0;
   
   //applying the input data to input stimulus
   for(i=0;i<j;i=i+1)
   begin
   {in_real,in_imag} = data[i];
   @(posedge clk);
   end
   
   in_push=1'b0;
   @(posedge clk);
   
   // wait till the output is ready and wait for 16 more cycles to record the ouptut
   while(out_push == 1'b0)
    begin
        @(posedge clk);
    end
           
   for (i=0;i<16;i=i+1)
    begin
      if (out_push === 1'b1 && out_stall === 1'b0) begin
            $display("out(%0d) = %0h + i*%0h;",
               count + 1, out_real, out_imag);

            $fwrite(output_file, " %b + i*%b;\n",
                out_real, out_imag);

            count = count + 1;
            @(posedge clk);

       end
     end
     
    @(posedge clk);
   $fclose(output_file);
   
   repeat(5) @(posedge clk);
   
   $finish;
   
   end

   initial
   begin
   $dumpfile("fft_rebirth.vcd");
   $dumpvars(0);
   end
   
   
endmodule

   
   
   
   
   
   
   
   
