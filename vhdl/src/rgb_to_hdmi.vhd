----------------------------------------------------------------------------------
-- Create Date: 22.03.2025 22:35:28
-- Design Name: RGB_TO_HDMI
-- Module Name: RGB_TO_HDMI - Behavioral
-- Project Name: RGB_TO_HDMI
-- Description: A basic video timing generator with TMDS encoder designed to produce a valid HDMI signal.
--
--                   ----------------------
--       CLK_px_i-->|                      |
--          CLK_i-->|     RGB_TO_HDMI      |--> TMDS_CLK_p_o,TMDS_CLK_n_o
--          RST_i-->|                      |--> TDMS_p_o,TDMS_n_o
--            R_i-->|                      |
--            G_i-->|                      |
--            B_i-->|                      |
--                   ----------------------
--
-- Revision 1.0 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY RGB_TO_HDMI IS
	GENERIC (
			h_visible_area : INTEGER := 800; -- Visible horizontal pixels
            h_frontporch   : INTEGER := 40; -- Horizontal front porch width
            h_sync_pulse   : INTEGER := 128; -- Horizontal sync pulse width
            h_back_porch   : INTEGER := 88; -- Horizontal back porch width
            h_whole_line   : INTEGER := 1056; -- Total horizontal pixels
    
            v_visible_area : INTEGER := 600; -- Visible vertical lines
            v_frontporch   : INTEGER := 1; -- Vertical front porch height
            v_sync_pulse   : INTEGER := 4; -- Vertical sync pulse height
            v_back_porch   : INTEGER := 23; -- Vertical back porch height
            v_whole_line   : INTEGER := 628 -- Total vertical lines
		);
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
END RGB_TO_HDMI;

ARCHITECTURE Behavioral OF RGB_TO_HDMI IS

	SIGNAL active_s : STD_LOGIC := '0';
	SIGNAL hsync_s : STD_LOGIC := '0';
	SIGNAL vsync_s : STD_LOGIC := '0';

	SIGNAL red_s : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others=>'0');
	SIGNAL green_s : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others=>'0');
	SIGNAL blue_s : STD_LOGIC_VECTOR(9 DOWNTO 0) := (others=>'0');
	SIGNAL control_s : STD_LOGIC_VECTOR(1 DOWNTO 0) := (others=>'0');
	SIGNAL tmds_s : STD_LOGIC_VECTOR(2 DOWNTO 0) := (others=>'0');

	COMPONENT vga_timing_generator IS
		GENERIC (
			h_visible_area : INTEGER := 800; -- Visible horizontal pixels
            h_frontporch   : INTEGER := 40; -- Horizontal front porch width
            h_sync_pulse   : INTEGER := 128; -- Horizontal sync pulse width
            h_back_porch   : INTEGER := 88; -- Horizontal back porch width
            h_whole_line   : INTEGER := 1056; -- Total horizontal pixels
    
            v_visible_area : INTEGER := 600; -- Visible vertical lines
            v_frontporch   : INTEGER := 1; -- Vertical front porch height
            v_sync_pulse   : INTEGER := 4; -- Vertical sync pulse height
            v_back_porch   : INTEGER := 23; -- Vertical back porch height
            v_whole_line   : INTEGER := 628 -- Total vertical lines
		);
		PORT (
			Clk_i    : IN  STD_LOGIC;
            Rst_i    : IN  STD_LOGIC;
            En_i     : IN  STD_LOGIC;
            Sync_i   : IN  STD_LOGIC;
            Active_o : OUT STD_LOGIC;
            H_sync_o : OUT STD_LOGIC;
            V_sync_o : OUT STD_LOGIC
		);
	END COMPONENT;

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

	COMPONENT TMDS_ENCODER IS
		PORT (
			CLK_i : IN STD_LOGIC;
			RST_i : IN STD_LOGIC;
			Video_Data_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			Controll_Data_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Data_o : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			VDE_i : IN STD_LOGIC
		);
	END COMPONENT;

BEGIN
	control_s <= vsync_s & hsync_s;

	pixel_timer1 : vga_timing_generator
	GENERIC MAP (
			h_visible_area => h_visible_area,
            h_frontporch   => h_frontporch,
            h_sync_pulse   => h_sync_pulse,
            h_back_porch   => h_back_porch,
            h_whole_line   => h_whole_line,
    
            v_visible_area => v_visible_area,
            v_frontporch   => v_frontporch,
            v_sync_pulse   => v_sync_pulse,
            v_back_porch   => v_back_porch,
            v_whole_line   => v_whole_line
		);
	PORT MAP
	(
		CLK_i => CLK_i,
		RST_i => RST_i,
		En_i  => '1',
		Sync_i  => '0',
		Active_o => active_s,
		H_sync_o => hsync_s,
		V_sync_o => vsync_s
	);

	RED_TMDS_ENCODER : TMDS_ENCODER PORT MAP
	(
		CLK_i => CLK_i,
		RST_i => RST_i,		
		Video_Data_i => R_i,
		Controll_Data_i => "00",
		VDE_i => active_s,
		Data_o => red_s
	);
	Green_TMDS_ENCODER : TMDS_ENCODER PORT MAP
	(
		CLK_i => CLK_i,
		RST_i => RST_i,
		Video_Data_i => G_i,
		Controll_Data_i => "00",
		VDE_i => active_s,
		Data_o => green_s
	);
	Blue_TMDS_ENCODER : TMDS_ENCODER PORT MAP
	(
		CLK_i => CLK_i,
		RST_i => RST_i,
		Video_Data_i => B_i,
		Controll_Data_i => control_s,
		VDE_i => active_s,
		Data_o => blue_s
	);

	Blue_pisoshr : piso_shift_register
	GENERIC MAP(reg_len => 10)
	PORT MAP(
		CLK_i => CLK_px_i,
		RST_i => RST_i,
		PData_i => blue_s,
		SData_o => tmds_s(0)
	);

	Blue_OBUFDS : OBUFDS
	GENERIC MAP(
		IOSTANDARD => "TMDS_33",
		SLEW => "FAST")
	PORT MAP(
		O => TDMS_p_o(0),
		OB => TDMS_n_o(0),
		I => tmds_s(0)
	);

	Green_pisoshr : piso_shift_register
	GENERIC MAP(reg_len => 10)
	PORT MAP(
		CLK_i => CLK_px_i,
		RST_i => RST_i,
		PData_i => green_s,
		SData_o => tmds_s(1)
	);

	Green_OBUFDS : OBUFDS
	GENERIC MAP(
		IOSTANDARD => "TMDS_33",
		SLEW => "FAST")
	PORT MAP(
		O => TDMS_p_o(1),
		OB => TDMS_n_o(1),
		I => tmds_s(1)
	);
	Red_pisoshr : piso_shift_register
	GENERIC MAP(reg_len => 10)
	PORT MAP(
		CLK_i => CLK_px_i,
		RST_i => RST_i,
		PData_i => red_s,
		SData_o => tmds_s(2)
	);

	RED_OBUFDS : OBUFDS
	GENERIC MAP(
		IOSTANDARD => "TMDS_33",
		SLEW => "FAST")
	PORT MAP(
		O => TDMS_p_o(2),
		OB => TDMS_n_o(2),
		I => tmds_s(2)
	);

	CLK_OBUFDS : OBUFDS
	GENERIC MAP(
		IOSTANDARD => "TMDS_33",
		SLEW => "FAST")
	PORT MAP(
		O => TMDS_CLK_p_o,
		OB => TMDS_CLK_n_o,
		I => CLK_i
	);
END Behavioral;
