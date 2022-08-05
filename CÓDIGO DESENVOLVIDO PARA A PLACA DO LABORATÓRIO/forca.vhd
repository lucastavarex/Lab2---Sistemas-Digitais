-------------- DATA: 03/08/2022                        --------------
-------------- AUTOR: LUCAS TAVARES DA SILVA FERREIRA  --------------
-------------- DRE: 120152739                          --------------
-------------- TÍTULO: TRABALHO 1 DE LABORATÓRIO       --------------
-------------- DISCIPLINA: SISTEMAS DIGITAIS           --------------
-------------- PROFESSOR: ROBERTO PACHECO              --------------

library ieee;
use ieee.std_logic_1164.all;

entity forca is

port(
	SW: in std_logic_vector(3 downto 0);
	LEDG: out std_logic_vector(13 downto 0):="00000000000000";
	CLOCK_50: in std_logic
			
);

end forca;

--
architecture behavioral of forca is

type state_type is 
(

tresVidas, duasVidas, umaVida, ganha, perde

);

signal  game_state, prox_state: state_type;
signal  clk,enable: std_logic;
signal  rst,acertou_0,acertou_1,acertou_2,acertou_3,acertou_4,acertou_5,acertou_6,acertou_7,a,b: std_logic := '0';
signal value: std_logic_vector(2 downto 0);

Component lcd IS
     Port ( LCD_DB: out std_logic_vector(7 downto 0);	
           RS:out std_logic;  				--WE
           RW:out std_logic;				--ADR(0)
	       CLK:in std_logic;				--GCLK2
	       OE:out std_logic;				--OE
	       rsti,
		   acerto_0,
		   acerto_1,
		   acerto_5,
		   acerto_6,
		   acerto_7,
		   flag_ganhou,
		   flag_perdeu: in std_logic := '0');--BTN

End component; 
begin
	enable <= SW(3);
	clk <= CLOCK_50;
	process(clk,enable, rst,acertou_7,acertou_6,acertou_5,acertou_1,acertou_0)
	begin
		if (rst = '1') then
			acertou_0 <= '0';
			acertou_1 <= '0';
			acertou_2 <= '0';
			acertou_3 <= '0';
			acertou_4 <= '0';
			acertou_5 <= '0';
			acertou_6 <= '0';
			acertou_7 <= '0';
			a <= '0';
			b <= '0';
	    	game_state <= tresVidas;
		elsif(acertou_7 = '1' and acertou_6 = '1' and acertou_5= '1' and acertou_1= '1'  and acertou_0 = '1') then
			 game_state <= ganha;
		elsif(clk'EVENT and clk = '1') then
          if(enable = '1' and rst ='0') then 
            value <= SW(2 downto 0);
          
    	    case value is
    			when "000" =>
    			    acertou_0 <= '1';
    			when "001" =>
    			    acertou_1 <= '1';
    			when "010" =>
    			    if (acertou_2 = '0') then
    			        game_state <= prox_state;
    			    end if;
    			    acertou_2 <= '1';
    		      
    			when "011" => 
    			    if (acertou_3 = '0') then
    			        game_state <= prox_state;
    			    end if;
    			    acertou_3 <= '1';
    		
    			when "100" =>
    			    if (acertou_4 = '0') then
    			        game_state <= prox_state;
    			    end if;
    			    acertou_4 <= '1';

    		    when "101" =>
    			    acertou_5 <= '1';
    			when "110" =>
    			   acertou_6 <= '1';
    			when others =>
    			    acertou_7 <= '1';
    		    end case; 
    	end if;	 
		end if;
	end process;
	
	process(game_state)
	begin
        case game_state is
    			when tresVidas =>
    			        rst <= '0';
    			        LEDG(2 downto 0) <= "111";
    		            prox_state <= duasVidas;
    			when duasVidas =>
    			       	  LEDG(2 downto 0) <= "011";
    			        prox_state <= umaVida;
    			when umaVida =>
    			       	  LEDG(2 downto 0) <= "001";
    			        prox_state <= perde;
    			when ganha => 
    			    a<='1';
            		 if(enable = '0') then 
            				    rst <= '1';
    				end if;
    			when perde =>
    		    	  LEDG(2 downto 0) <= "000";
    		    	  b<='1';
    		        if(enable = '0') then 
    				    rst <= '1';
    				end if;
    		end case;
	end process;
lcdPlaca: lcd port map(LEDG(10 downto 3),LEDG(11),LEDG(12),clk,LEDG(13),rst,acertou_0,acertou_1,acertou_5,acertou_6,acertou_7,'0','1');

end behavioral;