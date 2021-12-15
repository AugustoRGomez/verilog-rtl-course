`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Nombre: parallel_conv_1_n TestBench
// ----------------------------------------------
// Autor: Gomez Augusto
// ----------------------------------------------
//////////////////////////////////////////////////////////////////////////////////

module parallel_conv_5_3_tb();

    //LOCAL-PARAMETERS-------------------------------------------------------//
    localparam                          CLK_HALF_P        = 50;

    localparam                          N_5               = 5; 
    localparam                          N_3               = 3; 
    localparam                          NB_DATA           = 8; //1 Byte
    localparam                          TAP1              = 11;
    localparam                          TAP2              = 9; //[HINT] NB_DATA > TAP1 > TAP2.

    localparam                          F_MINLOG2_NB_DATA = $clog2(NB_DATA);
    localparam                          NB_COUNTER        = 32;
    localparam                          MSB_IS_NEWER      = 0;

    localparam                          N                 = 3;

    localparam                          NB_SD             = 64;

    //SIGNALS----------------------------------------------------------------//
    //PRBS GEN
    wire     [N_5*NB_DATA-1:0]          gen_o_data_out;
    reg                                 gen_i_start;
    reg                                 gen_i_valid;
    wire                                gen_i_enable;
    reg                                 tb_i_reset;
    wire                                tb_i_clock;

    //SIGMA DELTA VALID
    wire                                sd_o_valid;
    wire    [NB_SD-1 : 0]               sd_i_num;
    wire    [NB_SD-1 : 0]               sd_i_den;

    //PRBS CHECK
    wire                                check_o_prbs_in_lock;
    wire    [N_5*NB_DATA-1:0]           check_i_data_in;
    wire    [F_MINLOG2_NB_DATA-1:0]     check_i_bad_word_ones_threshold; //1
    wire    [NB_COUNTER-1:0]            check_i_bad_word_limit; //3

    //CONV
    wire    [N_3*NB_DATA-1: 0]          conv_o_data;
    wire                                conv_o_valid;
    wire    [32-1:0]                    conv_o_count;      //DEBUG         
    wire    [NB_COUNTER-1: 0]           conv_o_cnt_main;   //DEBUG
    wire    [NB_COUNTER-1: 0]           conv_o_cnt_aux;    //DEBUG
    wire                                conv_o_count_full; //DEBUG         
    wire    [(N_5+N_3+1)*NB_DATA-1: 0]  conv_o_shifter;    //DEBUG         
    reg                                 conv_i_valid;         
     

    // CLOCK GEN MODEL
    t_clock_generator
    #(
        .HALF_PERIOD            (CLK_HALF_P)
    )
    u_t_clock_generator
    (
        .o_clock                (tb_i_clock)
    ) ;

    //STIMULUS SIGNAL--------------------------------------------------------//
    assign check_i_bad_word_ones_threshold = 1; 
    assign check_i_bad_word_limit          = 3; 
    assign gen_i_enable                    = 1;
    assign sd_i_num                        = 3;
    assign sd_i_den                        = 5;

    initial 
    begin
        gen_i_start = 1;
        gen_i_valid = 1;
        gen_i_valid = 1;
        conv_i_valid = 0;
        tb_i_reset = 1;
        #51 gen_i_start = 0;
        tb_i_reset = 0;
    end

    //DUT INSTANCE----------------------------------------------------------//
    t_prbs_generator
    #(
        .NB_DATA        (N_5*NB_DATA),
        .TAP1           (TAP1),
        .TAP2           (TAP2),  // TAP1 > TAP2.
        .MSB_IS_NEWER   (MSB_IS_NEWER)
    )
    u_t_prbs_generator
    (
        .o_data_out     (gen_o_data_out),
        .i_start_gen    (gen_i_start),
        .i_valid        (sd_o_valid),
        .i_enable       (gen_i_enable),
        .i_reset        (tb_i_reset),
        .clock          (tb_i_clock)
    );

    sigma_delta
    #(
        .NB_SD          (NB_SD)
    )
    u_t_sigma_delta
    (
        .o_valid        (sd_o_valid),
        .i_num          (sd_i_num),
        .i_den          (sd_i_den),
        .i_valid        (gen_i_valid),
        .i_reset        (tb_i_reset),
        .i_clock        (tb_i_clock)
    );

    t_prbs_checker
    #(
        .NB_DATA                    (N_3*NB_DATA),
        .F_MINLOG2_NB_DATA          (F_MINLOG2_NB_DATA),
        .NB_COUNTER                 (NB_COUNTER),
        .TAP1                       (TAP1),
        .TAP2                       (TAP2), // TAP1 > TAP2.
        .MSB_IS_NEWER               (MSB_IS_NEWER)
    )
    u_t_prbs_checker
    (
        .o_prbs_in_lock             (check_o_prbs_in_lock),
        .i_data_in                  (conv_o_data),
        .i_valid                    (conv_o_valid),
        .i_bad_word_ones_threshold  (check_i_bad_word_ones_threshold),
        .i_bad_word_limit           (check_i_bad_word_limit),
        .i_reset                    (tb_i_reset),
        .clock                      (tb_i_clock)
    );

    parallel_conv_5_3
    #(
        //PARAMS ------------------------------//
        .NB_DATA                    (NB_DATA),
        .MSB_IS_NEWER               (MSB_IS_NEWER)
    )
    u_parallel_conv_5_3
    (
        //OUTPUTS ------------------------------//
        .o_data                     (conv_o_data),
        .o_valid                    (conv_o_valid),
        .o_count                    (conv_o_count), //DEBUG
        .o_cnt_main                 (conv_o_cnt_main), //DEBUG
        .o_cnt_aux                  (conv_o_cnt_aux), //DEBUG
        .o_count_full               (conv_o_count_full), //DEBUG
        .o_shifter                  (conv_o_shifter), //DEBUG
        
        //INPUTS -------------------------------//
        .i_data                     (gen_o_data_out), //gen_o_data_out
        .i_reset                    (tb_i_reset),
        .i_valid                    (sd_o_valid),
        .i_clock                    (tb_i_clock)
    );

endmodule
