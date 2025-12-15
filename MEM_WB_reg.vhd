library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MEM_WB_reg is
  port(
    clk   : in std_logic;
    rst   : in std_logic;

    MemReadData_in : in std_logic_vector(63 downto 0);
    WriteData_in : in std_logic_vector(63 downto 0);
    ALUres_in      : in std_logic_vector(63 downto 0);
    WR_in          : in std_logic_vector(4 downto 0);

    MemtoReg_in    : in std_logic;
    RegWrite_in    : in std_logic;

    MemReadData_out : out std_logic_vector(63 downto 0);
    WriteData_out : out std_logic_vector(63 downto 0);
    ALUres_out      : out std_logic_vector(63 downto 0);
    WR_out          : out std_logic_vector(4 downto 0);

    MemtoReg_out    : out std_logic;
    RegWrite_out    : out std_logic
  );
end entity MEM_WB_reg;

architecture Behavioral of MEM_WB_reg is
begin
  process(clk, rst)
  begin
    if rst = '1' then
      MemReadData_out <= x"0000000000000000";
      WriteData_out <= x"0000000000000000";
      ALUres_out      <= x"0000000000000000";
      WR_out          <= b"00000";
      MemtoReg_out    <= '0';
      RegWrite_out    <= '0';
    elsif rising_edge(clk) then
      MemReadData_out <= MemReadData_in;
      WriteData_out <= WriteData_in;
      ALUres_out      <= ALUres_in;
      WR_out          <= WR_in;
      MemtoReg_out    <= MemtoReg_in;
      RegWrite_out    <= RegWrite_in;
    end if;
  end process;
end architecture;