----------------------------------------------------------------------------------
-- Create Date: 22.03.2025 22:51:45
-- Design Name: TMDS_ENCODER
-- Module Name: TMDS_ENCODER - Behavioral
-- Project Name: TMDS_ENCODER
-- 
--                   ----------------------
--                  |                      |
--          CLK_i-->|     TMDS_ENCODER     |
--          RST_i-->|                      |--> Data_o
--   Video_Data_i-->|                      |
--Controll_Data_i-->|                      |
--          VDE_i-->|                      |
--                  |                      |
--                   ----------------------
--
-- Revision 1.0 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

ENTITY TMDS_ENCODER IS
	PORT (
		CLK_i : IN STD_LOGIC;
		RST_i : IN STD_LOGIC;
		Video_Data_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		Controll_Data_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		VDE_i : IN STD_LOGIC;
		Data_o : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END TMDS_ENCODER;

ARCHITECTURE Behavioral OF TMDS_ENCODER IS

	FUNCTION ones_to_int (operand : STD_LOGIC := '0') RETURN INTEGER IS
	BEGIN
		IF operand = '1' THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	END FUNCTION;

	FUNCTION ones_in_vec_to_int (operand : STD_LOGIC_VECTOR; size : INTEGER := 7) RETURN INTEGER IS
		VARIABLE sum_v : INTEGER := 0;
	BEGIN
		FOR x IN 0 TO size LOOP
			sum_v := sum_v + ones_to_int(operand(x));
		END LOOP;
		RETURN sum_v;
	END FUNCTION;

	FUNCTION zeros_to_int (operand : STD_LOGIC := '0') RETURN INTEGER IS
	BEGIN
		IF operand = '0' THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	END FUNCTION;

	FUNCTION zeros_in_vec_to_int (operand : STD_LOGIC_VECTOR; size : INTEGER := 7) RETURN INTEGER IS
		VARIABLE sum_v : INTEGER := 0;
	BEGIN
		FOR x IN 0 TO size LOOP
			sum_v := sum_v + zeros_to_int(operand(x));
		END LOOP;
		RETURN sum_v;
	END FUNCTION;
	SIGNAL cnt_s : INTEGER := 0;
	SIGNAL vd_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

BEGIN
	PROCESS (CLK_i, RST_i)
		VARIABLE ones_v : INTEGER := 0;
		VARIABLE zeros_v : INTEGER := 0;
		VARIABLE diff_v : INTEGER := 0;
		VARIABLE q_m_v : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0');
		VARIABLE Data_o_v : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
	BEGIN

		IF (rising_edge(clk_i)) THEN
			IF RST_i = '0' THEN
				cnt_s <= 0;
				vd_s <= (OTHERS => '0');

				diff_v := 0;
				ones_v := 0;
				zeros_v := 0;
				q_m_v := (OTHERS => '0');
				Data_o_v := (OTHERS => '0');
				
			ELSE
				ones_v := ones_in_vec_to_int(vd_s, 7);
				zeros_v := zeros_in_vec_to_int(vd_s, 7);
				diff_v := ones_v - zeros_v;
				IF (ones_v > 4 OR (ones_v = 4 AND vd_s(0) = '0')) THEN

					q_m_v(0) := vd_s(0);
					q_m_v(1) := q_m_v(0) XNOR vd_s(1);
					q_m_v(2) := q_m_v(1) XNOR vd_s(2);
					q_m_v(3) := q_m_v(2) XNOR vd_s(3);
					q_m_v(4) := q_m_v(3) XNOR vd_s(4);
					q_m_v(5) := q_m_v(4) XNOR vd_s(5);
					q_m_v(6) := q_m_v(5) XNOR vd_s(6);
					q_m_v(7) := q_m_v(6) XNOR vd_s(7);
					q_m_v(8) := '0';

				ELSE

					q_m_v(0) := vd_s(0);
					q_m_v(1) := q_m_v(0) XOR vd_s(1);
					q_m_v(2) := q_m_v(1) XOR vd_s(2);
					q_m_v(3) := q_m_v(2) XOR vd_s(3);
					q_m_v(4) := q_m_v(3) XOR vd_s(4);
					q_m_v(5) := q_m_v(4) XOR vd_s(5);
					q_m_v(6) := q_m_v(5) XOR vd_s(6);
					q_m_v(7) := q_m_v(6) XOR vd_s(7);
					q_m_v(8) := '1';

				END IF;
				vd_s <= Video_Data_i;

				ones_v := ones_in_vec_to_int(q_m_v, 7);
				zeros_v := zeros_in_vec_to_int(q_m_v, 7);
				diff_v := ones_v - zeros_v;

				IF VDE_i = '1' THEN

					IF (cnt_s = 0 OR zeros_v = ones_v) THEN

						Data_o_v(9) := NOT q_m_v(8);
						Data_o_v(8) := q_m_v(8);

						IF q_m_v(8) = '1' THEN
							cnt_s <= cnt_s + diff_v;
							Data_o_v(7 DOWNTO 0) := q_m_v(7 DOWNTO 0);
						ELSE
							Data_o_v(7 DOWNTO 0) := NOT q_m_v(7 DOWNTO 0);
							cnt_s <= cnt_s - diff_v;
						END IF;

					ELSE

						IF ((cnt_s > 0 AND ones_v > 4)
							OR (cnt_s < 0 AND ones_v < 4)) THEN

							Data_o_v(9) := '1';
							Data_o_v(8) := q_m_v(8);
							Data_o_v(7 DOWNTO 0) := NOT q_m_v(7 DOWNTO 0);
							cnt_s <= cnt_s + 2 * ones_to_int(q_m_v(8)) - diff_v;
						ELSE

							Data_o_v(9) := '0';
							Data_o_v(8) := q_m_v(8);
							Data_o_v(7 DOWNTO 0) := q_m_v(7 DOWNTO 0);
							cnt_s <= cnt_s - 2 * zeros_to_int(q_m_v(8)) + diff_v;

						END IF;

					END IF;
				ELSE

					CASE (Controll_Data_i) IS
						WHEN "00" => Data_o_v := "1101010100";
						WHEN "01" => Data_o_v := "0010101011";
						WHEN "10" => Data_o_v := "0101010100";
						WHEN "11" => Data_o_v := "1010101011";
						WHEN OTHERS => NULL;
					END CASE;

					cnt_s <= 0;

				END IF;

				Data_o <= Data_o_v;
			END IF;
		END IF;
	END PROCESS;
END Behavioral;
