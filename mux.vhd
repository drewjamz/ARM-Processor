library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MUX is -- Two by one mux with 5 bit inputs/outputs
port(
    in0    : in STD_LOGIC; -- sel == 0
    in1    : in STD_LOGIC; -- sel == 1
    sel    : in STD_LOGIC; -- selects in0 or in1
    output : out STD_LOGIC
);
end MUX;

architecture dataflow of MUX is
begin
    
    -- VHDL handles logic, can manually be done with or/and gates as well
    output <= in0 when sel = '0' else
              in1;
     
     
end dataflow;
