-- ==========================================================
-- TOP LEVEL - Robot seguidor de luz
-- FPGA: Intel DE10-Lite (MAX10, 50 MHz)
-- Reset: activo bajo (KEY0)
-- Sin PWM: Enable A y B con jumper a VCC
--
-- PINES LDR corregidos segun pin planner real:
--   ldr_front -> PIN_W10
--   ldr_left  -> PIN_V10
--   ldr_right -> PIN_W9
--   ldr_back  -> PIN_V9
-- ==========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk        : in  STD_LOGIC;                    -- PIN_P11
        reset      : in  STD_LOGIC;                    -- PIN_B8  KEY0 activo bajo

        ldr_front  : in  STD_LOGIC;                    -- PIN_W10
        ldr_left   : in  STD_LOGIC;                    -- PIN_V10
        ldr_right  : in  STD_LOGIC;                    -- PIN_W9
        ldr_back   : in  STD_LOGIC;                    -- PIN_V9

        mot_l_a    : out STD_LOGIC;                    -- PIN_AA15 IN1
        mot_l_b    : out STD_LOGIC;                    -- PIN_W13  IN2
        mot_r_a    : out STD_LOGIC;                    -- PIN_W5   IN3
        mot_r_b    : out STD_LOGIC;                    -- PIN_AA14 IN4

        leds_state : out STD_LOGIC_VECTOR(2 downto 0) -- PIN_A8/A9/A10
    );
end top;

architecture Structural of top is
begin
    inst_fsm : entity work.fsm
        port map (
            clk        => clk,
            reset      => reset,
            ldr_front  => ldr_front,
            ldr_left   => ldr_left,
            ldr_right  => ldr_right,
            ldr_back   => ldr_back,
            mot_l_a    => mot_l_a,
            mot_l_b    => mot_l_b,
            mot_r_a    => mot_r_a,
            mot_r_b    => mot_r_b,
            leds_state => leds_state
        );
end Structural;