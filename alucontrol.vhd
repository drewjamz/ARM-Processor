library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALUControl is
-- Functionality should match truth table shown in Figure 4.12 in the textbook. Avoid Figure 4.13 as it may 
--  cause confusion.
-- Check table on page2 of ISA.pdf on canvas. Pay attention to opcode of operations and type of operations. 
-- If an operation doesn't use ALU, you don't need to check for its case in the ALU control implemenetation.	
-- To ensure proper functionality, you must implement the "don't-care" values in the funct field,
--  for example when ALUOp = '00", Operation must be "0010" regardless of what Funct is.
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ALUControl;

architecture dataflow of ALUControl is
    
begin
    Operation <= "0010" when ALUOp = "00" else -- ADD
                "0111" when ALUOp = "01" else -- pass
                "0010" when ALUOp = "10" and (Opcode = "10001011000" or Opcode = "10010001000") else -- ADD
                "0110" when ALUOp = "10" and (Opcode = "11001011000" or Opcode = "11010001000") else -- SUB
                "0000" when ALUOp = "10" and (Opcode = "10001010000" or Opcode = "10010010000") else -- AND
                "0001" when ALUOp = "10" and (Opcode = "10101010000" or Opcode = "10110010000") else -- ORR
                "1010" when ALUOp = "10" and Opcode = "11010011011" else -- LSL
                "1011" when ALUOp = "10" and Opcode = "11010011010" else -- LSR
                "UUUU"; --undefined

end dataflow;