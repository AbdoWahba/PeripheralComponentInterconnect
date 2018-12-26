/**
*   PCI Device module
*   ! All Signals/Flags/Variables is active LOW 
*/

`timescale 1ns/1ps


`define DEVICE_A_ADDRESS 32'hAD
`define DEVICE_B_ADDRESS 32'hBD
`define DEVICE_C_ADDRESS 32'hCD

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

/**
*   Source of Control word values
*   http://www.cisl.columbia.edu/courses/spring-2004/ee4340/handouts/pci.pdf
*/
`define WRITE_C_BE 4'b0011
`define READ_C_BE 4'b0010

/**
*   dumy/random bit enable for transactions
*/
`define BIT_ENABLE_1 4'b0001
`define BIT_ENABLE_2 4'b0010
`define BIT_ENABLE_3 4'b0100




module Device (
        input  clk,

        output reg  REQ,
        input   GNT,

        inout [31:0] AD,
        inout [3:0]  C_BE,

        inout   FRAME,
        inout   DEVSEL,
        inout   IRDY,
        inout   TRDY,

        input [31:0] DEVICE_ADDRESS,

        
        /**
        *   Additional Signals
        */
        input   FREQ, // To force request Bus && determine number of required transactions
        input [31:0] TARGET_ADDRESS, // Select target to Communicate with
        input [3:0]  OPERATION,  // `WRITE_C_BE / `READ_C_BE
        input [31:0] DATA_DEVICE
        );



    /**
    *   ? Device Memory
    */
    reg [31:0] DATA [10];    reg [4:0] DATA_BE [10];    integer DATA_INDIX = 0;

    initial begin
        /**
        *   FOR testing only DATA_BE
        */
        DATA_BE[0] <= `BIT_ENABLE_1;
        DATA_BE[1] <= `BIT_ENABLE_2;
        DATA_BE[2] <= `BIT_ENABLE_3;
        DATA_BE[3] <= `BIT_ENABLE_1;
        DATA_BE[4] <= `BIT_ENABLE_2;
        DATA_BE[5] <= `BIT_ENABLE_3;
        DATA_BE[6] <= `BIT_ENABLE_1;
        DATA_BE[7] <= `BIT_ENABLE_2;
        DATA_BE[8] <= `BIT_ENABLE_3;
        DATA_BE[9] <= `BIT_ENABLE_1;
    end

    /**
    *   to save current operation read or write
    *       By default write operation
    */
    reg [3:0] control_operation = `WRITE_C_BE;

    /**
    *   AD
    *       If Master and Write op ADreg Assigned to AD treat as output
    *       If not Master AD treat as input
    *       for first transaction "writing address of target" AD must be output
    *       TODO: Must be input in read op 
    */
    reg [31:0] ADreg = 32'hzzzzzzzz;
    assign AD = (~isGrantedAsMaster && control_operation == `WRITE_C_BE) ? ADreg : (~isGrantedAsTarget && control_operation == `READ_C_BE) ? ADreg : 32'hzzzzzzzz;

    /**
    *   C_BE
    *       If Master C_BEreg Assigned to C_BE treat as output
    *       If not Master C_BE treat as input
    */
    reg [3:0] C_BEreg =32'hzzzzzzzz;
    assign C_BE = (~isGrantedAsMaster) ? C_BEreg : 32'hzzzzzzzz;

    /**
    *   DEVSEL
    *       input as Master and output as Target
    */
    reg DEVSELreg = 1'b1;
    assign DEVSEL = (~isGrantedAsTarget) ?  DEVSELreg : 1'bz;
    
    // assign DEVSEL = (~isGrantedAsMaster) ? 1'bz : DEVSELreg; // ERROR Should be z by default

    /**
    *   IRDY
    *       output as Master and input as Target
    */
    reg IRDYreg = 1'b1;
    assign IRDY = (~isGrantedAsMaster) ? IRDYreg : 1'bz;

    /**
    *   TRDY
    *       input as Master and output as Target
    */
    reg TRDYreg = 1'b1;
    assign TRDY = (~isGrantedAsTarget) ? TRDYreg : 1'bz;

    // assign TRDY = (~isGrantedAsMaster) ? 1'bz : TRDYreg;

    /**
    *   FRAME
    */
    reg FRAMEreg = 1'b1;
    assign FRAME = (~isGrantedAsMaster) ? FRAMEreg : 1'bz;
    
    /**
    *   GNT
    *       GNT Flag indecate State of device => Master
    */
    reg isGrantedAsMaster = 1'b1;
    always @ (posedge clk) begin
        /**
        *   Reading GNT on posedge and save it if Granted - read on posedge
        */
        if(~GNT) isGrantedAsMaster <= 1'b0;
    end

    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */

    /**
    *   ? For MASTER
    */

    /**
    *   FREQ
    *       Number of cycles = number of transactions this device need
    *       REQ should be LOW while Device need more transactions
    *       REQ = HIGH when numberOfTransactions goes to zero
    *       numberOfTransacrions decreases every time a Data transaction occurred
    *       REQ = HIGH before last transaction finished
    */
    integer numberOfTransactions = 0;
    always @ (negedge FREQ) begin
        /**
        *   Counting number of transaction on number of negedge of FREQ
        */
        numberOfTransactions <= numberOfTransactions + 1;
    end

    /**
    *   REQ = HIGH when number of transactions goes ZERO
    */
    always @ (negedge clk) begin
        if(numberOfTransactions != 4'b0000) REQ <= 1'b0;
        else REQ <= 1'b1;
    end

    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    
    /**
    *   addressTransactionOccurredFlag to indecate 1st transaction of selecting
    */
    reg addressTransactionOccurredFlag = 1'b1;
    always @ (negedge clk) begin
        /**
        *   After Granted Frame goes to LOW to start transaction - in negedge
        *
        *   Adding Address of target on bus
        *   Adding Control word to C/BE
        *   IRDY go LOW after Address and control bits added
        *   DATA added to AD when target selected => DEVSEL goes ZERO
        */
        if(addressTransactionOccurredFlag) begin
            if (~isGrantedAsMaster) begin
                FRAMEreg <= 1'b0;
                ADreg <=  TARGET_ADDRESS; //`DEVICE_B_ADDRESS;
                C_BEreg <= OPERATION; //`WRITE_C_BE
                addressTransactionOccurredFlag <= 1'b0;
                DATA_INDIX <= numberOfTransactions; /** To start indixing from 0 DATA_INDIX_WRITE **/
            end
        end 

        /**
        *   at negedge of last transaction
        *   FRAME = HIGH
        */
        if(~isGrantedAsMaster && numberOfTransactions == 4'b0000) begin
            FRAMEreg <= 1'b1;
        end
    end


    /**
    *   At negedge of DEVSEL, Defining the control operation if read or write depending on the OPERATION input
    */
    always @ (negedge DEVSEL) begin
        if(~isGrantedAsMaster)begin
            control_operation <= OPERATION; // `WRITE_C_BE
            IRDYreg <= 1'b0;
        end
    end

    /**
    *   at negedge after last transaction
    *   IRDY = HIGH && isGrantedAsMaster = HIGH
    */
    always @ (negedge clk) begin
        if(FRAMEreg && ~isGrantedAsMaster && numberOfTransactions == 4'b0000) begin
            /**
            *   Defaults
            */
            IRDYreg <= 1'b1;
            isGrantedAsMaster <= 1'b1;
            control_operation <= `WRITE_C_BE;
            addressTransactionOccurredFlag = 1'b1;
            DATA_INDIX <= 1'b0;
        end
    end

    /**
    *   ? Data transaction -- Write operation
    *   ? For testing only
    */

    /**
    *   For Write operation only 
    *       All condisions for write operation only
    */
    always @ (negedge clk or negedge TRDY) begin
        if(~DEVSEL && ~TRDY && ~isGrantedAsMaster && control_operation == `WRITE_C_BE && (numberOfTransactions != 4'b0000)) begin
            ADreg <= DATA_DEVICE + numberOfTransactions; //DATA [DATA_INDIX - numberOfTransactions]; // + numberOfTransactions For testing only
            C_BEreg <= DATA_BE[DATA_INDIX - numberOfTransactions];
            IRDYreg <= 1'b0;
            numberOfTransactions = numberOfTransactions - 1;
        end
    end

    /**
    *   ? Data transaction -- Read operation
    */

    always @(posedge clk) begin
        if(~DEVSEL && ~TRDY && ~isGrantedAsMaster && control_operation == `READ_C_BE && (numberOfTransactions != 4'b0000))begin
                /** read AD write in DATA memory */
                DATA[DATA_INDIX] <= AD;
                DATA_INDIX = DATA_INDIX + 1;
                if (DATA_INDIX == 9)begin
                    DATA_INDIX = 0;
                end
        end
    end

    /**
    *   Calculating Number Of TRansactions After Each Data Transaction
    */
    always @(negedge clk or negedge TRDY) begin
        if(~DEVSEL && ~TRDY && ~isGrantedAsMaster && control_operation == `READ_C_BE && (numberOfTransactions != 4'b0000))begin
                numberOfTransactions = numberOfTransactions - 1;
        end
    end

    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */
    /** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** ** ** ** ** * *** ** */

    /**
    *   ? For TARGET
    */

    /**
    *   Flag to indecate the first clk posedge after negedge of FRAME
    *   Active LOW
    */
    reg negFrameFlag = 1'b1;
    always @ (negedge FRAME) begin
        if(~FRAME) negFrameFlag <= 1'b0;
    end

    /**
    *   read Address and control bits on first posedge after FRAME goes LOW
    */
    reg isGrantedAsTarget = 1'b1;
    always @ (posedge clk) begin
        if(~negFrameFlag) begin
            if(AD == DEVICE_ADDRESS) begin
                isGrantedAsTarget <= 1'b0;
                control_operation <= C_BE;
            end
            else isGrantedAsTarget <= 1'b1;
            negFrameFlag <= 1'b1;
        end
    end


    /**
    *   DEVSEL = LOW on next negedge if granted as target
    *   and saving operation from control
    */
    always @ (negedge clk) begin
        if(~isGrantedAsTarget && ~FRAME) DEVSELreg <= 1'b0;

        if(~isGrantedAsTarget && ~FRAME && control_operation == `WRITE_C_BE) TRDYreg <= 1'b0;
    end

    /**
    *   Write data from bus to memory
    */
    always @(posedge clk) begin
        if(~DEVSEL && ~IRDY && ~isGrantedAsTarget && control_operation == `WRITE_C_BE)begin

            DATA[DATA_INDIX] <= AD;

            DATA_INDIX = DATA_INDIX + 1;
            if (DATA_INDIX == 9)begin
                DATA_INDIX = 0;
            end
        end
    end

    /**
    *   when all transactions finish
    *       TRDY goes HIGH
    *       isGrantedAsTarget goes HIGH
    */
    always @ (negedge clk) begin
        if(~isGrantedAsTarget && FRAME) begin
            TRDYreg <= 1'b1;
            DEVSELreg <= 1'b1;
            isGrantedAsTarget <= 1'b1;
        end
    end

    /** 
    *   Target Is Ready So The Transaction Start
    *   Putting Data In Target Memory
    *   Then Increasing DATA_INDIX
    */
    always @ (negedge clk) begin 
        if (~IRDY && ~DEVSEL && ~FRAME && control_operation == `READ_C_BE && ~isGrantedAsTarget) begin
            ADreg <= DATA_DEVICE; //DATA[DATA_INDIX];
            TRDYreg = 1'b0;
            DATA_INDIX = DATA_INDIX + 1;
            if (DATA_INDIX == 9)begin
                DATA_INDIX = 0;
            end

        end
    end

    /**
    *   Restore Defaults In Target
    */
    reg FrameHighFlag = 1'b1;
    always @ (posedge FRAME) begin
        FrameHighFlag <= 1'b0;
    end

    always @ (posedge FRAME) begin
        if(FRAME && ~isGrantedAsTarget) begin
            /**
            *   Defaults
            */
            // repeat(1)@(posedge clk);
            if(~FrameHighFlag)begin
                IRDYreg <= 1'b1;
                isGrantedAsMaster <= 1'b1;
                control_operation <= `WRITE_C_BE;
                addressTransactionOccurredFlag = 1'b1;
                DATA_INDIX <= 1'b0;
                FrameHighFlag <= 1'b1;
            end
        end
    end

endmodule