
library ieee;
use ieee.std_logic_1164.all;


entity tuto_fpga is
    --Initiation de l'entité tuto_fpga --
    port (
        --input--
        i_clk : in std_logic;
        i_rst_n : in std_logic;

        --output--
        o_led : out std_logic
    ); 

end entity tuto_fpga;

architecture rtl of tuto_fpga is
    signal r_led : std_logic := '0';
begin
    process(i_clk, i_rst_n)
        -- On initialise counter pouvant aller jusqu'à 50 Mhz. 

        variable counter : natural range 0 to 50000000 := 0;
    begin

        if (i_rst_n = '0') then
        counter := 0;
        r_led <= '0';
        

        elsif (rising_edge(i_clk)) then
            -- si counter atteint les 50Mhz ( au bout de 1 seconde) on le réinitialise à 0, la LED s'etteint .
            if (counter = 50000000) then
                counter := 0;
                r_led <= '0';
            -- Si counter atteint les 25 Mhz ( au bout de 0.5 seconde ) la LED s'allume et augmente le counter.
            elsif (counter = 25000000) then
                counter := counter + 1;
                r_led <= '1';


            else
            -- Si on est ni à 1 secondes ni a 0.5secondes, counter augmente entre les deux 
            counter := counter + 1;
            
            -- on réalise donc un clignottement toutes les 0.5 secondes. Un cycle (etteint allumé) dure 1s. 
            end if;
        end if;
    end process;
   o_led <= r_led;
end architecture rtl