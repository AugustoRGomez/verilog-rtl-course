`timescale 1ns / 1ps
/* 
Ejercicio #4
----------------------------------------------
Nombre: parallel_conv_1_N
----------------------------------------------
Autor: Gomez Augusto
----------------------------------------------
(05a) Conversor de paralelismo de 1 a N
Escribir el RTL de un conversor de paralelismo "converter_1toN" con las
siguientes caracteristicas :

Parametros:
    NB_DATA             : Numero de bits de las palabras de datos.
    N                   : Paralelismo de salida (ancho N*NB_DATA).
Salidas:
    o_data              : Datos de salida.
    o_valid             : Validez de los datos de salida.
Entradas:
    i_data              : Datos de entrada.
    i_valid             : Validez de los datos de entrada.

Observacion: preferentemente no aplicar la metodologia de FSM.

(05b) Escriba el testbench para dicho bloque. Para generar/chequear datos utilice
los modulos provistos t_prbs_generator, t_prbs_checker y common_sigma_delta_control.
Con el bloque common_sigma_delta_control y la funcion $random, generar el "i_valid"
de el conversor. Usar dicho i_valid para alimentar al t_prbs_generator.
Los datos de entrada al conversor deben provenir del t_prbs_generator.
La salida del conversor (tanto datos como o_valid) deben conectarse al
t_prbs_checker.
El test deben generarse 2 patrones de i_valid: maximo aceptado por el conversor
y maximo aceptado combinado con $random.
 */

module parallel_conv_1_n
#(
    //PARAMS ------------------------------//
    parameter                           NB_DATA      = 160,
    parameter                           N            = 3, 
    parameter                           MSB_IS_NEWER = 0
)
(
    //OUTPUTS ------------------------------//
    output reg      [N*NB_DATA-1: 0]    o_data,
    output reg                          o_valid,
    output wire     [32-1:0]            o_count, //DEBUG                 
    output wire                         o_count_full, //DEBUG                 
    output wire     [N*NB_DATA-1: 0]    o_shifter, //DEBUG                 
    
    //INPUTS -------------------------------//
    input wire      [NB_DATA-1: 0]      i_data,
    input wire                          i_reset,
    input wire                          i_valid,
    input wire                          i_clock
);
    //LOCAL_PARAMS -------------------------//
    localparam                          NB_COUNTER = $clog2(N)+1;

    //SIGNALS ------------------------------//
    reg             [N*NB_DATA-1: 0]    shifter;
    reg             [NB_COUNTER-1:0]    cnt;
    wire                                cnt_full;

    //ALGORITHM ----------------------------//

    //COUNTER
    always @(posedge i_clock)
    begin: CNT
        if (i_reset)
            cnt <= {NB_COUNTER{1'b0}};
        else if (i_valid)
            cnt <= (cnt == (N-1))? {NB_COUNTER{1'b0}}: cnt+1'b1;
    end 
    assign cnt_full = (cnt == (N-1)) & i_valid;

    //SHIFTING DIRECTION BASED ON MSB_IS_NEWER PARAMETER
    generate
        if (MSB_IS_NEWER == 0)
        begin
            always @(posedge i_clock)
            begin
                if(i_reset)
                    shifter <= {N*NB_DATA{1'b0}};
                else if (i_valid)
                    shifter <= {shifter[(N-1)*NB_DATA: 0], i_data};
            end
        end
        else
        begin
            always @(posedge i_clock)
            begin
                if(i_reset)
                    shifter <= {N*NB_DATA{1'b0}};
                else if (i_valid)
                    shifter <= {i_data, shifter[N*NB_DATA-1: NB_DATA]};
            end
        end
    endgenerate

    /*
        shift vi vt do   vo
        xxxx  1  0  xxxx 0
        xxxa  1  0  xxxx 0
        xxab  1  0  xxxx 0
        xabc  1  0  xxxx 0
        abcd  1  1  xxxx 0
        bcde  1  0  abcd 1
    */
    always @(posedge i_clock)
    begin
        if (i_reset)
            {o_data, o_valid} <= {{N*NB_DATA{1'b0}}, 1'b0};
        else if (cnt_full)
            {o_data, o_valid} <= {shifter, 1'b1};
        else 
            o_valid <= 1'b0;
    end

    assign o_count = cnt; //DEBUG
    assign o_count_full = cnt_full; //DEBUG
    assign o_shifter = shifter; //DEBUG

endmodule
