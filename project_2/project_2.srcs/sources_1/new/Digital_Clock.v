`timescale 1ns / 1ps

module Digital_Clock(
    input clk,
    input reset,
    input rst,//s
    input rst_aa,
    input rst_tt,
    input button_1,
    input button_2,
    input button_3,
    input buttonl,
    input buttonc,
    input buttonr,
    input buttonu, // for setting hour of alarm
    input buttond, // for setting minutes of alarm
    input clock, // switch for showing clock
    input alarm, // switch for showing alarm
    input ss,
    input timer,    // switch for showing stopwatch
    input start_ss,  // switch for pause and restart of stopwatch
    output reg [3:0] Anode_Activation,
    output reg [6:0] Cathode_Activation,
    output reg [4:0] hrs1,
    output reg blink,
    output reg blink1
);
    reg [4:0] hrs;
    reg [5:0] secs;
    reg [5:0] mins;
    wire buttonl_d,buttonr_d,buttonc_d;
    
//    wire clk_1Hz;
   // New register for storing set time hours
    clkDivider cd(clk, clkout);
    buttons l(.clk(clk), .btn_in(buttonl),.btn_out(buttonl_d));
    buttons r(.clk(clk), .btn_in(buttonr),.btn_out(buttonr_d));
    buttons c(.clk(clk), .btn_in(buttonc),.btn_out(buttonc_d));
    
    always @(posedge clkout or posedge reset) begin
        if (reset == 1'b1) begin // Reset or set time enable
            secs <= 0;
            mins <= 0;
            hrs <= 0;
            end
        else if(buttonc_d)
        begin
             
             if (mins==59) begin
             mins<=0;
             hrs<=hrs+1;
             end
             else mins<=mins+1;
         end
          else if(buttonl_d)
        begin
             
             if (hrs==23) begin
             hrs<=0;
             end
             else hrs<=hrs+1;
         end
          else if(buttonr_d)
          begin   
             
             if (secs==59) begin
             secs<=0;
             mins<=mins+1;
             end
             else secs<=secs+1;
                        
         end
         else begin
            secs <= secs + 1;
            if (secs == 59) begin
                secs <= 0;
                mins <= mins + 1;
                if (mins == 59) begin
                    mins <= 0;
                    hrs <= hrs + 1;
                    if (hrs == 23) begin
                        hrs <= 0;
                    end
                end
            end
        end
    end
    
    always @(posedge clk or posedge reset) begin
    if(clock) begin
    if (reset) begin
        hrs1 <= 5'b00000; // Reset LEDs to 0
    end else begin
        hrs1 <= hrs; // Assign LEDs with binary number
    end
   end
end
//------------------------------------------------------------------------------------------------------------------   
//stopwatch

    reg [5:0] secs_ss;
    reg [5:0] mins_ss;
    
//    wire clk_1Hz;
   // New register for storing set time hours

    always @(posedge clkout or posedge rst) begin
        if (rst == 1'b1) begin // Reset or set time enable
            secs_ss <= 0;
            mins_ss <= 0;
            end
        
         else if (!start_ss) begin
            secs_ss <= secs_ss + 1;
            if (secs_ss == 59) begin
                secs_ss <= 0;
                mins_ss <= mins_ss + 1;
                if (mins_ss == 59) begin
                    mins_ss <= 0;

                end
            end
        end
    end




//-------------------------------------------------------------------------------------------------------------------
 //ALARM
 reg [4:0] hrs_aa;
 reg [5:0] mins_aa;
 always @(posedge clkout or posedge rst_aa) begin
   
   if (rst_aa == 1'b1) begin // Reset or set time enable
            mins_aa <= 0;
            hrs_aa <= 0;
            end
   else if(buttond)
        begin
             if (mins_aa==59) begin
             mins_aa<=0;
             hrs_aa<=hrs_aa+1;
             end
             else mins_aa<=mins_aa+1;
         end
          else if(buttonu)
        begin
             
             if (hrs_aa==23) begin
             hrs_aa<=0;
             end
             else hrs_aa<= hrs_aa+1;
         end
 end
 
always @(posedge clkout)
    begin
    if(hrs_aa == hrs && mins_aa == mins && secs%2 == 5'b00000)
    begin
      blink =1'b1;
      end
     
    else 
    begin 
        blink=1'b0;
    end
    end
 //-------------------------------------------------------------------------------------------
 //Timer
 reg [5:0] mins_tt;
 reg [5:0] secs_tt = 5'b00001;
 
 always @(posedge clkout or posedge rst_tt) begin
   
   if (rst_tt == 1'b1) begin // Reset or set time enable
            mins_tt <= 0;
            secs_tt <= 0;
            end
    else if (!button_1)begin
        if(button_3)
        begin
             if (mins_tt==59) begin
             mins_tt<=0;
             end
             else mins_tt<=mins_tt+1;
         end
        else if(button_2)
        begin
             if (secs_tt==59) begin
             secs_tt<=0;
             mins_tt<=mins_tt+1;
             end
             else secs_tt<= secs_tt+1;
         end
         end
       else 
       begin
            if(secs_tt==00)begin
               secs_tt <= 59;
               mins_tt <=mins_tt-1;
            end
            else begin
            secs_tt <= secs_tt-1;
            end
    
        end
   end
   
 always @(posedge clkout) begin
   if(secs_tt == 0 && mins_tt == 0 )
   begin
       blink1=1'b1;
   end
   else
       blink1=1'b0;
 end
 
    
    
    
//-------------------------------------------------------------------------------------------------------------------    
    
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter;
    wire [1:0] LED_activation_counter;
    reg  [5:0] secs_ones,secs_tens,mins_ones,mins_tens;

    always @(posedge clk or posedge reset) begin
        if (reset == 1) begin
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end
     assign LED_activation_counter = refresh_counter[19:18];
     
always @(*)
begin
        if(clock)
        begin
        mins_ones = mins%10;
        mins_tens = mins/10;
        secs_ones = secs%10;
        secs_tens = secs/10;
        end
    else if(ss)
        begin 
        mins_ones = mins_ss%10;
        mins_tens = mins_ss/10;
        secs_ones = secs_ss%10;
        secs_tens = secs_ss/10;
        end
    else if(alarm)
    begin
    mins_ones = hrs_aa%10;
    mins_tens = hrs_aa/10;
    secs_ones = mins_aa%10;
    secs_tens = mins_aa/10;
    end
    else if(timer)
    begin
    mins_ones = mins_tt%10;
    mins_tens = mins_tt/10;
    secs_ones = secs_tt%10;
    secs_tens = secs_tt/10;
    end
    else
    begin
    mins_ones = 4'b1010;
    mins_tens = 4'b1010;
    secs_ones = 4'b1010;
    secs_tens = 4'b1010;
    end
end     
     
     
     
     

always @(*)

    begin
        case(LED_activation_counter)
        2'b00: begin
            Anode_Activation = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            
            LED_BCD = mins_tens;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            Anode_Activation = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = mins_ones;
            // the second digit of the 16-bit number
              end
        2'b10: begin
            Anode_Activation = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = secs_tens;
            // the third digit of the 16-bit number
                end
        2'b11: begin
            Anode_Activation = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = secs_ones;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
 
   
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: Cathode_Activation = 7'b0000001; // "0"     
        4'b0001: Cathode_Activation = 7'b1001111; // "1" 
        4'b0010: Cathode_Activation = 7'b0010010; // "2" 
        4'b0011: Cathode_Activation = 7'b0000110; // "3" 
        4'b0100: Cathode_Activation = 7'b1001100; // "4" 
        4'b0101: Cathode_Activation = 7'b0100100; // "5" 
        4'b0110: Cathode_Activation = 7'b0100000; // "6" 
        4'b0111: Cathode_Activation = 7'b0001111; // "7" 
        4'b1000: Cathode_Activation = 7'b0000000; // "8"     
        4'b1001: Cathode_Activation = 7'b0000100; // "9" 
        4'b1010: Cathode_Activation = 7'b1111111; // "0"
        endcase
    end
endmodule


