`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Nombre: async_fifo TestBench
// ----------------------------------------------
// Autor: Gomez Augusto
// ----------------------------------------------
//////////////////////////////////////////////////////////////////////////////////

module async_fifo_tb();

    //LOCALPARAM-------------------------------------------------------------------//
    localparam                                  CLK_HALF_P        = 50;
    localparam                                  NB_DATA           = 8;

    //FIFO        
    localparam                                  NB_ADRESS         = 3;
    localparam                                  NB_PTR            = NB_ADRESS +1;

    //GEN & CHECK
    localparam                                  TAP1              = 11;
    localparam                                  TAP2              = 9; //[HINT] NB_DATA > TAP1 > TAP2.
    localparam                                  F_MINLOG2_NB_DATA = $clog2(NB_DATA);
    localparam                                  NB_COUNTER        = 32;
    localparam                                  MSB_IS_NEWER      = 0;

    //SIGMA DELTA VALID
    localparam                                  NB_SD             = 64;

    //SIGNALS----------------------------------------------------------------------//
    wire                                        tb_i_wclk, tb_i_rclk;
    reg                                         tb_i_wrst, tb_i_rrst;
    reg         [NB_DATA-1:0]                   tb_i_wdata; 

    //FIFO
    wire        [NB_DATA-1:0]                   fifo_o_rdata;
    wire                                        fifo_o_rempty;
    wire                                        fifo_o_valid;
    wire                                        fifo_o_wfull;
    reg                                         fifo_i_winc;
    reg                                         fifo_i_rinc;
    wire        [NB_ADRESS:0]                   fifo_o_rptr;      //DEBUG
    wire        [NB_ADRESS:0]                   fifo_o_wptr;      //DEBUG
    wire        [NB_ADRESS:0]                   fifo_o_rptr_sync; //DEBUG
    wire        [NB_ADRESS:0]                   fifo_o_wptr_sync; //DEBUG
    wire        [NB_ADRESS:0]                   fifo_o_wptr_q1;   //DEBUG
    wire        [NB_ADRESS-1:0]                 fifo_o_raddr;     //DEBUG
    wire        [NB_ADRESS-1:0]                 fifo_o_waddr;     //DEBUG


    //PRBS GEN
    wire        [NB_DATA-1:0]                   gen_o_data_out;
    reg                                         gen_i_start;
    reg                                         gen_i_valid;
    wire                                        gen_i_enable;

    //SIGMA DELTA VALID
    wire                                        sd_o_valid_w;
    wire                                        sd_o_valid_r;
    wire        [NB_SD-1 : 0]                   sd_i_num;
    wire        [NB_SD-1 : 0]                   sd_i_den;

    //PRBS CHECK
    wire                                        check_o_prbs_in_lock;
    wire        [NB_DATA-1:0]                   check_i_data_in;
    wire        [F_MINLOG2_NB_DATA-1:0]         check_i_bad_word_ones_threshold; //1
    wire        [NB_COUNTER-1:0]                check_i_bad_word_limit; //3

    //CLK INSTANCE-----------------------------------------------------------------//
    //WRITING CLOCK (NORMAL)
    t_clock_generator
    #(
        .HALF_PERIOD            (CLK_HALF_P),
        .JITTER_ENABLE          (1'b0),
        .MAX_VALUE              (1'b0)
    )
    u_t_clock_generator_1
    (
        .o_clock                (tb_i_wclk)
    );

    //READING CLOCK (JITTER ADDED)
    t_clock_generator
    #(
        .HALF_PERIOD            (CLK_HALF_P), 
        .JITTER_ENABLE          (1'b1),
        .MAX_VALUE              (10) 
    )
    u_t_clock_generator_2
    (
        .o_clock                (tb_i_rclk)
    );

    //STIMULUS SIGNAL--------------------------------------------------------------//
    assign check_i_bad_word_ones_threshold = 1; 
    assign check_i_bad_word_limit          = 3; 
    assign gen_i_enable                    = 1;
    assign sd_i_num                        = 1;
    assign sd_i_den                        = 1;

    initial
    begin
        {tb_i_wrst, tb_i_rrst} = 2'b11;
        // tb_i_wdata             = 8'h00;
        fifo_i_winc            = 1;
        fifo_i_rinc            = 1;
        gen_i_start            = 1;
        gen_i_valid            = 1;

        repeat(1) @(posedge tb_i_wclk) //aca va el clock mas lento
        begin
            #(1) {tb_i_wrst, tb_i_rrst} = 2'b00;
            gen_i_start                 = 0;
        end

    end

    // always @(posedge tb_i_wclk)
    // begin
    //     tb_i_wdata             = tb_i_wdata +1'b1;
    //     if (tb_i_wdata == 8'hFF) tb_i_wdata = 8'h00;
    // end

    ////Reset at 1us
    // always @(posedge tb_i_wclk)
    // begin
    //     if($time() > 1000 && $time < 1100)
    //     begin
    //         {tb_i_wrst, tb_i_rrst} = 2'b11;
    //         #53 {tb_i_wrst, tb_i_rrst} = 2'b00;
    //     end
    // end

    //DUT INSTANCE-----------------------------------------------------------------//

    t_prbs_generator
    #(
        .NB_DATA                                (NB_DATA),
        .TAP1                                   (TAP1),
        .TAP2                                   (TAP2),  // TAP1 > TAP2.
        .MSB_IS_NEWER                           (MSB_IS_NEWER)
    )
    u_t_prbs_generator
    (
        .o_data_out                             (gen_o_data_out),
        .i_start_gen                            (gen_i_start),
        .i_valid                                (sd_o_valid_w),
        .i_enable                               (gen_i_enable),
        .i_reset                                (tb_i_wrst),
        .clock                                  (tb_i_wclk)
    );

    sigma_delta
    #(
        .NB_SD                                  (NB_SD)
    )
    u_t_sigma_delta_w
    (
        .o_valid                                (sd_o_valid_w),
        .i_num                                  (sd_i_num),
        .i_den                                  (sd_i_den),
        .i_valid                                (gen_i_valid),
        .i_reset                                (tb_i_wrst),
        .i_clock                                (tb_i_wclk)
    );

    t_prbs_checker
    #(
        .NB_DATA                                (NB_DATA),
        .F_MINLOG2_NB_DATA                      (F_MINLOG2_NB_DATA),
        .NB_COUNTER                             (NB_COUNTER),
        .TAP1                                   (TAP1),
        .TAP2                                   (TAP2), // TAP1 > TAP2.
        .MSB_IS_NEWER                           (MSB_IS_NEWER)
    )
    u_t_prbs_checker
    (
        .o_prbs_in_lock                         (check_o_prbs_in_lock),
        .i_data_in                              (fifo_o_rdata),
        .i_valid                                (sd_o_valid_r),
        .i_bad_word_ones_threshold              (check_i_bad_word_ones_threshold),
        .i_bad_word_limit                       (check_i_bad_word_limit),
        .i_reset                                (tb_i_rrst),
        .clock                                  (tb_i_rclk)
    );

    async_fifo
    #(
        //PARAMETER--------------------------------------------------------//
        .NB_DATA                                (NB_DATA  ),
        .NB_ADRESS                              (NB_ADRESS)
    )
    u_async_fifo
    (
        //OUTPUT----------------------------------------------------------//
        .o_rdata                                (fifo_o_rdata ),
        .o_rempty                               (fifo_o_rempty),
        .o_wfull                                (fifo_o_wfull ),
        .o_valid                                (fifo_o_valid ),

        //INPUT-----------------------------------------------------------//
        .i_wdata                                (gen_o_data_out  ),
        .i_winc                                 (sd_o_valid_w    ),
        .i_wclk                                 (tb_i_wclk       ),
        .i_wrst                                 (tb_i_wrst       ),
        .i_rinc                                 (sd_o_valid_r    ),
        .i_rclk                                 (tb_i_rclk       ),
        .i_rrst                                 (tb_i_rrst       ),
        .o_rptr                                 (fifo_o_rptr     ), //DEBUG    
        .o_wptr                                 (fifo_o_wptr     ), //DEBUG    
        .o_rptr_sync                            (fifo_o_rptr_sync), //DEBUG
        .o_wptr_sync                            (fifo_o_wptr_sync), //DEBUG
        .o_wptr_q1                              (fifo_o_wptr_q1  ), //DEBUG
        .o_raddr                                (fifo_o_raddr    ), //DEBUG
        .o_waddr                                (fifo_o_waddr    )  //DEBUG
    );

    //Additional sigma delta for control reading rate
    sigma_delta
    #(
        .NB_SD                                  (NB_SD)
    )
    u_t_sigma_delta_r
    (
        .o_valid                                (sd_o_valid_r),
        .i_num                                  (1),
        .i_den                                  (1),
        .i_valid                                (gen_i_valid),
        .i_reset                                (tb_i_rrst),
        .i_clock                                (tb_i_rclk)
    );

    //FUNCTIONS--------------------------------------------------------------------//
    //gray2bin
    // assign fifo_o_rptr_sync_bin[NB_PTR-1] = fifo_o_rptr_sync[NB_PTR-1];
    // assign fifo_o_wptr_sync_bin[NB_PTR-1] = fifo_o_wptr_sync[NB_PTR-1];
    // assign fifo_o_wptr_q1_bin[NB_PTR-1]   = fifo_o_wptr_q1[NB_PTR-1];
    // assign fifo_o_rptr_bin[NB_PTR-1]      = fifo_o_rptr[NB_PTR-1];
    // assign fifo_o_wptr_bin[NB_PTR-1]      = fifo_o_wptr[NB_PTR-1];
    // for(genvar i=NB_PTR-2;i>=0;i=i-1)
    // begin
    //     xor(fifo_o_rptr_sync_bin[i],fifo_o_rptr_sync[i],fifo_o_rptr_sync_bin[i+1]);
    //     xor(fifo_o_wptr_sync_bin[i],fifo_o_wptr_sync[i],fifo_o_wptr_sync_bin[i+1]);
    //     xor(fifo_o_wptr_q1_bin[i],fifo_o_wptr_q1[i],fifo_o_wptr_q1_bin[i+1]);
    //     xor(fifo_o_rptr_bin[i],fifo_o_rptr[i],fifo_o_rptr_bin[i+1]);
    //     xor(fifo_o_wptr_bin[i],fifo_o_wptr[i],fifo_o_wptr_bin[i+1]);
    // end
endmodule
