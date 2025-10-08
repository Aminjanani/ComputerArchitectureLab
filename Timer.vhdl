process(CLK10MS)
  variable RefreshSEG : integer range 0 to 4 :=0;
  begin
      if (rising_edge(CLK10MS)) then
        if RefreshSEG < 4 then
          RefreshSEG := RefreshSEG + 1 ;
        else RefreshSEG := 0;
      end if;
    case RefreshSEG is
        when 0 =>
              SEG_SEL(4) <='0';
              SEG_SEL(0) <='1';
              SEG_DATA <= SEG_DATA_reg1;
        when 1 => when 1 => 
SEG_SEL(0) <='0';
 SEG_SEL(1) <='1';
 SEG_DATA <= SEG_DATA_reg2;
 when 2 =>
 SEG_SEL(1) <='0';
 SEG_SEL(2) <='1';
 SEG_DATA <= SEG_DATA_reg3;
 when 3 => 
SEG_SEL(2) <='0';
 SEG_SEL(3) <='1';
 SEG_DATA <= SEG_DATA_reg4;
 when 4 => 
SEG_SEL(3) <='0';
 SEG_SEL(4) <='1'; SEG_SEL(2) <='1';
 SEG_DATA <= SEG_DATA_reg3;
 when 3 => 
SEG_SEL(2) <='0';
 SEG_SEL(3) <='1';
 SEG_DATA <= SEG_DATA_reg4;
 when 4 => 
SEG_SEL(3) <='0';
 SEG_SEL(4) <='1';
 SEG_DATA <= "0000000"; 
when others => null;
 end case;
 end if;
 end process;
