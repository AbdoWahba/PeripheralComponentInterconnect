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
        FREQA,
        GNT[4],
        AD,
        C_BE,
        FRAME,
        DEVSEL,
        IRDY,
        TRDY ,
        `DEVICE_A_ADDRESS,

        TARGET_ADDRESS,
        OPERATION
        );

    Device  devB(
        clk,
        REQB,
        FREQB,
        GNT[3],
        AD,
        C_BE,
        FRAME,
        DEVSEL,
        IRDY,
        TRDY,
        `DEVICE_B_ADDRESS,

        TARGET_ADDRESS,
        OPERATION
        );

    Device  devc(
        clk,
        REQC,
        FREQC,
        GNT[2],
        AD,
        C_BE,
        FRAME,
        DEVSEL,
        IRDY,
        TRDY,
        `DEVICE_C_ADDRESS,

        TARGET_ADDRESS,
        OPERATION
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
        /**
        *   force request Device A for 3 transactions
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
        *   force request Device B for 1 transaction after 5 unit time
        */
        #5 FREQB <= 1'b0;
        #1 FREQB <= 1'b1;
    end

    initial #1000 $finish;

endmodule


