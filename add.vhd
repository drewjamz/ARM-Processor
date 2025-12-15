library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADD is
-- Adds two signed 64-bit inputs
-- output = in1 + in2
-- carry_in : 1 bit carry_in
-- carry_out : 1 bit carry_out
-- Hint: there are multiple ways to do this
--       -- cascade smaller adders to make the 64-bit adder (make a heirarchy)
--       -- use a Python script (or Excel) to automate filling in the signals
--       -- try a Gen loop (you will have to look this up)
port(
     carry_in : in STD_LOGIC;
     in0    : in  STD_LOGIC_VECTOR(63 downto 0);
     in1    : in  STD_LOGIC_VECTOR(63 downto 0);
     output : out STD_LOGIC_VECTOR(63 downto 0);
     carry_out : out STD_LOGIC
);
end ADD;

architecture structural of ADD is
  -- Internal carries
  signal c : std_logic_vector(64 downto 0);

  component ADD1 is
    port(
      carry_in  : in  std_logic;
      in0       : in  std_logic;
      in1       : in  std_logic;
      output    : out std_logic;
      carry_out : out std_logic
     );
  end component;
begin

  c(0) <= carry_in;

  -- Use 64 1bit adders from Lab0
  gen_add: for i in 0 to 63 generate
    full_adder: ADD1
      port map(
        in0       => in0(i),
        in1       => in1(i),
        carry_in  => c(i),
        output    => output(i),
        carry_out => c(i+1)
      );
  end generate;

  -- Final carry out
  carry_out <= c(64);
end structural;
