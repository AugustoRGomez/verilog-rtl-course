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
 -- $Id: t_prbs_generator.v 1755 2014-08-11 22:54:30Z rlopez $
 -------------------------------------------------------------------------------
 -- Description : .
 -------------------------------------------------------------------------------
 -- Copyright (C) 2010 ClariPhy Argentina S.A.  All rights reserved.
 -----------------------------------------------------------------------------*/

module t_prbs_generator
#(
    // PARAMETERS.
    parameter                                   NB_DATA                 = 160,
    parameter                                   TAP1                    = 7,
    parameter                                   TAP2                    = 6,    // [HINT] NB_DATA > TAP1 > TAP2.
    parameter                                   MSB_IS_NEWER            = 1
)
(
    // OUTPUTS.
    output  reg     [NB_DATA-1:0]               o_data_out,

    // INPUTS.
    input   wire                                i_start_gen,
    input   wire                                i_valid,
    input   wire                                i_enable,
    // Clock and reset signals.
    input   wire                                i_reset,
    input   wire                                clock
);



    /* // BEGIN: Quick instance.
    t_prbs_generator
    #(
        .NB_DATA        ( 160   ),
        .TAP1           ( 7     ),
        .TAP2           ( 6     ),  // TAP1 > TAP2.
        .MSB_IS_NEWER   ( 1     )
    )
    u_t_prbs_generator
    (
        .o_data_out     (       ),
        .i_start_gen    (       ),
        .i_valid        (       ),
        .i_enable       (       ),
        .i_reset        (       ),
        .clock          (       )
    );
    // END: Quick instance */


    // LOCAL PARAMETERS.
    // None so far.


    // INTERNAL SIGNALS.
    reg             [NB_DATA-1:0]               c_data_prbs_next;
    reg             [NB_DATA-1:0]               c_data_prbs;
    reg             [TAP1-1:0]                  r_stored_prbs;
    integer                                     i;
    wire            [NB_DATA+TAP1-1:0]          exp_next_seed ;


    // ALGORITHM BEGIN.


    // Calculate next prbs word, based on the LSR status.
    always @( r_stored_prbs )
    begin : l_calc_next_prbs
        for ( i=0; i<NB_DATA; i=i+1 )
            if ( i < TAP2 )
                c_data_prbs_next[i]
                    = r_stored_prbs[i] ^ r_stored_prbs[i+TAP1-TAP2];
            else if ( i<TAP1 )
                c_data_prbs_next[i]
                    = r_stored_prbs[i] ^ c_data_prbs_next[i-TAP2];
            else
                c_data_prbs_next[i]
                    = c_data_prbs_next[i-TAP1] ^ c_data_prbs_next[i-TAP2];
    end // l_calc_next_prbs


    // Update LSR, with the next calculated word.
    always @( posedge clock )
    begin : l_load_prbs_lsr
        if ( i_reset || (!i_enable) )
            r_stored_prbs
                <= {TAP1{1'b1}};
        else if ( i_valid )
        begin : l_update_on_valid
            if (  i_start_gen )
                r_stored_prbs
                    <= {TAP1{1'b1}};
            else
                r_stored_prbs
                 // <= c_data_prbs_next[NB_DATA-1 -: TAP1];
                    <= exp_next_seed[NB_DATA+TAP1-1 -: TAP1];
        end // l_update_on_valid
    end // l_load_prbs_lsr
    assign  exp_next_seed
                = { c_data_prbs_next, r_stored_prbs } ;


    // Rewire signal so MSB corresponds to older bits.
    always @( c_data_prbs_next )
    begin : l_rewire_prbs_data
        for ( i=0; i<NB_DATA; i=i+1 )
            c_data_prbs[i]
                = c_data_prbs_next[NB_DATA-1-i];
    end // l_rewire_prbs_data


    // Output update.
    always @( * )
    begin : l_update_output
        if ( !i_enable )
            o_data_out
                = {NB_DATA{1'b0}};   //(rarenas) removing blocking assignment for verilator
        else
            o_data_out
                = ( MSB_IS_NEWER!=0 )? c_data_prbs_next : c_data_prbs;
    end // l_update_output


  //// FOR DEBUG.
  //reg     [TAP1-1:0]      debug1;
  //wire                    debug2;
  //reg                     debug_clock = 1'b0;
  //always #(1) debug_clock = ~debug_clock;
  //always @( posedge debug_clock )
  //    if ( i_reset )
  //        debug1  <= {TAP1{1'b1}};
  //    else
  //        debug1  <= { debug1[TAP1-2:0], debug1[TAP1-1]^debug1[TAP2-1] };
  //assign  debug2  = debug1[/*TAP1-1*/0];


endmodule // elm_marker_handler_tx_prbs_generator
