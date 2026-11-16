library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
    generic (
        G_FCLK_HZ    : positive := 50000000;
        G_PERIODE_MS : positive := 1;
        G_MAX        : positive := 1023
    );
    port (
        i_a     : in std_logic;
        i_b     : in std_logic;
        i_clk   : in std_logic;
        i_rst_n : in std_logic;

        r_a_cur : out std_logic;
        r_b_cur : out std_logic;

        s_a_rising  : out std_logic;
        s_a_stable  : out std_logic;
        s_a_falling : out std_logic;

        s_b_rising  : out std_logic;
        s_b_stable  : out std_logic;
        s_b_falling : out std_logic;

        o_count : out natural range 0 to G_MAX;
        o_leds  : out std_logic_vector(9 downto 0)
    );
end entity encoder;

architecture rtl of encoder is
    signal r_a_sync1, r_a_sync2 : std_logic := '1';
    signal r_b_sync1, r_b_sync2 : std_logic := '1';
    signal r_count : natural range 0 to G_MAX := 0;
begin

    process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            r_a_sync1 <= '1';
            r_a_sync2 <= '1';
            r_b_sync1 <= '1';
            r_b_sync2 <= '1';
            r_count   <= 0;
        elsif rising_edge(i_clk) then
            -- Double synchronisation pour éliminer la métastabilité
            r_a_sync1 <= i_a;
            r_a_sync2 <= r_a_sync1;
            r_b_sync1 <= i_b;
            r_b_sync2 <= r_b_sync1;

            -- Décodage en quadrature sur les transitions de A
            if (r_a_sync2 = '1' and r_a_sync1 = '0') then -- Front descendant de A
                if (r_b_sync2 = '1') then
                    if r_count < G_MAX then 
                        r_count <= r_count + 1; 
                    end if;
                else
                    if r_count > 0 then 
                        r_count <= r_count - 1; 
                    end if;
                end if;
            elsif (r_a_sync2 = '0' and r_a_sync1 = '1') then -- Front montant de A
                if (r_b_sync2 = '0') then
                    if r_count < G_MAX then 
                        r_count <= r_count + 1; 
                    end if;
                else
                    if r_count > 0 then 
                        r_count <= r_count - 1; 
                    end if;
                end if;
            end if;
        end if;
    end process;

    o_count <= r_count;
    o_leds  <= std_logic_vector(to_unsigned(r_count, 10));

    r_a_cur <= r_a_sync2;
    r_b_cur <= r_b_sync2;
    s_a_rising  <= '1' when (r_a_sync2 = '0' and r_a_sync1 = '1') else '0';
    s_a_falling <= '1' when (r_a_sync2 = '1' and r_a_sync1 = '0') else '0';
    s_a_stable  <= r_a_sync2;
    s_b_rising  <= '1' when (r_b_sync2 = '0' and r_b_sync1 = '1') else '0';
    s_b_falling <= '1' when (r_b_sync2 = '1' and r_b_sync1 = '0') else '0';
    s_b_stable  <= r_b_sync2;

end architecture rtl;