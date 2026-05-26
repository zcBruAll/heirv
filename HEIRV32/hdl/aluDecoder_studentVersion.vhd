-- Setup ALU operation based on instruction
ARCHITECTURE studentVersion OF aluDecoder IS
BEGIN

  -- The following is DUMMY code
  -- Change it according to your needs
  decode : process(op, funct3, funct7, ALUOp)
  begin
    case ALUOp is
      when "11" => ALUControl <= "---"; -- illegal
      when "00" => ALUControl <= "000"; -- lw, sw
      when "01" => ALUControl <= "001"; -- beq
      when others =>
		-- sub
        if funct3 = "000" and op = '1' and funct7 = '1' then
          ALUControl <= "001";
		-- add / addi
		elsif funct3 = "000" then
		  ALUControl <= "000";
		-- sll / slli
		elsif funct3 = "001" then
		  ALUControl <= "110";
		-- slt / slti
        elsif funct3 = "010" then
          ALUControl <= "101";
		-- xor / xori
        elsif funct3 = "100" then
          ALUControl <= "100";
		-- srl / srli
        elsif funct3 = "101" and funct7 = '0' then
          ALUControl <= "111";
		-- or / ori
        elsif funct3 = "110" then
          ALUControl <= "011";
		-- and / andi
        elsif funct3 = "111" then
          ALUControl <= "010";
		-- illegal
        else
          ALUControl <= "---";
        end if;
    end case;
  end process decode;

END ARCHITECTURE studentVersion;
