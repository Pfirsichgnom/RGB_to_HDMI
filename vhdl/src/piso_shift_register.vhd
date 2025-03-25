----------------------------------------------------------------------------------
-- Create Date: 22.03.2025 22:56:40
-- Design Name: piso_shift_register
-- Module Name: piso_shift_register - Behavioral
-- Project Name: piso_shift_register
-- Description: A parallel in serial out shift register with variable register length.
-- 
--                   ----------------------
--                  |                      |
--          CLK_i-->| piso_shift_register  |
--          RST_i-->|                      |--> SData_o
--        PData_i-->|                      |
--                  |                      |
--                   ----------------------
-- 
-- Revision 1.0 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY piso_shift_register IS
	GENERIC (
		reg_len : INTEGER := 10
	);
	PORT (
		CLK_i : IN STD_LOGIC;
		RST_i : IN STD_LOGIC;
		PData_i : IN STD_LOGIC_VECTOR (reg_len - 1 DOWNTO 0);
		SData_o : OUT STD_LOGIC
	);
END piso_shift_register;

ARCHITECTURE Behavioral OF piso_shift_register IS
	SIGNAL pdata_s : STD_LOGIC_VECTOR (reg_len - 2 DOWNTO 0) := (OTHERS => '0');
	SIGNAL counter : INTEGER := 0;
	SIGNAL sdata_s : STD_LOGIC := '0';

BEGIN

	PROCESS (CLK_i)
	BEGIN
		IF (rising_edge(CLK_i)) THEN
			IF RST_i = '0' THEN
				pdata_s <= (OTHERS => '0');
				counter <= 0;
				sdata_s <= '0';
			ELSE
				IF counter = 0 THEN
					pdata_s <= PData_i(reg_len - 1 DOWNTO 1);
					counter <= reg_len-1;
					sdata_s <= PData_i(0);
				ELSE
					counter <= counter - 1;
					pdata_s <= '0' & pdata_s(reg_len - 2 DOWNTO 1);
					sdata_s <= pdata_s(0);
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	sdata_o <= sdata_s;
END Behavioral;
