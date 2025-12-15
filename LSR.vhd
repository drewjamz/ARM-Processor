library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LSR is
    port(
        in0    : in  STD_LOGIC_VECTOR(63 downto 0);
        shamt  : in  STD_LOGIC_VECTOR(5 downto 0);
        output : out STD_LOGIC_VECTOR(63 downto 0)
    );
end LSR;

architecture dataflow of LSR is
begin
    process(in0, shamt)
        variable shift_val : integer range 0 to 63;
        variable temp      : STD_LOGIC_VECTOR(63 downto 0);
    begin
        shift_val := to_integer(unsigned(shamt));
        if shift_val = 0 then
            temp := in0;
        elsif shift_val < 64 then
            temp := (shift_val - 1 downto 0 => '0') & in0(63 downto shift_val);
        else
            temp := (others => '0');
        end if;
        output <= temp;
    end process;
end dataflow;