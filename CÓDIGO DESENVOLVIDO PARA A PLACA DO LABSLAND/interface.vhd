-------------- DATA: 03/08/2022                        --------------
-------------- AUTOR: LUCAS TAVARES DA SILVA FERREIRA  --------------
-------------- DRE: 120152739                          --------------
-------------- TÍTULO: TRABALHO 1 DE LABORATÓRIO       --------------
-------------- DISCIPLINA: SISTEMAS DIGITAIS           --------------
-------------- PROFESSOR: ROBERTO PACHECO              --------------


library ieee;
use ieee.std_logic_1164.all;


entity interface is
port(
    
    CLK :   in std_logic;
    
    TENTATIVA : in std_logic;
    
    BOTAO   :   in std_logic_vector (2 downto 0);
    
    PARSED_OUT  :   out std_logic_vector (2 downto 0)

);
end interface;


architecture hardware of interface is
begin

    process (CLK) begin
        if (TENTATIVA = '1') then
        
            PARSED_OUT <= BOTAO;
        end if;
    end process;
    
end hardware;