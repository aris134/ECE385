//-------------------------------------------------------------------------
//      VGA controller                                                   --
//      Kyle Kloepper                                                    --
//      4-05-2005                                                        --
//                                                                       --
//      Modified by Stephen Kempf 04-08-2005                             --
//                                10-05-2006                             --
//                                03-12-2007                             --
//      Translated by Joe Meng    07-07-2013                             --
//      Fall 2014 Distribution                                           --
//                                                                       --
//      Used standard 640x480 vga found at epanorama                     --
//                                                                       --
//      reference: http://www.xilinx.com/bvdocs/userguides/ug130.pdf     --
//                 http://www.epanorama.net/documents/pc/vga_timing.html --
//                                                                       --
//      note: The standard is changed slightly because of 25 mhz instead --
//            of 25.175 mhz pixel clock. Refresh rate drops slightly.    --
//                                                                       --
//      For use with ECE 385 Lab 7 and Final Project                     --
//      ECE Department @ UIUC                                            --
//-------------------------------------------------------------------------


module  vga_controller ( input        Clk,       // ppu clock
                                      Reset,     // reset signal
                         output logic hs,        // Horizontal sync pulse.  Active low
								              vs,        // Vertical sync pulse.  Active low
												  blank,     // Blanking interval indicator.  Active low.
												  sync,      // Composite Sync signal.  Active low.  We don't use it in this lab,
												             //   but the video DAC on the DE2 board requires an input for it.
								 output [8:0] DrawX,     // horizontal coordinate
								              DrawY );   // vertical coordinate
    
    // 341 pixels from 0 to 340
    // 262 lines from 0 to 261
    parameter [8:0] hpixels = 9'b101010101;
    parameter [8:0] vlines = 9'b100000110;
	 
	 // horizontal pixel and vertical line counters
    logic [8:0] dot_counter, line_counter;
    
	 // signal indicates if ok to display color for a pixel
	 logic display;
	 
    //Disable Composite Sync
    assign sync = 1'b0;
   
	//Runs the horizontal counter  when it resets vertical counter is incremented
   always_ff @ (posedge clkdiv or posedge Reset )
	begin: counter_proc
		  if ( Reset ) 
			begin 
				 hc <= 10'b0000000000;
				 vc <= 10'b0000000000;
			end
				
		  else 
			 if ( hc == hpixels )  //If hc has reached the end of pixel count
			  begin 
					hc <= 10'b0000000000;
					if ( vc == vlines )   //if vc has reached end of line count
						 vc <= 10'b0000000000;
					else 
						 vc <= (vc + 1'b1);
			  end
			 else 
				  hc <= (hc + 1'b1);  //no statement about vc, implied vc <= vc;
	 end 
   
    assign DrawX = hc;
    assign DrawY = vc;
   
	 //horizontal sync pulse is 96 pixels long at pixels 656-752
    //(signal is registered to ensure clean output waveform)
    always_ff @ (posedge Reset or posedge clkdiv )
    begin : hsync_proc
        if ( Reset ) 
            hs <= 1'b0;
        else  
            if ((((hc + 1) >= 10'b1010010000) & ((hc + 1) < 10'b1011110000))) 
                hs <= 1'b0;
            else 
				    hs <= 1'b1;
    end
	 
    //vertical sync pulse is 2 lines(800 pixels) long at line 490-491
    //(signal is registered to ensure clean output waveform)
    always_ff @ (posedge Reset or posedge clkdiv )
    begin : vsync_proc
        if ( Reset ) 
           vs <= 1'b0;
        else 
            if ( ((vc + 1) == 9'b111101010) | ((vc + 1) == 9'b111101011) ) 
			       vs <= 1'b0;
            else 
			       vs <= 1'b1;
    end
       
    //only display pixels between horizontal 0-255 and vertical 0-239 (256x240)
    //(This signal is registered within the DAC chip, so we can leave it as pure combinational logic here)    
    always_comb
    begin 
        if ( (hc >= 9'b100000000) | (vc >= 9'b011110000) ) 
            display = 1'b0;
        else 
            display = 1'b1;
    end 
   
    assign blank = display;
    assign pixel_clk = clkdiv;
    

endmodule
