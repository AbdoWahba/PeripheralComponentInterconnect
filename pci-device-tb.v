module Device_tb();
    
    reg clk, FREQA=1'b1,FREQB=1'b1;
    wire [31:0] AD;
    wire [3:0] C_BE;
    wire REQA, REQB, FRAME, DEVSEL, IRDY, TRDY;
    wire [4:0] GNT;

    pullup(FRAME);

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
        `DEVICE_A_ADDRESS
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
        `DEVICE_B_ADDRESS
        );

    wire [4:0] ARBREQ;
    assign ARBREQ = {REQA,REQB,3'b111};
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

            FREQA <= 1'b1;
            #0.1 FREQA <= 1'b0;
            #0.1 FREQA <= 1'b1;
            #0.1 FREQA <= 1'b0;
            #0.1 FREQA <= 1'b1;
            #0.1 FREQA <= 1'b0;
            #0.1 FREQA <= 1'b1;

        end

        initial begin
            #5 FREQB <= 1'b0;
            #1 FREQB <= 1'b1;
        end

        initial #50 $finish;

endmodule