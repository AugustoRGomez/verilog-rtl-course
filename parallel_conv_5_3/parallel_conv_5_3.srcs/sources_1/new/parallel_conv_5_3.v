`timescale 1ns / 1ps
/* 
Ejercicio #5
----------------------------------------------
Nombre: parallel_conv_5_3
----------------------------------------------
Autor: Gomez Augusto
----------------------------------------------
[ converter_5to3 ]

(05c) Similar al ejercicio anterior, pero en este caso la relacion de tamanio
entre la entrada y la salida es de 5 a 3.
Es decir, la entrada esta dada de la siguiente forma:
    input   wire    [CONST_5*NB_DATA-1:0]     i_data ,
y la salida:
    output  wire    [CONST_3*NB_DATA-1:0]     o_data ,
donde: CONST_5=5 y CONST_3=3 (se los declara como parametros para evitar warnings
de LINT).

Observacion: preferentemente no aplicar la metodologia de FSM. Utilizar la menor
cantidad de registros posibles.

(05d) Escribir testbench similar al del conversor 1 to n (simil 05b).

TODO
    Agregar generate msb_is_new x
 */

module parallel_conv_5_3
#(
    //PARAMS ------------------------------------------------------------------//
    parameter                                           NB_DATA      = 8,
    parameter                                           CONST_5      = 5,
    parameter                                           CONST_3      = 3,
    parameter                                           MSB_IS_NEWER = 0
)
(
    //OUTPUTS -----------------------------------------------------------------//
    output reg      [CONST_3*NB_DATA-1: 0]             o_data, 
    output reg                                         o_valid,
    output wire     [32-1:0]                           o_count,         //DEBUG              
    output wire     [32-1:0]                           o_cnt_main,      //DEBUG                 
    output wire     [32-1:0]                           o_cnt_aux,       //DEBUG                 
    output wire                                        o_count_full,    //DEBUG                 
    output wire     [(CONST_3+CONST_5+1)*NB_DATA-1: 0] o_shifter,       //DEBUG                 
    
    //INPUTS ------------------------------------------------------------------//
    input wire      [CONST_5*NB_DATA-1: 0]             i_data,
    input wire                                         i_reset,
    input wire                                         i_valid,
    input wire                                         i_clock
);         
    //LOCAL_PARAMS ------------------------------------------------------------//
    localparam                                         NB_COUNTER = 8;
    localparam                                         NB_SHIFTER = (CONST_5+CONST_3+1)*NB_DATA; //9*NB_DATA
    localparam                                         CONST_6    = 6;
    localparam                                         CONST_4    = 4;
    localparam                                         CONST_2    = 2;
        
    //SIGNALS -----------------------------------------------------------------//
    reg             [NB_SHIFTER-1: 0]                  shifter;
    wire            [NB_COUNTER-1: 0]                  cnt; 
    reg             [NB_COUNTER-1: 0]                  cnt_main;
    reg             [NB_COUNTER-1: 0]                  cnt_aux;
    wire                                               cnt_full;
    integer                                            i;

    //ALGORITHM ---------------------------------------------------------------//
    /*
        Shifter:
        8   7   6   5   4   3   2   1   0
        /------------//------------------/
             aux              main

        *cuando el dato es válido, este siempre se coloca en la parte "main" del shifter (al menos en msb_is_newer=0).
        *cnt_main y cnt_aux contabilizan la cantidad de elementos en las partes respectivas del shifter.
    */

    always @(posedge i_clock)
    begin: CNT
        if (i_reset)
            {cnt_main, cnt_aux} <= {CONST_2*NB_COUNTER{1'b0}};
        else if (i_valid)
        begin
            cnt_main <= CONST_5;
            cnt_aux  <= (cnt_main >= CONST_3)? cnt_main+cnt_aux-CONST_3: cnt_main;
        end
        else if (cnt_full) //pregunto por cnt_full de lo contrario ocurre underflow al principio
        begin
            cnt_main <= (cnt_aux >= CONST_3)? CONST_5: cnt_main+cnt_aux-CONST_3;
            cnt_aux  <= (cnt_aux >= CONST_3)? cnt_aux-CONST_3: 1'b0;
        end
    end 
    
    assign cnt      = cnt_main + cnt_aux;
    assign cnt_full = (cnt >= CONST_3); //hay datos suficientes para generar una salida

    generate
        if (MSB_IS_NEWER == 0)
        begin
            always @(posedge i_clock)
            begin
                if (i_reset)
                    shifter <= {NB_SHIFTER{1'b0}};
                else if (i_valid)
                begin
                    shifter <= {shifter[CONST_4*NB_DATA-1: 0], i_data}; 
                end
            end
        end
        else
        begin
            always @(posedge i_clock)
            begin
                if (i_reset)
                    shifter <= {NB_SHIFTER{1'b0}};
                else if (i_valid)
                begin
                    shifter <= {i_data, shifter[NB_SHIFTER-1 -: CONST_4*NB_DATA]}; 
                end
            end
        end
    endgenerate

    generate
        if (MSB_IS_NEWER == 0)
        begin
            always @(posedge i_clock)
            begin
                if (i_reset)
                    {o_data, o_valid} <= {{CONST_3*NB_DATA{1'b0}}, 1'b0};
                else if (cnt_full)
                    {o_data, o_valid} <= {shifter >> (cnt-CONST_3)*NB_DATA, 1'b1};
                else 
                    o_valid <= 1'b0;
            end
        end
        else
        begin
            always @(posedge i_clock)
            begin
                if (i_reset)
                    {o_data, o_valid} <= {{CONST_3*NB_DATA{1'b0}}, 1'b0};
                else if (cnt_full)
                    {o_data, o_valid} <= {shifter >> (CONST_6+CONST_3-cnt)*NB_DATA, 1'b1};
                else 
                    o_valid <= 1'b0;
            end
        end
    endgenerate

    assign o_count      = cnt;      //DEBUG
    assign o_cnt_main   = cnt_main; //DEBUG
    assign o_cnt_aux    = cnt_aux;  //DEBUG
    assign o_count_full = cnt_full; //DEBUG
    assign o_shifter    = shifter;  //DEBUG

    // always @(*)
    // begin
    //     for(i=0; i<CONST_3; i=i+1)
    //     begin
    //         o_data[(i+1)*NB_DATA-1 -: NB_DATA]= data_out[(CONST_3-i)*NB_DATA-1 -: NB_DATA];
    //     end
    // end  

endmodule
