library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
-- as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'ARM Reference Data' sheet at the
--    front of the textbook (or the Green Card pdf on Canvas).
port(
     in0       : in     STD_LOGIC_VECTOR(63 downto 0);
     in1       : in     STD_LOGIC_VECTOR(63 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(63 downto 0);
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
    );
end ALU;

architecture dataflow of ALU is

    component ADD
        port(
            carry_in  : in  STD_LOGIC;
            in0       : in  STD_LOGIC_VECTOR(63 downto 0);
            in1       : in  STD_LOGIC_VECTOR(63 downto 0);
            output    : out STD_LOGIC_VECTOR(63 downto 0);
            carry_out : out STD_LOGIC
        );
    end component;

    component LSL
    port(
        in0    : in  STD_LOGIC_VECTOR(63 downto 0);
        shamt  : in  STD_LOGIC_VECTOR(5 downto 0);
        output : out STD_LOGIC_VECTOR(63 downto 0)
    );
    end component;

    component LSR
        port(
            in0    : in  STD_LOGIC_VECTOR(63 downto 0);
            shamt  : in  STD_LOGIC_VECTOR(5 downto 0);
            output : out STD_LOGIC_VECTOR(63 downto 0)
        );
    end component;

    signal b_operand : STD_LOGIC_VECTOR(63 downto 0);
    signal cin       : STD_LOGIC;
    signal sum       : STD_LOGIC_VECTOR(63 downto 0);

    --Pos/Neg signs of signals, for ease of reading
    signal a_sign    : STD_LOGIC;
    signal b_sign    : STD_LOGIC;
    signal s_sign    : STD_LOGIC;

    -- Shifting signals
    signal lsl_out : STD_LOGIC_VECTOR(63 downto 0);
    signal lsr_out : STD_LOGIC_VECTOR(63 downto 0);
    signal shamt_int : STD_LOGIC_VECTOR(5 downto 0);

begin

    -- Two's complement for sub (in0 + (not in1) + 1)
    b_operand <= in1 when operation = "0010" else
                 not in1;
    cin <= '0' when operation = "0010" else
           '1';    --Using carry to add 1

    shamt_int <= in1(5 downto 0);

    -- Instantiate 64-bit adder
    ADD_inst: ADD
    port map(
        carry_in  => cin,
        in0       => in0,
        in1       => b_operand,
        output    => sum,
        carry_out => open
    );

    LSL_inst: LSL 
    port map(
        in0 => in0,
        shamt => shamt_int,
        output => lsl_out
    );
        
    LSR_inst: LSR
    port map(
        in0 => in0, 
        shamt => shamt_int, 
        output => lsr_out
    );

    -- ALU results
    result <=   (in0 and in1)  when operation = "0000" else -- AND
                (in0 or in1)   when operation = "0001" else -- OR
                sum            when operation = "0010" else -- ADD
                sum            when operation = "0110" else -- SUB
                lsl_out        when operation = "1010" else -- LSL
                lsr_out        when operation = "1011";     -- LSR

    -- Zero flag
    zero <= '1' when result = x"0000000000000000" else '0';

    -- Overflow flag
    a_sign <= in0(63);
    b_sign <= in1(63);
    s_sign <= sum(63);

    overflow <= '1' when
        -- ADD overflow (when adding same sign gives opposite sign)
        ((operation = "0010" and a_sign = b_sign and s_sign /= a_sign) or  
        -- SUB overflow (when subtracting different sign gives opposite sign)
         (operation = "0110" and a_sign /= b_sign and s_sign /= a_sign))   
        else '0';

end dataflow;