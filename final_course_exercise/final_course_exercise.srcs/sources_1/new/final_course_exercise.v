`timescale 1ns / 1ps
/* 
Ejercicio #7
----------------------------------------------
Nombre: ejercicio integrador
----------------------------------------------
Autor: Gomez Augusto
----------------------------------------------
(07a) Utilizando los módulos de los ejercicios anteriores, elaborar un módulo que responda a los siguientes requisitos:
(a) Acepta una tasa de throughput de entrada (asociado al pin i_valid) aleatoria, pero que potencialmente podría ser 
de 1 todo el tiempo (throughput máximo).
(b) Recibe una entrada de i_data de NB_IN bits, donde NB_IN=8.
(c) La entrada debe convertirse a paralelismo intermedio NB_MID = 5*NB_IN (40 bits).
(d) Cuando los datos han sido convertidos al paralelismo intermedio, debe hacerse un proceso de búsqueda de FAS paralelo.
El FAS es de 32 bits, su valor es programable y se recibe en un puerto "i_rf_static_fas".
El largo del frame es múltiplo de 40*3 bits, y se recibe en un puerto "i_rf_static_frame_clocks".
El FAS aligner tiene que cumplir con los requisitos del ejercicio 4, y generar la salida de o_sof usando 
los thresholds de enganche "i_rf_static_n_conf" e "i_rf_static_n_conf".
(e) Luego del proceso de alineación del FAS, los datos deben pasarse por una FIFO de CDT, donde la frecuencia de 
entrada (f_in) es siempre menor que la de salida (f_out); como máximo f_in/f_out= 3/5.
(f) Los datos de la FIFO de CDT deben leerse con un rate determinado por la salida de un generador sigma-delta con un 
rate de 3/5. 
(g) Los datos de salida de la CDT, leídos con el rate de valid 3/5, deben pasarse por un conversor de paralelismo de 
relación de conversión 5:3 (5*8=40 a 3*8=24).
(h) La salida de o_sof, generada por el alineador debe propagarse por la CDT y regenerarse a la salida del conversor 5:3.

(07b) Utilizando el t_prbs_generator y el bloque t_prbs_checker, probar que el datapath funcione correctamente (el 
t_prbs_checker debe engancharse sin errores). NOTA: en este caso se transmite PRBS cruda, sin insertar el FAS requerido 
por el alineador.
(07c) Generar frames de prueba (insertando el FAS requerido (i_rf_static_fas) cada (i_rf_static_frame_clocks*40) bits)
y probar que la FSM del aligner se enganche correctamete.
*/

module final_course_exercise
#(
    //PARAMS ---------------------------------------------------------------------//
    parameter                                   NB_IN        = 8,
    parameter                                   NB_FAS       = 32,
    parameter                                   NB_FRAME_CNT = 32,
    parameter                                   NB_CNT       = 3,
    parameter                                   MSB_IS_NEWER = 0,
    parameter                                   N_MID        = 5,
    parameter                                   N_END        = 3,
    parameter                                   NB_ADRESS    = 3
)
(  
    //OUTPUTS --------------------------------------------------------------------//
    output wire      [NB_IN*N_END-1:0]          o_c2_o_data,
    output wire                                 o_c2_o_valid,
    output wire                                 o_regen_sof,

    //INPUTS ---------------------------------------------------------------------//
    input  wire                                 i_valid,
    input  wire                                 i_wrst,
    input  wire                                 i_wclk,
    input  wire      [NB_IN-1:0]                i_data,
    input  wire      [NB_FAS-1:0]               i_rf_static_fas,
    input  wire      [NB_FRAME_CNT-1:0]         i_rf_static_frame_clocks,
    input  wire      [NB_CNT-1:0]               i_rf_static_n_conf,
    input  wire      [NB_CNT-1:0]               i_rf_static_n_loss,

    input  wire                                 i_rclk,
    input  wire                                 i_rrst,

    //DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG
    output wire      [NB_IN*N_MID-1:0]          o_c1_o_data,
    output wire                                 o_c1_o_valid,

    output wire                                 o_fas_o_sof,
    output wire                                 o_fas_o_lock,
    output wire      [NB_FRAME_CNT-1:0]         o_fas_search_count,
    output wire                                 o_fas_match,
    output wire                                 o_fas_conf_cnt_done,
    output wire      [NB_FRAME_CNT-1:0]         o_fas_loss_count,

    output wire      [NB_IN*N_MID+1-1:0]        o_fifo_o_rdata ,
    output wire                                 o_fifo_o_rempty,
    output wire                                 o_fifo_o_wfull,
    output wire                                 o_fifo_o_valid, 
    output wire      [NB_IN*N_MID+1-1:0]        o_fifo_i_conc_data, 

    output wire                                 o_sd_o_valid,

    output wire      [NB_IN*N_MID-1:0]          o_c2_i_data,
    
    output wire      [N_END-1:0]                o_c3_o_sof_bus,
    output wire      [N_MID-1:0]                o_c3_i_sof_bus
);

    //LOCAL PARAM-----------------------------------------------------------------//
    localparam                                  NB_SD        = 64;
    localparam                                  NB_FIFO_DATA = NB_IN*N_MID+1;

    //SIGANLS---------------------------------------------------------------------//
    wire          [NB_IN*N_MID-1:0]             c1_o_data;
    wire                                        c1_o_valid;
    wire                                        fas_o_sof;
    wire                                        fas_o_lock;  

    wire          [NB_FIFO_DATA-1:0]            fifo_o_rdata ;
    wire                                        fifo_o_rempty;
    wire                                        fifo_o_wfull ;
    wire          [NB_FIFO_DATA-1:0]            fifo_i_conc_data;

    wire          [NB_IN*N_END-1:0]             c2_o_data;
    wire                                        c2_o_valid;  
    wire          [NB_IN*N_MID-1:0]             c2_i_data;

    wire          [N_END-1:0]                   c3_o_sof_bus;
    wire                                        c3_o_valid;
    wire          [N_MID-1:0]                   c3_i_sof_bus;
    
    //ALGORITHM-------------------------------------------------------------------//
    parallel_conv_1_n
    #(
        //PARAMS------------------------------//
        .NB_DATA                    (NB_IN            ),
        .N                          (N_MID            ),
        .MSB_IS_NEWER               (MSB_IS_NEWER     )
    )
    u_parallel_conv_1_n_c1
    (
        //OUTPUTS------------------------------//
        .o_data                     (c1_o_data        ),
        .o_valid                    (c1_o_valid       ),
        
        //INPUTS-------------------------------//
        .i_data                     (i_data           ),
        .i_reset                    (i_wrst           ),
        .i_valid                    (i_valid          ),
        .i_clock                    (i_wclk           ),

        //DEBUG--------------------------------//
        .o_count                    (/*UNCONNECTED*/  ), 
        .o_count_full               (/*UNCONNECTED*/  ), 
        .o_shifter                  (/*UNCONNECTED*/  )
    );

    seq_aligner
    #(
        //PARAMS------------------------------//
        .NB_DATA                    (NB_IN*N_MID             ),
        .NB_FRAME_CNT               (NB_FRAME_CNT            ),
        .NB_CONF                    (NB_CNT                  ),
        .NB_LOSS                    (NB_CNT                  ),
        .NB_FAS                     (NB_FAS                  )
    )   

    u_seq_aligner   
    (   
        //OUTPUTS------------------------------//
        .o_sof                      (fas_o_sof               ),
        .o_lock                     (fas_o_lock              ),

        //INPUTS-------------------------------//
        .i_data                     (c1_o_data               ),
        .i_valid                    (c1_o_valid              ),
        .i_rf_static_fas            (i_rf_static_fas         ),
        .i_rf_static_frame_clocks   (i_rf_static_frame_clocks),
        .i_n_conf                   (i_rf_static_n_conf      ),
        .i_n_loss                   (i_rf_static_n_loss      ),
        .i_clock                    (i_wclk                  ),
        .i_reset                    (i_wrst                  ),

        //DEBUG--------------------------------//
        .o_search_count             (o_fas_search_count     ),
        .o_match                    (o_fas_match            ),
        .o_conf_cnt_done            (o_fas_conf_cnt_done    ),
        .o_loss_count               (o_fas_loss_count       )
    );

    assign  fifo_i_conc_data = {c1_o_data, fas_o_sof};

    async_fifo
    #(
        //PARAMS------------------------------//
        .NB_DATA                     (NB_FIFO_DATA    ),
        .NB_ADRESS                   (NB_ADRESS       )
    )
    u_async_fifo
    (
        //OUTPUTS------------------------------//
        .o_rdata                     (fifo_o_rdata    ),
        .o_rempty                    (fifo_o_rempty   ),
        .o_wfull                     (fifo_o_wfull    ),
        .o_valid                     (fifo_o_valid    ),

        //INPUTS-------------------------------//
        .i_wdata                     (fifo_i_conc_data),
        .i_winc                      (c1_o_valid      ),
        .i_wclk                      (i_wclk          ),
        .i_wrst                      (i_wrst          ),
        .i_rinc                      (sd_o_valid_r    ),
        .i_rclk                      (i_rclk          ),
        .i_rrst                      (i_rrst          ),

        //DEBUG--------------------------------//
        .o_rptr                      (/*UNCONNECTED*/ ),   
        .o_wptr                      (/*UNCONNECTED*/ ),   
        .o_rptr_sync                 (/*UNCONNECTED*/ ), 
        .o_wptr_sync                 (/*UNCONNECTED*/ ), 
        .o_wptr_q1                   (/*UNCONNECTED*/ ), 
        .o_raddr                     (/*UNCONNECTED*/ ), 
        .o_waddr                     (/*UNCONNECTED*/ )  
    );

    /*
        f_w*rate_v_w = f_r*rate_v_r
        f_w*(1/5) = (f_w*5/3)*rate_v_r
        rate_v_r = (1/5)*(3/5) = 3/25
    */
    sigma_delta
    #(
        //PARAMS------------------------------//
        .NB_SD                       (NB_SD       )
    )
    u_t_sigma_delta_r
    (
        //OUTPUTS------------------------------//
        .o_valid                     (sd_o_valid_r),

        //INPUTS-------------------------------//
        .i_num                       (3           ),
        .i_den                       (25          ),
        .i_valid                     (i_valid     ),
        .i_reset                     (i_rrst      ),
        .i_clock                     (i_rclk      )
    );

    assign  c2_i_data    = fifo_o_rdata[NB_FIFO_DATA-1:1];

    generate
        if (MSB_IS_NEWER == 0)
        begin
            assign  c3_i_sof_bus = {fifo_o_rdata[0], 4'h0000};
            assign  o_regen_sof  = c3_o_sof_bus[N_END-1] && c2_o_valid;
        end
        else
        begin
            assign  c3_i_sof_bus = {4'b0000, fifo_o_rdata[0]};
            assign  o_regen_sof  = c3_o_sof_bus[0] && c2_o_valid;
        end
    endgenerate
    
    parallel_conv_5_3
    #(
        //PARAMS------------------------------//
        .NB_DATA                     (NB_IN          ),
        .MSB_IS_NEWER                (MSB_IS_NEWER   )
    )
    u_parallel_conv_5_3_c2
    (
        //OUTPUTS------------------------------//
        .o_data                      (c2_o_data      ), 
        .o_valid                     (c2_o_valid     ),

        //INPUTS-------------------------------//  
        .i_data                      (c2_i_data      ),
        .i_reset                     (i_rrst         ),
        .i_valid                     (fifo_o_valid   ),
        .i_clock                     (i_rclk         ),

        //DEBUG--------------------------------//
        .o_count                     (/*UNCONNECTED*/),                
        .o_cnt_main                  (/*UNCONNECTED*/),                 
        .o_cnt_aux                   (/*UNCONNECTED*/),               
        .o_count_full                (/*UNCONNECTED*/),                 
        .o_shifter                   (/*UNCONNECTED*/)          
    );

    parallel_conv_5_3
    #(
        //PARAMS------------------------------//
        .NB_DATA                     (1'b1           ),
        .MSB_IS_NEWER                (MSB_IS_NEWER   )
    )
    u_parallel_conv_5_3_c3
    (
        //OUTPUTS------------------------------//
        .o_data                      (c3_o_sof_bus   ), 
        .o_valid                     (c3_o_valid     ),

        //INPUTS-------------------------------//  
        .i_data                      (c3_i_sof_bus   ),
        .i_reset                     (i_rrst         ),
        .i_valid                     (fifo_o_valid   ),
        .i_clock                     (i_rclk         ),

        //DEBUG--------------------------------//
        .o_count                     (/*UNCONNECTED*/),                
        .o_cnt_main                  (/*UNCONNECTED*/),                 
        .o_cnt_aux                   (/*UNCONNECTED*/),               
        .o_count_full                (/*UNCONNECTED*/),                 
        .o_shifter                   (/*UNCONNECTED*/)          
    );

    assign  o_c2_o_valid       = c2_o_valid;
    assign  o_c2_o_data        = c2_o_data;

    //DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG
    assign  o_c1_o_data        = c1_o_data;
    assign  o_c1_o_valid       = c1_o_valid;
    assign  o_fas_o_sof        = fas_o_sof;
    assign  o_fas_o_lock       = fas_o_lock;
    assign  o_fifo_o_rdata     = fifo_o_rdata;
    assign  o_fifo_o_rempty    = fifo_o_rempty;
    assign  o_fifo_o_wfull     = fifo_o_wfull;
    assign  o_fifo_o_valid     = fifo_o_valid;
    assign  o_fifo_i_conc_data = fifo_i_conc_data;
    assign  o_sd_o_valid       = sd_o_valid_r;
    assign  o_c3_o_sof_bus     = c3_o_sof_bus;
    assign  o_c2_i_data        = c2_i_data;
    assign  o_c3_i_sof_bus     = c3_i_sof_bus;
    
endmodule

