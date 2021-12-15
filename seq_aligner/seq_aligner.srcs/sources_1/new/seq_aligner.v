`timescale 1ns / 1ps
/* 
Ejercicio #4
----------------------------------------------
Nombre: Seq_Aligner
----------------------------------------------
Autor: Gomez Augusto
----------------------------------------------
Consigna:
(A) Escribir el RTL de un bloque que ejecute el proceso de deteccion y confirmacion de una sequencia de inicio de paquete de datos 
(FAS: frame alignment sequence). Los paquetes (frames) son de 256 bytes (2k bits, donde se incluye el FAS) y se reciben en una interfaz 
paralela "i_data" de 64 bits. La secuencia de FAS es 64'hf6f6f6282828ff00 y viene alineada al paralelismo (pero no se sabe en cual paralelismo
comienza cada frame). El bloque ademas recibe una senial de control de throughput "i_valid", que indica si los datos del clock actual son 
validos (i_valid=1) o si deben ignorarse (i_valid=0).
Como parte del proceso de deteccion, el modulo debe confirmar que el FAS aparezca cierta cantidad de frames consecutivos con el periodo 
esperado (2k bits). Para eso se usa una entrada i_n_conf, que indica justamente ese numero. Debe generarse un flag "o_lock" para indicar que
se encontro y confirmo correctamente el FAS. Tambien debe generarse un pulso "o_sof" indicando los clocks en los que deberian aparecer la 
secuencia FAS. Luego de detectar y confirmar la ubicacion de la senial FAS, el modulo debe monitorear dicha ubicacion, y si en la misma no se 
encuentra el FAS (o tiene errorres) cierta cantidad de frames seguidos, el flag se "o_lock" se debe limpiar y el bloque debe reiniciar la 
busqueda.
Implementar el modulo usando una FSM y las recomendaciones de codificacion que aplican.
(B) Si la tasa de error (BER: bit error rate) es de 1/1000, cual es la probabilidad de detectar el FAS correctamente con i_n_conf=2?
(C) Escribir un testbench que genere frames con una tasa de error de 0 y verificar visualmente el proceso de enganche de la FSM.
(D) Agregar un modo al testbench para que se pueda modificar la BER y observar visualmente el proceso de enganche y desenganche de la FSM.
 */


module seq_aligner
#(    
    //PARAMS ------------------------------//
    parameter                           NB_DATA  = 64,
    parameter                           NB_FRAME = 256*8,
    parameter                           NB_CONF  = 4,
    parameter                           NB_LOSS  = 4,
    parameter                           FAS      = 64'hf6f6f6282828ff00
            
)
(
    //OUTPUTS -----------------------------// 
    output  wire                        o_sof,
    output  wire                        o_lock,
    
    //INPUTS -----------------------------// 
    input   wire    [NB_CONF-1:0]       i_n_conf,
    input   wire    [NB_LOSS-1:0]       i_n_loss,
    input   wire    [NB_DATA-1:0]       i_data,
    input   wire                        i_valid,
    input   wire                        i_reset,
    input   wire                        i_clock

);
    //LOCAL PARAM -------------------------//
    localparam                          CNT_END         = NB_FRAME/NB_DATA;
    localparam                          NB_COUNTER      = $clog2(CNT_END)+1;

    localparam                          NB_STATE        = 2;
    localparam      [NB_STATE-1: 0]     ST_OUT_OF_LOCK  = 0;
    localparam      [NB_STATE-1: 0]     ST_CONFIRMATION = 1;
    localparam      [NB_STATE-1: 0]     ST_PRE_LOCK     = 2;
    localparam      [NB_STATE-1: 0]     ST_IN_LOCK      = 3;

    //SIGNALS----------------------------//
    wire                                match;

    reg             [NB_STATE-1:0]      state; 
    reg             [NB_STATE-1:0]      next_state;

    reg             [NB_COUNTER-1:0]    conf_count;
    reg                                 conf_cnt_enable;
    reg                                 conf_cnt_reset;
    reg                                 conf_cnt_done;

    reg             [NB_COUNTER-1:0]    loss_count;
    reg                                 loss_cnt_enable;
    reg                                 loss_cnt_reset;
    reg                                 loss_cnt_done;

    reg                                 fsmo_lock;

    reg             [NB_COUNTER-1:0]    search_count;
    reg                                 search_cnt_done;
    reg                                 search_cnt_reset;

    //ALGORITHM--------------------------//
    assign match= (FAS == i_data);
    
    //Update state
    always @(posedge i_clock) 
        if(i_reset)         state <= ST_OUT_OF_LOCK;
        else if(i_valid)    state <= next_state;
    
    //Decide next state
    always @(*) 
    begin
        next_state       = ST_OUT_OF_LOCK;
        search_cnt_reset = 1'b1;
        conf_cnt_reset   = 1'b1;
        conf_cnt_enable  = 1'b0;
        loss_cnt_reset   = 1'b1;
        loss_cnt_enable  = 1'b0;
        fsmo_lock        = 1'b0;

        case (state)
            ST_OUT_OF_LOCK:
            begin
                next_state       = (match)? ST_CONFIRMATION: ST_OUT_OF_LOCK;
                search_cnt_reset = 1'b1;
                conf_cnt_reset   = 1'b1;
                conf_cnt_enable  = 1'b0;
                loss_cnt_reset   = 1'b1;
                loss_cnt_enable  = 1'b0;
                fsmo_lock        = 1'b0;
            end
            ST_CONFIRMATION:
            begin
                casez ({conf_cnt_done, !match, search_cnt_done})
                    3'b1??:  next_state = ST_PRE_LOCK;
                    3'b?11:  next_state = ST_OUT_OF_LOCK; 
                    default: next_state = ST_CONFIRMATION;
                endcase
                search_cnt_reset = 1'b0;
                conf_cnt_reset   = 1'b0;
                conf_cnt_enable  = 1'b1;
                loss_cnt_reset   = 1'b1;
                loss_cnt_enable  = 1'b0;
                fsmo_lock        = 1'b0;
            end
            ST_PRE_LOCK:
            begin
                next_state       = ST_IN_LOCK;
                search_cnt_reset = 1'b0;
                conf_cnt_reset   = 1'b1;
                conf_cnt_enable  = 1'b0;
                loss_cnt_reset   = 1'b1;
                loss_cnt_enable  = 1'b0;
                fsmo_lock        = 1'b1;
            end
            ST_IN_LOCK:
            begin
                casez ({loss_cnt_done, match, search_cnt_done})
                    3'b1??:  next_state = ST_OUT_OF_LOCK;
                    3'b?11:  next_state = ST_PRE_LOCK;  
                    default: next_state = ST_IN_LOCK;
                endcase
                search_cnt_reset = 1'b0;
                conf_cnt_reset   = 1'b1;
                conf_cnt_enable  = 1'b0;
                loss_cnt_reset   = 1'b0;
                loss_cnt_enable  = 1'b1;
                fsmo_lock        = 1'b1;
            end
            default:
            begin
                next_state       = ST_OUT_OF_LOCK;
                search_cnt_reset = 1'b1;
                conf_cnt_reset   = 1'b1;
                conf_cnt_enable  = 1'b0;
                loss_cnt_reset   = 1'b1;
                loss_cnt_enable  = 1'b0;
                fsmo_lock        = 1'b0;
            end
        endcase
    end
    assign  o_lock = fsmo_lock;

    //Search FAS counter, it ticks each CNT_END+1 cycles
    always @(posedge i_clock) 
    begin
        if(search_cnt_reset)
            {search_count, search_cnt_done} <= {1'b1, 1'b0}; //to compensate 1 cycle lost due reset
        else if(i_valid) 
            {search_count, search_cnt_done} <= (search_count < CNT_END)? {search_count+1, 1'b0}: {{NB_COUNTER{1'b0}}, 1'b1};
    end  
    assign  o_sof  = search_cnt_done;

    //Confirmation counter
    always @(posedge i_clock) 
    begin
        if (conf_cnt_reset) 
            {conf_count, conf_cnt_done}  <= {{NB_CONF{1'b0}}, 1'b0};
        else if(conf_cnt_enable && match && search_cnt_done && i_valid)
            {conf_count, conf_cnt_done}  <= (conf_count == (i_n_conf-1))? {{NB_CONF{1'b0}}, 1'b1}: {conf_count+1, 1'b0};
    end

    //Loss counter
    always @(posedge i_clock) 
    begin
        if (loss_cnt_reset) 
            {loss_count, loss_cnt_done}  <= {{NB_LOSS{1'b0}}, 1'b0};
        else if(loss_cnt_enable && !match && search_cnt_done && i_valid)
            {loss_count, loss_cnt_done}  <= (loss_count == (i_n_loss-1))? {{NB_LOSS{1'b0}}, 1'b1}: {loss_count+1, 1'b0};
    end

    // //Edge detector for o_lock signal (no lo termine usando)
    // always @(posedge i_clock) 
    // begin
    //     if(i_valid)
    //         edge_detector_aux <= o_lock; 
    // end

endmodule