module arbitration(clk,rst,frame,req,IRDY,GNT);
input rst,clk,frame,IRDY;
input [4:0] req;
output reg [4:0] GNT;

integer i,t,gate;
reg idle;
reg [4:0] re;

initial
begin
i <=0;
t <=0;
idle <=1;
GNT <=5'b11111;
end

always@(req)
 re [4:0]<= req [4:0];

always@(negedge clk )// set gnt if req turned to 1
for (i=4;i>=0;i=i-1)
begin
if(re[i])
GNT[i] = 1; //( <= ) makes a transitional 1 cycle 1f 
end

//timer 
always@(negedge clk , re[gate] )
begin

if(!re[gate])
t <= t+1; //( <= )makes the clock count more with 1 cycle 
if(t== 2)
begin
t <= 0;
for(i=4;i>=0;i=i-1)//
begin
if(i==gate)
re[gate] <=1;
else
re[i]<= req[i];
end
end
end

always@(negedge clk or frame ) // (or re) for testing
begin

// if none takes gnt
if(GNT == 5'h1f)
begin
idle <=1;// all = 1
for (i=4;i>=0;i=i-1)
if(!re[i]& frame & idle)
begin
GNT[i]<=0;
gate <= i;
idle = 0; // adds a transitional 1f cycle <=

end
end

end

endmodule


module arbitre_tb ();

reg rst,clk,frame,IRDY;
reg [4:0] req;
wire [4:0] GNT;

arbitration arb(clk,rst,frame,req,IRDY,GNT);


always #50 clk=~clk;

initial 
begin
clk=0;
#50
frame=1;
req=5'b01111;
#50
req=5'b00111;
#120
//frame=0;
//#100
frame=1;

end


endmodule



