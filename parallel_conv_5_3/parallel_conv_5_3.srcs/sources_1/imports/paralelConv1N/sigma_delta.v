

module sigma_delta
#(
    parameter                                           NB_SD = 64
)
(
    output  wire                                        o_valid  ,
    input   wire    [NB_SD-1:0]                         i_num ,
    input   wire    [NB_SD-1:0]                         i_den ,
    input   wire                                        i_valid ,
    input   wire                                        i_reset ,
    input   wire                                        i_clock
);

    // LOCAL PARAMETERS.
    // None so far.

    // INTERNAL SIGNALS.
    reg         [NB_SD-1:0]                             sd_accum ;
    wire        [NB_SD  :0]                             add_sd_accum ;
    wire        [NB_SD-1:0]                             next_sd_accum ;
    wire                                                sd_high ;
    reg                                                 sd_high_d;

    // ALGORITHM BEGIN.

    assign  add_sd_accum    =  sd_accum + i_num ;
    assign  next_sd_accum   =  add_sd_accum >= {1'b0,i_den} ?
                               add_sd_accum -  {1'b0,i_den} :
                               add_sd_accum ;

    assign  sd_high =  next_sd_accum < i_num ;

    always @( posedge  i_clock )
    begin
        if ( i_reset )
            sd_accum <= {NB_SD{1'b0}} ;
        else if ( i_valid )
            sd_accum <= next_sd_accum ;
    end

    always @( posedge  i_clock )
    begin
        if ( i_reset )
            sd_high_d <= 1'b0 ;
        else
            sd_high_d <= sd_high ;
    end

    assign  o_valid = sd_high_d ;


endmodule
