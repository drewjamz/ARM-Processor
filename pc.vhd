library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc is -- 64-bit rising-edge triggered register with write-enable and Asynchronous reset
    port(
    clk : in STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
    write_enable : in STD_LOGIC; -- Only write if ’1’
    rst : in STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
    AddressIn : in STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
    AddressOut : out STD_LOGIC_VECTOR(63 downto 0)-- Current PC address
);
end pc;

architecture behavioral of pc is
    signal pc_reg : std_logic_vector(63 downto 0); -- internal register to hold PC
begin

    -- Process with asynchronous reset
    process(clk, rst)
    begin
        if rst = '1' then
            -- reset to 0
            pc_reg <= x"0000000000000000"; 
        elsif rising_edge(clk) then
            if write_enable = '1' then
                -- update PC
                pc_reg <= AddressIn; 
            end if;
        end if;
    end process;

    -- drive output
    AddressOut <= pc_reg; 

end behavioral;
