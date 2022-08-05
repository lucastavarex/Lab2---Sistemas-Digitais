-------------- DATA: 03/08/2022                        --------------
-------------- AUTOR: LUCAS TAVARES DA SILVA FERREIRA  --------------
-------------- DRE: 120152739                          --------------
-------------- TÍTULO: TRABALHO 1 DE LABORATÓRIO       --------------
-------------- DISCIPLINA: SISTEMAS DIGITAIS           --------------
-------------- PROFESSOR: ROBERTO PACHECO              --------------


library ieee;
use ieee.std_logic_1164.all;


entity decodificador7seg is 
port(

    CLK :   in std_logic;
    
    FLAG_STATUS : in std_logic;
    
    -- Vetor de 3 bits com a entrada para o display
    VALOR : in std_logic_vector (2 DOWNTO 0) := (others => '1');
    
    DISPLAY : out std_logic_vector (0 to 6)

);
end decodificador7seg;


ARCHITECTURE hardware of decodificador7seg is
begin


        DISPLAY <= "1111110" when FLAG_STATUS = '0' else -- mostra "-" 
        
                "0000001" when VALOR = "000" else --0
                
                "1001111" when VALOR = "001" else --1
                
                "0010010" when VALOR = "010" else --2
                
                "0000110" when VALOR = "011" else --3 
                 
                "1001100" when VALOR = "100" else ---4 
                
                "0100100" when VALOR = "101" else --5
                
                "1100000" when VALOR = "110" else ---6
                
                "0001111" when VALOR = "111" else ---7
                
                "0000000";


   
end hardware;