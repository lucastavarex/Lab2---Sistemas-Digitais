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
    
    CLOCK_50    : in std_logic; ---clock da placa
    
    V_SW        : in std_logic_vector (3 downto 0); ----- switches da placa
    
    G_LED       : out std_logic_vector (0 to 9); ------ leds verdes
    
    G_HEX0, G_HEX1, G_HEX2, G_HEX3, G_HEX4, G_HEX5, G_HEX6:   out std_logic_vector (0 to 6) ----- display 7 segmentos
    
    
    
);
end forca;


architecture hardware of forca is


    
    --signal Game_State : std_logic := '0';
    
    signal user_guess : std_logic_vector (2 downto 0) := "010"; ---- Chute da pessoa 

    ------- NUMEROS SECRETOS SÃO DEFINIDOS:------------
    signal numero_secreto0 : std_logic_vector (2 downto 0) := "000"; ---- número secreto 0  = 0 
	 
    signal numero_secreto1 : std_logic_vector (2 downto 0) := "101"; ---- número secreto 1 = 5
    
    signal numero_secreto2 : std_logic_vector (2 downto 0) := "110"; ---- número seceto 2 = 6
    
    signal numero_secreto3 : std_logic_vector (2 downto 0) := "011"; ---- numero secreto 3 = 3   => DEFINI ESTE DÍGITO IGUAL A 3 AO INVÉS DE 1

    signal numero_secreto4 : std_logic_vector (2 downto 0) := "001";---- numero secreto 4  = 1
    
    signal numero_secreto5 : std_logic_vector (2 downto 0) := "111" ; ---- numero secreto5 = 7


   
     ------- QUANTIDADE DE VIDAS DEFINIDO ------
     
   
    signal vida : std_logic_vector (0 to 2) := (others => '1');  
    
    
    ----- O QUE SERA MOSTRADO NO DISPLAY----
    
  
    signal revelado_numero0, revelado_numero1, revelado_numero2, revelado_numero3, revelado_numero4,revelado_numero5:
    std_logic_vector (2 downto 0) := (others => '1'); ---- numeros que foram revelados
    --111
        
    signal perdeu_ganhou: std_logic_vector (2 downto 0) := (others => '1'); -- P e G
    
    

     ------ STATUS QUE ESTAMOS , QUANTOS ACERTOS JÁ FORAM---------------
     

    signal status   :   std_logic_vector (5 downto 0) := (others => '0'); ----- lugar que estamos , quantos acertos já foram 
    
    
    signal ultima_entrada   :   std_logic_vector (2 downto 0) := "001"; 
    
    
    begin
      
      -- reset<= not (KEY(0));
       
        process (CLOCK_50) begin
         --process (CLOCK_50,reset) begin
                
            
          
            if (CLOCK_50'event and CLOCK_50 = '1') then
           
                
               
                if (status = "111111") then  ----- se estivermos no status final, logo ganhamos o jogo 
                
                    revelado_numero0 <= numero_secreto0 ; ---- para o  display receber -
                    
                    revelado_numero1 <= numero_secreto1;---- para o  display receber -
                    
                    revelado_numero2 <= numero_secreto2;---- para o  display receber -
                    
                    revelado_numero3 <= numero_secreto3;----  para o  display receber -

                    revelado_numero4 <= numero_secreto4;----  para o  display receber -

                    revelado_numero5 <= numero_secreto5; ----  para o  display receber -

                   -- Game_State <= '1';
                    perdeu_ganhou <= "100"; ---- para o primeiro display receber G 
                    
                    
                  
    
                
                else --- caso ainda estejamos jogando 
                
                ----- CHECANDO SE ESTÁ COMPATIVEL O CHUTE COM O NUMERO SECRETO----
                    case user_guess is
       
                        when numero_secreto0 => 
                            revelado_numero0 <= numero_secreto0; 
                            
                            status(0) <= '1';
                            
                        
                        when numero_secreto1 =>
                            revelado_numero1 <= numero_secreto1; 
                            status(1) <= '1';

          
                        when numero_secreto2 =>
                            revelado_numero2 <= numero_secreto2; 
                            
                            status(2) <= '1';
          
          
                        when numero_secreto3 =>
                            revelado_numero3 <= numero_secreto3; 
                            
                            status(3) <= '1';
                      
                        when numero_secreto4 =>
                            revelado_numero4 <= numero_secreto4; 
 
                            
                            status(4) <= '1';
                      
                        when numero_secreto5 =>
                            revelado_numero5 <= numero_secreto5; 
                            
                            status(5) <= '1';
          
          
                 

          
                        when others => --caso de erro

                            if (ultima_entrada /= user_guess) then
                                ultima_entrada <= user_guess;
                                
                                case vida is --- vida vai perder uma 
                               
                                    when "111" =>
                                        vida <= "011";
                                        
                                        
                                    when "011" =>
                                        vida <= "001";
                                    
                                 
                                    when others =>
                                        vida <= "000";
                                        
                                        
                                        
                                        revelado_numero0 <= "111"; --- para ficar P no display de 7 segmentos 
                                        
                                        revelado_numero1 <= "111";
                                        
                                        revelado_numero2 <= "111";
                                        
                                        revelado_numero3 <= "111";
                                      
                                        revelado_numero4 <= "111";
                                        
                                        revelado_numero5 <= "111";
                                        
                                       -- Game_State <= '1';
                                        perdeu_ganhou <= "110";
                                        
                                        
                                        
                                    end case;
                                    
                                end if;
                            
                        end case;
          
                    end if;
                        
                end if;
                        
                        
            end process;
            

        G_LED(0 to 2) <= vida; ---- para mostrar no led 
        
        
        
        
        decode_usuario_entrada  : entity work.interface(hardware) port map(
                                                                        
                                                                        CLK => CLOCK_50,
                                                                        
                                                                        TENTATIVA => V_SW(3),
                                                                        
                                                                        BOTAO => V_SW(2 downto 0),
                                                                        
                                                                        PARSED_OUT => user_guess
                                                                            );
        
        DISPLAY0    :   entity work.decodificador7seg_PG(hardware) port map(
                                                                                    
                                                                        CLK => CLOCK_50,
                                                                        
                                                                        
                                                                        VALOR => perdeu_ganhou,
                                                                                    
                                                                        DISPLAY => G_HEX0
        
                                                                        );
        

        DISPLAY1    :   entity work.decodificador7seg(hardware) port map(
        
                                                                        CLK => CLOCK_50,
                                                                        
                                                                        FLAG_STATUS => status(0),
                                                                        
                                                                        VALOR => revelado_numero0,
                                                                        
                                                                        DISPLAY => G_HEX1
        
                                                                        );


        DISPLAY2    :   entity  work.decodificador7seg(hardware) port map(
                                                                        
                                                                        CLK => CLOCK_50,
                                                                        
                                                                        FLAG_STATUS => status(1),
                                                                        
                                                                        VALOR => revelado_numero1,
                                                                        
                                                                        DISPLAY => G_HEX2
                                                                        
                                                                        );


        DISPLAY3    :   entity  work.decodificador7seg(hardware) port map(
                                                                        
                                                                        CLK => CLOCK_50,
                                                                        
                                                                        FLAG_STATUS => status(2),
                                                                        
                                                                        VALOR => revelado_numero2,
                                                                        
                                                                        DISPLAY => G_HEX3
                                                                        
                                                                        );
    
        DISPLAY4   :   entity  work.decodificador7seg(hardware) port map(
                                                                        
                                                                        CLK => CLOCK_50,
                                                                        
                                                                        FLAG_STATUS => status(3),
                                                                        
                                                                        VALOR => revelado_numero3,
                                                                        
                                                                        DISPLAY => G_HEX4
                                                                        
                                                                        );
                                                                        
        DISPLAY5   :   entity  work.decodificador7seg(hardware) port map(
                                                                        
                                                                        CLK => CLOCK_50,
                                                                        
                                                                        FLAG_STATUS => status(4),
                                                                        
                                                                        VALOR => revelado_numero4,
                                                                        
                                                                        DISPLAY => G_HEX5
                                                                        
                                                                        );
                                                                        
        DISPLAY6  :   entity  work.decodificador7seg(hardware) port map(
                                                                        
                                                                        CLK => CLOCK_50,
                                                                        
                                                                        FLAG_STATUS => status(5),
                                                                        
                                                                        VALOR => revelado_numero5,
                                                                        
                                                                        DISPLAY => G_HEX6
                                                                        
                                                                        );


        
    end hardware;