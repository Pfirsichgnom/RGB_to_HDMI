----------------------------------------------------------------------------------
-- Create Date: 22.03.2025 22:51:03
-- Design Name: TOP
-- Module Name: TOP - Behavioral
-- Project Name: RGB_TO_HDMI - TOP
--
--                   ----------------------
--          CLK_i-->|                      |
--          RST_i-->|     RGB_TO_HDMI      |--> TMDS_CLK_p_o,TMDS_CLK_n_o
--            R_i-->|         TOP          |--> TDMS_p_o,TDMS_n_o
--            G_i-->|                      |
--            B_i-->|                      |
--            		|                      |
--                   ----------------------
-- 
-- Revision 1.0 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TOP IS
	PORT (
		CLK_i : IN STD_LOGIC;
		RST_i : IN STD_LOGIC;
		R_i : IN STD_LOGIC;
		G_i : IN STD_LOGIC;
		B_i : IN STD_LOGIC;
		TDMS_p_o : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		TDMS_n_o : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		TMDS_clk_p_o : OUT STD_LOGIC;
		TMDS_clk_n_o : OUT STD_LOGIC	
	);
END TOP;

ARCHITECTURE Behavioral OF TOP IS

	COMPONENT clk_wiz_0
		PORT (

			clk_out1 : OUT STD_LOGIC;
			clk_out2 : OUT STD_LOGIC;
			clk_in1 : IN STD_LOGIC
		);
	END COMPONENT;
	COMPONENT RGB_TO_HDMI IS
		PORT (
			CLK_px_i : IN STD_LOGIC;
			CLK_i : IN STD_LOGIC;
			RST_i : IN STD_LOGIC;
			R_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			G_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			B_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			TDMS_p_o : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			TDMS_n_o : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			TMDS_CLK_p_o : OUT STD_LOGIC;
			TMDS_CLK_n_o : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL r_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL g_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL b_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL clk_px_s : STD_LOGIC;
	SIGNAL clk_s : STD_LOGIC;
BEGIN

	r_s <= (OTHERS => R_i);
	g_s <= (OTHERS => G_i);
	b_s <= (OTHERS => B_i);
	clk : clk_wiz_0 PORT MAP(
		clk_in1 => CLK_i,
		clk_out1 => clk_s,
		clk_out2 => clk_px_s
	);
	hdmi : RGB_TO_HDMI PORT MAP
	(
		CLK_px_i => clk_px_s,
		CLK_i => clk_s,
		RST_i => RST_i,
		R_i => r_s,
		G_i => g_s,
		B_i => b_s,
		TDMS_p_o => TDMS_p_o,
		TDMS_n_o => TDMS_n_o,
		TMDS_CLK_p_o => TMDS_CLK_p_o,
		TMDS_CLK_n_o => TMDS_CLK_n_o
	);
END Behavioral;
