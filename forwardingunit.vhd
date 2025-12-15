library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ForwardingUnit is
    port(
        -- MEM stage
        EX_MEM_RegWrite : in  std_logic;
        EX_MEM_MemWrite : in  std_logic;
        EX_MEM_WR       : in  std_logic_vector(4 downto 0);

        -- WB stage
        MEM_WB_RegWrite : in  std_logic;
        MEM_WB_WR       : in  std_logic_vector(4 downto 0);

        -- ID/EX source registers (current ALU inputs)
        ID_EX_RR1       : in  std_logic_vector(4 downto 0);
        ID_EX_RR2       : in  std_logic_vector(4 downto 0);
        ID_EX_MemWrite  : in std_logic;

        -- MEM source register
        EX_MEM_RR2      : in  std_logic_vector(4 downto 0);

        -- Outputs to select ALU inputs
        ForwardA        : out std_logic_vector(1 downto 0);
        ForwardB        : out std_logic_vector(1 downto 0);

        ForwardC        : out std_logic;
        ForwardCEX      : out std_logic
    );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is
begin
    process(EX_MEM_RegWrite, EX_MEM_WR, MEM_WB_RegWrite, MEM_WB_WR, ID_EX_RR1, ID_EX_RR2, ID_EX_MemWrite)
    begin
        -- Default no forwarding
        ForwardA <= "00";
        ForwardB <= "00";
        ForwardC <= '0';
        ForwardCEX <= '0';

        -- FORWARD A forwarding from EX/MEM
        if (EX_MEM_RegWrite = '1') and (EX_MEM_WR /= "00000") and (EX_MEM_WR = ID_EX_RR1) then
            ForwardA <= "10";  -- from EX/MEM ALU result
        elsif (MEM_WB_RegWrite = '1') and (MEM_WB_WR /= "00000") and (MEM_WB_WR = ID_EX_RR1) then
            ForwardA <= "01";  -- from MEM/WB (load or writeback)
        else
            ForwardA <= "00";  -- from register file
        end if;

        -- FORWARD B forwarding from EX/MEM
        if (EX_MEM_RegWrite = '1') and (EX_MEM_WR /= "00000") and (EX_MEM_WR = ID_EX_RR2) then
            ForwardB <= "10";
        elsif (MEM_WB_RegWrite = '1') and (MEM_WB_WR /= "00000") and (MEM_WB_WR = ID_EX_RR2) then
            -- Forwarding from MEM/WB
            ForwardB <= "01";
        else
            ForwardB <= "00";
        end if;

        -- FOWARD C fowarding
        if EX_MEM_MemWrite = '1' then
            if (MEM_WB_RegWrite = '1') and (MEM_WB_WR /= "00000") and
            (MEM_WB_WR = EX_MEM_RR2) then
                ForwardC <= '1';   -- forward from MEM/WB
            end if;
        else
            ForwardC <= '0';
        end if;

        if ID_EX_MemWrite = '1' then
            if (MEM_WB_RegWrite = '1') and (MEM_WB_WR /= "00000") and
            (MEM_WB_WR = ID_EX_RR2) then
                ForwardCEX <= '1';
            end if;
        else
            ForwardCEX <= '0';   
        end if;

    end process;
end Behavioral;
