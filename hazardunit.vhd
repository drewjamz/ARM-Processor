library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HazardUnit is
    port(

        ID_EX_MemRead : in  std_logic;                  
        ID_EX_WR      : in  std_logic_vector(4 downto 0); -- destination register of the load in ID/EX

        IF_ID_Rn      : in  std_logic_vector(4 downto 0); -- source registers in IF/ID
        IF_ID_Rm      : in  std_logic_vector(4 downto 0);

      
        PCWrite       : out std_logic;
        IFIDWrite     : out std_logic;
        ControlStall  : out std_logic 
    );
end HazardUnit;

architecture Behavioral of HazardUnit is
begin
    process(ID_EX_MemRead, ID_EX_WR, IF_ID_Rn, IF_ID_Rm)
        variable hazard : boolean;
    begin
        hazard := false;

        -- If previous instruction is a load and its destination matches either source of next instruction
        if (ID_EX_MemRead = '1') then
            if (ID_EX_WR /= "00000") and ((ID_EX_WR = IF_ID_Rn) or (ID_EX_WR = IF_ID_Rm)) then
                hazard := true;
            end if;
        end if;

        if hazard then
            -- Stall pipeline for one cycle
            PCWrite      <= '0';
            IFIDWrite    <= '0';
            ControlStall <= '1';  -- Insert NOP
        else
            PCWrite      <= '1';
            IFIDWrite    <= '1';
            ControlStall <= '0';
        end if;
    end process;
end Behavioral;