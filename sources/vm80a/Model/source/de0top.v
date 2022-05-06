//
// Top module for DE0 board based system
//
`include "config.h"

//______________________________________________________________________________
//
// Top project module - instantiates the DE0 board itself
//
module de0
(
   input          de0_clock_50,        // clock input 50 MHz
   input          de0_clock_50_2,      // clock input 50 MHz
                                       //
   input    [2:0] de0_button,          // push button[2:0]
                                       //
   input    [9:0] de0_sw,              // DPDT toggle switch[9:0]
   output   [7:0] de0_hex0,            // seven segment digit 0
   output   [7:0] de0_hex1,            // seven segment digit 1
   output   [7:0] de0_hex2,            // seven segment digit 2
   output   [7:0] de0_hex3,            // seven segment digit 3
   output   [9:0] de0_led,             // LED green[9:0]
                                       //
   output         de0_uart_txd,        // UART transmitter
   input          de0_uart_rxd,        // UART receiver
   output         de0_uart_cts,        // UART clear to send
   input          de0_uart_rts,        // UART request to send
                                       //
   inout   [15:0] de0_dram_dq,         // SDRAM data bus 16 bits
   output  [12:0] de0_dram_addr,       // SDRAM address bus 13 bits
   output         de0_dram_ldqm,       // SDRAM low-byte data mask
   output         de0_dram_udqm,       // SDRAM high-byte data mask
   output         de0_dram_we_n,       // SDRAM write enable
   output         de0_dram_cas_n,      // SDRAM column address strobe
   output         de0_dram_ras_n,      // SDRAM row address strobe
   output         de0_dram_cs_n,       // SDRAM chip select
   output   [1:0] de0_dram_ba,         // SDRAM bank address
   output         de0_dram_clk,        // SDRAM clock
   output         de0_dram_cke,        // SDRAM clock enable
                                       //
   inout   [15:0] de0_fl_dq,           // FLASH data bus 15 Bits
   output  [21:0] de0_fl_addr,         // FLASH address bus 22 Bits
   output         de0_fl_we_n,         // FLASH write enable
   output         de0_fl_rst_n,        // FLASH reset
   output         de0_fl_oe_n,         // FLASH output enable
   output         de0_fl_ce_n,         // FLASH chip enable
   output         de0_fl_wp_n,         // FLASH hardware write protect
   output         de0_fl_byte_n,       // FLASH selects 8/16-bit mode
   input          de0_fl_rb,           // FLASH ready/busy
                                       //
   output         de0_lcd_blig,        // LCD back light ON/OFF
   output         de0_lcd_rw,          // LCD read/write select, 0 = write, 1 = read
   output         de0_lcd_en,          // LCD enable
   output         de0_lcd_rs,          // LCD command/data select, 0 = command, 1 = data
   inout    [7:0] de0_lcd_data,        // LCD data bus 8 bits
                                       //
   inout          de0_sd_dat0,         // SD Card Data 0
   inout          de0_sd_dat3,         // SD Card Data 3
   inout          de0_sd_cmd,          // SD Card Command Signal
   output         de0_sd_clk,          // SD Card Clock
   input          de0_sd_wp_n,         // SD Card Write Protect
                                       //
   inout          de0_ps2_kbdat,       // PS2 Keyboard Data
   inout          de0_ps2_kbclk,       // PS2 Keyboard Clock
   inout          de0_ps2_msdat,       // PS2 Mouse Data
   inout          de0_ps2_msclk,       // PS2 Mouse Clock
                                       //
   output         de0_vga_hs,          // VGA H_SYNC
   output         de0_vga_vs,          // VGA V_SYNC
   output   [3:0] de0_vga_r,           // VGA Red[3:0]
   output   [3:0] de0_vga_g,           // VGA Green[3:0]
   output   [3:0] de0_vga_b,           // VGA Blue[3:0]
                                       //
   input    [1:0] de0_gpio0_clkin,     // GPIO Connection 0 Clock In Bus
   output   [1:0] de0_gpio0_clkout,    // GPIO Connection 0 Clock Out Bus
   inout   [31:0] de0_gpio0_d,         // GPIO Connection 0 Data Bus
                                       //
   input    [1:0] de0_gpio1_clkin,     // GPIO Connection 1 Clock In Bus
   output   [1:0] de0_gpio1_clkout,    // GPIO Connection 1 Clock Out Bus
   inout   [31:0] de0_gpio1_d          // GPIO Connection 1 Data Bus
);

wire [15:0] a;
wire [7:0] dcpu, dram, dsys;
wire clk, wr_n, hsel, rst_n;
reg [7:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
reg [2:0] div;
reg f1, f2;
reg [7:0] rcnt = 8'h00;
reg [7:0] led;
reg [15:0] div1ms;
reg ms, intrq, inta;
wire inte, sync;

assign clk = de0_clock_50;
assign hsel = de0_button[0];
assign rst_n = (rcnt == 8'hFF);
assign dsys = inta ? 8'hE7 : (a[15] ? de0_button[1] : dram);

always @(posedge clk)
begin
   div <= div + 3'b001;
   f1  <= div[0];
   f2  <= ~div[0];

   if (sync) inta = dcpu[0];
   if (div1ms == ((`SYS_CLOCK/1000)-1))
      begin
         div1ms <= 16'h0000;
         ms <= 1;
      end
   else
      begin
         div1ms <= div1ms + 16'h0001;
         ms <= 0;
      end

   if (ms) intrq <= 1;
   if (inta) intrq <= 0;
end

always @(posedge clk)
begin
   if (~de0_button[2])
      rcnt <= 8'h00;
   else
      if (rcnt != 8'hFF) rcnt <= rcnt + 8'h01;
end

memini ram
(
   .address(a[14:0]),
   .clock(clk),
   .data(dcpu),
   .wren(~wr_n & rst_n & ~a[15]),
   .q(dram)
);

always @(posedge clk)
begin
   if (~wr_n)
   begin
      if (a == 16'hFFF7) led  <= dcpu;
      if (a == 16'hFFF8) hex0 <= dcpu;
      if (a == 16'hFFF9) hex1 <= dcpu;
      if (a == 16'hFFFA) hex2 <= dcpu;
      if (a == 16'hFFFB) hex3 <= dcpu;
      if (a == 16'hFFFC) hex4 <= dcpu;
      if (a == 16'hFFFD) hex5 <= dcpu;
      if (a == 16'hFFFE) hex6 <= dcpu;
      if (a == 16'hFFFF) hex7 <= dcpu;
   end
end

vm80a_core cpu
(
   .pin_clk(clk),
   .pin_f1(f1),
   .pin_f2(f2),
   .pin_reset(~rst_n),
   .pin_a(a),
   .pin_dout(dcpu),
   .pin_din(dsys),
   .pin_hold(1'b0),
   .pin_ready(1'b1),
   .pin_int(intrq),
   .pin_wr_n(wr_n),
   .pin_inte(inte),
   .pin_sync(sync)
);

assign de0_hex0 = hsel ? ~hex0 : ~hex4;
assign de0_hex1 = hsel ? ~hex1 : ~hex5;
assign de0_hex2 = hsel ? ~hex2 : ~hex6;
assign de0_hex3 = hsel ? ~hex3 : ~hex7;
assign de0_led[0] = ~hsel;
assign de0_led[9:2] = led;

//______________________________________________________________________________
//
// Temporary and debug assignments
//
assign   de0_uart_txd   = 1'bz;
assign   de0_uart_cts   = 1'bz;

assign   de0_dram_dq    = 16'hzzzz;
assign   de0_dram_addr  = 13'h0000;
assign   de0_dram_ldqm  = 1'b0;
assign   de0_dram_udqm  = 1'b0;
assign   de0_dram_we_n  = 1'b1;
assign   de0_dram_cas_n = 1'b1;
assign   de0_dram_ras_n = 1'b1;
assign   de0_dram_cs_n  = 1'b1;
assign   de0_dram_ba[0] = 1'b0;
assign   de0_dram_ba[1] = 1'b0;
assign   de0_dram_clk   = 1'b0;
assign   de0_dram_cke   = 1'b0;

assign   de0_fl_dq      = 16'hzzzz;
assign   de0_fl_addr    = 22'hzzzzzz;
assign   de0_fl_we_n    = 1'b1;
assign   de0_fl_rst_n   = 1'b0;
assign   de0_fl_oe_n    = 1'b1;
assign   de0_fl_ce_n    = 1'b1;
assign   de0_fl_wp_n    = 1'b0;
assign   de0_fl_byte_n  = 1'b1;

assign   de0_lcd_data   = 8'hzz;
assign   de0_lcd_blig   = 1'b0;
assign   de0_lcd_rw     = 1'b0;
assign   de0_lcd_en     = 1'b0;
assign   de0_lcd_rs     = 1'b0;

assign   de0_sd_clk     = 1'b0;
assign   de0_sd_dat0    = 1'hz;
assign   de0_sd_dat3    = 1'hz;
assign   de0_sd_cmd     = 1'hz;

assign   de0_ps2_kbdat  = 1'hz;
assign   de0_ps2_kbclk  = 1'hz;
assign   de0_ps2_msdat  = 1'hz;
assign   de0_ps2_msclk  = 1'hz;

assign   de0_vga_hs     = 1'b0;
assign   de0_vga_vs     = 1'b0;
assign   de0_vga_r      = 4'h0;
assign   de0_vga_g      = 4'h0;
assign   de0_vga_b      = 4'h0;

assign   de0_gpio0_clkout  = 2'b00;
assign   de0_gpio1_clkout  = 2'b00;
assign   de0_gpio0_d       = 32'hzzzzzzzz;
assign   de0_gpio1_d       = 32'hzzzzzzzz;

//______________________________________________________________________________
//
endmodule
