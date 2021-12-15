`timescale 10ns / 1ps
/* 
Ejercicio #3
----------------------------------------------
Nombre: N_Adder_TestBench 
----------------------------------------------
Autor: Gomez Augusto
 */

module n_adder_tb ();

    // LOCAL-PARAMETERS
    localparam                          NB_DATA= 2;
    localparam                          N_TERM= 16;
    localparam                          CLK_HALF_P= 50;
    
    // SIGNALS
    wire [NB_DATA-1: 0]                 sum_o_gen, sum_o_alw;
    reg  [NB_DATA-1: 0]                 sum_o_tb;
    wire                                clock_i;
    reg  [NB_DATA*N_TERM-1: 0]          data_bus_i;
    integer                             i;

    // Clock genertor model.
    t_clock_generator
    #(
        .HALF_PERIOD            ( CLK_HALF_P    )
    )
    u_t_clock_generator
    (
        .o_clock                ( clock_i       )
    ) ;

    //STIMULUS SIGNAL
     initial
     begin
        repeat(6) @(posedge clock_i)
        begin 
            data_bus_i= $random;
            sum_o_tb= 0;
            for(i=0; i< N_TERM; i= i+1)
            begin
                sum_o_tb= sum_o_tb+ data_bus_i[(i+1)*NB_DATA-1 -: NB_DATA];
            end   
     end
     $finish();
     end

    //DUT INSTANCE 1
    n_adder
    #(
        .NB_DATA                (NB_DATA),
        .N_TERM                 (N_TERM),
        .SELECT                 (1'b1)
    )
    u_n_adder_alw
    (
        .o_sum                  (sum_o_alw),
        .i_data_bus             (data_bus_i),
        .i_clock                (clock_i)
    );
    
    //DUT INSTANCE 2
    n_adder
    #(
        .NB_DATA                (NB_DATA),
        .N_TERM                 (N_TERM),
        .SELECT                 (1'b0)
    )
    u_n_adder_gen
    (
        .o_sum                  (sum_o_gen),
        .i_data_bus             (data_bus_i),
        .i_clock                (clock_i)
    );

    //ASSERTIONS
    reg                                 add_ok;
    always @(negedge clock_i)
    begin
        add_ok= (sum_o_alw== sum_o_gen)&(sum_o_alw== sum_o_tb)&(sum_o_gen== sum_o_tb);
        if(add_ok)
            $display("TEST PASSED: Test_data= %h, result= %h, N_TERM= %d, NB_DATA= %d", data_bus_i, sum_o_tb, N_TERM, NB_DATA);
        else
            $display("ERROR: Addition mismatch (_gen, _alw, _real)-> (%h, %h, %h)", sum_o_gen, sum_o_alw, sum_o_tb); 
    end
    
endmodule 


