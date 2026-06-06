-- ==========================================================
-- TOP LEVEL - Robot seguidor de luz con esquive ultrasonico
-- FPGA: Intel DE10-Lite (MAX10, 50 MHz)
-- Reset: activo bajo (KEY0)
-- LDR segun pin planner real:
--   ldr_front -> PIN_W10
--   ldr_left  -> PIN_V10
--   ldr_right -> PIN_W7
--   ldr_back  -> PIN_V9
-- Ultrasonico tipo HC-SR04:
-- ==========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk        : in  STD_LOGIC;                    -- PIN_P11, 50 MHz
        reset      : in  STD_LOGIC;                    -- PIN_B8, KEY0 activo bajo

        ldr_front  : in  STD_LOGIC;                    -- PIN_W10
        ldr_left   : in  STD_LOGIC;                    -- PIN_V10
        ldr_right  : in  STD_LOGIC;                    -- PIN_W9
        ldr_back   : in  STD_LOGIC;                    -- PIN_V9

        -- Sensor ultrasonico frontal
        us_echo    : in  STD_LOGIC;                    -- ECHO del sensor, usar divisor a 3.3V
        us_trigger : out STD_LOGIC;                    -- TRIGGER del sensor

        -- Driver de motores tipo L293D / L298N
        mot_l_a    : out STD_LOGIC;                    -- PIN_AA15 IN1
        mot_l_b    : out STD_LOGIC;                    -- PIN_W13  IN2
        mot_r_a    : out STD_LOGIC;                    -- PIN_W5   IN3
        mot_r_b    : out STD_LOGIC;                    -- PIN_AA14 IN4

        leds_state : out STD_LOGIC_VECTOR(2 downto 0)  -- PIN_A8/A9/A10
    );
end top;

architecture Structural of top is

    signal obstaculo_20cm_s : STD_LOGIC;
    signal medida_lista_s   : STD_LOGIC;

begin

    -- Modulo del sensor ultrasonico.
    -- Entrega obstaculo_20cm_s = '1' cuando detecta objeto a 20 cm o menos.
    inst_ultrasonico : entity work.ultrasonico_hcsr04
        generic map (
            CLK_FREQ_HZ       => 50_000_000,
            DIST_THRESHOLD_CM => 20,
            MEASURE_PERIOD_MS => 60,
            ECHO_TIMEOUT_MS   => 30
        )
        port map (
            clk             => clk,
            reset           => reset,
            echo            => us_echo,
            trigger         => us_trigger,
            obstaculo_20cm  => obstaculo_20cm_s,
            medida_lista    => medida_lista_s
        );

    -- FSM principal: seguidor de luz + estado ESTADO_ESQUIVE.
    inst_fsm : entity work.fsm
        generic map (
            CLK_FREQ_HZ     => 50_000_000,
            ESQUIVE_TIME_MS => 650
        )
        port map (
            clk             => clk,
            reset           => reset,

            ldr_front       => ldr_front,
            ldr_left        => ldr_left,
            ldr_right       => ldr_right,
            ldr_back        => ldr_back,

            obstaculo_20cm  => obstaculo_20cm_s,

            mot_l_a         => mot_l_a,
            mot_l_b         => mot_l_b,
            mot_r_a         => mot_r_a,
            mot_r_b         => mot_r_b,

            leds_state      => leds_state
        );

end Structural;
