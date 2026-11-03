library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder_tb is
end entity encoder_tb;

architecture tb of encoder_tb is
    constant tb_G_FCLK_HZ    : positive := 50000000;
    constant tb_G_PERIODE_MS : positive := 1;   -- 1 ms au lieu de 100 ms pour simuler vite

    constant C_CLK_PERIOD : time := 20 ns;                      -- 50 MHz
    constant C_T_ECH      : time := tb_G_PERIODE_MS * 1 ms;     -- période d'échantillonnage

    signal tb_a     : std_logic := '0';
    signal tb_b     : std_logic := '0';
    signal tb_clk   : std_logic := '0';
    signal tb_rst_n : std_logic := '0';

    signal tb_r_a_cur : std_logic;
    signal tb_r_b_cur : std_logic;

    signal tb_s_a_rising  : std_logic;
    signal tb_s_a_stable  : std_logic;
    signal tb_s_a_falling : std_logic;

    signal tb_s_b_rising  : std_logic;
    signal tb_s_b_stable  : std_logic;
    signal tb_s_b_falling : std_logic;

    signal tb_o_leds : std_logic_vector(9 downto 0) := "0000000000";

    signal tb_done : boolean := false;
begin

    uut : entity work.encoder
        generic map (
            G_FCLK_HZ    => tb_G_FCLK_HZ,
            G_PERIODE_MS => tb_G_PERIODE_MS
        )
        port map (
            i_a     => tb_a,
            i_b     => tb_b,
            i_clk   => tb_clk,
            i_rst_n => tb_rst_n,

            r_a_cur => tb_r_a_cur,
            r_b_cur => tb_r_b_cur,

            s_a_rising  => tb_s_a_rising,
            s_a_stable  => tb_s_a_stable,
            s_a_falling => tb_s_a_falling,

            s_b_rising  => tb_s_b_rising,
            s_b_stable  => tb_s_b_stable,
            s_b_falling => tb_s_b_falling,

            o_leds => tb_o_leds
        );

    -- Horloge 50 MHz
    process
    begin
        while not tb_done loop
            tb_clk <= '0';
            wait for C_CLK_PERIOD / 2;
            tb_clk <= '1';
            wait for C_CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    
    process
    begin
        -- Reset
        tb_rst_n <= '0';
        tb_a <= '0';
        tb_b <= '0';
        wait for 10 * C_CLK_PERIOD;
        tb_rst_n <= '1';
        wait for 3 * C_T_ECH;

        -- Rotation à gauche (B monte pendant que A = 0) : 1ère fois
        tb_b <= '1';
        wait for 3 * C_T_ECH;
        tb_b <= '0';
        wait for 3 * C_T_ECH;

        -- Rotation à gauche : 2ème fois
        tb_b <= '1';
        wait for 3 * C_T_ECH;
        tb_b <= '0';
        wait for 3 * C_T_ECH;

        assert tb_o_leds = "0000000011"
            report "ERREUR : apres 2 rotations a gauche, attendu 0000000011"
            severity error;

        -- Rotation à droite (A monte pendant que B = 0) : 1 fois
        tb_a <= '1';
        wait for 3 * C_T_ECH;
        tb_a <= '0';
        wait for 3 * C_T_ECH;

        assert tb_o_leds = "0000000001"
            report "ERREUR : apres 1 rotation a droite, attendu 0000000001"
            severity error;

        report "Fin de simulation" severity note;
        tb_done <= true;
        wait;
    end process;

end architecture tb;