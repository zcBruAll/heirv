-- Defines extend type based on instruction
ARCHITECTURE studentVersion OF instrDecoder IS
BEGIN

  -- The following is DUMMY code
  -- Change it according to your needs
  decode : process(op)
  begin
    case op is
      when "0010011" => immSrc <= "00";
      when "0000011" => immSrc <= "00";
      when "0100011" => immSrc <= "01";
      when "1100011" => immSrc <= "10";
      when "1101111" => immSrc <= "11";
      when "1100111" => immSrc <= "00";
      when others    => immSrc <= "--";
    end case;
  end process decode;

END ARCHITECTURE studentVersion;
