`timescale 1ns / 1ps

/* 
Ejercicio #3
----------------------------------------------
Nombre: N_Adder
----------------------------------------------
Autor: Gomez Augusto
----------------------------------------------
Consigna:
(01) Escribir el codigo RTL de un sumador de N_TERM elementos (N_TERM es un parametro del módulo) de NB_DATA bits cada elemento. N_TERM es pot de 2.
Los datos de entrada vienen juntos (concatenados) en un bus llamado i_data_bus. i_data_bus[NB_DATA-1:0] tiene el primer dato de entrada,
i_data_bus[2*NB_DATA-1:NB_DATA] tiene el segundo dato de entrada, i_data_bus[3*NB_DATA-1:2*NB_DATA] tiene el tercero dato de entrada, y
asi sucesivamente. El tamanio de la salida "suma" (o_sum) tiene que ser tambien de NB_DATA. La salida debe estar registrada.
Para escribir el modulo, usar un bloque "always" que contenga un bucle "for".

(02) Idem anterior, pero en lugar de usar un bloque "always", usar un bloque generate que arme una estructura de interconeccion lo
mas optima posible. La salida del bloque tambien debe registarse.
Ayuda: para sumar N elementos hacen falta N-1 sumas auxiliares/sumadores.

(03) Escribir un testbench donde se generen entradas de forma aleatoria y se compare la salida de los modulos del punt (01) y (02)
 */

module basic_adder
#(    
    //PARAMS
    parameter  NB_DATA= 8
)
(
    //PORTS
    input  wire  [NB_DATA-1: 0]     in1,
    input  wire  [NB_DATA-1: 0]     in2,
    output reg   [NB_DATA-1: 0]     out
);
    //ALGORITHM
    always @(*) 
        out= in1+ in2; 

endmodule

module n_adder
#(    
    //PARAMS
    parameter N_TERM= 8,
    parameter NB_DATA= 8,
    parameter SELECT= 1'b0
)
(
    //OUTPUTS
    output  wire [NB_DATA-1: 0]               o_sum,
    
    //INPUTS
    input   wire [N_TERM*NB_DATA-1: 0]        i_data_bus,
    input   wire                              i_clock
);
    //LOCAL PARAM
    localparam TOT_LAYER= $clog2(N_TERM);
     
    //ALGORITHM
    generate
        if (SELECT) 
        begin
            //ALWAYS-FOR-BASED ADDER
            integer                              i;
            reg [NB_DATA-1: 0]                   aux;  
            always @(*) 
            begin
                aux=i_data_bus[NB_DATA-1 -: NB_DATA];
                for (i= 1; i< N_TERM; i= i+1) 
                begin
                    aux=aux+ i_data_bus[(i+1)*NB_DATA-1 -: NB_DATA];
                end
            end
            assign o_sum= aux;    
        end
        else 
        begin
            //GENERATE-FOR-BASED ADDER (BINARY TREE)
            genvar i, j;
            wire [NB_DATA-1: 0]     in1 [N_TERM-2: 0];
            wire [NB_DATA-1: 0]     in2 [N_TERM-2: 0];
            wire [NB_DATA-1: 0]     out [N_TERM-2: 0];

            for (i= 0; i< TOT_LAYER; i= i+1) 
            begin  
                if (i==0)
                begin
                    for(j= 0; j< N_TERM/2; j= j+1)
                    begin 
                        assign in1[j]= i_data_bus[(2*j+1)*NB_DATA-1 -: NB_DATA];
                        assign in2[j]= i_data_bus[(2*j+2)*NB_DATA-1 -: NB_DATA];
                        basic_adder
                        #(
                            .NB_DATA                (NB_DATA)
                        )
                        u_basic_adder
                        (
                            .out                    (out[j]),          
                            .in1                    (in1[j]),     
                            .in2                    (in2[j])          
                        );
                    end
                end
                else 
                begin
                    for(j= 0; j< N_TERM/(2**(i+1)); j= j+1)
                    begin
                        assign in1[N_TERM-N_TERM/(2**i)+j]= out[N_TERM-N_TERM/(2**(i-1))+2*j];
                        assign in2[N_TERM-N_TERM/(2**i)+j]= out[N_TERM-N_TERM/(2**(i-1))+2*j+1];
                        basic_adder
                        #(
                            .NB_DATA                (NB_DATA)
                        )
                        u_basic_adder
                        (
                            .out                    (out[N_TERM-N_TERM/(2**i)+j]),          
                            .in1                    (in1[N_TERM-N_TERM/(2**i)+j]),     
                            .in2                    (in2[N_TERM-N_TERM/(2**i)+j])          
                        );
                    end
                    if(i== TOT_LAYER-1)
                        assign o_sum= out[N_TERM-2];
                end
            end
        end    
    endgenerate
endmodule

