library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity SignExtend is
port(
     instr : in STD_LOGIC_VECTOR(31 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0)
);
end SignExtend;
architecture behavioral of SignExtend is
begin
     process(instr)
     begin
          -- If I-type
          if (instr(31 downto 22) = "1001000100" or instr(31 downto 22) = "1101000100") then
               y(63 downto 12) <= (others => instr(21));
               y(11 downto 0)  <= instr(21 downto 10);
          -- I-type: ANDI / ORRI / LSL / LSR (zero-extend)
          elsif (instr(31 downto 22) = "1001001000" or  -- ANDI
                 instr(31 downto 22) = "1011001000" or  -- ORRI
                 instr(31 downto 21) = "11010011011" or -- LSL
                 instr(31 downto 21) = "11010011010")   -- LSR
          then
               y(63 downto 12) <= (others => '0');
               y(11 downto 0)  <= instr(21 downto 10);
          -- D-type
          elsif (instr(31 downto 21) = "11111000010" or instr(31 downto 21) = "11111000000") then
               y(63 downto 9) <= (others => instr(20));
               y(8 downto 0) <= instr(20 downto 12);
          -- Branch
          elsif (instr(31 downto 26) = "000101") then
               y(63 downto 26) <= (others => instr(25));
               y(25 downto 0) <= instr(25 downto 0);
          -- CBranch
          elsif (instr(31 downto 24) = "10110100" or instr(31 downto 24) = "10110101") then
               y(63 downto 19) <= (others => instr(23));
               y(18 downto 0) <= instr(23 downto 5);
          -- Default
          else
               y <= (others => '0');
          end if;
     end process;
end behavioral;