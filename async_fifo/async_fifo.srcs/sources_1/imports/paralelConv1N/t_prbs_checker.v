/*------------------------------------------------------------------------------
 -- Project     : CL100GC
 -------------------------------------------------------------------------------
 -- File        : elm_marker_handler_tx_fix_generator.v
 -- Author      : Ramiro R. Lopez
 -- Originator  : Clariphy Argentina S.A.
 -- Date        : 2012/02/29
 --
 -- Rev 0       : Initial release. RRL.
 --
 --
 -- $Id: t_prbs_checker.v 3323 2015-01-22 17:35:27Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : .
 -------------------------------------------------------------------------------
 -- Copyright (C) 2010 ClariPhy Argentina S.A.  All rights reserved.
 -----------------------------------------------------------------------------*/

module t_prbs_checker
#(
    // PARAMETERS.
    parameter                                   NB_DATA                 = 160,
    parameter                                   F_MINLOG2_NB_DATA       = 8,
    parameter                                   NB_COUNTER              = 10,
    parameter                                   TAP1                    = 7,
    parameter                                   TAP2                    = 6,    // TAP1 > TAP2.
    parameter                                   MSB_IS_NEWER            = 1
)
(
    // OUTPUTS.
    output  wire                                o_prbs_in_lock,

    // INPUTS.
    input   wire    [NB_DATA-1:0]               i_data_in,
    input   wire                                i_valid,
    input   wire    [F_MINLOG2_NB_DATA-1:0]     i_bad_word_ones_threshold,  // 1
    input   wire    [NB_COUNTER-1:0]            i_bad_word_limit,           // 3
    // Clock and reset signals.
    input   wire                                i_reset,
    input   wire                                clock
);

    /* // BEGIN: Quick instance.
    t_prbs_checker
    #(
        .NB_DATA                    ( 160   ),
        .F_MINLOG2_NB_DATA          (       ),
        .NB_COUNTER                 (       ),
        .TAP1                       ( 7     ),
        .TAP2                       ( 6     ),  // TAP1 > TAP2.
        .MSB_IS_NEWER               ( 1     )
    )
    u_t_prbs_checker
    (
        .o_prbs_in_lock             (       ),
        .i_data_in                  (       ),
        .i_valid                    (       ),
        .i_bad_word_ones_threshold  (       ),
        .i_bad_word_limit           (       ),
        .i_reset                    (       ),
        .clock                      (       )
    );
    // END: Quick instance */

    // LOCAL PARAMETERS.
    localparam                                  NB_SHIFTER              = NB_DATA + (TAP1);
    localparam                                  SIZE_PRBS               = 2**TAP1-1;
    localparam                                  NB_STATE                = 2 ;
    localparam                                  ST_OOL                  = 0 ;
    localparam                                  ST_CONF                 = 1 ;
    localparam                                  ST_LOCK                 = 2 ;


    // INTERNAL SIGNALS.
    reg             [F_MINLOG2_NB_DATA-1:0]     n_ones;
    reg                                         bad_word;
    reg             [NB_COUNTER-1:0]            bad_word_count;
    wire                                        bad_input;
    reg             [NB_SHIFTER-1:0]            data_in_shifter;
    reg             [NB_DATA-1:0]               prbs_ok_b;
    integer                                     i;
    wire                                        prbs_in_lock_raw ;
    wire                                        lock_done ;
    wire                                        loss_done ;
    reg             [NB_STATE-1:0]              state ;
    reg             [NB_STATE-1:0]              next_state ;
    reg                                         lock ;
    reg                                         enable_conf ;
    reg                                         enable_mon ;
    integer                                     count_conf ;
    integer                                     count_mon ;
    integer                                     ia ;
    reg             [NB_DATA-1:0]               flipped_data_in ;


    // ALGORITHM BEGIN.

    // FLip input data depending on MSB_IS_NEWER.
    always  @( * )
    begin : l_flip_input
        for ( ia=0; ia<NB_DATA; ia=ia+1 )
            if ( MSB_IS_NEWER == 0 )
                flipped_data_in[ia]
                    = i_data_in[ia] ;
            else
                flipped_data_in[ia]
                    = i_data_in[NB_DATA-1-ia] ;
    end // l_flip_input


    // Esure input is not always 0: count ones inside data bus.
    // common_encoder
    // #(
    //     .NB_VECTOR      ( NB_DATA           ),
    //     .NB_ENCODER     ( F_MINLOG2_NB_DATA )
    // )
    // u_common_encoder
    // (
    //     .o_encode       ( n_ones            ),
    //     .i_vector       ( flipped_data_in   )
    // );

    // Common Encoder
    always @(*) 
    begin
        n_ones = 0;
        for ( ia=0; ia<NB_DATA; ia=ia+1 ) 
            n_ones = n_ones + flipped_data_in[ia];    
    end

    // Esure input is not always 0: compare number of ones in current
    // data word against the expected limit.
    always @( posedge clock )
    begin
        if ( i_valid )
            bad_word
                <= (n_ones < i_bad_word_ones_threshold);
    end


    // Esure input is not always 0: count consecutive bad_words.
    always @( posedge clock )
    begin
        if ( i_reset || (i_valid && !bad_word) )
            bad_word_count
                <= {NB_COUNTER{1'b0}};
        else if ( i_valid )
            bad_word_count
                <= ( bad_input )? bad_word_count : bad_word_count + {{NB_COUNTER-1{1'b0}}, 1'b1};
    end


    // Bad input flag.
    assign  bad_input
                = ( bad_word_count > i_bad_word_limit );


    // Shift data to check for PRBS property continuity between consecutive
    // words.
    always @( posedge clock )
    begin
        if ( i_valid )
            data_in_shifter
                <= { data_in_shifter[NB_SHIFTER-1-NB_DATA:0], flipped_data_in };
    end


    // Evaluate if input words meet PRBS property.
    always @( posedge clock )
    begin
        if ( i_valid )
            for ( i=0; i<NB_DATA; i=i+1 )
            begin
                prbs_ok_b[i]
                    <= data_in_shifter[i] ^ data_in_shifter[i+(TAP2)] ^ data_in_shifter[i+(TAP1)];
            end
    end
    assign  prbs_in_lock_raw
                = ~bad_input & ~(|prbs_ok_b) ;


    // FSM: update state.
    always @( posedge clock )
    begin
        if ( i_reset )
            state
                <= ST_OOL ;
        else if ( i_valid )
            state
                <= next_state ;
    end


    // FSM: next state.
    always @( * )
    begin
        case ( state )

            ST_OOL :
            begin : case_OOL
                casez   ( {prbs_in_lock_raw, lock_done, loss_done} )
                    3'b1??  :   next_state  = ST_CONF ;
                    default :   next_state  = ST_OOL ;
                endcase
                lock        = 1'b0 ;
                enable_conf = 1'b0 ;
                enable_mon  = 1'b0 ;
            end // case_OOL

            ST_CONF :
            begin : case_CONF
                casez   ( {prbs_in_lock_raw, lock_done, loss_done} )
                    3'b0??  :   next_state  = ST_OOL ;
                    3'b11?  :   next_state  = ST_LOCK ;
                    default :   next_state  = ST_CONF ;
                endcase
                lock        = 1'b0 ;
                enable_conf = 1'b1 ;
                enable_mon  = 1'b0 ;
            end // case_CONF

            ST_LOCK :
            begin : case_LOCK
                casez   ( {prbs_in_lock_raw, lock_done, loss_done} )
                    3'b??1  :   next_state  = ST_OOL ;
                    default :   next_state  = ST_LOCK ;
                endcase
                lock        = 1'b1 ;
                enable_conf = 1'b0 ;
                enable_mon  = ~prbs_in_lock_raw ;
            end // case_CONF

            default :
            begin : case_default
                casez   ( {prbs_in_lock_raw, lock_done, loss_done} )
                    3'b1??  :   next_state  = ST_CONF ;
                    default :   next_state  = ST_OOL ;
                endcase
                lock        = 1'b0 ;
                enable_conf = 1'b0 ;
                enable_mon  = 1'b0 ;
            end // case_default

        endcase // state
    end


    always @( posedge clock )
    begin
        if ( i_reset || (i_valid && !enable_conf) )
            count_conf
                <= 0 ;
        else if ( i_valid && prbs_in_lock_raw )
            count_conf
                <= count_conf + 1 ;
    end
    assign  lock_done
                = (count_conf >= 9) ;


    always @( posedge clock )
    begin
        if ( i_reset || (i_valid && !enable_mon) )
            count_mon
                <= 0 ;
        else if ( i_valid && ~prbs_in_lock_raw )
            count_mon
                <= count_mon + 1 ;
    end
    assign  loss_done
                = (count_mon >= 1) ;


    assign  o_prbs_in_lock
                = lock & ~(|prbs_ok_b) ;


 // always @( posedge clock )
 // begin
 //     if ( i_reset )
 //     begin
 //         p_data_mcm
 //             <= 0;
 //         count_p
 //             <= 0;
 //         p_data_mcm_locked
 //             <= 0;
 //     end
 //     else if ( i_valid )
 //     begin
 //         p_data_mcm
 //             <= { p_data_mcm[MCM-1-NB_DATA:0], i_data_in };
 //         count_p
 //             <= ( count_p == (SIZE_PRBS-1) )? 0 : count_p + 1'b1;
 //         if ( count_p == (SIZE_PRBS-1) )
 //             p_data_mcm_locked
 //                 <= p_data_mcm;
 //     end
 // end


endmodule // elm_marker_handler_tx_prbs_generator
