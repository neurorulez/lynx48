---------------------------------------------------------------------
-- Control Module to simulate a Mister/Mist-Arm menu by NeuroRulez --
---------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.zpupkg.ALL;

entity data_io is
	generic (
		sysclk_frequency : integer := 640 --500 -- Sysclk frequency * 10 
	);
	port (
		clk 			: in std_logic;
		CLOCK_50    : in std_logic;
		
		reset_n 	: in std_logic;
		debug    : out std_logic;
		
		-- Video signals for OSD
		vga_hsync : in std_logic;
		vga_vsync : in std_logic;

		red_i     : in std_logic_vector(7  downto 0);
		green_i   : in std_logic_vector(7  downto 0);
		blue_i    : in std_logic_vector(7  downto 0);
		
		red_o     : out std_logic_vector(7  downto 0);
		green_o   : out std_logic_vector(7  downto 0);
		blue_o    : out std_logic_vector(7  downto 0);		
		
		-- PS/2 keyboard
		ps2k_clk_in : in std_logic := '1';
		ps2k_dat_in : in std_logic := '1';
	   ps2_key     : out std_logic_vector(10 downto 0) := "00000000000";
		
		host_scandoubler_disable : buffer std_logic;
		
	   --Joystick
		JOY_CLK    : out std_logic;
		JOY_LOAD   : out std_logic;
		JOY_DATA   : in std_logic;
		JOY_SELECT : out std_logic;
		joy1  : out std_logic_vector(6  downto 0); 	
		joy2  : out std_logic_vector(6  downto 0); 	

		--Audio I2s
		dac_MCLK : out std_logic;
		dac_LRCK : out std_logic;
		dac_SCLK : out std_logic;
		dac_SDIN : out std_logic;
		sigma_L : out std_logic;
		sigma_R : out std_logic;
	   L_data : in std_logic_vector(15  downto 0); 	
	   R_data : in std_logic_vector(15  downto 0); 	

		-- SD card interface
		spi_miso		: in std_logic := '1';
		spi_mosi		: out std_logic;
		spi_clk		: out std_logic;
		spi_cs 		: out std_logic;

		-- DIP switches
		status      : out std_logic_vector(31 downto 0);
		
		img_mounted  : out std_logic_vector(1  downto 0);
		img_size     : out std_logic_vector(63 downto 0); --(63 downto 0);
		img_readonly : out std_logic := '0';
		
		-- Host control signals
		ioctl_ce       : in std_logic;
		ioctl_wr       : buffer std_logic;
		ioctl_addr     : buffer std_logic_vector(24 downto 0);
		ioctl_dout     : out std_logic_vector(7  downto 0);  
		ioctl_download : out std_logic;
		ioctl_index    : buffer std_logic_vector(7  downto 0);  
		ioctl_file_ext : out std_logic_vector(31  downto 0) 		
	);
end entity;

architecture rtl of data_io is

-- ZPU signals
constant maxAddrBit : integer := 20; -- 20 Optional - defaults to 32 - but helps keep the logic element count down.
signal mem_busy           : std_logic;
signal mem_read             : std_logic_vector(wordSize-1 downto 0);
signal mem_write            : std_logic_vector(wordSize-1 downto 0);
signal mem_addr             : std_logic_vector(maxAddrBit downto 0);
signal mem_writeEnable      : std_logic; 
signal mem_readEnable       : std_logic;
signal mem_hEnable      : std_logic; 
signal mem_bEnable      : std_logic; 

signal zpu_to_rom : ZPU_ToROM;
signal zpu_from_rom : ZPU_FromROM;


-- OSD related signals

signal osd_wr : std_logic;
signal osd_charwr : std_logic;
signal osd_char_q : std_logic_vector(7 downto 0);
signal osd_data : std_logic_vector(15 downto 0);
signal vga_vsync_d : std_logic;
signal vblank : std_logic;
signal osd_window : std_logic;
signal osd_pixel :  std_logic;


-- PS/2 related signals

signal kbdrecv : std_logic;
signal kbdrecvreg : std_logic;
signal kbdrecvbyte : std_logic_vector(10 downto 0);


-- Interrupt signals

constant int_max : integer := 2;
signal int_triggers : std_logic_vector(int_max downto 0);
signal int_status : std_logic_vector(int_max downto 0);
signal int_ack : std_logic;
signal int_req : std_logic;
signal int_enabled : std_logic :='0'; -- Disabled by default


-- SPI Clock counter
signal spi_tick : unsigned(8 downto 0);
signal spiclk_in : std_logic;
signal spi_fast : std_logic;

-- SPI signals
signal host_to_spi : std_logic_vector(7 downto 0);
signal spi_to_host : std_logic_vector(7 downto 0);
signal spi_trigger : std_logic;
signal spi_busy : std_logic;
signal spi_active : std_logic;

		-- Boot upload signals
signal host_bootdata       : std_logic_vector(31 downto 0);
signal host_bootdata_adr   : std_logic_vector(24 downto 0);
signal host_bootdata_adr_W : std_logic_vector(24 downto 0);
signal host_bootdata_req   : std_logic;
signal host_bootdata_ack   : std_logic :='0';

signal		host_divert_sdcard : std_logic;
signal		host_divert_keyboard :std_logic;
signal		host_reset     : std_logic;
signal		host_video     : std_logic;
signal		host_video_d   : std_logic;
signal		host_loadrom   : std_logic := '0';		
signal		host_loadrom_d : std_logic := '0';		
signal		host_loadmed   : std_logic := '0';		
signal		host_loadmed_d : std_logic := '0';	
signal      reset_address  : std_logic;		
signal		host_download  : std_logic := '0';		

type boot_states is (idle, ramwait);
signal boot_state : boot_states := idle;
signal ram_write  : std_logic_vector(31 downto 0);
signal ram_addr : std_logic_vector(12 downto 0);
signal ram_data_wr_8bit   : std_logic_vector(7 downto 0);
signal ram_addr_wr_8bit : std_logic_vector(18 downto 0); 
signal ram_step : integer := 0;
signal ram_wr  : std_logic := '0';

signal dipswitches : std_logic_vector(31 downto 0);
signal size : std_logic_vector(31 downto 0);
signal extension : std_logic_vector(31 downto 0);
signal ioctl_start_addr     : std_logic_vector(23 downto 0); --Direccion de la ROM para el estado incial
signal ioctl_addr_s     : std_logic_vector(24 downto 0);
signal rclkD  : std_logic := '0';
signal rclkD2 : std_logic := '0';
signal rdownload : std_logic := '0';
signal media_ce : std_logic := '0';

signal ps2_int : std_logic := '0';
signal ps2_scan : std_logic_vector(7 downto 0);
signal keys_s : std_logic_vector(7 downto 0);
signal joystick1 : std_logic_vector(7 downto 0);
signal joystick2 : std_logic_vector(7 downto 0);

	COMPONENT joydecoder
		PORT
		(
			clk		  :	 IN  STD_LOGIC;
			JOY_CLK	  :	 OUT STD_LOGIC;
			JOY_LOAD	  :	 OUT STD_LOGIC;
			JOY_DATA	  :	 IN  STD_LOGIC;
			JOY_SELECT :    OUT STD_LOGIC;
			joystick1  :    OUT STD_LOGIC_VECTOR(7 downto 0);
			joystick2  :    OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	END COMPONENT;

	COMPONENT sigma_delta_dac
	PORT
		(			
			CLK		:	 IN  STD_LOGIC;
			RESET		:	 IN  STD_LOGIC;
			DACin		:   IN  STD_LOGIC_VECTOR(15 downto 0);
			DACout	:   OUT STD_LOGIC
		);
	END COMPONENT;

begin

-- ROM

	myrom : entity work.CtrlROM_ROM
	generic map
	(
		maxAddrBitBRAM => 13
	)
	port map (
		clk => clk,
		from_zpu => zpu_to_rom,
		to_zpu => zpu_from_rom
	);

	
-- Main CPU
-- We instantiate the CPU with the optional instructions enabled, which allows us to reduce
-- the size of the ROM by leaving out emulation code.
	zpu: zpu_core_flex
	generic map (
		IMPL_MULTIPLY => true,
		IMPL_COMPARISON_SUB => true,
		IMPL_EQBRANCH => true,
		IMPL_STOREBH => true,
		IMPL_LOADBH => true,
		IMPL_CALL => true,
		IMPL_SHIFT => true,
		IMPL_XOR => true,
		CACHE => true,	-- Modest speed-up when running from ROM
--		IMPL_EMULATION => minimal, -- Emulate only byte/halfword accesses, with alternateive emulation table
		REMAP_STACK => false, -- We're not using SDRAM so no need to remap the Boot ROM / Stack RAM
		EXECUTE_RAM => false, -- We don't need to execute code from external RAM.
		maxAddrBit => maxAddrBit,
		maxAddrBitBRAM => 13
	)
	port map (
		clk                 => clk,
		reset               => not reset_n,
		in_mem_busy         => mem_busy,
		mem_read            => mem_read,
		mem_write           => mem_write,
		out_mem_addr        => mem_addr,
		out_mem_writeEnable => mem_writeEnable,
		out_mem_hEnable     => mem_hEnable,
		out_mem_bEnable     => mem_bEnable,
		out_mem_readEnable  => mem_readEnable,
		from_rom => zpu_from_rom,
		to_rom => zpu_to_rom,
		interrupt => int_req
	);


-- OSD

myosd : entity work.OnScreenDisplay
port map(
	reset_n => reset_n,
	clk => clk,
	-- Video
	hsync_n => vga_hsync,
	vsync_n => vga_vsync,
	vblank => vblank,
	pixel => osd_pixel,
	window => osd_window,
	-- Registers
	addr => mem_addr(8 downto 0),	-- low 9 bits of address
	data_in => mem_write(15 downto 0),
	data_out => osd_data(15 downto 0),
	reg_wr => osd_wr,			-- Trigger a write to the control registers
	char_wr => osd_charwr,	-- Trigger a write to the character RAM
	char_q => osd_char_q		-- Data from the character RAM
);


-- PS2 keyboard
mykeyboard : entity work.io_ps2_com
generic map (
	clockFilter => 15,
	ticksPerUsec => sysclk_frequency/10
)
port map (
	clk => clk,
	reset => not reset_n, -- active high!
	ps2_clk_in => ps2k_clk_in,
	ps2_dat_in => ps2k_dat_in,
--			ps2_clk_out => ps2k_clk_out, -- Receive only
--			ps2_dat_out => ps2k_dat_out,
	
	inIdle => open,
	sendTrigger => '0',
	sendByte => (others=>'X'),
	sendBusy => open,
	sendDone => open,
	recvTrigger => kbdrecv,
	recvByte => kbdrecvbyte
);

mykeyboardout : entity work.io_ps2_out
port map
(	
	CLK      => clk, 
	OSD_ENA  => host_divert_keyboard,
	ps2_code => kbdrecvbyte(8 downto 1),
	ps2_int  => kbdrecv,
	ps2_key  => ps2_key
);	
-- SPI Timer
process(clk)
begin
	if rising_edge(clk) then
		spiclk_in<='0';
		spi_tick<=spi_tick+1;
		if (spi_fast='1' and spi_tick(5)='1') or spi_tick(8)='1' then
			spiclk_in<='1'; -- Momentary pulse for SPI host.
			spi_tick<='0'&X"00";
		end if;
	end if;
end process;


-- SD Card host

spi : entity work.spi_interface
	port map(
		sysclk => clk,
		reset => reset_n,

		-- Host interface
		spiclk_in => spiclk_in,
		host_to_spi => host_to_spi,
		spi_to_host => spi_to_host,
		trigger => spi_trigger,
		busy => spi_busy,

		-- Hardware interface
		miso => spi_miso,
		mosi => spi_mosi,
		spiclk_out => spi_clk
	);

		
-- Interrupt controller

intcontroller: entity work.interrupt_controller
generic map (
	max_int => int_max
)
port map (
	clk => clk,
	reset_n => reset_n,
	enable => int_enabled,
	trigger => int_triggers,
	ack => int_ack,
	int => int_req,
	status => int_status
);

int_triggers<=(0=>kbdrecv,
					1=>vblank,
					others => '0');

process(clk,reset_n)
begin
	if reset_n='0' then
		int_enabled<='0';
		kbdrecvreg <='0';
		host_reset <='0';
		host_loadrom <='0'; --Se usa para lanzar la se�al de que ha empezado una carga de rom
		host_loadmed <='0';
		host_video <= '0';
		host_bootdata_req<='0';
		host_bootdata_adr <= "0000000000000000000000000";
		spi_active<='0';
		spi_cs<='1';
	elsif reset_address = '1' then
		host_bootdata_adr <= "0000000000000000000000000";
	elsif rising_edge(clk) then
		mem_busy<='1';
		osd_charwr<='0';
		osd_wr<='0';
		int_ack<='0';
		spi_trigger<='0';

		-- Write from CPU?
		if mem_writeEnable='1' then
			case mem_addr(maxAddrBit)&mem_addr(10 downto 8) is
				when X"B" =>	-- OSD controller at 0xFFFFFB00
					osd_wr<='1';
					mem_busy<='0';
				when X"C" =>	-- OSD controller at 0xFFFFFC00 & 0xFFFFFD00
					osd_charwr<='1';
					mem_busy<='0';
				when X"D" =>	-- OSD controller at 0xFFFFFC00 & 0xFFFFFD00
					osd_charwr<='1';
					mem_busy<='0';

				when X"F" =>	-- Peripherals at 0xFFFFFF00
					case mem_addr(7 downto 0) is

						when X"B0" => -- Interrupts
							int_enabled<=mem_write(0);
							mem_busy<='0';

						when X"D0" => -- SPI CS
							spi_cs<=not mem_write(0);
							spi_fast<=mem_write(8);
							mem_busy<='0';

						when X"D4" => -- SPI Data (blocking)
							spi_trigger<='1';
							host_to_spi<=mem_write(7 downto 0);
							spi_active<='1';

						when X"E8" => -- Host boot data
							-- Note that we don't clear mem_busy here; it's set instead when the ack signal comes in.
							host_bootdata_adr_W<=host_bootdata_adr;
							host_bootdata<=mem_write;
							host_bootdata_adr<=std_logic_vector(unsigned(host_bootdata_adr) + 1);
							host_bootdata_req<=not host_bootdata_req;

						when X"EC" => -- Host control
							mem_busy<='0';
							host_reset<=mem_write(0);
							host_divert_keyboard<=mem_write(1);
							host_divert_sdcard<=mem_write(2);
							host_loadrom<=mem_write(3);
							host_video<=mem_write(4);
							host_loadmed<=mem_write(5);
							--host_xxx  <=mem_write(6);
							--host_xxx  <=mem_write(7);

						--when X"F0" => -- Scale Red
						--	mem_busy<='0';
						--	scalered<=unsigned(mem_write(4 downto 0));
							
						when X"F4" => -- Extension
							mem_busy<='0';
							extension<=mem_write(31 downto 0);
							
						when X"F8" => -- ROM Size
							mem_busy<='0';
							size<=mem_write(31 downto 0);
							
						when X"FC" => -- Host SW
							mem_busy<='0';
							dipswitches<=mem_write(31 downto 0);

						when others =>
							mem_busy<='0';
							null;
					end case;
				when others =>
					mem_busy<='0';
			end case;

		-- Read from CPU?
		elsif mem_readEnable='1' then
			case mem_addr(maxAddrBit)&mem_addr(10 downto 8) is
				when X"B" =>	-- OSD registers
					mem_read(31 downto 16)<=(others => '0');
					mem_read(15 downto 0)<=osd_data;
					mem_busy<='0';
				when X"C" =>	-- OSD controller at 0xFFFFFC00 & 0xFFFFFD00
					mem_read(31 downto 8)<=(others => 'X');
					mem_read(7 downto 0)<=osd_char_q;
					mem_busy<='0';
				when X"D" =>	-- OSD controller at 0xFFFFFC00 & 0xFFFFFD00
					mem_read(31 downto 8)<=(others => 'X');
					mem_read(7 downto 0)<=osd_char_q;
					mem_busy<='0';
				when X"F" =>	-- Peripherals
					case mem_addr(7 downto 0) is
					
						when X"B0" => -- Read from Interrupt status register
							mem_read<=(others=>'X');
							mem_read(int_max downto 0)<=int_status;
							int_ack<='1';
							mem_busy<='0';

						when X"D0" => -- SPI Status
							mem_read<=(others=>'X');
							mem_read(15)<=spi_busy;
							mem_busy<='0';

						when X"D4" => -- SPI read (blocking)
							spi_active<='1';
							
						when X"E0" =>	-- Read from PS/2 regs

							mem_read<=(others =>'X');
							mem_read(11 downto 0)<=kbdrecvreg & '1' & kbdrecvbyte(10 downto 1);
							kbdrecvreg<='0';
							mem_busy<='0';
						when others =>
							mem_busy<='0';
							null;
					end case;

				when others => -- SDRAM
					mem_busy<='0';
			end case;
		end if;

		-- Boot data termination - allow CPU to proceed once boot data is acknowleged:
		if host_bootdata_ack='1' then
			mem_busy<='0';
			--host_bootdata_req<='0';
		end if;

		
		-- SPI cycle termination
		if spi_active='1' and spi_busy='0' then
			mem_read(7 downto 0)<=spi_to_host;
			mem_read(31 downto 8)<=(others => '0');
			spi_active<='0';
			mem_busy<='0';
		end if;
		

		if kbdrecv='1' then
			kbdrecvreg <= '1'; -- remains high until cleared by a read
		end if;
		
	end if; -- rising-edge(clk)

end process;

overlay : entity work.OSD_Overlay
port map
(
		clk => clk, 
		red_in => red_i,
		green_in => green_i,
		blue_in => blue_i,
		window_in => '1',
		osd_window_in => osd_window,
		osd_pixel_in => osd_pixel,
		hsync_in => vga_hsync,
		red_out => red_o,
		green_out => green_o,
		blue_out => blue_o,
		window_out => open,
		scanline_ena => '0'
	);

joystick : joydecoder 
port map
(
	clk        => CLOCK_50,
	JOY_CLK    => JOY_CLK,
	JOY_LOAD   => JOY_LOAD,
	JOY_DATA   => JOY_DATA,
	JOY_SELECT => JOY_SELECT,
	joystick1  => joystick1,
	joystick2  => joystick2
);

joy1 <= not joystick1(6 downto 0);
joy2 <= not joystick2(6 downto 0);

audio_top : entity work.audio_top  
port map
(
	clk_50MHz => CLOCK_50,
	dac_MCLK  => dac_MCLK,
	dac_LRCK  => dac_LRCK,
	dac_SCLK  => dac_SCLK,
	dac_SDIN  => dac_SDIN,
	L_data    => L_data,
	R_data    => R_data
); 

sigma_delta_dac_l : sigma_delta_dac
port map
(
	CLK => CLOCK_50,
	RESET => not reset_n,
	DACin => not L_data(15) & L_data(14 downto 0),
	DACout => sigma_L
);

sigma_delta_dac_r : sigma_delta_dac
port map
(
	CLK => CLOCK_50,
	RESET => not reset_n,
	DACin => not R_data(15) & R_data(14 downto 0),
	DACout => sigma_R
);

---	

process(clk)
begin
	if rising_edge(clk) then
		host_video_d <= host_video;
		if host_video_d = '1' and host_video = '0' then
			host_scandoubler_disable <= not host_scandoubler_disable;
		end if;
	end if;
end process;
	
--ioctl_download <= host_loadrom or host_loadmed;
 
ioctl_file_ext(31 DOWNTO 0) <=  extension; --X"2E444154";
img_size <= x"00000000" & size; 
--img_size <= x"00000000" & x"0002F900";

status(0)<=host_reset;
status(31 downto 1)<=dipswitches(31 downto 1);
--status(13 downto 12)<=dipswitches(31 downto 30);
--status(31 downto 14) <= (others => '0');

--status(2 downto 1)<=dipswitches(3 downto 2); --st_joy1
--status(4 downto 3)<=dipswitches(5 downto 4); --st_joy2
--status(5)<='0';
--status(6)<=dipswitches(15); --st_fasttape
--status(7)<='0';
--status(9  downto  8) <= dipswitches(11 downto 10); --st_video_ULA
--status(12 downto 10) <= dipswitches(14 downto 12); --st_memory "100" Plus3
--status(14 downto 13) <= dipswitches(9) & dipswitches(9); --st_feat Recortado 00 = ULA+ & TIMEX 11=Desactivado
--status(16 downto 15) <= dipswitches( 1 downto  0);  --st_scanlines
--status(18 downto 17) <= dipswitches( 7 downto  6);  --st_mmc
--status(19)<='0';
--status(21 downto 20) <= '1' & dipswitches(8);  --st_gsnd Recortado 11 = Off / 10 = GS_2MB
--status(31 downto 22) <= (others => '0');

debug <= '1' when ioctl_index = X"04" else '0';

ioctl_index <= X"00" when host_loadrom = '1' else
               X"01" when extension(23 downto 0)  = x"4F2020" else --Tape .o
				   X"41" when extension(23 downto 0)  = x"502020" else --Tape .p
					X"FF";
					
--ioctl_start_addr <= --x"150000" when host_loadrom = '1' else
						  --x"200000" when host_loadmed = '1' and (extension(23 downto 0)  = x"545244" or extension(23 downto 0)  = x"44534B") else  --dsk o trd
						  --x"400000" when host_loadmed = '1' and (extension(23 downto 0)  = x"544150" or extension(23 downto 0)  = x"545a58" or extension(23 downto 0)  = x"435357") else  --tap o tzx o csw
						  --x"600000" when host_loadmed = '1' and (extension(23 downto 0)  = x"5a3830" or extension(23 downto 0)  = x"534e41") else  --tap o tzx						  
--						  x"000000";
						  
--ioctl_addr <= std_logic_vector(unsigned(ioctl_addr_s) + unsigned(ioctl_start_addr));

--ioctl_download<=host_loadrom or host_loadmed; --host_download; --host_loadrom or host_loadmed;
host_download<=host_loadrom or host_loadmed;
process(clk, host_loadrom, host_loadmed)
begin
if rising_edge(clk) then
 host_loadrom_d <= host_loadrom;
 host_loadmed_d <= host_loadmed;
 --Montamos con "10" porque el "01" esta reservado para montar el ESXDOS
 if ( host_loadmed = '1' and ioctl_index(3 downto 0) = x"1" ) then img_mounted <= "10"; else img_mounted <= "00"; end if;
 if ( (host_loadmed = '0' and host_loadmed_d = '1') or (host_loadrom = '0' and host_loadrom_d = '1') ) then reset_address <= '1'; else reset_address <= '0'; end if;
end if;
end process;

-- State machine to receive and stash boot data in SRAM
process(clk)
begin 
 if rising_edge(clk) then
  if ioctl_ce = '1' or ioctl_index(3 downto 0) = x"1" then --Para la carga a SRAM no tiene que usar el "ioctl_ce"
   rclkD <= host_bootdata_req;
   rclkD2 <= rclkD;
   ioctl_wr <= '0';
   host_bootdata_ack<='0';
   ioctl_download<=host_download;
   if (rclkD /= rclkD2) then
	 ioctl_dout<=host_bootdata(7 downto 0);
	 ioctl_addr<=host_bootdata_adr_W;
	 ioctl_wr<='1';
	 host_bootdata_ack<='1';
   end if; 
  end if;
 end if;
end process;

--media_ce <= rclkD and not rclkD2 when extension(23 downto 0) = x"534e41" else 
--				ioctl_ce;
--
--process(clk, host_bootdata_req, ioctl_ce, reset_address, media_ce)
--begin
--	if rising_edge(clk) then
--		if reset_n='0' or reset_address='1' then
--			ioctl_addr_s <= "0000000000000000000000000";
--			ioctl_wr <= '0';
--			host_bootdata_ack<='0';
--			boot_state<=idle;
--			ram_step <= 0;
--		else
--			host_bootdata_ack<='0';
--			case boot_state is
--				when idle =>
--					if (host_bootdata_req='1' and media_ce = '1') then 
						--if    ram_step = 0 then ioctl_dout<=host_bootdata(31 downto 24); ram_step <= ram_step + 1; 
						--elsif ram_step = 1 then ioctl_dout<=host_bootdata(23 downto 16); ram_step <= ram_step + 1; 
						--elsif ram_step = 2 then ioctl_dout<=host_bootdata(15 downto  8); ram_step <= ram_step + 1; 
						--elsif ram_step = 3 then ioctl_dout<=host_bootdata(7  downto  0); ram_step <= 0; host_bootdata_ack<='1'; end if;
--						ioctl_dout<=host_bootdata(7 downto 0);
--						ioctl_wr<='1';
--						host_bootdata_ack<='1';
--						boot_state<=ramwait;
--					end if;					
--				when ramwait =>
--						ioctl_addr_s<=std_logic_vector((unsigned(ioctl_addr_s)+1));
--						ioctl_wr<='0';						
--						boot_state<=idle;
--			end case;
--		end if;
--	end if;
--end process;
	
end architecture;