library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PipelinedCPU1 is
port(
clk :in std_logic;
rst :in std_logic;
--Probe ports used for testing
-- Forwarding control signals
DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
--The current address (AddressOut from the PC)
DEBUG_PC : out std_logic_vector(63 downto 0);
--Value of PC.write_enable
DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
--The current instruction (Instruction output of IMEM)
DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
--DEBUG ports from other components
DEBUG_TMP_REGS : out std_logic_vector(64*4-1 downto 0);
DEBUG_SAVED_REGS : out std_logic_vector(64*4-1 downto 0);
DEBUG_MEM_CONTENTS : out std_logic_vector(64*4-1 downto 0)
);
end PipelinedCPU1;

architecture Behavioral of PipelinedCPU1 is

    -- Program counter
    signal PC_OUT : STD_LOGIC_VECTOR(63 downto 0);
    signal PCWrite_sig : std_logic := '1';

    -- Instruction signals
    signal instr        : std_logic_vector(31 downto 0);
    signal opcode       : std_logic_vector(10 downto 0);
    signal rn_field     : std_logic_vector(4 downto 0);
    signal rt_field     : std_logic_vector(4 downto 0);
    signal rd_field     : std_logic_vector(4 downto 0);
    signal rm_field     : std_logic_vector(4 downto 0);
    signal imm64_I      : std_logic_vector(63 downto 0);
    signal imm64_I_SL2  : std_logic_vector(63 downto 0);

    -- Control signals
    signal Reg2Loc_sig  : std_logic := '0';
    signal CBranch_sig  : std_logic := '0';
    signal MemRead_sig  : std_logic := '0';
    signal MemtoReg_sig : std_logic := '0';
    signal MemWrite_sig : std_logic := '0';
    signal ALUSrc_sig   : std_logic := '0';
    signal RegWrite_sig : std_logic := '0';
    signal UBranch_sig  : std_logic := '0';
    signal ALUOp_sig    : std_logic_vector(1 downto 0) := b"00";

    signal CPU_Reg2Loc   : std_logic;
    signal CPU_CBranch   : std_logic;
    signal CPU_CBranchNeg: std_logic;
    signal CPU_MemRead   : std_logic;
    signal CPU_MemtoReg  : std_logic;
    signal CPU_MemWrite  : std_logic;
    signal CPU_ALUSrc    : std_logic;
    signal CPU_RegWrite  : std_logic;
    signal CPU_UBranch   : std_logic;
    signal CPU_ALUOp     : std_logic_vector(1 downto 0);

    -- register signals
    signal RR1_sig : std_logic_vector(4 downto 0);
    signal RR2_sig : std_logic_vector(4 downto 0);
    signal WR_sig  : std_logic_vector(4 downto 0);
    signal RD1_sig : std_logic_vector(63 downto 0);
    signal RD2_sig : std_logic_vector(63 downto 0);
    -- Reset guard logic: disable writes and force safe values during reset
    signal FinRegWrite : std_logic;
    signal FinRegWriteData : std_logic_vector(63 downto 0);

    -- ALU
    signal ALUOperation : std_logic_vector(3 downto 0);

    signal ALU_in0   : std_logic_vector(63 downto 0);
    signal ALU_in1   : std_logic_vector(63 downto 0);
    signal ALU_result : std_logic_vector(63 downto 0) := x"0000000000000000";
    signal ALU_zero_sig   : std_logic := '0';
    signal ALU_overflow_sig : std_logic := '0';

    signal i_field          : std_logic_vector(31 downto 0);
    signal imm_for_alu     : std_logic_vector(63 downto 0);

    -- Memory read data
    signal MemReadData : std_logic_vector(63 downto 0);

    -- next PC
    signal PC_plus4       : STD_LOGIC_VECTOR(63 downto 0);
    signal PC_branch      : std_logic_vector(63 downto 0);
    signal PC_next        : std_logic_vector(63 downto 0);
    signal branch_taken_sig : std_logic := '0';
    signal PC_sel_sig : std_logic := '0';
    signal CBranchNeg_sig : std_logic := '0';



    -- IF/ID
    signal IF_ID_instr       : std_logic_vector(31 downto 0);
    signal IF_ID_PC          : std_logic_vector(63 downto 0);

    -- ID/EX
    signal ID_EX_PC          : std_logic_vector(63 downto 0);
    signal ID_EX_RD1         : std_logic_vector(63 downto 0);
    signal ID_EX_RD2         : std_logic_vector(63 downto 0);
    signal ID_EX_imm64       : std_logic_vector(63 downto 0);
    signal ID_EX_RR1         : std_logic_vector(4 downto 0);
    signal ID_EX_RR2         : std_logic_vector(4 downto 0);
    signal ID_EX_WR          : std_logic_vector(4 downto 0);

    signal ID_EX_Reg2Loc     : std_logic;
    signal ID_EX_CBranch     : std_logic;
    signal ID_EX_CBranchNeg  : std_logic;
    signal ID_EX_MemRead     : std_logic;
    signal ID_EX_MemtoReg    : std_logic;
    signal ID_EX_MemWrite    : std_logic;
    signal ID_EX_ALUSrc      : std_logic;
    signal ID_EX_RegWrite    : std_logic;
    signal ID_EX_UBranch     : std_logic;
    signal ID_EX_ALUOp       : std_logic_vector(1 downto 0);
    signal ID_EX_opcode      : std_logic_vector(10 downto 0);
    
    -- EX/MEM
    signal EX_MEM_ALU_result : std_logic_vector(63 downto 0);
    signal EX_MEM_RR2        : std_logic_vector(4 downto 0);
    signal EX_MEM_RD2        : std_logic_vector(63 downto 0);
    signal EX_MEM_WR         : std_logic_vector(4 downto 0);
    signal EX_MEM_zero       : std_logic;
    signal EX_MEM_PC_branch  : std_logic_vector(63 downto 0);

    signal EX_MEM_MemRead    : std_logic;
    signal EX_MEM_MemWrite   : std_logic;
    signal EX_MEM_MemtoReg   : std_logic;
    signal EX_MEM_RegWrite   : std_logic;
    signal EX_MEM_UBranch     : std_logic;
    signal EX_MEM_CBranch     : std_logic;
    signal EX_MEM_CBranchNeg  : std_logic;

    -- MEM/WB
    signal MEM_WB_MemReadData: std_logic_vector(63 downto 0);
    signal MEM_WB_WriteData: std_logic_vector(63 downto 0);
    signal MEM_WB_ALU_result : std_logic_vector(63 downto 0);
    signal MEM_WB_WR         : std_logic_vector(4 downto 0);
    signal MEM_WB_MemtoReg   : std_logic;
    signal MEM_WB_RegWrite   : std_logic;

    signal WB_DATA_PRE  : std_logic_vector(63 downto 0);
    signal WB_DATA_POST : std_logic_vector(63 downto 0);

    -- Hazards

    signal IFIDWrite_sig   : std_logic := '1';
    signal ControlStall_sig: std_logic := '0';

    -- Forwarding
    signal ForwardA_sig : std_logic_vector(1 downto 0);
    signal ForwardB_sig : std_logic_vector(1 downto 0);
    signal ForwardC_sig : std_logic;
    signal ForwardCEX_sig : std_logic;

    signal FWD_ALU_A    : std_logic_vector(63 downto 0);
    signal FWD_ALU_B    : std_logic_vector(63 downto 0);
    signal FWD_C_DATA : std_logic_vector(63 downto 0);

    signal MemSrc_sel        : std_logic;
    signal MEM_forward_data  : std_logic_vector(63 downto 0);
    signal RD2_Final         : std_logic_vector(63 downto 0);


begin

--Instruction Fetch (IF)

    -- PC
    PC_inst : entity work.pc 
    port map(
        clk => clk,
        write_enable => PCWrite_sig,
        rst => rst,
        AddressIn => PC_next,
        AddressOut => PC_OUT
    );

    DEBUG_PC <= PC_OUT;

    -- Instruction memory
    IMEM_inst : entity work.IMEM
    generic map (NUM_BYTES => 64)
    port map (
        Address  => PC_OUT,
        ReadData => instr
    );

    -- IF/ID Register
    IFID_U : entity work.IF_ID_reg
    port map(
        clk      => clk,
        rst      => rst,
        WriteEnable => IFIDWrite_sig,
        Instr_in => instr,
        PC_in  => PC_OUT,
        Instr_out=> IF_ID_instr,
        PC_out => IF_ID_PC
    );

    DEBUG_INSTRUCTION <= instr;

    -- Increment PC ADDER
    PC_plus4_inst : entity work.ADD
    port map(
        carry_in  => '0',
        in0       => PC_OUT,
        in1       => x"0000000000000004",
        output    => PC_plus4,
        carry_out => open
    );
    

-- Instruction Decode (ID)
    opcode   <= IF_ID_instr(31 downto 21);
    rm_field <= IF_ID_instr(20 downto 16);
    rn_field <= IF_ID_instr(9 downto 5);
    rd_field <= IF_ID_instr(4 downto 0);
    rt_field <= IF_ID_instr(4 downto 0);
    i_field  <= IF_ID_instr(31 downto 0);

    -- CPU Control
    CPUControl_inst : entity work.CPUControl
        port map(
            Opcode   => opcode,
            Reg2Loc  => CPU_Reg2Loc,
            CBranch  => CPU_CBranch,
            CBranchNeg => CPU_CBranchNeg,
            MemRead  => CPU_MemRead,
            MemtoReg => CPU_MemtoReg,
            MemWrite => CPU_MemWrite,
            ALUSrc   => CPU_ALUSrc,
            RegWrite => CPU_RegWrite,
            UBranch  => CPU_UBranch,
            ALUOp    => CPU_ALUOp
        );

    -- Stall logic
    Reg2Loc_sig  <= '0' when (ControlStall_sig = '1') else CPU_Reg2Loc;
    CBranch_sig  <= '0' when (ControlStall_sig = '1') else CPU_CBranch;
    CBranchNeg_sig <= '0' when (ControlStall_sig = '1') else CPU_CBranchNeg;
    MemRead_sig  <= '0' when (ControlStall_sig = '1') else CPU_MemRead;
    MemtoReg_sig <= '0' when (ControlStall_sig = '1') else CPU_MemtoReg;
    MemWrite_sig <= '0' when (ControlStall_sig = '1') else CPU_MemWrite;
    ALUSrc_sig   <= '0' when (ControlStall_sig = '1') else CPU_ALUSrc;
    RegWrite_sig <= '0' when (ControlStall_sig = '1') else CPU_RegWrite;
    UBranch_sig  <= '0' when (ControlStall_sig = '1') else CPU_UBranch;
    ALUOp_sig    <= "00" when (ControlStall_sig = '1') else CPU_ALUOp;

    -- Instruction sign extend
    SE_I : entity work.SignExtend
    port map(instr => i_field, y => imm64_I);

    RR1_sig <= rn_field;

    -- Read Register 2 MUX
    RR2_mux : entity work.MUX5
    port map(
        in0    => rm_field,    
        in1    => rt_field,  
        sel    => Reg2Loc_sig,
        output => RR2_sig
    );

    WR_sig <= rd_field;

    -- Registers
    registers_inst : entity work.registers
    port map(
        RR1 => RR1_sig,
        RR2 => RR2_sig,
        WR  => MEM_WB_WR,
        WD  => FinRegWriteData,
        RegWrite => FinRegWrite,
        Clock => clk,              
        RD1 => RD1_sig,
        RD2 => RD2_sig,
        DEBUG_TMP_REGS   => DEBUG_TMP_REGS,
        DEBUG_SAVED_REGS => DEBUG_SAVED_REGS
    );

    -- ID/EX Register
    IDEX_U : entity work.ID_EX_reg
    port map(
        clk   => clk,
        rst   => rst,
        clr  => ControlStall_sig,

        RD1_in => RD1_sig,
        RD2_in => RD2_sig,
        Imm_in => imm64_I,
        RR1_in => rn_field,
        RR2_in => RR2_sig,
        WR_in  => rd_field,
        PC_in=> IF_ID_PC,

        Reg2Loc_in  => Reg2Loc_sig,
        CBranch_in  => CBranch_sig,
        CBranchNeg_in => CBranchNeg_sig,
        MemRead_in  => MemRead_sig,
        MemtoReg_in => MemtoReg_sig,
        MemWrite_in => MemWrite_sig,
        ALUSrc_in   => ALUSrc_sig,
        RegWrite_in => RegWrite_sig,
        UBranch_in  => UBranch_sig,
        ALUOp_in    => ALUOp_sig,
        opcode_in   => opcode,

        RD1_out => ID_EX_RD1,
        RD2_out => ID_EX_RD2,
        Imm_out => ID_EX_imm64,
        RR1_out => ID_EX_RR1,
        RR2_out => ID_EX_RR2,
        WR_out  => ID_EX_WR,
        PC_out=> ID_EX_PC,

        Reg2Loc_out  => ID_EX_Reg2Loc,
        CBranch_out  => ID_EX_CBranch,
        CBranchNeg_out => ID_EX_CBranchNeg,
        MemRead_out  => ID_EX_MemRead,
        MemtoReg_out => ID_EX_MemtoReg,
        MemWrite_out => ID_EX_MemWrite,
        ALUSrc_out   => ID_EX_ALUSrc,
        RegWrite_out => ID_EX_RegWrite,
        UBranch_out  => ID_EX_UBranch,
        ALUOp_out    => ID_EX_ALUOp,
        opcode_out   => ID_EX_opcode
    );

-- Execute (EX)
    -- Forwarding mux operand A
    FWD_A_MUX : entity work.ALU_mux3
    port map(
        sel     => ForwardA_sig,      
        ID_in  => ID_EX_RD1,
        EX_in  => EX_MEM_ALU_result,
        MEM_in   => WB_DATA_POST,
        alu_src => FWD_ALU_A
    );

    -- Forwarding mux operand B 
    FWD_B_MUX : entity work.ALU_mux3
    port map(
        sel     => ForwardB_sig,       
        ID_in  => ID_EX_RD2,
        EX_in  => EX_MEM_ALU_result,
        MEM_in   => WB_DATA_POST,
        alu_src => FWD_ALU_B
    );

    ALU_in0 <= FWD_ALU_A;

    -- ALU second input mux
    ALU_in1_mux : entity work.MUX64
    port map(
        in0    => FWD_ALU_B,       
        in1    => ID_EX_imm64,      
        sel    => ID_EX_ALUSrc,   
        output => ALU_in1
    );

    -- ALU Control
    ALUControl_inst : entity work.ALUControl
    port map(
        ALUOp    => ID_EX_ALUOp, 
        Opcode   => ID_EX_opcode,
        Operation=> ALUOperation
    );

    -- ALU
    ALU_inst : entity work.ALU
    port map(
        in0       => ALU_in0,
        in1       => ALU_in1,
        operation => ALUOperation,
        result    => ALU_result,
        zero      => ALU_zero_sig,
        overflow  => ALU_overflow_sig
    );

    -- Branch shift left
    SL2_I : entity work.ShiftLeft2
    port map (
        x => ID_EX_imm64, 
        y => imm64_I_SL2
    );

    -- Branch ADDER
    PC_branch_inst : entity work.ADD
    port map(
        carry_in  => '0',
        in0       => ID_EX_PC,
        in1       => imm64_I_SL2,
        output    => PC_branch,
        carry_out => open
    );

    -- MEM forwarding EX
    FWD_CEX_MUX : entity work.MUX64
    port map(
        in0    => ID_EX_RD2,     
        in1    => WB_DATA_POST,   
        sel    => ForwardCEX_sig,       
        output => RD2_Final
    );

    -- EX/MEM Register
    EXMEM_U : entity work.EX_MEM_reg
    port map(
        clk    => clk,
        rst    => rst,
        ALUres_in => ALU_result,
        RR2_in    => ID_EX_RR2,
        RD2_in    => RD2_Final,        
        WR_in     => ID_EX_WR,
        Zero_in   => ALU_zero_sig,
        PCbranch_in => PC_branch,
        CBranch_in  => ID_EX_CBranch,
        CBranchNeg_in => ID_EX_CBranchNeg,
        UBranch_in => ID_EX_UBranch,

        MemRead_in  => ID_EX_MemRead,
        MemWrite_in => ID_EX_MemWrite,
        MemtoReg_in => ID_EX_MemtoReg,
        RegWrite_in => ID_EX_RegWrite,

        ALUres_out  => EX_MEM_ALU_result,
        RR2_out     => EX_MEM_RR2,
        RD2_out     => EX_MEM_RD2,
        WR_out      => EX_MEM_WR,
        Zero_out    => EX_MEM_zero,
        PCbranch_out=> EX_MEM_PC_branch,

        MemRead_out  => EX_MEM_MemRead,
        MemWrite_out => EX_MEM_MemWrite,
        MemtoReg_out => EX_MEM_MemtoReg,
        RegWrite_out => EX_MEM_RegWrite,
        CBranch_out  => EX_MEM_CBranch,
        CBranchNeg_out => EX_MEM_CBranchNeg,
        UBranch_out => EX_MEM_UBranch

    );


-- Memory Access (MEM)


    FWD_C_MUX : entity work.MUX64
    port map(
        in0    => EX_MEM_RD2,     
        in1    => WB_DATA_POST,   
        sel    => ForwardC_sig,       
        output => FWD_C_DATA
    );

    DMEM_inst : entity work.DMEM
    generic map ( NUM_BYTES => 144 )
    port map(
        WriteData        => FWD_C_DATA,
        Address          => EX_MEM_ALU_result,
        MemRead          => EX_MEM_MemRead,
        MemWrite         => EX_MEM_MemWrite,
        Clock            => clk,
        ReadData         => MemReadData,
        DEBUG_MEM_CONTENTS => DEBUG_MEM_CONTENTS
    );

    -- Branch logic
    Branch_mux : entity work.MUX
    port map(
        in0    => EX_MEM_CBranchNeg,
        in1    => EX_MEM_CBranch,
        sel    => EX_MEM_zero,
        output => branch_taken_sig
    );
    
    PC_sel_sig <= branch_taken_sig or EX_MEM_UBranch;

    -- PC Increment or Branch MUX
    PC_mux : entity work.MUX64
    port map(
        in0    => PC_plus4,
        in1    => EX_MEM_PC_branch,
        sel    => PC_sel_sig,
        output => PC_next
    );

    -- MEM/WB Register
    MEMWB_U : entity work.MEM_WB_reg
    port map(
        clk => clk,
        rst => rst,
        MemReadData_in => MemReadData,
        WriteData_in   => FWD_C_DATA,
        ALUres_in      => EX_MEM_ALU_result,
        WR_in          => EX_MEM_WR,
        MemtoReg_in    => EX_MEM_MemtoReg,
        RegWrite_in    => EX_MEM_RegWrite,

        MemReadData_out => MEM_WB_MemReadData,
        WriteData_out   => MEM_WB_WriteData,
        ALUres_out      => MEM_WB_ALU_result,
        WR_out          => MEM_WB_WR,
        MemtoReg_out    => MEM_WB_MemtoReg,
        RegWrite_out    => MEM_WB_RegWrite
    );

-- Write Back (WB)

    -- Writeback mux
    B_SEL_MUX : entity work.MUX64
    port map(
        in0    => MEM_WB_ALU_result,       
        in1    => MEM_WB_MemReadData,    
        sel    => MEM_WB_MemtoReg,
        output => WB_DATA_PRE
    );

    -- Reset protection
    WB_RESET_MUX : entity work.MUX64
    port map(
        in0    => WB_DATA_PRE,
        in1    => x"0000000000000000",
        sel    => rst,
        output => WB_DATA_POST
    );

    FinRegWrite <= '0' when (rst = '1') else MEM_WB_RegWrite;

    FinRegWriteData <= WB_DATA_POST;

-- Hazard detection
    Hazard_U : entity work.HazardUnit
    port map(
        ID_EX_MemRead => ID_EX_MemRead, 
        ID_EX_WR      => ID_EX_WR,       

        IF_ID_Rn      => rn_field,       
        IF_ID_Rm      => rm_field,

        PCWrite       => PCWrite_sig,    
        IFIDWrite     => IFIDWrite_sig, 
        ControlStall  => ControlStall_sig
    );

-- Forwarding
    FWD_U : entity work.ForwardingUnit
    port map(
        EX_MEM_RegWrite => EX_MEM_RegWrite,
        EX_MEM_MemWrite => EX_MEM_MemWrite,
        EX_MEM_WR => EX_MEM_WR,
        MEM_WB_RegWrite => MEM_WB_RegWrite,
        MEM_WB_WR => MEM_WB_WR,
        ID_EX_RR1 => ID_EX_RR1,
        ID_EX_RR2 => ID_EX_RR2,
        ID_EX_MemWrite => ID_EX_MemWrite,
        EX_MEM_RR2 => EX_MEM_RR2,
        ForwardA => ForwardA_sig,
        ForwardB => ForwardB_sig,
        ForwardC => ForwardC_sig,
        ForwardCEX => ForwardCEX_sig
    );

    DEBUG_FORWARDA <= ForwardA_sig;
    DEBUG_FORWARDB <= ForwardB_sig;

end Behavioral;
