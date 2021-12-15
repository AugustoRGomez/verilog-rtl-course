`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Nombre: parallel_conv_1_n TestBench
// ----------------------------------------------
// Autor: Gomez Augusto
// ----------------------------------------------
//////////////////////////////////////////////////////////////////////////////////

module parallel_conv_1_n_tb();

    //LOCAL-PARAMETERS----------------------------------------------------//
    localparam                          CLK_HALF_P        = 50;

    localparam                          NB_DATA           = 8;
    localparam                          TAP1              = 11;
    localparam                          TAP2              = 9;    // [HINT] NB_DATA > TAP1 > TAP2.

    localparam                          F_MINLOG2_NB_DATA = $clog2(NB_DATA);
    localparam                          NB_COUNTER        = 32;
    localparam                          MSB_IS_NEWER      = 1;

    localparam                          N                 = 3;

    //SIGNALS-------------------------------------------------------------//
    //PRBS GEN
    wire     [NB_DATA-1:0]              gen_o_data_out;
    reg                                 gen_i_start;
    reg                                 gen_i_valid;
    wire                                gen_i_enable;
    reg                                 tb_i_reset;
    wire                                tb_i_clock;

    //PRBS CHECK
    wire                                check_o_prbs_in_lock;
    wire    [N*NB_DATA-1:0]             check_i_data_in;
    wire    [F_MINLOG2_NB_DATA-1:0]     check_i_bad_word_ones_threshold;  // 1
    wire    [NB_COUNTER-1:0]            check_i_bad_word_limit;           // 3

    //CONV
    wire    [N*NB_DATA-1: 0]            conv_o_data;
    wire                                conv_o_valid;
    wire    [32-1:0]                    conv_o_count; //DEBUG         
    wire                                conv_o_count_full; //DEBUG         
    wire    [N*NB_DATA-1: 0]            conv_o_shifter; //DEBUG         
    reg                                 conv_i_valid;         

    reg     [NB_DATA-1: 0]              tb_i_data;
    integer                             i;

    // CLOCK GEN MODEL
    t_clock_generator
    #(
        .HALF_PERIOD            (CLK_HALF_P)
    )
    u_t_clock_generator
    (
        .o_clock                (tb_i_clock)
    ) ;

    //STIMULUS SIGNAL-----------------------------------------------------//
    assign check_i_bad_word_ones_threshold = 1; 
    assign check_i_bad_word_limit          = 3; 
    assign gen_i_enable                    = 1;

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

    always @(posedge tb_i_clock) 
    begin
        // conv_i_valid  = ($time() >= 1350)? 1'b1: $random(); //VALID Random() hasta 1350 ns
        // conv_i_valid  = $random();
        conv_i_valid  = 1'b1; // VALID siempre 1 
    end

    //DUT INSTANCE--------------------------------------------------------//
    t_prbs_generator
    #(
        .NB_DATA        (NB_DATA),
        .TAP1           (TAP1),
        .TAP2           (TAP2),  // TAP1 > TAP2.
        .MSB_IS_NEWER   (MSB_IS_NEWER)
    )
    u_t_prbs_generator
    (
        .o_data_out     (gen_o_data_out),
        .i_start_gen    (gen_i_start),
        .i_valid        (gen_i_valid),
        .i_enable       (gen_i_enable),
        .i_reset        (tb_i_reset),
        .clock          (tb_i_clock)
    );
    
    t_prbs_checker
    #(
        .NB_DATA                    (N*NB_DATA),
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

    parallel_conv_1_n
    #(
        //PARAMS ------------------------------//
        .NB_DATA                    (NB_DATA),
        .N                          (N),
        .MSB_IS_NEWER               (MSB_IS_NEWER)
    )
    u_parallel_conv_1_n
    (
        //OUTPUTS ------------------------------//
        .o_data                     (conv_o_data ),
        .o_valid                    (conv_o_valid),
        .o_count                    (conv_o_count), //DEBUG
        .o_count_full               (conv_o_count_full), //DEBUG
        .o_shifter                  (conv_o_shifter), //DEBUG
        
        //INPUTS -------------------------------//
        .i_data                     (gen_o_data_out),
        .i_reset                    (tb_i_reset),
        .i_valid                    (conv_i_valid),
        .i_clock                    (tb_i_clock)
    );

endmodule
