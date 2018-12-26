`timescale 1ns/1ps 


module arbitration(clk,rst,frame,req,IRDY,GNT,mode);
input rst,clk,frame,IRDY;
input [4:0] req;
output reg [4:0] GNT;
//FCFS
input mode; // mode =0 -> priority , mode=1 -> FCFS


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

always@(rst)
begin
if(rst)
re <= 5'h1f;
GNT <=5'h1f;
end

always@(negedge clk  )// set gnt if req turned to 1
if(!mode) begin
for (i=4;i>=0;i=i-1)
begin
if(re[i])
GNT[i] = 1; //( <= ) makes a transitional 1 cycle 1f 
end
end

always@( posedge frame )
begin
if (!mode) begin
for(i=4;i>=0;i=i-1)
begin
if(i == gate)
re[gate] <=1;
else
re[i]<= req[i];
end
end // endif mode=0
end

always@(negedge clk  ) 
begin
if(!rst & !mode)
begin
// if none takes gnt
if(GNT == 5'h1f)
begin
idle <=1;// all = 1
for (i=4;i>=0;i=i-1)
if(!re[i]&frame & idle)
begin
GNT[i]<=0;
gate <= i;
idle = 0; // adds a transitional 1f cycle <=
end
end
end // end !rst
end


//------FCFS---------

reg [2:0]token [4:0];
integer j=4;
integer pointer ,sel;
//reg selected;//active low

initial begin
sel <=0;
pointer<=1;

for(i=4;i>=0;i=i-1)
for(j=2;j>=0;j=j-1)
token[i][j]<= 0;

end

always@(req)
begin
if(mode) begin
for(i=4;i>=0;i=i-1)
begin
if (!req[i]) begin
for(j=0;j<=4;j=j+1)
if(token[j]!=i) begin
token[pointer]<=i;
pointer<=pointer+1;
end
end
end
end
end

always @(negedge clk)
begin
if(mode & GNT==5'h1f) begin
if( frame & pointer >= sel & token[sel] != 0) begin
GNT[token[sel]]<=0;
end
end
end




always@( posedge frame  )
begin
if(mode) begin

@(negedge clk)
GNT[token[sel]]<=1;

sel<=sel+1;
end

end


endmodule


module arbitre_tb ();

reg rst,clk,frame,IRDY;
reg [4:0] req;
wire [4:0] GNT;
reg mode;

arbitration arb(clk,rst,frame,req,IRDY,GNT,mode);


always #50 clk=~clk;

initial begin
            /**
            *    $dumpfile("wave.vcd");
            *    $dumpvars(0,Device_tb);
            *       for gtkwave extinsion on linux 
            */
            $dumpfile("wave.vcd");
            $dumpvars(0,arbitre_tb);
end
// device 3 request then 4 then 2 then 1 .. expected GNT -> 17  0F  1b 1b 
initial 
begin
frame=1;
clk=0;
mode=1;
rst=0;
#50
frame=1;
req=5'b10111;
#50
req=5'b01111;
#50
req=5'b01011;
#50
req=5'b10001;
#120
frame=0;
#50
frame=1;
#200
frame=0;
#80
frame=1;
#200
frame=0;
#80
frame=1;
#200
frame=0;
#80
frame=1;


//frame=0;

end

initial #6000 $finish;


endmodule



