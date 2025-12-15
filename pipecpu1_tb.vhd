library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity PipeCPU_testbench is
end PipeCPU_testbench;

-- when your testbench is complete you should report error with severity failure.
-- this will end the simulation. Do not add stop times to the Makefile

architecture structural of PipeCPU_testbench is

  -- UUT signals
  signal clk_sig    : std_logic;
  signal rst_sig    : std_logic;

  signal TB_DEBUG_FORWARDA       : std_logic_vector(1 downto 0);
  signal TB_DEBUG_FORWARDB       : std_logic_vector(1 downto 0);
  signal TB_DEBUG_PC            : std_logic_vector(63 downto 0);
  signal TB_DEBUG_INSTRUCTION   : std_logic_vector(31 downto 0);
  signal TB_DEBUG_TMP_REGS      : std_logic_vector(64*4 - 1 downto 0);
  signal TB_DEBUG_SAVED_REGS    : std_logic_vector(64*4 - 1 downto 0);
  signal TB_DEBUG_MEM_CONTENTS  : std_logic_vector(64*4 - 1 downto 0);

  constant CLK_PERIOD : time := 10 ns;

begin

  -- Instantiate unit under test (PipelinedCPU1)
  uut: entity work.PipelinedCPU1
    port map(
      clk => clk_sig,
      rst => rst_sig,
      DEBUG_FORWARDA => TB_DEBUG_FORWARDA,
      DEBUG_FORWARDB => TB_DEBUG_FORWARDB,
      DEBUG_PC => TB_DEBUG_PC,
      DEBUG_INSTRUCTION => TB_DEBUG_INSTRUCTION,
      DEBUG_TMP_REGS => TB_DEBUG_TMP_REGS,
      DEBUG_SAVED_REGS => TB_DEBUG_SAVED_REGS,
      DEBUG_MEM_CONTENTS => TB_DEBUG_MEM_CONTENTS
    );

  -- Test process
  stim_proc: process
  begin
    
    -- Initialize signals
    clk_sig <= '1';
    rst_sig <= '1';
    wait for 10 ns;
    clk_sig <= '0';
    wait for 5 ns;
    rst_sig <= '0';
    wait for 5 ns;

    -- Generate several clock cycles
    for i in 1 to 16 loop
      clk_sig <= '1';
      wait for 10 ns;
      clk_sig <= '0';
      wait for 10 ns;
    end loop;

    -- End of test
    assert false report "Test done." severity failure;
    wait;

  end process stim_proc;

end structural;