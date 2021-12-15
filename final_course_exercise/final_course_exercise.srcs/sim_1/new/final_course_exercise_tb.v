`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Nombre: final_course_exercise TestBench
// ----------------------------------------------
// Autor: Gomez Augusto
// ----------------------------------------------
//////////////////////////////////////////////////////////////////////////////////

module final_course_exercise_tb();

    //LOCALPARAM-------------------------------------------------------------------//
    localparam                           NB_IN             = 8;
    localparam                           N_MID             = 5;
    localparam                           NB_FAS            = 32;
    localparam                           NB_FRAME_CNT      = 32;
    localparam                           NB_CNT            = 3;
    localparam                           CLK_HALF_P        = 50;
    localparam                           BIT_ERR           = 10000;
    
    localparam                           NB_ADRESS         = 3;
    
    localparam                           N_END             = 3;

    //GEN & CHECK
    localparam                           TAP1              = 11;
    localparam                           TAP2              = 9; //[HINT] NB_DATA > TAP1 > TAP2.
    localparam                           F_MINLOG2_NB_DATA = $clog2(NB_IN*N_END);
    localparam                           NB_COUNTER        = 32;
    localparam                           MSB_IS_NEWER      = 0;

    //SIGNALS----------------------------------------------------------------------//
    //PRBS GEN
    wire      [NB_IN-1:0]                tb_gen_o_data_out;
    reg                                  tb_gen_i_start;
    wire                                 tb_gen_i_enable;    
    
    //PRBS CHECKER
    wire                                 tb_check_o_prbs_in_lock;
    wire      [F_MINLOG2_NB_DATA-1:0]    tb_check_i_bad_word_ones_threshold;
    wire      [NB_COUNTER-1:0]           tb_check_i_bad_word_limit;         

    //MODULE SIGNALS
    wire                                 tb_o_regen_sof;
    wire      [NB_IN*N_END-1:0]          tb_o_c2_o_data;
    wire                                 tb_o_c2_o_valid;
    reg                                  tb_i_valid;
    reg                                  tb_i_wrst;
    wire                                 tb_i_wclk;
    reg                                  tb_i_rrst;
    wire                                 tb_i_rclk;
    reg       [NB_IN-1:0]                tb_i_data;
    wire      [NB_FAS-1:0]               tb_i_rf_static_fas;
    wire      [NB_FRAME_CNT-1:0]         tb_i_rf_static_frame_clocks;
    wire      [NB_CNT-1:0]               tb_i_rf_static_n_conf;
    wire      [NB_CNT-1:0]               tb_i_rf_static_n_loss;

    //DEBUG
    wire      [NB_IN*N_MID-1:0]          tb_o_c1_o_data;
    wire                                 tb_o_c1_o_valid;
    wire                                 tb_o_fas_o_sof;
    wire                                 tb_o_fas_o_lock;
    wire      [NB_FRAME_CNT-1:0]         tb_o_fas_search_count;
    wire                                 tb_o_fas_match;
    wire                                 tb_o_fas_conf_cnt_done;
    wire      [NB_FRAME_CNT-1:0]         tb_o_fas_loss_count;
    wire      [NB_IN*N_MID+1-1:0]        tb_o_fifo_i_conc_data;
    wire      [NB_IN*N_MID+1-1:0]        tb_o_fifo_o_rdata ; 
    wire                                 tb_o_fifo_o_rempty; 
    wire                                 tb_o_fifo_o_wfull ; 
    wire                                 tb_o_fifo_o_valid;
    wire                                 tb_o_sd_o_valid;
    wire      [N_END-1:0]                tb_o_c3_o_sof_bus;
    wire      [NB_IN*N_MID-1:0]          tb_o_c2_i_data;
    wire      [N_MID-1:0]                tb_o_c3_i_sof_bus;

    //TB SIGNALS
    integer                              count_cycles;   
    integer                              i;   
    wire                                 add_fas;
    integer                              flag_add_fas; 
    reg       [N_MID*NB_IN-1:0]          test_1_word;

    //CLK INSTANCE-----------------------------------------------------------------//
    t_clock_generator
    #(
        .HALF_PERIOD            (CLK_HALF_P),
        .JITTER_ENABLE          (1'b0),
        .MAX_VALUE              (1'b0)
    )
    u_t_clock_generator_w
    (
        .o_clock                (tb_i_wclk)
    );

    t_clock_generator
    #(
        .HALF_PERIOD            (CLK_HALF_P*0.6), //Tread = (3/5)*T_write
        .JITTER_ENABLE          (1'b0),
        .MAX_VALUE              (1'b0)
    )
    u_t_clock_generator_r
    (
        .o_clock                (tb_i_rclk)
    );

    //STIMULUS SIGNAL--------------------------------------------------------------//
    assign  tb_i_rf_static_fas                 = 32'ha1a2a3a4;
    assign  tb_i_rf_static_frame_clocks        = 3*5*2; //(frame_size/i_data_size)*5_clk_cycles = (40*3*n/40)*5 = 3*5*n
    assign  tb_i_rf_static_n_conf              = 2;
    assign  tb_i_rf_static_n_loss              = 2; 
    assign  tb_gen_i_enable                    = 1;
    assign  tb_check_i_bad_word_ones_threshold = 1;
    assign  tb_check_i_bad_word_limit          = 3;         

    initial
    begin
        tb_i_wrst              = 1'b1;    
        tb_i_rrst              = 1'b1;

        tb_i_data              = {NB_IN{1'b1}}; 
        i                      = 0;
        count_cycles           = 0;
        flag_add_fas           = 0;

        test_1_word            = {tb_i_rf_static_fas, 8'hff};

        //PRBS GEN
        tb_gen_i_start         = 1;

        repeat(1) @(posedge tb_i_wclk)
        begin
            #(1) tb_i_wrst     = 1'b0;
            tb_gen_i_start     = 0;
            #(1000) tb_i_rrst  = 1'b0;
        end
    end

   //Random valid signal
    // always @(posedge tb_i_wclk)
    // begin
    //     tb_i_valid = $random;
    // end

   //Always '1' valid signal
   initial
   begin
        tb_i_valid = 1'b1;
   end

   //Data stream 1 to test frame aligner module
   always @(posedge tb_i_wclk)
   begin
       if ($time > CLK_HALF_P) 
            count_cycles  = (add_fas)? 1: count_cycles+1;
   end
   assign add_fas = (count_cycles == tb_i_rf_static_frame_clocks);

    always @(posedge tb_i_wclk)
    begin
        if(count_cycles == tb_i_rf_static_frame_clocks || flag_add_fas)
        begin
            if (MSB_IS_NEWER == 0)
                tb_i_data    = test_1_word[(N_MID*NB_IN-NB_IN*i)-1 -: NB_IN]; //los datos de entrada son de 8bits
            else
                tb_i_data    = test_1_word[(N_MID*NB_IN-NB_IN*(4-i))-1 -: NB_IN];
            i            = i+1;
            flag_add_fas = (count_cycles == 4)? 0: 1;
        end
        else 
        begin
            tb_i_data    = {NB_IN{1'b1}}; 
            i            = 0;
        end  
    end

    //Data stream 2 to test datapath using PRBS generator and checker
    t_prbs_generator
    #(
        .NB_DATA                      (NB_IN            ),
        .TAP1                         (TAP1             ),
        .TAP2                         (TAP2             ),  // TAP1 > TAP2.
        .MSB_IS_NEWER                 (MSB_IS_NEWER     )
    )
    u_t_prbs_generator
    (
        .o_data_out                   (tb_gen_o_data_out),
        .i_start_gen                  (tb_gen_i_start   ),
        .i_valid                      (tb_i_valid       ),
        .i_enable                     (tb_gen_i_enable  ),
        .i_reset                      (tb_i_wrst        ),
        .clock                        (tb_i_wclk        )
    );

    t_prbs_checker
    #(
        .NB_DATA                      (NB_IN*N_END                    ),
        .F_MINLOG2_NB_DATA            (F_MINLOG2_NB_DATA              ),
        .NB_COUNTER                   (NB_COUNTER                     ),
        .TAP1                         (TAP1                           ),
        .TAP2                         (TAP2                           ), // TAP1 > TAP2.
        .MSB_IS_NEWER                 (MSB_IS_NEWER                   )
    )
    u_t_prbs_checker
    (
        .o_prbs_in_lock               (tb_check_o_prbs_in_lock           ),
        .i_data_in                    (tb_o_c2_o_data                    ),
        .i_valid                      (tb_o_c2_o_valid                   ),
        .i_bad_word_ones_threshold    (tb_check_i_bad_word_ones_threshold),
        .i_bad_word_limit             (tb_check_i_bad_word_limit         ),
        .i_reset                      (tb_i_rrst                         ),
        .clock                        (tb_i_rclk                         )
    );



    //DUT INSTANCE-----------------------------------------------------------------//
    final_course_exercise
    #(
        //PARAMS ------------------------------//
        .NB_IN                        (NB_IN                      ),
        .NB_FAS                       (NB_FAS                     ),
        .NB_FRAME_CNT                 (NB_FRAME_CNT               ),
        .NB_CNT                       (NB_CNT                     ),
        .MSB_IS_NEWER                 (MSB_IS_NEWER               ),
        .NB_ADRESS                    (NB_ADRESS                  )
    )
    u_final_course_exercise
    (  
        //OUTPUTS------------------------------//
        .o_regen_sof                  (tb_o_regen_sof             ),

        //INPUTS-------------------------------//
        .i_wrst                       (tb_i_wrst                  ),
        .i_wclk                       (tb_i_wclk                  ),
        .i_rclk                       (tb_i_rclk                  ),
        .i_rrst                       (tb_i_rrst                  ),
        .i_valid                      (tb_i_valid                 ),
        .i_data                       (tb_i_data                  ), //usar tb_i_data para test 1, o tb_gen_o_data_out para test 2
        .i_rf_static_fas              (tb_i_rf_static_fas         ),
        .i_rf_static_frame_clocks     (tb_i_rf_static_frame_clocks),
        .i_rf_static_n_conf           (tb_i_rf_static_n_conf      ),
        .i_rf_static_n_loss           (tb_i_rf_static_n_loss      ),

        //DEBUG--------------------------------//
        .o_c1_o_data                  (tb_o_c1_o_data             ),
        .o_c1_o_valid                 (tb_o_c1_o_valid            ),
        .o_fas_o_sof                  (tb_o_fas_o_sof             ),
        .o_fas_o_lock                 (tb_o_fas_o_lock            ),
        .o_fas_search_count           (tb_o_fas_search_count      ),
        .o_fas_match                  (tb_o_fas_match             ),
        .o_fas_conf_cnt_done          (tb_o_fas_conf_cnt_done     ),
        .o_fas_loss_count             (tb_o_fas_loss_count        ),
        .o_fifo_i_conc_data           (tb_o_fifo_i_conc_data      ),
        .o_fifo_o_rdata               (tb_o_fifo_o_rdata          ),
        .o_fifo_o_rempty              (tb_o_fifo_o_rempty         ),
        .o_fifo_o_wfull               (tb_o_fifo_o_wfull          ),
        .o_fifo_o_valid               (tb_o_fifo_o_valid          ),
        .o_sd_o_valid                 (tb_o_sd_o_valid            ),
        .o_c2_o_data                  (tb_o_c2_o_data             ),
        .o_c2_o_valid                 (tb_o_c2_o_valid            ),
        .o_c3_o_sof_bus               (tb_o_c3_o_sof_bus          ),
        .o_c2_i_data                  (tb_o_c2_i_data             ),
        .o_c3_i_sof_bus               (tb_o_c3_i_sof_bus          )
    );

    //FUNCTIONS--------------------------------------------------------------------//
    // function automatic [NB_IN-1: 0] corrupt_data;
    //     input reg       [NB_IN-1: 0]  original_data;
    //     input integer                 bit_error;
    //     reg             [NB_IN-1: 0]  mask;
    //     integer                         ii;
    //     begin
    //         for (ii= 0; ii<NB_IN; ii= ii+1) 
    //         begin
    //             mask[ii] = ($urandom % bit_error == 0); 
    //         end
    //         corrupt_data = original_data ^ mask;
    //     end    
    // endfunction

endmodule

