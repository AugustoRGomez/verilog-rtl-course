`timescale 1ps/1ps
/*--------------------------------------------------------------------------
 -- Project     : Curso de Verilog-RTL 2021
----------------------------------------------------------------------------
 -- File        : t_clock_generator.v
 -- Date        : 2021/06/03
 -- 
----------------------------------------------------------------------------
 -- Description : Modelo de generador de clock (no es RTL)
----------------------------------------------------------------------------
 -- Changelog   :
 --
 -- Initial rev by: rlopez
 --
--------------------------------------------------------------------------*/

module t_clock_generator
#(
    // PARAMETERS.
    parameter                           HALF_PERIOD     = 50,
    parameter                           JITTER_ENABLE   = 0,
    parameter                           MAX_VALUE       = 10 //ps
)
(
    // OUTPUTS.
    output  wire                        o_clock

    // INPUTS.
    // Ups... no inputs! This must be a simulation model...
) ;

    //==========================================
    // LOCAL-PARAMETERS
    //==========================================
    localparam                         CONST_1k = 1000;

    //==========================================
    // SIGNALS
    //==========================================
    reg                                 clk;

    //==========================================
    // ALGORITHM
    //==========================================

    // Initial value for clock signal (clock starts with a known value)
    initial
    begin
        clk = 1'b0;
    end

    // Generate a square wave form.
    generate
        if(JITTER_ENABLE == 0)
            always // always without sensitivity list... this is not RTL.
            begin : l_clock_gen
                #( HALF_PERIOD*CONST_1k )    clk = ~clk ;
            end // l_clock_gen
        else
            always 
            begin
                #( HALF_PERIOD*CONST_1k + $random % MAX_VALUE ) clk = ~clk;   
            end
    endgenerate

    // Clock generator output
    assign  o_clock = clk;

endmodule // t_clock_generator