-- ==========================================================
-- ULTRASONICO HC-SR04
-- Funcion:
--   Genera trigger de 10 us.
--   Mide el ancho del pulso ECHO.
--   Activa obstaculo_20cm = '1' si la distancia es <= umbral.
-- Formula aproximada:
--   distancia_cm = tiempo_echo_us / 58
--   Para 20 cm: tiempo_echo_us = 20 * 58 = 1160 us
-- ==========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ultrasonico_hcsr04 is
    generic (
        CLK_FREQ_HZ       : positive := 50_000_000;
        DIST_THRESHOLD_CM : positive := 20;
        MEASURE_PERIOD_MS : positive := 60;
        ECHO_TIMEOUT_MS   : positive := 30
    );
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC; 

        echo            : in  STD_LOGIC;
        trigger         : out STD_LOGIC;

        obstaculo_20cm  : out STD_LOGIC;
        medida_lista    : out STD_LOGIC
    );
end ultrasonico_hcsr04;

architecture Behavioral of ultrasonico_hcsr04 is

    function us_to_ticks(us_value : positive) return natural is
    begin
        return (CLK_FREQ_HZ / 1_000_000) * us_value;
    end function;

    function ms_to_ticks(ms_value : positive) return natural is
    begin
        return (CLK_FREQ_HZ / 1_000) * ms_value;
    end function;

    constant TRIG_TICKS         : natural := us_to_ticks(10);
    constant PERIOD_TICKS       : natural := ms_to_ticks(MEASURE_PERIOD_MS);
    constant ECHO_TIMEOUT_TICKS : natural := ms_to_ticks(ECHO_TIMEOUT_MS);
    constant DIST_LIMIT_TICKS   : natural := us_to_ticks(58 * DIST_THRESHOLD_CM);

    type sensor_state_type is (
        S_IDLE,
        S_TRIGGER,
        S_WAIT_ECHO_HIGH,
        S_COUNT_ECHO
    );

    signal sensor_state : sensor_state_type := S_IDLE;

    signal trigger_r        : STD_LOGIC := '0';
    signal obstaculo_r      : STD_LOGIC := '0';
    signal medida_lista_r   : STD_LOGIC := '0';

    signal period_cnt       : natural range 0 to PERIOD_TICKS       := 0;
    signal trig_cnt         : natural range 0 to TRIG_TICKS         := 0;
    signal timeout_cnt      : natural range 0 to ECHO_TIMEOUT_TICKS := 0;
    signal echo_cnt         : natural range 0 to ECHO_TIMEOUT_TICKS := 0;

    signal echo_ff1         : STD_LOGIC := '0';
    signal echo_ff2         : STD_LOGIC := '0';

begin

    trigger        <= trigger_r;
    obstaculo_20cm <= obstaculo_r;
    medida_lista   <= medida_lista_r;

    -- Sincronizador de ECHO
    process(clk, reset)
    begin
        if reset = '0' then
            echo_ff1 <= '0';
            echo_ff2 <= '0';
        elsif rising_edge(clk) then
            echo_ff1 <= echo;
            echo_ff2 <= echo_ff1;
        end if;
    end process;

    -- Maquina de medicion del sensor
    process(clk, reset)
    begin
        if reset = '0' then
            sensor_state   <= S_IDLE;
            trigger_r      <= '0';
            obstaculo_r    <= '0';
            medida_lista_r <= '0';
            period_cnt     <= 0;
            trig_cnt       <= 0;
            timeout_cnt    <= 0;
            echo_cnt       <= 0;

        elsif rising_edge(clk) then
            -- Pulso de un ciclo cuando termina una medicion.
            medida_lista_r <= '0';

            case sensor_state is

                -- Esperas antes de iniciar una nueva medicion.
                when S_IDLE =>
                    trigger_r   <= '0';
                    trig_cnt    <= 0;
                    timeout_cnt <= 0;
                    echo_cnt    <= 0;

                    if period_cnt >= PERIOD_TICKS - 1 then
                        period_cnt   <= 0;
                        trigger_r    <= '1';
                        sensor_state <= S_TRIGGER;
                    else
                        period_cnt <= period_cnt + 1;
                    end if;

                -- Pulso TRIGGER de 10 us.
                when S_TRIGGER =>
                    trigger_r <= '1';

                    if trig_cnt >= TRIG_TICKS - 1 then
                        trig_cnt     <= 0;
                        trigger_r    <= '0';
                        timeout_cnt  <= 0;
                        sensor_state <= S_WAIT_ECHO_HIGH;
                    else
                        trig_cnt <= trig_cnt + 1;
                    end if;

                -- Espera el flanco de subida de ECHO.
                when S_WAIT_ECHO_HIGH =>
                    trigger_r <= '0';

                    if echo_ff2 = '1' then
                        echo_cnt     <= 0;
                        timeout_cnt  <= 0;
                        sensor_state <= S_COUNT_ECHO;

                    elsif timeout_cnt >= ECHO_TIMEOUT_TICKS - 1 then
                        -- No llego eco: se considera sin obstaculo cercano.
                        obstaculo_r    <= '0';
                        medida_lista_r <= '1';
                        timeout_cnt    <= 0;
                        sensor_state   <= S_IDLE;

                    else
                        timeout_cnt <= timeout_cnt + 1;
                    end if;

                -- Cuenta cuanto tiempo ECHO permanece en alto.
                when S_COUNT_ECHO =>
                    if echo_ff2 = '0' then
                        if echo_cnt <= DIST_LIMIT_TICKS then
                            obstaculo_r <= '1';
                        else
                            obstaculo_r <= '0';
                        end if;

                        medida_lista_r <= '1';
                        echo_cnt       <= 0;
                        sensor_state   <= S_IDLE;

                    elsif echo_cnt >= ECHO_TIMEOUT_TICKS - 1 then
                        -- Pulso demasiado largo o sensor atorado.
                        obstaculo_r    <= '0';
                        medida_lista_r <= '1';
                        echo_cnt       <= 0;
                        sensor_state   <= S_IDLE;

                    else
                        echo_cnt <= echo_cnt + 1;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
