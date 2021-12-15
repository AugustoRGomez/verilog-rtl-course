`timescale 1ps / 1ps
/* 
Ejercicio #6
----------------------------------------------
Nombre: async_fifo
----------------------------------------------
Autor: Gomez Augusto
----------------------------------------------
[FIFO de CDT]

(06a) Considerando el paper "Simulation and Synthesis Techniques for Asynchronous
FIFO Design" (Clifford E. Cummings, Sunburst Design, Inc. San Jose 2002) desarrollar
el codigo RTL para una cola FIFO para adaptar dominios de reloj.
Los clocks deben ser de igual frequencia pero con distinto jitter (ruido de fase).

(06b) Escriba un testbench para comprobar el funcionamiento de la FIFO del punto
anterior. Genere 2 clocks diferentes de igual frequencia, pero uno de ellos debe
tener ruido de fase aleatorio.
Comprobar el funcionamiento empleando generadores/chequeadores de PRBS
(los mismos que en el caso de los conversores).
Nota: el generador debe usar uno de los clocks, el chequeador, debe usar el otro.
*/
module async_fifo
#(
    //PARAMETER--------------------------------------------------------//
    parameter                               NB_DATA   = 8,
    parameter                               NB_ADRESS = 3
)
(
    //OUTPUT----------------------------------------------------------//
    output  reg         [NB_DATA-1:0]       o_rdata,
    output  reg                             o_rempty, o_wfull,
    output  reg                             o_valid,
    output  wire        [NB_ADRESS:0]       o_rptr,      //DEBUG
    output  wire        [NB_ADRESS:0]       o_wptr,      //DEBUG
    output  wire        [NB_ADRESS:0]       o_rptr_sync, //DEBUG
    output  wire        [NB_ADRESS:0]       o_wptr_sync, //DEBUG
    output  wire        [NB_ADRESS:0]       o_wptr_q1,   //DEBUG
    output  wire        [NB_ADRESS-1:0]     o_raddr,     //DEBUG
    output  wire        [NB_ADRESS-1:0]     o_waddr,     //DEBUG

    //INPUT-----------------------------------------------------------//
    input   wire        [NB_DATA-1:0]       i_wdata,
    input   wire                            i_winc, i_wclk, i_wrst,
    input   wire                            i_rinc, i_rclk, i_rrst
);

    //LOCALPARAM------------------------------------------------------//
    localparam                              NB_PTR = NB_ADRESS + 1;
    localparam                              DEPTH  = 1<<NB_ADRESS;

    //SIGNALS---------------------------------------------------------//
    wire                [NB_ADRESS-1:0]     waddr, raddr;
    reg                 [NB_PTR-1:0]        wptr, rptr, wq2_rptr, rq2_wptr; 

    //RAM MEMORY MODEL (FIFO)
    reg                 [NB_DATA-1:0]       mem [DEPTH-1:0];

    //SYNC READ POINTER to WRITE DOMAIN
    reg                 [NB_PTR-1:0]        wq1_rptr;

    //SYNC WRITE POINTER to READ DOMAIN
    reg                 [NB_PTR-1:0]        rq1_wptr;

    //READ PTR & EMPTY FLAG GENERATOR
    reg                 [NB_PTR-1:0]        rbin;
    wire                [NB_PTR-1:0]        rgraynext, rbinnext;
    wire                                    rempty_val;
    
    //WRITE PTR & FULL FLAG GENERATOR
    reg                 [NB_PTR-1:0]        wbin;
    wire                [NB_PTR-1:0]        wgraynext, wbinnext;
    wire                                    wfull_val;  

    //ALGORITHM-------------------------------------------------------//
    //FIFO
    // assign o_rdata = mem[raddr];

    always @(posedge i_wclk)
        if (i_winc && !o_wfull)
            mem[waddr] <= i_wdata; 

    always @(posedge i_rclk)
        if (i_rinc && !o_rempty)
            o_rdata    <= mem[raddr]; 

    always @(posedge i_rclk)
    begin
        if (i_rrst)
           o_valid     <= 1'b0; 
        else if (i_rinc && !o_rempty)
           o_valid     <= 1'b1;  
        else
           o_valid     <= 1'b0;
    end
    
    //SYNC READ POINTER to WRITE DOMAIN
    always @(posedge i_wclk)
    begin
        if (i_wrst) {wq2_rptr,wq1_rptr} <= {2*NB_PTR{1'b0}};
        else {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
    end
    
    //SYNC WRITE POINTER to READ DOMAIN
    always @(posedge i_rclk)
    begin
        if (i_rrst) {rq2_wptr, rq1_wptr} <= {2*NB_PTR{1'b0}};
        else {rq2_wptr, rq1_wptr} <= {rq1_wptr, wptr};
    end

    //READ PTR & EMPTY FLAG GENERATOR
    always @(posedge i_rclk)
    begin
        if (i_rrst) {rbin, rptr} <= 0;
        else {rbin, rptr} <= {rbinnext, rgraynext};
    end
    
    assign raddr      = rbin[NB_ADRESS-1:0];
    assign rbinnext   = rbin + (i_rinc & ~o_rempty);
    assign rgraynext  = (rbinnext>>1) ^ rbinnext;

    assign rempty_val = (rgraynext == rq2_wptr);
    always @(posedge i_rclk)
    begin
        if (i_rrst) o_rempty <= 1'b1;
        else o_rempty <= rempty_val;
    end

    //WRITE PTR & FULL FLAG GENERATOR
    always @(posedge i_wclk)
    begin
        if (i_wrst) {wbin, wptr} <= 0;
        else {wbin, wptr} <= {wbinnext, wgraynext};
    end

    assign waddr     = wbin[NB_ADRESS-1:0];
    assign wbinnext  = wbin + (i_winc & ~o_wfull);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;

    assign wfull_val = (wgraynext == {~wq2_rptr[NB_PTR-1:NB_PTR-2], wq2_rptr[NB_PTR-3:0]});
    always @(posedge i_wclk)
    begin
        if (i_wrst) o_wfull <= 1'b0;
        else o_wfull <= wfull_val;
    end

    assign o_rptr      = rptr;     //DEBUG
    assign o_wptr      = wptr;     //DEBUG
    assign o_rptr_sync = wq2_rptr; //DEBUG
    assign o_wptr_sync = rq2_wptr; //DEBUG
    assign o_wptr_q1   = rq1_wptr; //DEBUG
    assign o_raddr     = raddr;    //DEBUG   
    assign o_waddr     = waddr;    //DEBUG

    //DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG//DEBUG
    // always @(posedge i_rclk) 
    // begin
    //     $display("time= %d, wtpr= %b, rq1_wptr= %b, rq2_wptr= %b", $time, wptr, rq1_wptr, rq2_wptr);  
    // end

    // always @(posedge i_wclk) 
    // begin
    //     $display("time= %d, rtpr= %b, wq1_rptr= %b, wq2_rptr= %b", $time, rptr, wq1_rptr, wq2_rptr);  
    // end

    ////EMPTY CONDITION
    // always @(posedge i_rclk) 
    // begin
    //     $display("time= %d, raddr= %b, rptr= %b, rq2_wptr= %b, o_rempty= %b", $time, raddr , rptr, rq2_wptr, o_rempty);  
    // end

    ////FULL CONDITION
    // always @(posedge i_wclk) 
    // begin
    //     $display("time= %d, waddr= %b, wptr= %b, wq2_rptr= %b, o_wfull= %b", $time, waddr , wptr, wq2_rptr, o_wfull);  
    // end

endmodule
