-- VHDL Code for a Digital Timer (MM:SS) using 4-digit 7-Segment Display
-- Based on the structure and partial code snippets from the provided PDF.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define the Entity for the Digital Timer
entity Digital_Timer is
    port (
        GCLK        : in  std_logic;                    -- Global Clock (e.g., 100 MHz)
        RESET       : in  std_logic;                    -- Asynchronous Reset (Active High)
        
        -- 7-Segment Display Outputs
        SEG_DATA    : out std_logic_vector(6 downto 0); -- 7 segments (a, b, c, d, e, f, g)
        SEG_SEL     : out std_logic_vector(3 downto 0)  -- 4 Digit Selects (Active Low for Common Anode)
    );
end entity Digital_Timer;

architecture Behavioral of Digital_Timer is

    -- CONSTANT: Counter limit for 1 second (1 Hz tick)
    -- Assuming GCLK = 100 MHz, 100,000,000 cycles / 2 = 50,000,000 cycles needed per rising edge
    -- (The counter counts from 0 up to 49,999,999, which is 50,000,000 cycles)
    constant CLK_1S_MAX_COUNT : integer := 50000000 - 1; 

    -- CONSTANT: Counter limit for display refreshing (approx 400 Hz)
    -- 100 MHz / (125,000 cycles * 4 digits) = 200 Hz digit refresh rate
    -- 100 MHz / 125000 = 800 Hz signal. 
    -- For 4 digits, we refresh each one at 800/4 = 200 Hz. This is fast enough.
    constant CLK_REF_MAX_COUNT : integer := 125000 - 1; 

    -- Internal Signals
    signal CLK1S            : std_logic := '0';        -- 1 Hz clock signal for the timer logic
    signal CLK_REF          : std_logic := '0';        -- Fast clock for display multiplexing

    -- BCD Registers for the four display digits (MM:SS -> M1, M0, S1, S0)
    signal SEC_UNIT         : unsigned(3 downto 0) := (others => '0'); -- S0 (Seconds units: 0-9)
    signal SEC_TEN          : unsigned(3 downto 0) := (others => '0'); -- S1 (Seconds tens: 0-5)
    signal MIN_UNIT         : unsigned(3 downto 0) := (others => '0'); -- M0 (Minutes units: 0-9)
    signal MIN_TEN          : unsigned(3 downto 0) := (others => '0'); -- M1 (Minutes tens: 0-5)

    -- Register for the currently displayed BCD value
    signal BCD_DISPLAY_REG  : unsigned(3 downto 0);
    
    -- Function to decode BCD (4-bit) to 7-segment (7-bit)
    -- Assuming a Common Anode Display (Active Low Segments)
    function BCD_TO_7SEG (bcd_input : unsigned) return std_logic_vector is
        variable seg_output : std_logic_vector(6 downto 0) := (others => '0');
    begin
        case bcd_input is
            when "0000" => seg_output := "1000000"; -- 0
            when "0001" => seg_output := "1111001"; -- 1
            when "0010" => seg_output := "0100100"; -- 2
            when "0011" => seg_output := "0110000"; -- 3
            when "0100" => seg_output := "0011001"; -- 4
            when "0101" => seg_output := "0010010"; -- 5
            when "0110" => seg_output := "0000010"; -- 6
            when "0111" => seg_output := "1111000"; -- 7
            when "1000" => seg_output := "0000000"; -- 8
            when "1001" => seg_output := "0010000"; -- 9
            when others => seg_output := "1111111"; -- Blank
        end case;
        return seg_output;
    end function BCD_TO_7SEG;

    -- Signal to hold the 7-segment code for the currently selected digit
    signal SEG_DECODED_DATA : std_logic_vector(6 downto 0);

begin

    -- DECODER MAPPING: Map the BCD register to the 7-segment output
    -- This is continuously calculated
    SEG_DECODED_DATA <= BCD_TO_7SEG(BCD_DISPLAY_REG);
    SEG_DATA <= SEG_DECODED_DATA;

    -- ----------------------------------------------------------------------
    -- PROCESS 1: Clock Generation (Based on the PDF's 'How to Synthesize Required Delay' on Page 8)
    -- Creates CLK1S (1 Hz tick for counting) and CLK_REF (400 Hz for refreshing)
    -- ----------------------------------------------------------------------
    process(GCLK, RESET)
        variable count_1s  : integer range 0 to CLK_1S_MAX_COUNT := 0;
        variable count_ref : integer range 0 to CLK_REF_MAX_COUNT := 0;
    begin
        if RESET = '1' then
            count_1s  := 0;
            CLK1S     <= '0';
            count_ref := 0;
            CLK_REF   <= '0';
        elsif rising_edge(GCLK) then
            -- 1. Generate 1 Hz Clock (CLK1S) for Timer logic
            if count_1s < CLK_1S_MAX_COUNT then
                count_1s := count_1s + 1;
            else
                count_1s := 0;
                CLK1S <= not CLK1S; -- Toggle for 1 Hz
            end if;

            -- 2. Generate Refresh Clock (CLK_REF) for Multiplexing
            if count_ref < CLK_REF_MAX_COUNT then
                count_ref := count_ref + 1;
            else
                count_ref := 0;
                CLK_REF <= not CLK_REF; -- Toggle for 400 Hz (fast refresh)
            end if;
        end if;
    end process;


    -- ----------------------------------------------------------------------
    -- PROCESS 2: Timer Counter Logic (The "rest of the timers code" that was missing)
    -- This process updates the MM:SS BCD registers on the 1 Hz rising edge of CLK1S.
    -- ----------------------------------------------------------------------
    process(CLK1S, RESET)
    begin
        if RESET = '1' then
            SEC_UNIT <= (others => '0');
            SEC_TEN  <= (others => '0');
            MIN_UNIT <= (others => '0');
            MIN_TEN  <= (others => '0');
        elsif rising_edge(CLK1S) then
            -- Seconds Unit (S0) counts from 0 to 9
            if SEC_UNIT < 9 then
                SEC_UNIT <= SEC_UNIT + 1;
            else
                SEC_UNIT <= (others => '0'); -- Reset to 0
                
                -- Seconds Tens (S1) counts from 0 to 5
                if SEC_TEN < 5 then
                    SEC_TEN <= SEC_TEN + 1;
                else
                    SEC_TEN <= (others => '0'); -- Reset to 0
                    
                    -- Minutes Unit (M0) counts from 0 to 9
                    if MIN_UNIT < 9 then
                        MIN_UNIT <= MIN_UNIT + 1;
                    else
                        MIN_UNIT <= (others => '0'); -- Reset to 0

                        -- Minutes Tens (M1) counts from 0 to 5
                        if MIN_TEN < 5 then
                            MIN_TEN <= MIN_TEN + 1;
                        else
                            -- Timer wraps back to 00:00
                            MIN_TEN <= (others => '0');
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;


    -- ----------------------------------------------------------------------
    -- PROCESS 3: Display Multiplexing/Refreshing 
    -- (Based on the PDF's 'How to Set up a 7-Segment Display' on Pages 5-7, completed and corrected)
    -- Cycles through the four BCD registers (M1, M0, S1, S0) and sets the appropriate select pin.
    -- ----------------------------------------------------------------------
    process(CLK_REF, RESET)
        -- The PDF uses a variable 'RefreshSEG' from 0 to 4. We use 0 to 3 for 4 digits.
        variable RefreshSEG : integer range 0 to 3 := 0; 
    begin
        if RESET = '1' then
            RefreshSEG := 0;
            SEG_SEL <= "1111"; -- Turn all digits OFF (assuming Active Low Selects)
            BCD_DISPLAY_REG <= (others => '0');
        elsif rising_edge(CLK_REF) then
            
            -- Increment the digit selector index (0 -> 1 -> 2 -> 3 -> 0)
            if RefreshSEG < 3 then
                RefreshSEG := RefreshSEG + 1;
            else 
                RefreshSEG := 0;
            end if;

            -- Case statement to select the correct digit and data
            case RefreshSEG is
                when 0 => -- Display S0 (Seconds Unit - Rightmost)
                    SEG_SEL <= "1110"; -- Select Digit 0 (Active Low)
                    BCD_DISPLAY_REG <= SEC_UNIT;

                when 1 => -- Display S1 (Seconds Ten)
                    SEG_SEL <= "1101"; -- Select Digit 1
                    BCD_DISPLAY_REG <= SEC_TEN;

                when 2 => -- Display M0 (Minutes Unit)
                    SEG_SEL <= "1011"; -- Select Digit 2
                    BCD_DISPLAY_REG <= MIN_UNIT;

                when 3 => -- Display M1 (Minutes Ten - Leftmost)
                    SEG_SEL <= "0111"; -- Select Digit 3
                    BCD_DISPLAY_REG <= MIN_TEN;

                when others =>
                    SEG_SEL <= "1111"; -- All OFF
                    BCD_DISPLAY_REG <= (others => '1'); -- Blank BCD
            end case;

        end if;
    end process;

end architecture Behavioral;
