/**
*   PCI Device module
*   Device A address = 32'hAD
*   Device B address = 32'hBD
*   Device C address = 32'hCD
*/ 

module DeviceA (
        input  clk,

        output reg  REQ,
        input   FREQ,
        input   GNT, /** input from arbiter module selecting Device state -- 0 => Master/Initiator , 1 => Slave/Target */

        inout [31:0] AD,
        inout [3:0]  C_BE,

        inout   FRAME,
        inout   DEVSEL,
        inout   IRDY,
        inout   TRDY 
        );


        reg [31:0] DeviceAddress = 32'hAD;

    /**
    *   FREQ
    *       Number of cycles = number of transactions this device need
    *       REQ should be LOW while Device need more transactions
    ###     numberOfTransacrions decreases every time a Data transaction occurred
    *       REQ go HIGH when numberOfTransactions goes to zero
    */
    reg [3:0] numberOfTransactions = 0;
    always @ (negedge FREQ) begin
        /**
        *   Counting number of transaction on number of negedge of FREQ
        */
        numberOfTransactions <= numberOfTransactions + 1;
    end

    always @ (negedge clk) begin
        REQ <= (numberOfTransactions > 0) ? 1'b0 : 1'b1;
    end

    /** ** ** ** ** * *** ** */

    /**
    *   GNT
    *       GNT Flag indecate State of device => Master
    */
    reg isGrantedAsMaster = 1'b1;
    always @ (posedge clk) begin
        isGrantedAsMaster <= (~GNT) ? 1'b0 : 1'b1;
    end

    /** *** ** ** ** ** ** ** */

    /**
    *   FRAME
    */
    reg FRAMEreg;
    assign FRAME = (~isGrantedAsMaster) ? FRAMEreg : 1'bz;
    always @ (negedge clk) begin
        FRAMEreg <= (~isGrantedAsMaster) ? 1'b0 : 1'b1;
        /**
        *   ##### wrong conditions
        */
    end


endmodule

/* ** ** ** ** ** ** ** ** ** */