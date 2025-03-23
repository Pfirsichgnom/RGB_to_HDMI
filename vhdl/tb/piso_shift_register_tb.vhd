----------------------------------------------------------------------------------
-- Create Date: 21.03.2025 25:22:47
-- Design Name: piso_shift_register_tb
-- Module Name: piso_shift_register_tb- Behavioral
-- Project Name: piso_shift_register_tb
-- Description: 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;
USE IEEE.math_real.ALL;

ENTITY piso_shift_register_tb IS
	--  Port ( );
END piso_shift_register_tb;

ARCHITECTURE Behavioral OF piso_shift_register_tb IS

	CONSTANT half_clock_period_c : TIME := 10 ns;
	CONSTANT clock_period_c : TIME := 2 * half_clock_period_c;
	CONSTANT reg_len_c : INTEGER := 10;
	CONSTANT mem_len_c : INTEGER := (reg_len_c) * 60;

	SIGNAL clk_s : STD_LOGIC := '0';
	SIGNAL rst_s : STD_LOGIC := '0';
	SIGNAL pdata_s : STD_LOGIC_VECTOR (reg_len_c - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sdata_s : STD_LOGIC;

	SIGNAL runmem_s : STD_LOGIC_VECTOR(mem_len_c - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL cntmem_s : STD_LOGIC_VECTOR(mem_len_c - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL start_record_s : STD_LOGIC := '0';

	IMPURE FUNCTION random_std_logic_vector(len : INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE random_r : real;
		VARIABLE std_logic_vector_return : STD_LOGIC_VECTOR(len - 1 DOWNTO 0);
		VARIABLE s1 : INTEGER := 12345;
		VARIABLE s2 : INTEGER := 854;
	BEGIN
		FOR i IN 0 TO len - 1 LOOP
			uniform(s1, s2, random_r);
			IF random_r >= 0.5 THEN
				std_logic_vector_return(i) := '1';
			ELSE
				std_logic_vector_return(i) := '0';
			END IF;
		END LOOP;
		RETURN std_logic_vector_return;
	END FUNCTION;

	COMPONENT piso_shift_register IS
		GENERIC (
			reg_len : INTEGER := 10
		);
		PORT (
			CLK_i : IN STD_LOGIC;
			RST_i : IN STD_LOGIC;
			PData_i : IN STD_LOGIC_VECTOR (reg_len - 1 DOWNTO 0);
			SData_o : OUT STD_LOGIC
		);
	END COMPONENT;
BEGIN
	uut : piso_shift_register
	GENERIC MAP(reg_len => reg_len_c)
	PORT MAP(
		clk_s, rst_s, pdata_s, sdata_s
	);

	clk_gen : PROCESS
	BEGIN
		clk_s <= NOT clk_s;
		WAIT FOR half_clock_period_c;
	END PROCESS;

	der : PROCESS
	BEGIN

		rst_s <= '0';
		pdata_s <= (OTHERS => '0');
		runmem_s <= random_std_logic_vector(runmem_s'length);
		start_record_s <= '0';
		WAIT FOR clock_period_c;

		FOR i IN 0 TO ((mem_len_c)/reg_len_c) - 1
        LOOP
            start_record_s <= '1';
            rst_s <= '1';
            pdata_s <= runmem_s((reg_len_c - 1) * (i + 1) + i DOWNTO i * (reg_len_c - 1) + i);
            WAIT FOR clock_period_c * reg_len_c;
        END LOOP;

        WAIT FOR clock_period_c;
        ASSERT runmem_s = cntmem_s REPORT "Paralell Input and Serial Output content are not equal" SEVERITY failure;
        ASSERT 1 = 0 REPORT "Simulation complete successfully" SEVERITY failure;

    END PROCESS;

    der2 : PROCESS
    BEGIN
        WAIT FOR clock_period_c;
        IF start_record_s = '1' THEN
            cntmem_s <= sdata_s & cntmem_s(cntmem_s'length - 1 DOWNTO 1);
        END IF;
    END PROCESS;

END Behavioral;
