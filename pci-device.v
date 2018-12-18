/**
*   PCI Device module
*/ 

`define DEVICE_A_ADDRESS 32'hAD
`define DEVICE_B_ADDRESS 32'hBD
`define DEVICE_C_ADDRESS 32'hCD

/**
*   TODO: Check Control word values
*/
`define WRITE_C_BE 4'b0000
`define READ_C_BE 4'b0001

module DeviceA (
        input  clk,

        output reg  REQ,
        input   FREQ,
        input   GNT,

        inout [31:0] AD,
        inout [3:0]  C_BE,

        inout   FRAME,
        inout   DEVSEL,
        inout   IRDY,
        inout   TRDY 
        );

    /**
    *   ? Address of DeviceA
    */
    reg [31:0] DeviceAddress = 32'hAD;


    /** 
    *   AD
    *       If Master and Write op ADreg Assigned to AD treat as output
    *       If not Master AD treat as input
    *       ? First transaction "writing address of target" AD must be output
    *       TODO: Must be input in read op
    */
    reg [31:0] ADreg;
    assign AD = (~isGrantedAsMaster) ? ADreg : 32'hzzzzzzzz;
    
    /** 
    *   C_BE
    *       If Master C_BEreg Assigned to C_BE treat as output
    *       If not Master C_BE treat as input
    */
    reg [31:0] C_BEreg;
    assign C_BE = (~isGrantedAsMaster) ? C_BEreg : 32'hzzzzzzzz;

    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */

    /**
    *   FREQ
    *       Number of cycles = number of transactions this device need
    *       REQ should be LOW while Device need more transactions
    *       REQ go HIGH when numberOfTransactions goes to zero
    *       TODO: numberOfTransacrions decreases every time a Data transaction occurred
    *       TODO: REQ shoild go HIGH before last transaction finished
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

    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */

    /**
    *   GNT
    *       GNT Flag indecate State of device => Master
    *       TODO: if GNT goes to another device while bus with DeviceA isGrantedAsMaster will goes HIGH
    */
    reg isGrantedAsMaster = 1'b1;
    always @ (posedge clk) begin
        /**
        *   Reading GNT on posedge and save it if Granted - read on posedge
        */
        isGrantedAsMaster <= (~GNT) ? 1'b0 : 1'b1;
    end

    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */

    /**
    *   FRAME
    */
    reg FRAMEreg;
    assign FRAME = (~isGrantedAsMaster) ? FRAMEreg : 1'bz;
    always @ (negedge clk) begin

        /**
        *   * After Granted Frame goes to LOW to start transaction - in negedge
        *   TODO: wrong conditions - should be low when granted and high when last transaction occurred
        *
        *   * Adding Address of target on bus
        *   * Adding Control word to C/BE
        */
        FRAMEreg <= (~isGrantedAsMaster) ? 1'b0 : 1'b1;
        ADreg <= `DEVICE_B_ADDRESS;
        C_BEreg <= `WRITE_C_BE;
        
    end

    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */


endmodule

/* ** ** ** ** ** ** ** ** ** */