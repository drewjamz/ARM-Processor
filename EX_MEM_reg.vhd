library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity EX_MEM_reg is
  port(
    clk   : in std_logic;
    rst   : in std_logic;

    ALUres_in : in std_logic_vector(63 downto 0);
    RR2_in    : in std_logic_vector(4 downto 0);
    RD2_in    : in std_logic_vector(63 downto 0);
    WR_in     : in std_logic_vector(4 downto 0);
    Zero_in   : in std_logic;
    PCbranch_in : in std_logic_vector(63 downto 0);

    MemRead_in  : in std_logic;
    MemWrite_in : in std_logic;
    MemtoReg_in : in std_logic;
    RegWrite_in : in std_logic;
    UBranch_in : in std_logic;
    CBranch_in : in std_logic;
    CBranchNeg_in : in std_logic;

    ALUres_out : out std_logic_vector(63 downto 0);
    RR2_out    : out std_logic_vector(4 downto 0);
    RD2_out    : out std_logic_vector(63 downto 0);
    WR_out     : out std_logic_vector(4 downto 0);
    Zero_out   : out std_logic;
    PCbranch_out: out std_logic_vector(63 downto 0);

    MemRead_out  : out std_logic;
    MemWrite_out : out std_logic;
    MemtoReg_out : out std_logic;
    RegWrite_out : out std_logic;
    UBranch_out : out std_logic;
    CBranch_out : out std_logic;
    CBranchNeg_out : out std_logic
  );
end entity EX_MEM_reg;

architecture Behavioral of EX_MEM_reg is
begin
  process(clk, rst)
  begin
    if rst = '1' then
      ALUres_out   <= x"0000000000000000";
      RD2_out      <= x"0000000000000000";
      RR2_out      <= b"00000";
      WR_out       <= b"00000";
      Zero_out     <= '0';
      PCbranch_out <= x"0000000000000000";
      
      MemRead_out  <= '0';
      MemWrite_out <= '0';
      MemtoReg_out <= '0';
      RegWrite_out <= '0';
      UBranch_out <= '0';
      CBranch_out <= '0';
      CBranchNeg_out <= '0';
    elsif rising_edge(clk) then
      ALUres_out   <= ALUres_in;
      RR2_out      <= RR2_in;
      RD2_out       <= RD2_in;
      WR_out       <= WR_in;
      Zero_out     <= Zero_in;
      PCbranch_out <= PCbranch_in;
      
      MemRead_out  <= MemRead_in;
      MemWrite_out <= MemWrite_in;
      MemtoReg_out <= MemtoReg_in;
      RegWrite_out <= RegWrite_in;
      UBranch_out <= UBranch_in;
      CBranch_out <= CBranch_in;
      CBranchNeg_out <= CBranchNeg_in;
    end if;
  end process;
end architecture;
