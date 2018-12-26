// for modelsim
`define DEVICE_A_ADDRESS 32'hAD
`define DEVICE_B_ADDRESS 32'hBD
`define DEVICE_C_ADDRESS 32'hCD
`timescale 1ns/1ps
`define WRITE_C_BE 4'b0011
`define READ_C_BE 4'b0010



/**
*   dumy/random data for transactions
*/

`define DATA_1 32'hAA
`define DATA_2 32'hBB
`define DATA_3 32'hCC
`define DATA_4 32'hAAA
`define DATA_5 32'hBBB
`define DATA_6 32'hCCC
`define DATA_7 32'hAAAA
`define DATA_8 32'hBBBB
`define DATA_9 32'hCCCC
`define DATA_10 32'hA


module Device_tb();
    
    /**
    *   PCI basic signals
    */
    reg clk;
    wire [31:0] AD;    wire [3:0] C_BE;    wire [4:0] GNT;
    wire REQA, REQB, REQC, FRAME, DEVSEL, IRDY, TRDY;
    
    /**
    *   Make all signals HIGH by Default
    */
    pullup(FRAME);    pullup(IRDY);    pullup(TRDY);    pullup(DEVSEL);

    /**
    *   Additional Signals
    */
    reg FREQA=1'b1,FREQB=1'b1, FREQC=1'b1; // To force request Bus && determine number of required transactions
    reg [31:0] TARGET_ADDRESS; // Select target to Communicate with
    reg [3:0] OPERATION; // `WRITE_C_BE / `READ_C_BE


    Device  devA(
        clk,
        REQA,
        GNT[4],
        AD,
        C_BE,
        FRAME,
        DEVSEL,
        IRDY,
        TRDY ,
        `DEVICE_A_ADDRESS,

        FREQA,
        TARGET_ADDRESS,
        OPERATION,
        32'hAAAAAAAA
        );

    Device  devB(
        clk,
        REQB,
        GNT[3],
        AD,
        C_BE,
        FRAME,
        DEVSEL,
        IRDY,
        TRDY,
        `DEVICE_B_ADDRESS,

        FREQB,
        TARGET_ADDRESS,
        OPERATION,
        32'hBBBBBBBB
        );

    Device  devc(
        clk,
        REQC,
        GNT[2],
        AD,
        C_BE,
        FRAME,
        DEVSEL,
        IRDY,
        TRDY,
        `DEVICE_C_ADDRESS,
        
        
        FREQC,
        TARGET_ADDRESS,
        OPERATION,
        32'hCCCCCCCC
        );


    wire [4:0] ARBREQ;
    assign ARBREQ = {REQA,REQB,REQC,2'b11};
    arbitration arb(clk,1'b0,FRAME,ARBREQ ,IRDY,GNT);


    initial begin
        /**
        *    $dumpfile("wave.vcd");
        *    $dumpvars(0,Device_tb);
        *       for gtkwave extinsion on linux 
        */
        $dumpfile("wave.vcd");
        $dumpvars(0,Device_tb);

        clk <= 0;
    end

    always #1 clk = !clk;


    initial begin
        TARGET_ADDRESS <= `DEVICE_B_ADDRESS;
        OPERATION <= `WRITE_C_BE;
        /**
        *   force request Device A for 3 Data Transmission
        */
        #0.1 FREQA <= 1'b0;
        #0.1 FREQA <= 1'b1;

        #0.1 FREQA <= 1'b0;
        #0.1 FREQA <= 1'b1;

        #0.1 FREQA <= 1'b0;
        #0.1 FREQA <= 1'b1;
    end

    initial begin
        /**
        *   force request Device B for 2 transaction after A finishes
        */

        #16 TARGET_ADDRESS <= 32'hAD;
        #0.1 FREQB <= 1'b0;
        #0.1 FREQB <= 1'b1;

        #0.1 FREQB <= 1'b0;
        #0.1 FREQB <= 1'b1;

    end

    initial begin
        /**
        *   force request Device c for 2 transaction one for A and the other for B
        */
	
        #30
        #0.1 FREQC <= 1'b0;
        #0.1 FREQC <= 1'b1;
	    if( !GNT[2]) TARGET_ADDRESS <= 32'hAD;

        #0.1 FREQC <= 1'b0;
        #0.1 FREQC <= 1'b1;
	    if(! GNT[2]) TARGET_ADDRESS <= 32'hBD;

    end

    initial begin
        /**
        *   force request Device A for 2 transactions for C 
        */

        #30 
        #0.1 FREQA <= 1'b0;
        #0.1 FREQA <= 1'b1;

        #0.1 FREQA <= 1'b0;
        #0.1 FREQA <= 1'b1;
	#4 if( !GNT[4]) TARGET_ADDRESS <= 32'hBD; //after 2 cycles to check gnt

    end

    initial #1000 $finish;

endmodule


