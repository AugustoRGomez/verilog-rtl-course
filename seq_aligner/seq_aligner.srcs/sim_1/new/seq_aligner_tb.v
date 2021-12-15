`timescale 1ns / 1ps
/* 
Ejercicio #4
----------------------------------------------
Nombre: SEQ_ALIGNER_TestBench 
----------------------------------------------
Autor: Gomez Augusto
 */
`define MACRO_TIME1 3250 //ns

module seq_aligner_tb();

    // LOCAL-PARAMETERS
    localparam                          NB_CONF    = 4; 
    localparam                          NB_LOSS    = 4; 
    localparam                          NB_DATA    = 64;
    localparam                          NB_FRAME   = 256*8;
    localparam                          CLK_HALF_P = 50;
    localparam                          FAS        = 64'hf6f6f6282828ff00;
    localparam                          ZERO       = {NB_DATA{1'b0}};
    localparam                          BIT_ERR    = 1000;

    // SIGNALS
    wire                                tb_o_sof;
    wire                                tb_o_lock;

    wire                                tb_i_clock; 
    reg         [NB_CONF-1: 0]          tb_i_n_conf; //como lo interprete: numero de coincidencias FAS Y o_sof en el tiempo (posteriores a detectar el primer FAS solo) 
    reg         [NB_LOSS-1: 0]          tb_i_n_loss;
    reg         [NB_DATA-1: 0]          tb_i_data;
    reg                                 tb_i_valid;
    reg                                 tb_i_reset;

    reg         [8-1: 0]                tb_count; 
  
    // Clock genertor model.
    t_clock_generator
    #(
        .HALF_PERIOD            (CLK_HALF_P)
    )
    u_t_clock_generator
    (
        .o_clock                (tb_i_clock)
    ) ;

    //STIMULUS SIGNAL
    initial
    begin
        tb_i_valid     = 1'b1;
        tb_count       = 0;
        tb_i_data      = {NB_DATA{1'b0}};
        tb_i_n_conf    = 2;
        tb_i_n_loss    = 3;
        #10 tb_i_reset = 1'b1;
        #60 tb_i_reset = 1'b0;
        
//         repeat(64) @(posedge tb_i_clock)
//         begin
//             if($time() > `MACRO_TIME1)
//             begin
//                 tb_i_reset = ~($random()%2);
//             end
//         end
    end

    always @(posedge tb_i_clock) 
    begin
        
        if(tb_count == 32)
        begin
            // tb_i_data = (~|(corrupt_data(FAS, BIT_ERR) ^ FAS)) * FAS; 
            tb_i_data = corrupt_data(FAS, BIT_ERR);
            tb_count  = 0;
            // $display("data_with_error: %b", tb_i_data);
            // $display("places_with_err: %b", tb_i_data ^ FAS);
        end
        else
        begin
            tb_i_data = {NB_DATA{1'b1}}; //rest of the frame is 1111....1 (for better a visualization)
            tb_count  = tb_count+1;
        end       
    end

    //DUT INSTANCE
    seq_aligner
    #(
        .NB_DATA                (NB_DATA ),
        .NB_FRAME               (NB_FRAME),
        .NB_CONF                (NB_CONF ),
        .NB_LOSS                (NB_LOSS ),
        .FAS                    (FAS     )
    )

    u_seq_aligner
    (
        .o_sof                  (tb_o_sof   ),
        .o_lock                 (tb_o_lock  ),
        .i_data                 (tb_i_data  ),
        .i_valid                (tb_i_valid ),
        .i_n_conf               (tb_i_n_conf),
        .i_n_loss               (tb_i_n_loss),
        .i_clock                (tb_i_clock ),
        .i_reset                (tb_i_reset )
    );
    
    //CONSIGNAS
    initial 
    begin
        $display("//CONSIGNA --------------------------------------//");
        $display("*Si la tasa de error (BER: bit error rate) es de 1/1000,cual es la probabilidad de detectar el FAS correctamente con i_n_conf=2?");
        $display("P_FAS= prob_fas_con_error= 64/1000= %f", 0.064);
        $display("como la prob de que venga otro FAS no depende del anterior FAS, son eventos independientes");
        $display("el modulo se engancha luego de un 3 FAS correctos siendo los 2 ultimos coincidentes en el tiempo con o_sof");
        $display("la probabilidad de engancharse dado estos 3 eventos sera P_LOCK= 1- (64/1000)= %f", 0.936);
        $display("//-----------------------------------------------//");
    end

    //FUNCTIONS
    function automatic [NB_DATA-1: 0] corrupt_data;
        input reg       [NB_DATA-1: 0]  original_data;
        input integer                   bit_error;
        reg             [NB_DATA-1: 0]  mask;
        integer                         ii;
        begin
            for (ii= 0; ii<NB_DATA; ii= ii+1) 
            begin
                mask[ii] = ($urandom % bit_error == 0); 
            end
            corrupt_data = original_data ^ mask;
        end    
    endfunction

endmodule
