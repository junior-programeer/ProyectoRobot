-- ==========================================================
-- FSM -SEUIR luz con estado de esquive
-- Estados:
--   ESTADO_INICIO      : 1 segundo parado
--   ESTADO_BUSCAR_LUZ  : detenido hasta detectar luz
--   ESTADO_SEGUIR_LUZ  : mueve motores segun LDR
--   ESTADO_ESQUIVE     : inicia con obstaculo a 20 cm o menos
--   ESTADO_META        : parado al cumplir condicion de meta

--Autores:
--Almodovar Tufiño Tarek - 423127375
--Najera Higuera Junior Josue - 421112869
--Romero Calixto Carlo Magno - 320187890
--Lopez Gonzalez Hector Albino - 320342732
-- ==========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    generic (
        CLK_FREQ_HZ     : positive := 50_000_000;
        ESQUIVE_TIME_MS : positive := 650
    );
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC;

        ldr_front       : in  STD_LOGIC;   -- PIN_W10
        ldr_left        : in  STD_LOGIC;   -- PIN_V10
        ldr_right       : in  STD_LOGIC;   -- PIN_W9
        ldr_back        : in  STD_LOGIC;   -- PIN_V9

        obstaculo_20cm  : in  STD_LOGIC;   -- '1' si hay objeto a 20 cm o menos

        mot_l_a         : out STD_LOGIC;   -- PIN_AA15 IN1
        mot_l_b         : out STD_LOGIC;   -- PIN_W13  IN2
        mot_r_a         : out STD_LOGIC;   -- PIN_W5   IN3
        mot_r_b         : out STD_LOGIC;   -- PIN_AA14 IN4

        leds_state      : out STD_LOGIC_VECTOR(2 downto 0)
    );
end fsm;

architecture Behavioral of fsm is

    constant LDR_ACTIVO : STD_LOGIC := '0';

    type state_type is (
        ESTADO_INICIO,
        ESTADO_BUSCAR_LUZ,
        ESTADO_SEGUIR_LUZ,
        ESTADO_ESQUIVE,
        ESTADO_META
    );

    signal estado : state_type := ESTADO_INICIO;

    constant ARRANQUE_MAX : integer := 50_000_000;
    signal arranque_cnt : integer range 0 to 50_000_000 := 0;

    constant DB_MAX : integer := 2_500_000;
    signal db_f : integer range 0 to 2_500_000 := 0;
    signal db_l : integer range 0 to 2_500_000 := 0;
    signal db_r : integer range 0 to 2_500_000 := 0;
    signal db_b : integer range 0 to 2_500_000 := 0;

    signal luz_front : STD_LOGIC := '0';
    signal luz_left  : STD_LOGIC := '0';
    signal luz_right : STD_LOGIC := '0';
    signal luz_back  : STD_LOGIC := '0';

    function ms_to_ticks(ms_value : positive) return natural is
    begin
        return (CLK_FREQ_HZ / 1_000) * ms_value;
    end function;

    constant ESQUIVE_MAX : natural := ms_to_ticks(ESQUIVE_TIME_MS);
    signal esquive_cnt : natural range 0 to ESQUIVE_MAX := 0;

begin
    -- Debounce y nomralizacion ldr
    process(clk, reset)
    begin
        if reset = '0' then
            db_f <= 0; luz_front <= '0';
            db_l <= 0; luz_left  <= '0';
            db_r <= 0; luz_right <= '0';
            db_b <= 0; luz_back  <= '0';

        elsif rising_edge(clk) then

            if ldr_front = LDR_ACTIVO then
                if db_f < DB_MAX then
                    db_f <= db_f + 1;
                else
                    luz_front <= '1';
                end if;
            else
                db_f <= 0;
                luz_front <= '0';
            end if;

            if ldr_left = LDR_ACTIVO then
                if db_l < DB_MAX then
                    db_l <= db_l + 1;
                else
                    luz_left <= '1';
                end if;
            else
                db_l <= 0;
                luz_left <= '0';
            end if;

            if ldr_right = LDR_ACTIVO then
                if db_r < DB_MAX then
                    db_r <= db_r + 1;
                else
                    luz_right <= '1';
                end if;
            else
                db_r <= 0;
                luz_right <= '0';
            end if;

            if ldr_back = LDR_ACTIVO then
                if db_b < DB_MAX then
                    db_b <= db_b + 1;
                else
                    luz_back <= '1';
                end if;
            else
                db_b <= 0;
                luz_back <= '0';
            end if;

        end if;
    end process;

    -- Prioridad de obstaculo:
    --   Si obstaculo_20cm = '1' durante BUSCAR_LUZ o SEGUIR_LUZ,
    --   entra a ESTADO_ESQUIVE.
    -- ESTADO_ESQUIVE:
    --   Para girar al lado contrario, apaga el izquierdo y activa el derecho.
    process(clk, reset)
    begin
        if reset = '0' then
            estado       <= ESTADO_INICIO;
            arranque_cnt <= 0;
            esquive_cnt  <= 0;
            mot_l_a      <= '0';
            mot_l_b      <= '0';
            mot_r_a      <= '0';
            mot_r_b      <= '0';
            leds_state   <= "000";

        elsif rising_edge(clk) then

            if (estado = ESTADO_BUSCAR_LUZ or estado = ESTADO_SEGUIR_LUZ) and
               (obstaculo_20cm = '1') then

                estado      <= ESTADO_ESQUIVE;
                esquive_cnt <= 0;

                -- Un solo motor activo: motor izquierdo adelante.
                mot_l_a    <= '1';
                mot_l_b    <= '0';
                mot_r_a    <= '0';
                mot_r_b    <= '0';
                leds_state <= "011";

            else
                case estado is

                    when ESTADO_INICIO =>
                        leds_state <= "000";
                        mot_l_a    <= '0';
                        mot_l_b    <= '0';
                        mot_r_a    <= '0';
                        mot_r_b    <= '0';
                        esquive_cnt <= 0;

                        if arranque_cnt = ARRANQUE_MAX then
                            arranque_cnt <= 0;
                            estado       <= ESTADO_BUSCAR_LUZ;
                        else
                            arranque_cnt <= arranque_cnt + 1;
                        end if;

                    -- BUSCAR_LUZ: robot detenido mientras espera luz
                    when ESTADO_BUSCAR_LUZ =>
                        leds_state <= "001";
                        esquive_cnt <= 0;

                        mot_l_a <= '0';
                        mot_l_b <= '0';
                        mot_r_a <= '0';
                        mot_r_b <= '0';

                        if luz_front = '1' or luz_left = '1' or
                           luz_right = '1' or luz_back = '1' then
                            estado <= ESTADO_SEGUIR_LUZ;
                        end if;

                    -- SEGUIR_LUZ
                    when ESTADO_SEGUIR_LUZ =>
                        leds_state <= "010";
                        esquive_cnt <= 0;

                        if luz_front = '1' and luz_left = '1' and luz_right = '1' then
                            estado  <= ESTADO_META;
                            mot_l_a <= '0'; mot_l_b <= '0';
                            mot_r_a <= '0'; mot_r_b <= '0';

                        elsif luz_left = '1' then
                            mot_l_a <= '1'; mot_l_b <= '0';
                            mot_r_a <= '1'; mot_r_b <= '0';

                        elsif luz_back = '1' then
                            mot_l_a <= '0'; mot_l_b <= '1';
                            mot_r_a <= '1'; mot_r_b <= '0';

                        elsif luz_front = '1' then
                            mot_l_a <= '1'; mot_l_b <= '0';
                            mot_r_a <= '0'; mot_r_b <= '1';

                        elsif luz_right = '1' then
                            mot_l_a <= '0'; mot_l_b <= '1';
                            mot_r_a <= '0'; mot_r_b <= '1';

                        else
                            estado  <= ESTADO_BUSCAR_LUZ;
                            mot_l_a <= '0';
                            mot_l_b <= '0';
                            mot_r_a <= '0';
                            mot_r_b <= '0';
                        end if;

                    -- ESQUIVE:
                    -- Inicia desde que ultrasonico detecta obstaculo.
                    when ESTADO_ESQUIVE =>
                        leds_state <= "011";

                        -- Solo motor izquierdo activo hacia adelante.
                        -- Motor derecho apagado.
                        mot_l_a <= '1';
                        mot_l_b <= '0';
                        mot_r_a <= '0';
                        mot_r_b <= '0';

                        if esquive_cnt >= ESQUIVE_MAX - 1 then
                            esquive_cnt <= 0;

                            if luz_front = '1' or luz_left = '1' or
                               luz_right = '1' or luz_back = '1' then
                                estado <= ESTADO_SEGUIR_LUZ;
                            else
                                estado <= ESTADO_BUSCAR_LUZ;
                            end if;
                        else
                            esquive_cnt <= esquive_cnt + 1;
                        end if;
                    -- META: parado
                    when ESTADO_META =>
                        leds_state <= "111";
                        esquive_cnt <= 0;

                        mot_l_a <= '0'; mot_l_b <= '0';
                        mot_r_a <= '0'; mot_r_b <= '0';

                        if luz_front = '0' and luz_left = '0' and luz_right = '0' then
                            estado <= ESTADO_BUSCAR_LUZ;
                        end if;

                    when others =>
                        estado      <= ESTADO_INICIO;
                        esquive_cnt <= 0;
                        mot_l_a     <= '0';
                        mot_l_b     <= '0';
                        mot_r_a     <= '0';
                        mot_r_b     <= '0';
                        leds_state  <= "000";

                end case;
            end if;
        end if;
    end process;

end Behavioral;
