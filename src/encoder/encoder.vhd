library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity encoder is 
    generic (
    G_FCLK_HZ    : positive := 50000000;  -- i_clk = 50 MHz
    G_PERIODE_MS : positive := 100          -- prélèvement toutes les 100 ms
    );

    port(
        -- signaux d'entrées
        i_a : in std_logic; 
        i_b: in std_logic; 
        i_clk : in std_logic; 
        i_rst_n : in std_logic; 


        -- signaux de sorties 
        r_a_cur : out std_logic; 
        r_b_cur : out std_logic; 

        s_a_rising : out std_logic; 
        s_a_stable : out std_logic; 
        s_a_falling : out std_logic; 

        s_b_rising : out std_logic; 
        s_b_stable : out std_logic; 
        s_b_falling : out std_logic; 


        o_leds: out std_logic_vector( 9 downto 0)
    ); 
end entity encoder;



architecture rtl of encoder is
    -- periode d'echantillonage 
    constant C_DIV : positive := (G_FCLK_HZ / 1000) * G_PERIODE_MS;

    -- compteur
    signal CNT_DCNT : integer range 0 to 10 := 0; 
    signal clockwise     : std_logic := '0'; 
    signal cntclockwise  : std_logic := '0'; 

    signal r_a_prev : std_logic := '0'; 
    signal r_b_prev : std_logic := '0'; 

    -- signaux internes 
    signal r_a_cur_i, r_b_cur_i : std_logic := '0';
    signal s_a_rising_i, s_a_stable_i, s_a_falling_i : std_logic := '0';
    signal s_b_rising_i, s_b_stable_i, s_b_falling_i : std_logic := '0';

    signal s_cnt : integer range 0 to (C_DIV - 1) := 0;
    signal s_en  : std_logic := '0';


begin
    -- Diviseur ---
    process (i_clk)
        begin
            if rising_edge(i_clk) then
                if (i_rst_n='0') then 
                    s_cnt <= 0;
                    s_en  <= '0';
                elsif s_cnt = C_DIV - 1 then
                    s_cnt <= 0 ;
                    s_en  <= '1';
                else
                    s_cnt <= s_cnt + 1;
                    s_en  <= '0';
                end if;
            end if;
    end process;


    --- bascule D pour  A et  B  ----
    process(i_clk, i_rst_n)
        begin 
            if ( i_rst_n = '0') then 
                r_a_cur_i <= '0';
                r_b_cur_i <= '0';
            
            elsif (rising_edge(i_clk)) then
                if( s_en='1') then 
                    r_a_cur_i <= i_a;
                    r_b_cur_i <= i_b ; 
                end if; 
            end if;  
    end process;


    --- Deuxieme bscule D  pour A et B ---- 
    process(i_clk, i_rst_n)
        begin 
            if ( i_rst_n='0') then 
                r_a_prev <= '0'; 
                r_b_prev <= '0';
            elsif ( rising_edge(i_clk)) then
                if ( s_en='1') then 
                    r_a_prev <= r_a_cur_i; 
                    r_b_prev <= r_b_cur_i; 
                end if ;
            end if ; 
    end process;


    -- comparateur----
    process(r_a_prev, r_a_cur_i, r_b_prev, r_b_cur_i)
        begin 
            if ( r_a_prev= r_a_cur_i ) then 
                s_a_stable_i <='1'; 
                s_a_rising_i <='0'; 
                s_a_falling_i <='0'; 
            elsif ( r_a_prev= '1' ) then 
                s_a_stable_i <='0'; 
                s_a_rising_i <='0'; 
                s_a_falling_i <='1'; 
            else 
                s_a_stable_i <='0'; 
                s_a_rising_i <='1'; 
                s_a_falling_i <='0'; 
            end if; 


            if ( r_b_prev= r_b_cur_i ) then 
                s_b_stable_i <='1'; 
                s_b_rising_i <='0'; 
                s_b_falling_i <='0'; 

            elsif ( r_b_prev= '1' ) then 
                s_b_stable_i <='0'; 
                s_b_rising_i <='0'; 
                s_b_falling_i <='1'; 
            else 
                s_b_stable_i <='0'; 
                s_b_rising_i <='1'; 
                s_b_falling_i <='0'; 
            end if; 
    end process;

    
    ------sens de rotation 
    clockwise    <= s_a_rising_i and not r_b_cur_i; 
    cntclockwise <= s_b_rising_i and not r_a_cur_i;


    ---- CNT_DCNT 
    process( i_clk, i_rst_n )
        begin
            if ( i_rst_n = '0') then 
                CNT_DCNT <= 0;
            elsif ( rising_edge(i_clk)) then
                if ( s_en = '1') then 
                    if ( cntclockwise = '1' and CNT_DCNT < 10) then   -- rotation à gauche : +1
                        CNT_DCNT <= CNT_DCNT + 1;
                    elsif ( clockwise = '1' and CNT_DCNT > 0) then    -- rotation à droite : -1
                        CNT_DCNT <= CNT_DCNT - 1;
                    end if;
                end if;
            end if;
    end process;


    -- o_leds : barre de LEDs (CNT_DCNT = nombre de LEDs allumées)
    process( CNT_DCNT )
        begin
            case CNT_DCNT is
                when 0      => o_leds <= "0000000000";
                when 1      => o_leds <= "0000000001";
                when 2      => o_leds <= "0000000011";
                when 3      => o_leds <= "0000000111";
                when 4      => o_leds <= "0000001111";
                when 5      => o_leds <= "0000011111";
                when 6      => o_leds <= "0000111111";
                when 7      => o_leds <= "0001111111";
                when 8      => o_leds <= "0011111111";
                when 9      => o_leds <= "0111111111";
                when others => o_leds <= "1111111111";   -- 10
            end case;
    end process;


    -- recopie des signaux internes vers les sorties
    r_a_cur     <= r_a_cur_i;
    r_b_cur     <= r_b_cur_i;

    s_a_rising  <= s_a_rising_i;
    s_a_stable  <= s_a_stable_i;
    s_a_falling <= s_a_falling_i;

    s_b_rising  <= s_b_rising_i;
    s_b_stable  <= s_b_stable_i;
    s_b_falling <= s_b_falling_i;
         

end architecture rtl;