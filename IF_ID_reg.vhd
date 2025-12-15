library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IF_ID_reg is
  port(
    clk      : in std_logic;
    rst      : in std_logic;
    WriteEnable : in std_logic;
    Instr_in : in std_logic_vector(31 downto 0);
    PC_in  : in std_logic_vector(63 downto 0);
    Instr_out: out std_logic_vector(31 downto 0);
    PC_out : out std_logic_vector(63 downto 0)
  );
end entity IF_ID_reg;

architecture Behavioral of IF_ID_reg is
begin
  process(clk, rst)
  begin
    if rst = '1' then
      Instr_out <= x"00000000";
      PC_out  <= x"0000000000000000";
    elsif rising_edge(clk) then
      if WriteEnable = '1' then                        
        Instr_out <= Instr_in;
        PC_out    <= PC_in;
      end if;
    end if;
  end process;
end architecture;
