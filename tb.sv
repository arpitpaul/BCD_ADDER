`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2024 03:53:15
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

class transaction;
randc bit[3:0] a;
randc bit[3:0] b;
bit [7:0] dout;

constraint c1 {a <= 4'd9; b<=4'd9;};
endclass

interface bcd_intf();
logic [3:0] a;
logic [3:0] b;
logic [7:0] dout;
endinterface

class generator;
transaction t;
mailbox mbx;
integer i;
event done;

function new(mailbox mbx);
this.mbx= mbx;
endfunction


task run();
t=new();
for(i=0; i<30; i++)
begin
t.randomize();
mbx.put(t);
@(done);
#10;
end
endtask
endclass


class driver;
transaction t;
mailbox mbx;
virtual bcd_intf vif;
event done;


function new(mailbox mbx);
this.mbx = mbx;
endfunction


task run();
t=new();
forever begin
mbx.get(t);
vif.a=t.a;
vif.b=t.b;
->done;
#10;
end
endtask
endclass

class monitor;
mailbox mbx;
virtual bcd_intf vif;
transaction t;

function new(mailbox mbx);
this.mbx= mbx;
endfunction


task run();
t=new();
forever begin
t.a=vif.a;
t.b=vif.b;
t.dout = vif.dout;
mbx.put(t);
#10;
end
endtask
endclass


class scoreboard;
bit [7:0] res;
mailbox mbx;
transaction t;

function new(mailbox mbx);
this.mbx=mbx;
endfunction

task run();
forever begin
mbx.get(t);

res = t.a+t.b;

if(res <= 4'd9)
begin
 if(t.dout==res)
    $display("[SCO] : TEST PASSED");
 else
    $display("[SCO] : TEST FAILED");
end


else
  begin
    if(t.dout == res + 3'd6)
      $display("[SCO] : TEST PASSED");
    else
      $display("[SCO] : TEST FAILED");    
  end
  
  #10;
end
endtask
endclass

class environment;
generator gen;
driver drv;
virtual bcd_intf vif;
monitor mon;
scoreboard sco;

event gddone;

mailbox gdmbx,msmbx;


function new(mailbox gdmbx, mailbox msmbx);
this.gdmbx=gdmbx;
this.msmbx=msmbx;

gdmbx=new();
msmbx=new();
gen = new(gdmbx);
drv = new(gdmbx);
mon = new(msmbx);
sco = new(msmbx);
endfunction


task run();
gen.done = gddone;
drv.done = gddone;

drv.vif = vif;
mon.vif=vif;

fork
 gen.run();
 drv.run();
 mon.run();
 sco.run();
 
 join_any
endtask
endclass


module tb;

environment env;
mailbox gdmbx;
mailbox msmbx;
bcd_intf vif();

bcd_adder dut(vif.a, vif.b, vif.dout);
initial begin
gdmbx = new();
msmbx= new();

env = new(gdmbx, msmbx);

env.vif=vif;

env.run();
#250;
$finish;
end
endmodule
