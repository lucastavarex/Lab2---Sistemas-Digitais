-------------- DATA: 03/08/2022                        --------------
-------------- AUTOR: LUCAS TAVARES DA SILVA FERREIRA  --------------
-------------- DRE: 120152739                          --------------
-------------- TÍTULO: TRABALHO 1 DE LABORATÓRIO       --------------
-------------- DISCIPLINA: SISTEMAS DIGITAIS           --------------
-------------- PROFESSOR: ROBERTO PACHECO              --------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity lcd is
    Port ( LCD_DB: out std_logic_vector(7 downto 0);		--DB( 7 through 0)
           RS:out std_logic;  				--WE
           RW:out std_logic;				--ADR(0)
	       CLK:in std_logic;				--GCLK2
	       --ADR1:out std_logic;			--ADR(1)
	       --ADR2:out std_logic;			--ADR(2)
	       --CS:out std_logic;				--CSC
	       OE:out std_logic;				--OE
	       rsti,
		   acerto_0,
		   acerto_1,
		   acerto_5,
		   acerto_6,
		   acerto_7,
		   flag_ganhou,
		   flag_perdeu: in std_logic := '0');	--BTN
	   --rdone: out std_logic);			--WriteDone output to work with DI05 test
end lcd;

architecture Behavioral of lcd is
			    
------------------------------------------------------------------
--  Component Declarations
------------------------------------------------------------------

------------------------------------------------------------------
--  Local Type Declarations
-----------------------------------------------------------------
--  Symbolic names for all possible states of the state machines.

	--LCD control state machine
	type mstate is (					  
		stFunctionSet,		 			--Initialization states
		stDisplayCtrlSet,
		stDisplayClear,
		stPowerOn_Delay,  				--Delay states
		stFunctionSet_Delay,
		stDisplayCtrlSet_Delay, 	
		stDisplayClear_Delay,
		stInitDne,					--Display charachters and perform standard operations
		stActWr,
		stCharDelay					--Write delay for operations
		--stWait					--Idle state
	);

	--Write control state machine
	type wstate is (
		stRW,						--set up RS and RW
		stEnable,					--set up E
		stIdle						--Write data on DB(0)-DB(7)
	);
	

------------------------------------------------------------------
--  Signal Declarations and Constants
------------------------------------------------------------------
	--These constants are used to initialize the LCD pannel.

	--FunctionSet:
		--Bit 0 and 1 are arbitrary
		--Bit 2:  Displays font type(0=5x8, 1=5x11)
		--Bit 3:  Numbers of display lines (0=1, 1=2)
		--Bit 4:  Data length (0=4 bit, 1=8 bit)
		--Bit 5-7 are set
	--DisplayCtrlSet:
		--Bit 0:  Blinking cursor control (0=off, 1=on)
		--Bit 1:  Cursor (0=off, 1=on)
		--Bit 2:  Display (0=off, 1=on)
		--Bit 3-7 are set
	--DisplayClear:
		--Bit 1-7 are set	
	signal clkCount:std_logic_vector(5 downto 0);
	signal activateW:std_logic:= '0';		    			--Activate Write sequence
	signal count:std_logic_vector (16 downto 0):= "00000000000000000";	--15 bit count variable for timing delays
	signal delayOK:std_logic:= '0';						    --High when count has reached the right delay time
	signal OneUSClk:std_logic;						        --Signal is treated as a 1 MHz clock	
	signal stCur:mstate:= stPowerOn_Delay;					--LCD control state machine
	signal stNext:mstate;			  	
	signal stCurW:wstate:= stIdle; 						    --Write control state machine
	signal stNextW:wstate;
	signal writeDone:std_logic:= '0';					    --Command set finish
	signal auxiliar7,
	auxiliar6,
	auxiliar5,
	auxiliar1,
	auxiliar0,
	auxiliar2 :  std_logic_vector(9 downto 0) :="00"&X"2D" ;

    
	type LCD_CMDS_T is array(integer range <>) of std_logic_vector(9 downto 0);
	constant LCD_CMDS : LCD_CMDS_T := ( 0 => "00"&X"3C",			--Function Set
					    1 => "00"&X"0C",		                 	--Display ON, Cursor OFF, Blink OFF
					    2 => "00"&X"01",							--Clear Display
					    3 => "00"&X"02", 							--return home

					    4 => auxiliar7, 		 
					    5 => auxiliar1,  			
					    6 => auxiliar2,  			
					    7 => auxiliar5, 		
					    8 => auxiliar6, 
					    9 => auxiliar0);
					  

													
	signal lcd_cmd_ptr : integer range 0 to LCD_CMDS'HIGH + 1 := 0;
begin
 	process(acerto_7,acerto_6,acerto_5,acerto_1,acerto_0)
   	begin
        if(flag_ganhou ='1') then 
            auxiliar7 <= "10"&X"76";
            auxiliar1 <= "10"&X"65"; 
            auxiliar2 <= "10"&X"6E";
            auxiliar1 <="10"&X"63";
            --auxiliar1 <="10"&X"63"; 2 auxiliar1jQuery36002175778873346388_1659576112346
            auxiliar0 <="10"&X"65";
        elsif(flag_perdeu = '1') then 
            auxiliar7 <= "10"&X"70";
            auxiliar1 <= "10"&X"65"; 
            auxiliar2 <= "10"&X"72";
            auxiliar1 <="10"&X"64";
            auxiliar0 <="10"&X"65";
        else
            if(acerto_7 = '1') then 
                auxiliar7 <= "00"&X"37"; --codificação do número 7 = 00"&X"37"
            end if;
             if(acerto_6 = '1') then
                auxiliar6 <= "00"&X"36"; --codificação do número 6 = 00"&X"36
            end if;
             if(acerto_5 = '1') then
                auxiliar5 <= "00"&X"35"; --codificação do número 5 = "00"&X"35"
            end if;
             if(acerto_1 = '1') then
                auxiliar1 <= "00"&X"31";
                auxiliar2 <= "00"&X"31"; -- codificação do número 1 = 00"&X"31
             end if;
             if(acerto_0 = '1') then
                auxiliar0 <= "00"&X"30"; --codificação do número = "00"&X"30"
            end if;
        end if;
    end process;
	--  This process counts to 50, and then resets.  It is used to divide the clock signal time.
	process (CLK, oneUSClk)
    		begin
			if (CLK = '1' and CLK'event) then
				clkCount <= clkCount + 1;
			end if;
		end process;
	--  This makes oneUSClock peak once every 1 microsecond

	oneUSClk <= clkCount(5);
	--  This process incriments the count variable unless delayOK = 1.
	process (oneUSClk, delayOK)
		begin
			if (oneUSClk = '1' and oneUSClk'event) then
				if delayOK = '1' then
					count <= "00000000000000000";
				else
					count <= count + 1;
				end if;
			end if;
		end process;

	--This goes high when all commands have been run
	writeDone <= '1' when (lcd_cmd_ptr = LCD_CMDS'HIGH) 
		else '0';
	--rdone <= '1' when stCur = stWait else '0';
	--Increments the pointer so the statemachine goes through the commands
	process (lcd_cmd_ptr, oneUSClk)
   		begin
			if (oneUSClk = '1' and oneUSClk'event) then
				if ((stNext = stInitDne or stNext = stDisplayCtrlSet or stNext = stDisplayClear) and writeDone = '0') then 
					lcd_cmd_ptr <= lcd_cmd_ptr + 1;
				elsif stCur = stPowerOn_Delay or stNext = stPowerOn_Delay then
					lcd_cmd_ptr <= 0;
				else
					lcd_cmd_ptr <= lcd_cmd_ptr;
				end if;
			end if;
		end process;
	
	--  Determines when count has gotten to the right number, depending on the state.

	delayOK <= '1' when ((stCur = stPowerOn_Delay and count = "00100111001010010") or 			--20050  
					(stCur = stFunctionSet_Delay and count = "00000000000110010") or	--50
					(stCur = stDisplayCtrlSet_Delay and count = "00000000000110010") or	--50
					(stCur = stDisplayClear_Delay and count = "00000011001000000") or	--1600
					(stCur = stCharDelay and count = "11111111111111111"))			--Max Delay for character writes and shifts
					--(stCur = stCharDelay and count = "00000000000100101"))		--37  This is proper delay between writes to ram.
		else	'0';
  	
	-- This process runs the LCD status state machine
	process (oneUSClk, rsti)
		begin
			if oneUSClk = '1' and oneUSClk'Event then
				if rsti = '1' then
					stCur <= stPowerOn_Delay;
				else
					stCur <= stNext;
				end if;
			end if;
		end process;

	
	--  This process generates the sequence of outputs needed to initialize and write to the LCD screen
	process (stCur, delayOK, writeDone, lcd_cmd_ptr)
		begin   
		
			case stCur is
			
				--  Delays the state machine for 20ms which is needed for proper startup.
				when stPowerOn_Delay =>
					if delayOK = '1' then
						stNext <= stFunctionSet;
					else
						stNext <= stPowerOn_Delay;
					end if;
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';

				-- This issuse the function set to the LCD as follows 
				-- 8 bit data length, 2 lines, font is 5x8.
				when stFunctionSet =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '1';	
					stNext <= stFunctionSet_Delay;
				
				--Gives the proper delay of 37us between the function set and
				--the display control set.
				when stFunctionSet_Delay =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';
					if delayOK = '1' then
						stNext <= stDisplayCtrlSet;
					else
						stNext <= stFunctionSet_Delay;
					end if;
				
				--Issuse the display control set as follows
				--Display ON,  Cursor OFF, Blinking Cursor OFF.
				when stDisplayCtrlSet =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '1';
					stNext <= stDisplayCtrlSet_Delay;

				--Gives the proper delay of 37us between the display control set
				--and the Display Clear command. 
				when stDisplayCtrlSet_Delay =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';
					if delayOK = '1' then
						stNext <= stDisplayClear;
					else
						stNext <= stDisplayCtrlSet_Delay;
					end if;
				
				--Issues the display clear command.
				when stDisplayClear	=>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '1';
					stNext <= stDisplayClear_Delay;

				--Gives the proper delay of 1.52ms between the clear command
				--and the state where you are clear to do normal operations.
				when stDisplayClear_Delay =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';
					if delayOK = '1' then
						stNext <= stInitDne;
					else
						stNext <= stDisplayClear_Delay;
					end if;
				
				--State for normal operations for displaying characters, changing the
				--Cursor position etc.
				when stInitDne =>		
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';
					stNext <= stActWr;

				when stActWr =>		
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '1';
					stNext <= stCharDelay;
					
				--Provides a max delay between instructions.
				when stCharDelay =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';					
					if delayOK = '1' then
						stNext <= stInitDne;
					else
						stNext <= stCharDelay;
					end if;
			end case;
		
		end process;					
								   
 	--This process runs the write state machine
	process (oneUSClk, rsti)
		begin
			if oneUSClk = '1' and oneUSClk'Event then
				if rsti = '1' then
					stCurW <= stIdle;
				else
					stCurW <= stNextW;
				end if;
			end if;
		end process;

	--This genearates the sequence of outputs needed to write to the LCD screen
	process (stCurW, activateW)
		begin   
		
			case stCurW is
				--This sends the address across the bus telling the DIO5 that we are
				--writing to the LCD, in this configuration the adr_lcd(2) controls the
				--enable pin on the LCD
				when stRw =>
					OE <= '0';
					--CS <= '0';
					--ADR2 <= '1';
					--ADR1 <= '0';
					stNextW <= stEnable;
				
				--This adds another clock onto the wait to make sure data is stable on 
				--the bus before enable goes low.  The lcd has an active falling edge 
				--and will write on the fall of enable
				when stEnable => 
					OE <= '0';
					--CS <= '0';
					--ADR2 <= '0';
					--ADR1 <= '0';
					stNextW <= stIdle;
				
				--Waiting for the write command from the instuction state machine
				when stIdle =>
					--ADR2 <= '0';
					--ADR1 <= '0';
					--CS <= '1';
					OE <= '1';
					if activateW = '1' then
						stNextW <= stRw;
					else
						stNextW <= stIdle;
					end if;
				end case;
		end process;
				
end Behavioral;