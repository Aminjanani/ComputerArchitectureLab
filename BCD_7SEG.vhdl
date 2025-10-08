library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD_to_7seg is

    Port (A1, B1, C1, D1 : in  STD_LOGIC; 
      digit_select : out STD_LOGIC_VECTOR(4 downto 0); 
          a, b, c, d, e, f, g, dpbit : out STD_LOGIC);
end BCD_to_7seg;

architecture Behavioral of BCD_to_7seg is
    signal bcd_input : STD_LOGIC_VECTOR(3 downto 0);
begin

    bcd_input <= A1 & B1 & C1 & D1;  
  digit_select <= "11110";
    PROCESS (bcd_input)
    BEGIN
        CASE bcd_input IS
            WHEN "0000" => a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '1'; f <= '1'; g <= '0'; dpbit <= '0'; -- 0
            WHEN "0001" => a <= '0'; b <= '1'; c <= '1'; d <= '0'; e <= '0'; f <= '0'; g <= '0'; dpbit <= '0';-- 1
            WHEN "0010" => a <= '1'; b <= '1'; c <= '0'; d <= '1'; e <= '1'; f <= '0'; g <= '1'; dpbit <= '0'; -- 2
            WHEN "0011" => a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '0'; f <= '0'; g <= '1'; dpbit <= '0'; -- 3
            WHEN "0100" => a <= '0'; b <= '1'; c <= '1'; d <= '0'; e <= '0'; f <= '1'; g <= '1'; dpbit <= '0'; -- 4
            WHEN "0101" => a <= '1'; b <= '0'; c <= '1'; d <= '1'; e <= '0'; f <= '1'; g <= '1'; dpbit <= '0'; -- 5
            WHEN "0110" => a <= '1'; b <= '0'; c <= '1'; d <= '1'; e <= '1'; f <= '1'; g <= '1'; dpbit <= '0'; -- 6
            WHEN "0111" => a <= '1'; b <= '1'; c <= '1'; d <= '0'; e <= '0'; f <= '0'; g <= '0'; dpbit <= '0'; -- 7
            WHEN "1000" => a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '1'; f <= '1'; g <= '1'; dpbit <= '0'; -- 8
            WHEN "1001" => a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '0'; f <= '1'; g <= '1'; dpbit <= '0'; -- 9 
      -- Invalid input assignment we assumed -> "0000000"
            WHEN OTHERS => a <= '0'; b <= '0'; c <= '0'; d <= '0'; e <= '0'; f <= '0'; g <= '0'; dpbit <= '0';
        END CASE;
    END PROCESS;

end Behavioral;
