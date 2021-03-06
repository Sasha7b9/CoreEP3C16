//______________________________________________________________________________
//
// Simulation configuration parameters
//
`timescale 1ns / 100ps
//
// CAUTION: SIM_CONFIG_FAST_RESET should be undefined in release version
// Defining this parameter shorts the system reset time intervals and
// provides much quicker simulation
//
`define  SIM_CONFIG_FAST_RESET         1
//
// Simulation stops (breakpoint) after this time elapsed
//
`define  SIM_CONFIG_TIME_LIMIT         2000000
//
// External clock frequency
//
`define  SIM_CONFIG_CLOCK_HPERIOD      10

//
// Generated F1/F2/pause phase cycles
//
`define  SIM_CONFIG_F1                 1
`define  SIM_CONFIG_F2                 1
`define  SIM_CONFIG_F0                 0

//______________________________________________________________________________
//
// External oscillator clock, feeds the PLLs
//
`define  OSC_CLOCK                  50000000
//
// Global system clock
//
`define  SYS_CLOCK                  50000000

//______________________________________________________________________________
//
// Reset button debounce interval (in ms))
//
`define  RESET_BUTTON_DEBOUNCE_MS   5
//
// Internal reset pulse width (in system clocks)
//
`define  RESET_PULSE_WIDTH_CLK      7

