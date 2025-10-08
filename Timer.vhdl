library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FourDigitCounter is
    Port (
        CLK10MS : in  STD_LOGIC;                     -- 10 ms clock input
        SEG_SEL : out STD_LOGIC_VECTOR(3 downto 0);  -- digit select (active low)
        SEG_DATA : out STD_LOGIC_VECTOR(6 downto 0)  -- segments (a–g)
    );
end FourDigitCounter;

architecture Behavioral of FourDigitCounter is

    -- Counters
    signal count_10ms : integer := 0;
    signal counter    : integer range 0 to 9999 := 0;

    -- Digits (thousands to ones)
    signal d1, d2, d3, d4 : integer range 0 to 9 := 0;
    -- d1 = ones, d2 = tens, d3 = hundreds, d4 = thousands

    -- Refresh control
    signal refresh_seg : integer range 0 to 3 := 0;

    -- Segment data registers
    signal seg_reg1, seg_reg2, seg_reg3, seg_reg4 : STD_LOGIC_VECTOR(6 downto 0);

    -- 7-segment digit decoder
    function BCD_to_7SEG(d : integer) return STD_LOGIC_VECTOR is
        variable seg : STD_LOGIC_VECTOR(6 downto 0);
    begin
        case d is
            when 0 => seg := "0000001";
            when 1 => seg := "1001111";
            when 2 => seg := "0010010";
            when 3 => seg := "0000110";
            when 4 => seg := "1001100";
            when 5 => seg := "0100100";
            when 6 => seg := "0100000";
            when 7 => seg := "0001111";
            when 8 => seg := "0000000";
            when 9 => seg := "0000100";
            when others => seg := "1111111";
        end case;
        return seg;
    end function;

begin

    process (CLK10MS)
    begin
        if rising_edge(CLK10MS) then

            ------------------------------------------------
            -- 1. Create 1-second tick from 10 ms clock
            ------------------------------------------------
            if count_10ms = 99 then   -- 100 × 10ms = 1s
                count_10ms <= 0;

                ------------------------------------------------
                -- 2. Increment counter every second
                ------------------------------------------------
                if counter = 9999 then
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

                ------------------------------------------------
                -- 3. Split into individual digits
                ------------------------------------------------
                d1 <= counter mod 10;
                d2 <= (counter / 10) mod 10;
                d3 <= (counter / 100) mod 10;
                d4 <= (counter / 1000) mod 10;

                ------------------------------------------------
                -- 4. Update segment data
                ------------------------------------------------
                seg_reg1 <= BCD_to_7SEG(d1);
                seg_reg2 <= BCD_to_7SEG(d2);
                seg_reg3 <= BCD_to_7SEG(d3);
                seg_reg4 <= BCD_to_7SEG(d4);

            else
                count_10ms <= count_10ms + 1;
            end if;

            ------------------------------------------------
            -- 5. Multiplex the 4 displays
            ------------------------------------------------
            case refresh_seg is
                when 0 =>
                    SEG_SEL <= "1110";       -- enable digit 1 (ones)
                    SEG_DATA <= seg_reg1;
                    refresh_seg <= 1;

                when 1 =>
                    SEG_SEL <= "1101";       -- enable digit 2 (tens)
                    SEG_DATA <= seg_reg2;
                    refresh_seg <= 2;

                when 2 =>
                    SEG_SEL <= "1011";       -- enable digit 3 (hundreds)
                    SEG_DATA <= seg_reg3;
                    refresh_seg <= 3;

                when 3 =>
                    SEG_SEL <= "0111";       -- enable digit 4 (thousands)
                    SEG_DATA <= seg_reg4;
                    refresh_seg <= 0;

                when others =>
                    refresh_seg <= 0;
            end case;

        end if;
    end process;

end Behavioral;
