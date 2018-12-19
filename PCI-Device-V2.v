/**
*This structure of Devices has:
    1-Read Master Side Module
**/

/**
* Read Master Side
**/
module DeviceA(
    input clk,
    input GNTA,
    input DEVSEL,
    input TRDY,
    input [31:0]AD,

    output REQA,
    output FRAME,
    output reg IRDY,
    output reg [31:0]AD_reg,
    output [3:0]C_BE
    );


    reg FRAME_reg;
    reg GNTA_reg ;
    


    always @(negedge GNTA) begin

        FRAME_reg <= 1'b0;
        AD_reg    <= AD;

        IRDY <= #5 1'b0;



    end 
    
    always @(negedge DEVSEL) begin

        TRDY <= 1'b0;
    end 







endmodule