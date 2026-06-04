-- ==========================================================
-- FSM - Robot seguidor de luz
-- FPGA: Intel DE10-Lite (MAX10, 50 MHz)
-- Reset: activo bajo (KEY0)
-- ==========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;

        ldr_front  : in  STD_LOGIC;   -- PIN_W10
        ldr_left   : in  STD_LOGIC;   -- PIN_V10
        ldr_right  : in  STD_LOGIC;   -- PIN_W9
        ldr_back   : in  STD_LOGIC;   -- PIN_V9

        mot_l_a    : out STD_LOGIC;   -- PIN_AA15
        mot_l_b    : out STD_LOGIC;   -- PIN_W13
        mot_r_a    : out STD_LOGIC;   -- PIN_W5
        mot_r_b    : out STD_LOGIC;   -- PIN_AA14

        leds_state : out STD_LOGIC_VECTOR(2 downto 0)
    );
end fsm;

architecture Behavioral of fsm is

    constant LDR_ACTIVO : STD_LOGIC := '0';

    type state_type is (
        ESTADO_INICIO,
        ESTADO_BUSCAR_LUZ,
        ESTADO_SEGUIR_LUZ,
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

begin

    -- ==========================================================
    -- DEBOUNCE + NORMALIZACION LDR
    -- ==========================================================
    process(clk, reset)
    begin
        if reset = '0' then
            db_f <= 0; luz_front <= '0';
            db_l <= 0; luz_left  <= '0';
            db_r <= 0; luz_right <= '0';
            db_b <= 0; luz_back  <= '0';
        elsif rising_edge(clk) then

            if ldr_front = LDR_ACTIVO then
                if db_f < DB_MAX then db_f <= db_f + 1;
                else luz_front <= '1'; end if;
            else db_f <= 0; luz_front <= '0'; end if;

            if ldr_left = LDR_ACTIVO then
                if db_l < DB_MAX then db_l <= db_l + 1;
                else luz_left <= '1'; end if;
            else db_l <= 0; luz_left <= '0'; end if;

            if ldr_right = LDR_ACTIVO then
                if db_r < DB_MAX then db_r <= db_r + 1;
                else luz_right <= '1'; end if;
            else db_r <= 0; luz_right <= '0'; end if;

            if ldr_back = LDR_ACTIVO then
                if db_b < DB_MAX then db_b <= db_b + 1;
                else luz_back <= '1'; end if;
            else db_b <= 0; luz_back <= '0'; end if;

        end if;
    end process;

    -- ==========================================================
    -- FSM: todo registrado, pines asignados directamente
    --
    -- PARADO  : mot_X_a='0'  mot_X_b='0'
    -- ADELANTE: mot_X_a='1'  mot_X_b='0'
    -- ATRAS   : mot_X_a='0'  mot_X_b='1'
    --
    -- Si las llantas van al reves de lo esperado,
    -- intercambia los cables fisicos en el L298N.
    -- ==========================================================
    process(clk, reset)
    begin
        if reset = '0' then
            estado       <= ESTADO_INICIO;
            arranque_cnt <= 0;
            mot_l_a      <= '0';
            mot_l_b      <= '0';
            mot_r_a      <= '0';
            mot_r_b      <= '0';
            leds_state   <= "000";

        elsif rising_edge(clk) then
            case estado is

            -- ================================================
            -- INICIO: 1 segundo parado antes de arrancar
            -- ================================================
            when ESTADO_INICIO =>
                leds_state <= "000";
                mot_l_a    <= '0';
                mot_l_b    <= '0';
                mot_r_a    <= '0';
                mot_r_b    <= '0';

                if arranque_cnt = ARRANQUE_MAX then
                    arranque_cnt <= 0;
                    estado       <= ESTADO_BUSCAR_LUZ;
                else
                    arranque_cnt <= arranque_cnt + 1;
                end if;

            -- ================================================
            -- BUSCAR_LUZ: gira sobre el eje
            -- Motor izq ADELANTE, motor der ATRAS
            -- Si el carro avanza en vez de girar:
            --   cambia mot_r_b a '0' y mot_l_b a '1'
            -- ================================================
            when ESTADO_BUSCAR_LUZ =>
    leds_state <= "001";

    -- ROBOT DETENIDO MIENTRAS ESPERA LUZ
    mot_l_a <= '0';
    mot_l_b <= '0';
    mot_r_a <= '0';
    mot_r_b <= '0';

    if luz_front='1' or luz_left='1' or luz_right='1' then
        estado <= ESTADO_SEGUIR_LUZ;
    end if;

            -- ================================================
            -- SEGUIR_LUZ
            -- ================================================
            when ESTADO_SEGUIR_LUZ =>
                leds_state <= "010";

                if luz_front='1' and luz_left='1' and luz_right='1' then
                    estado  <= ESTADO_META;
                    mot_l_a <= '0'; mot_l_b <= '0';
                    mot_r_a <= '0'; mot_r_b <= '0';

                elsif luz_front = '1' then
                    mot_l_a <= '1'; mot_l_b <= '0';
                    mot_r_a <= '1'; mot_r_b <= '0';

                elsif luz_left = '1' then
                    mot_l_a <= '0'; mot_l_b <= '1';
                    mot_r_a <= '1'; mot_r_b <= '0';

                elsif luz_right = '1' then
                    mot_l_a <= '1'; mot_l_b <= '0';
                    mot_r_a <= '0'; mot_r_b <= '1';

                else
    estado  <= ESTADO_BUSCAR_LUZ;

    mot_l_a <= '0';
    mot_l_b <= '0';
    mot_r_a <= '0';
    mot_r_b <= '0';
end if;

            -- ================================================
            -- META: parado
            -- ================================================
            when ESTADO_META =>
                leds_state <= "111";
                mot_l_a    <= '0'; mot_l_b <= '0';
                mot_r_a    <= '0'; mot_r_b <= '0';

                if luz_front='0' and luz_left='0' and luz_right='0' then
                    estado <= ESTADO_BUSCAR_LUZ;
                end if;

            when others =>
                estado  <= ESTADO_INICIO;
                mot_l_a <= '0'; mot_l_b <= '0';
                mot_r_a <= '0'; mot_r_b <= '0';

            end case;
        end if;
    end process;

end Behavioral;