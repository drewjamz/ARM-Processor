library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ID_EX_reg is
  port(
    clk   : in std_logic;
    rst   : in std_logic;
    clr   : in std_logic;

    -- inputs
    RD1_in : in std_logic_vector(63 downto 0);
    RD2_in : in std_logic_vector(63 downto 0);
    Imm_in : in std_logic_vector(63 downto 0);
    RR1_in : in std_logic_vector(4 downto 0);
    RR2_in : in std_logic_vector(4 downto 0);
    WR_in  : in std_logic_vector(4 downto 0);
    PC_in: in std_logic_vector(63 downto 0);

    Reg2Loc_in  : in std_logic;
    CBranch_in  : in std_logic;
    CBranchNeg_in  : in  std_logic;
    MemRead_in  : in std_logic;
    MemtoReg_in : in std_logic;
    MemWrite_in : in std_logic;
    ALUSrc_in   : in std_logic;
    RegWrite_in : in std_logic;
    UBranch_in  : in std_logic;
    ALUOp_in    : in std_logic_vector(1 downto 0);
    opcode_in   : in std_logic_vector(10 downto 0);

    -- outputs
    RD1_out : out std_logic_vector(63 downto 0);
    RD2_out : out std_logic_vector(63 downto 0);
    Imm_out : out std_logic_vector(63 downto 0);
    RR1_out : out std_logic_vector(4 downto 0);
    RR2_out : out std_logic_vector(4 downto 0);
    WR_out  : out std_logic_vector(4 downto 0);
    PC_out: out std_logic_vector(63 downto 0);

    Reg2Loc_out  : out std_logic;
    CBranch_out  : out std_logic;
    CBranchNeg_out : out std_logic;
    MemRead_out  : out std_logic;
    MemtoReg_out : out std_logic;
    MemWrite_out : out std_logic;
    ALUSrc_out   : out std_logic;
    RegWrite_out : out std_logic;
    UBranch_out  : out std_logic;
    ALUOp_out    : out std_logic_vector(1 downto 0);
    opcode_out   : out std_logic_vector(10 downto 0)
  );
end entity ID_EX_reg;

architecture Behavioral of ID_EX_reg is
begin
  process(clk, rst)
  begin
    if rst = '1' then
      RD1_out <= x"0000000000000000";
      RD2_out <= x"0000000000000000";
      Imm_out <= x"0000000000000000";
      RR1_out <= b"00000";
      RR2_out <= b"00000";
      WR_out  <= b"00000";
      PC_out<= x"0000000000000000";

      Reg2Loc_out  <= '0';
      CBranch_out  <= '0';
      CBranchNeg_out  <= '0';
      MemRead_out  <= '0';
      MemtoReg_out <= '0';
      MemWrite_out <= '0';
      ALUSrc_out   <= '0';
      RegWrite_out <= '0';
      UBranch_out  <= '0';
      ALUOp_out    <= "00";
      opcode_out   <= "00000000000";
    elsif rising_edge(clk) then
      --NOP Bubble Insertion
      if clr = '1' then
        RD1_out <= x"0000000000000000";
        RD2_out <= x"0000000000000000";
        Imm_out <= x"0000000000000000";
        RR1_out <= b"00000";
        RR2_out <= b"00000";
        WR_out  <= b"00000";
        PC_out  <= x"0000000000000000";

        Reg2Loc_out  <= '0';
        CBranch_out  <= '0';
        CBranchNeg_out  <= '0';
        MemRead_out  <= '0';
        MemtoReg_out <= '0';
        MemWrite_out <= '0';
        ALUSrc_out   <= '0';
        RegWrite_out <= '0';
        UBranch_out  <= '0';
        ALUOp_out    <= "00";
        opcode_out   <= "00000000000";
      else
        RD1_out <= RD1_in;
        RD2_out <= RD2_in;
        Imm_out <= Imm_in;
        RR1_out <= RR1_in;
        RR2_out <= RR2_in;
        WR_out  <= WR_in;
        PC_out<= PC_in;

        Reg2Loc_out  <= Reg2Loc_in;
        CBranch_out  <= CBranch_in;
        CBranchNeg_out <= CBranchNeg_in;
        MemRead_out  <= MemRead_in;
        MemtoReg_out <= MemtoReg_in;
        MemWrite_out <= MemWrite_in;
        ALUSrc_out   <= ALUSrc_in;
        RegWrite_out <= RegWrite_in;
        UBranch_out  <= UBranch_in;
        ALUOp_out    <= ALUOp_in;
        opcode_out   <= opcode_in;
      end if;
    end if;
  end process;
end architecture;