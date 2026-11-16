library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library pll;
use pll.all;

entity telecran is
    port (
        -- FPGA
        i_clk_50: in std_logic;

        -- HDMI
        io_hdmi_i2c_scl        : inout std_logic;
        io_hdmi_i2c_sda        : inout std_logic;
        o_hdmi_tx_clk          : out std_logic;
        o_hdmi_tx_d            : out std_logic_vector(23 downto 0);
        o_hdmi_tx_de           : out std_logic;
        o_hdmi_tx_hs           : out std_logic;
        i_hdmi_tx_int          : in std_logic;
        o_hdmi_tx_vs           : out std_logic;

        -- KEYs
        i_rst_n : in std_logic;
          
        -- LEDs
        o_leds : out std_logic_vector(9 downto 0);
        o_de10_leds : out std_logic_vector(7 downto 0);

        -- Coder
        i_left_ch_a : in std_logic;
        i_left_ch_b : in std_logic;
        i_left_pb : in std_logic;
        i_right_ch_a : in std_logic;
        i_right_ch_b : in std_logic;
        i_right_pb : in std_logic
    );
end entity telecran;

architecture rtl of telecran is
    component I2C_HDMI_Config 
        port (
            iCLK : in std_logic;
            iRST_N : in std_logic;
            I2C_SCLK : out std_logic;
            I2C_SDAT : inout std_logic;
            HDMI_TX_INT  : in std_logic
        );
     end component;
     
    component pll 
        port (
            refclk : in std_logic;
            rst : in std_logic;
            outclk_0 : out std_logic;
            locked : out std_logic
        );
    end component;

    component hdmi_controler
        generic (
            h_res : positive := 720;
            v_res : positive := 480;

            h_sync : positive := 61;
            h_fp   : positive := 58;
            h_bp   : positive := 18;

            v_sync : positive := 5;
            v_fp   : positive := 30;
            v_bp   : positive := 9
        );
        port (
            i_clk            : in std_logic;
            i_rst_n          : in std_logic;

            o_hdmi_hs        : out std_logic;
            o_hdmi_vs        : out std_logic;
            o_hdmi_de        : out std_logic;

            o_pixel_en       : out std_logic;
            o_pixel_address  : out natural range 0 to (h_res * v_res - 1);
            o_x_counter      : out natural range 0 to (h_res - 1);
            o_y_counter      : out natural range 0 to (v_res - 1)
        );
    end component;

    component encoder
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
    end component;

    component dpram is
        generic (
            mem_size    : natural := 720 * 480;
            data_width  : natural := 8
        );
        port (
            i_clk_a     : in std_logic;
            i_clk_b     : in std_logic;
            i_data_a    : in std_logic_vector(data_width-1 downto 0);
            i_data_b    : in std_logic_vector(data_width-1 downto 0);
            i_addr_a    : in natural range 0 to mem_size-1;
            i_addr_b    : in natural range 0 to mem_size-1;
            i_we_a      : in std_logic := '1';
            i_we_b      : in std_logic := '1';
            o_q_a       : out std_logic_vector(data_width-1 downto 0);
            o_q_b       : out std_logic_vector(data_width-1 downto 0)
        );
    end component;

    constant h_res : natural := 720;
    constant v_res : natural := 480;

    signal s_clk_27 : std_logic;
    signal s_rst_n : std_logic;    

    -- Compteurs du controleur HDMI
    signal s_x_counter : natural range 0 to (h_res - 1);
    signal s_y_counter : natural range 0 to (v_res - 1);

    -- Position du stylet
    signal s_x_enc : natural range 0 to (h_res - 1);
    signal s_y_enc : natural range 0 to (v_res - 1);

    signal s_leds_x : std_logic_vector(9 downto 0);
    signal s_leds_y : std_logic_vector(9 downto 0);

    -- Signaux pour la RAM dual-port et l'effacement
    signal s_wr_addr      : natural range 0 to (720 * 480 - 1);
    signal s_rd_addr      : natural range 0 to (720 * 480 - 1);
    signal s_pixel_in     : std_logic_vector(0 downto 0);
    signal s_pixel_out    : std_logic_vector(0 downto 0);
    
    signal s_erase_active : std_logic := '0';
    signal s_erase_addr   : natural range 0 to (720 * 480 - 1) := 0;

begin
    
    -- Frequence pour HDMI de 27MHz generée par le PLL
    pll0 : component pll 
        port map (
            refclk => i_clk_50,
            rst => not(i_rst_n),
            outclk_0 => s_clk_27,
            locked => s_rst_n
        );

    -- Configure le ADV7513 pour du 480p
    I2C_HDMI_Config0 : component I2C_HDMI_Config 
        port map (
            iCLK => i_clk_50,
            iRST_N => i_rst_n,
            I2C_SCLK => io_hdmi_i2c_scl,
            I2C_SDAT => io_hdmi_i2c_sda,
            HDMI_TX_INT => i_hdmi_tx_int
     );

    -- HDMI controller (480p)
    hdmi_controler0 : component hdmi_controler
        generic map (
            h_res => h_res,
            v_res => v_res
        )
        port map (
            i_clk            => s_clk_27,
            i_rst_n          => s_rst_n,
            o_hdmi_hs        => o_hdmi_tx_hs,
            o_hdmi_vs        => o_hdmi_tx_vs,
            o_hdmi_de        => o_hdmi_tx_de,
            o_pixel_en       => open,
            o_pixel_address  => open,
            o_x_counter      => s_x_counter,
            o_y_counter      => s_y_counter
        );

    -- Encodeur gauche : deplacement horizontal (x)
    encoder_left : component encoder
        generic map (
            G_FCLK_HZ    => 27000000,
            G_PERIODE_MS => 1,
            G_MAX        => h_res - 1
        )
        port map (
            i_a         => i_left_ch_a,
            i_b         => i_left_ch_b,
            i_clk       => s_clk_27,
            i_rst_n     => s_rst_n,
            r_a_cur     => open,
            r_b_cur     => open,
            s_a_rising  => open,
            s_a_stable  => open,
            s_a_falling => open,
            s_b_rising  => open,
            s_b_stable  => open,
            s_b_falling => open,
            o_count     => s_x_enc,
            o_leds      => s_leds_x
        );

    -- Encodeur droit : deplacement vertical (y)
    encoder_right : component encoder
        generic map (
            G_FCLK_HZ    => 27000000,
            G_PERIODE_MS => 1,
            G_MAX        => v_res - 1
        )
        port map (
            i_a         => i_right_ch_a,
            i_b         => i_right_ch_b,
            i_clk       => s_clk_27,
            i_rst_n     => s_rst_n,
            r_a_cur     => open,
            r_b_cur     => open,
            s_a_rising  => open,
            s_a_stable  => open,
            s_a_falling => open,
            s_b_rising  => open,
            s_b_stable  => open,
            s_b_falling => open,
            o_count     => s_y_enc,
            o_leds      => s_leds_y
        );

    -- Gestion du balayage pour l'effacement de l'écran (via le bouton de l'encodeur gauche)
    process(s_clk_27, s_rst_n)
    begin
        if (s_rst_n = '0') then
            s_erase_active <= '0';
            s_erase_addr   <= 0;
        elsif rising_edge(s_clk_27) then
            if (i_left_pb = '0') then -- Appui sur le bouton (actif bas)
                s_erase_active <= '1';
                s_erase_addr   <= 0;
            elsif (s_erase_active = '1') then
                if (s_erase_addr = (h_res * v_res - 1)) then
                    s_erase_active <= '0';
                else
                    s_erase_addr <= s_erase_addr + 1;
                end if;
            end if;
        end if;
    end process;

    -- Multiplexage des adresses et des données d'écriture (Port A) : Effacement prioritaire ou Dessin par le stylet
    s_wr_addr  <= s_erase_addr when s_erase_active = '1' else (s_y_enc * h_res + s_x_enc);
    s_pixel_in <= "0"          when s_erase_active = '1' else "1";

    -- Port B : Lecture continue pilotée par les compteurs du contrôleur HDMI
    s_rd_addr  <= s_y_counter * h_res + s_x_counter;

    -- Instanciation de la mémoire RAM dual-port
    dpram0 : component dpram
        generic map (
            mem_size   => h_res * v_res,
            data_width => 1
        )
        port map (
            i_clk_a     => s_clk_27,
            i_clk_b     => s_clk_27,
            i_data_a    => s_pixel_in,
            i_data_b    => "0",
            i_addr_a    => s_wr_addr,
            i_addr_b    => s_rd_addr,
            i_we_a      => '1',
            i_we_b      => '0',
            o_q_a       => open,
            o_q_b       => s_pixel_out
        );

    -- Pixel clock 
    o_hdmi_tx_clk <= s_clk_27;

    -- Affichage du pixel :
    o_hdmi_tx_d <= x"FFFFFF" when s_pixel_out(0) = '1' else x"000000";

end architecture rtl;