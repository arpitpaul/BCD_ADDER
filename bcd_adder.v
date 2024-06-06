`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2024 03:46:22
// Design Name: 
// Module Name: bcd_adder
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


module bcd_adder(

input [3:0] a,
input [3:0] b,
output reg [7:0] dout
    );
    
    reg [7:0] temp;
    
    always@(*)
    begin
     temp = a+b;
     
     if(temp <= 4'd9)
      begin
        dout = temp;
       end
       
       else
         begin
           dout = temp + 3'd6;
        end
    
    end
endmodule
