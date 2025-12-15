library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU_mux3 is
  port(
    sel      : in  std_logic_vector(1 downto 0); -- 2-bit control
    ID_in    : in  std_logic_vector(63 downto 0); 
    EX_in    : in  std_logic_vector(63 downto 0); 
    MEM_in   : in  std_logic_vector(63 downto 0); 
    alu_src  : out std_logic_vector(63 downto 0)
  );
end entity;

architecture Behavioral of ALU_mux3 is
begin
  process(sel, ID_in, EX_in, MEM_in)
  begin
    case sel is
      when "00" =>
        alu_src <= ID_in;
      when "01" =>
        alu_src <= MEM_in;
      when "10" =>
        alu_src <= EX_in;
      when others =>
        alu_src <= ID_in;  -- safe default
    end case;
  end process;
end architecture;
