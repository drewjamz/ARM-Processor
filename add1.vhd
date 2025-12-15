library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADD1 is
-- Adds two unsigned 1-bit inputs
-- output = in0 + in1
-- carry_in : 1 bit carry_in
-- carry_out : 1 bit carry_out
port(
     carry_in : in STD_LOGIC;
     in0    : in  STD_LOGIC;
     in1    : in  STD_LOGIC;
     output : out STD_LOGIC;
     carry_out : out STD_LOGIC
);
end ADD1;

architecture dataflow of ADD1 is

     -- Internal variables for full adder
     signal first_xor : STD_LOGIC;
     signal sec_xor : STD_LOGIC;
     signal first_and : STD_LOGIC;
     signal sec_and : STD_LOGIC;
begin

     -- S output logic
     first_xor <= in0 XOR in1;
     sec_xor <= first_xor XOR carry_in;
     output <= sec_xor;

     -- Cout output logic
     first_and <= in0 AND in1;
     sec_and <= first_xor AND carry_in;
     carry_out <= first_and OR sec_and;


end dataflow;
