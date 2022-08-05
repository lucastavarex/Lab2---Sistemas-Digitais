-------------- DATA: 03/08/2022                        --------------
-------------- AUTOR: LUCAS TAVARES DA SILVA FERREIRA  --------------
-------------- DRE: 120152739                          --------------
-------------- TÍTULO: TRABALHO 1 DE LABORATÓRIO       --------------
-------------- DISCIPLINA: SISTEMAS DIGITAIS           --------------
-------------- PROFESSOR: ROBERTO PACHECO              --------------

library ieee;
use ieee.std_logic_1164.all;


entity decodificador7seg_PG is 
port(

    CLK :   in std_logic;
    

    -- Vetor de 3 bits com a entrada para o display
    VALOR : in std_logic_vector (2 DOWNTO 0) := (others => '1');
    
    DISPLAY : out std_logic_vector (0 to 6)

);
end decodificador7seg_PG;


ARCHITECTURE hardware of decodificador7seg_PG is
begin
    DISPLAY <=  
                "0100001" when VALOR = "100" else ---- G
                
                "0011000" when VALOR = "110" else ---- P
                
                "1111110";
end hardware;