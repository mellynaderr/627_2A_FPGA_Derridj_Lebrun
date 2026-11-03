library ieee;
use ieee.std_logic_1164.all;


-- Pour cette première version du chenillard qui n'était pas optimisée, on réalisait un compteur sur 10Mhz
-- on découpe les 10Mhz en 11 ( car il y a 11 positions possibles : 0000000000-> 0000000001 -> . . .-> 1000000000)
-- Chaque bit parmis les 10 représentent donc une LED qui s'allume toutes les 2/11 secondes ( 2secondes pour faire tout le motif)

entity tuto_fpga is
    port (
        --input 
        i_clk : in std_logic;
        i_rst_n : in std_logic;

        -- output 
        o_led : out std_logic_vector (9 downto 0)
    );
end entity tuto_fpga;

architecture rtl of tuto_fpga is
    signal r_led : std_logic_vector (9 downto 0) := "0000000000";
begin

    process(i_clk, i_rst_n)
        variable counter : natural range 0 to 100000000 := 0;
    begin
        if (i_rst_n = '0') then
        counter := 0;
        -- initialisation du motif 
        r_led <= "0000000000";

        elsif (rising_edge(i_clk)) then
           -- lorsque le compteur à atteint la fin du motif à 2secondes 
            if (counter = 100000000) then
            counter := 0;
                r_led <= "0000000000";


            else
            counter := counter + 1;
             --- premiere LED allumé 
            if (counter = 91000000) then
            r_led <= "0000000001";
            --- deuxieme LED allumé
            elsif (counter = 82000000) then
                r_led <= "0000000010";

            elsif (counter = 73000000) then
                r_led <= "0000000100";

            elsif (counter = 64000000) then
                r_led <= "0000001000";

            elsif (counter = 55000000) then
                r_led <= "0000010000";

            elsif (counter = 46000000) then
                r_led <= "0000100000";

            elsif (counter = 37000000) then
                r_led <= "0001000000";

            elsif (counter = 28000000) then
                r_led <= "0010000000";

            elsif (counter = 19000000) then
                r_led <= "0100000000";

            -- dernière allumé
            elsif (counter = 10000000) then
                r_led <= "1000000000";

            end if;
            end if;
        end if;
    end process;
   o_led <= r_led;

end architecture rtl;

--- Cette version n'est évidemment pas optimisée on se propose dans la version 2 de plutot faire un motif de base
--- et le répeter en décalant le motif