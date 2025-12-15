library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPUControl is
  port(
    Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
    Reg2Loc  : out STD_LOGIC;
    CBranch  : out STD_LOGIC;  -- conditional
    CBranchNeg : out STD_LOGIC;
    MemRead  : out STD_LOGIC;
    MemtoReg : out STD_LOGIC;
    MemWrite : out STD_LOGIC;
    ALUSrc   : out STD_LOGIC;
    RegWrite : out STD_LOGIC;
    UBranch  : out STD_LOGIC; -- unconditional
    ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
  );
end CPUControl;

architecture behavioral of CPUControl is
begin
  process(Opcode)
  begin
    -- Default values
    Reg2Loc   <= '0';
    CBranch   <= '0';
    CBranchNeg <= '0';
    MemRead   <= '0';
    MemtoReg  <= '0';
    MemWrite  <= '0';
    ALUSrc    <= '0';
    RegWrite  <= '0';
    UBranch   <= '0';
    ALUOp     <= "00";

    -- R-format ADD
    if Opcode = "10001011000" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '0';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- R-format SUB
    elsif Opcode = "11001011000" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '0';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- I-format ADDI
    elsif Opcode = "10010001000" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '1';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- I-format SUBI
    elsif Opcode = "11010001000" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '1';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- R-format AND
    elsif Opcode = "10001010000" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '0';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- I-format ANDI
    elsif Opcode = "10010010000" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '1';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- R-format ORR
    elsif Opcode = "10101010000" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '0';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- I-format ORRI
    elsif Opcode = "10110010000" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '1';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- R-type LSL
    elsif Opcode = "11010011011" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '1';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- R-type LSR  
    elsif Opcode = "11010011010" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '1';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "10";

    -- LDUR
    elsif Opcode = "11111000010" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '1';
      MemtoReg <= '1';
      MemWrite <= '0';
      ALUSrc   <= '1';
      RegWrite <= '1';
      UBranch  <= '0';
      ALUOp    <= "00";

    -- STUR
    elsif Opcode = "11111000000" then
      Reg2Loc  <= '1';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0'; 
      MemWrite <= '1';
      ALUSrc   <= '1';
      RegWrite <= '0';
      UBranch  <= '0';
      ALUOp    <= "00";

    -- CBZ
    elsif Opcode(10 downto 3) = "10110100" then
      Reg2Loc  <= '1';
      CBranch  <= '1';
      MemRead  <= '0';
      MemtoReg <= '0'; 
      MemWrite <= '0';
      ALUSrc   <= '0';
      RegWrite <= '0';
      UBranch  <= '0';
      ALUOp    <= "01";

    -- CBNZ
    elsif Opcode(10 downto 3) = "10110101" then
      Reg2Loc  <= '1';
      CBranch  <= '0';
      CBranchNeg <= '1';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '0';
      RegWrite <= '0';
      UBranch  <= '0';
      ALUOp    <= "01";

    -- B (unconditional branch)
    elsif Opcode(10 downto 5) = "000101" then
      Reg2Loc  <= '0';
      CBranch  <= '0';
      MemRead  <= '0';
      MemtoReg <= '0';
      MemWrite <= '0';
      ALUSrc   <= '0';
      RegWrite <= '0';
      UBranch  <= '1';
      ALUOp    <= "00";

    end if;

  end process;
end behavioral;
