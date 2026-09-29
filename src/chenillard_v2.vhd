library ieee;
use ieee.std_logic_1164.all;

--- Version améliorée ! on fait un motif qui se décale 

entity tuto_fpga is
    port (
        --intput--
        i_clk : in std_logic;
        i_rst_n : in std_logic;

        -- output--
        o_led : out std_logic_vector (9 downto 0)
    );
end entity tuto_fpga;

architecture rtl of tuto_fpga is
    signal r_led : std_logic_vector (9 downto 0) := "0000000001";
begin

    process(i_clk, i_rst_n)
        variable counter : natural range 0 to 10000000 := 0;
    begin
        if (i_rst_n = '0') then
        counter := 0;

        --- initialisation du motif de base  ---
        r_led <= "0000000001";

        elsif (rising_edge(i_clk)) then
            counter := counter + 1;

            if (counter = 10000000) then
            -- Les bits de 8 à 0 sont décalés sur les bits de 9 à 1--
            r_led(9 downto 1) <= r_led(8 downto 0);
            -- le dernier bit prend la valeur du premier -- 
            r_led(0) <= r_led(9);
         counter := 0;


            end if;
        end if;
    end process;
   o_led <= r_led;

end architecture rtl;