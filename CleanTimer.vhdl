process(CLK10MS)
    variable RefreshSEG : integer range 0 to 4 := 0;
begin
    if rising_edge(CLK10MS) then
        
        -- Increment refresh counter (0 → 4)
        if RefreshSEG < 4 then
            RefreshSEG := RefreshSEG + 1;
        else
            RefreshSEG := 0;
        end if;

        -- Turn off all segments before selecting the next one
        SEG_SEL <= (others => '0');

        -- Select segment and assign data
        case RefreshSEG is
            when 0 =>
                SEG_SEL(0) <= '1';
                SEG_DATA   <= SEG_DATA_reg1;

            when 1 =>
                SEG_SEL(1) <= '1';
                SEG_DATA   <= SEG_DATA_reg2;

            when 2 =>
                SEG_SEL(2) <= '1';
                SEG_DATA   <= SEG_DATA_reg3;

            when 3 =>
                SEG_SEL(3) <= '1';
                SEG_DATA   <= SEG_DATA_reg4;

            when 4 =>
                SEG_SEL(4) <= '1';
                SEG_DATA   <= "0000000";  -- optional: blank or extra digit

            when others =>
                SEG_DATA   <= "0000000";  -- safety fallback
        end case;

    end if;
end process;
