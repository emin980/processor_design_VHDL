
-- ?slemci tasar?m?

library ieee;
use ieee.std_logic_1164.all;
use IEEE.Numeric_Std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

entity eIslemci is
generic(n:natural:=8);
port( s, r : in std_logic;  --Reset
         kmt: in std_logic_vector(2*n-1 downto 0) -- 16 bit giris? secme
);
end entity;

Architecture struct of eIslemci is


TYPE tMEM IS ARRAY(0 TO 63) OF std_logic_vector(n-1 DOWNTO 0);
SIGNAL Ram : tMEM;  -- RAM

TYPE tREG IS ARRAY(0 TO 15) OF std_logic_vector(n-1 DOWNTO 0);
SIGNAL Reg : tREG;

Begin -- mimari

Komut:
process(s, r)
Begin
     If( Rising_edge(s) ) then 
     Case Kmt(15 downto 12) is -- en anlamli 4 bit
	When "0000" =>
	    null;   -- is?lem yok... 

	-- loadx     0001  4bitREGadresi   8bit sabit sayi
	When "0001" =>
		Reg(to_integer(unsigned(Kmt(11 downto 8)))) <= Kmt(7 downto 0);  --sabit sayiyi register'e atiyor

	-- loadr     0010  4bitREGadresi   4bitREGadresiKaynak         Loadr  ax, bx    -- ax<=bx
	When "0010" =>  
		Reg(  to_integer(unsigned(Kmt(11 downto 8))))  <= Reg(  to_integer(unsigned(Kmt(7 downto 4)) ))  ; --registerden register'e atiyor

	When "0011" =>  -- loadm     0001  REGadresi   8bitRamAdresi 
		Reg(  to_integer(unsigned(Kmt(11 downto 8))))  <= Ram(  to_integer(unsigned(Kmt(7 downto 0)) ))  ;--Ram'den register'e at?yor

	
	When "0101" =>  -- loadmr     0101  REGadresi   RegAdresi 
		Reg(  to_integer(unsigned(Kmt(11 downto 8))))  <= 
			Ram( to_integer(unsigned( Reg( to_integer(unsigned(Kmt(7 downto 4)))  ))))  ;--register'in icerigini ram'e yukledi oradan register'e aktardi

	-- Storer    0011  REGadresi   8bitRamAdresi
	
 	When "0110" =>  
           Ram( to_integer(unsigned(Kmt(7 downto 0))) ) <= 
			Reg( to_integer(unsigned(Kmt(11 downto 8))));-- Registerda olan bilgi BEllege yazilir
	
	-- ADDx    0111  4bitRegAdresi     8bit sabit Sayi 	
	
 	When "0111" =>  
           Reg(  to_integer(unsigned(Kmt(11 downto 8))) )   <= 
				std_logic_vector( 
					unsigned(Reg( to_integer(unsigned(Kmt(11 downto 8)))))
					 + unsigned(Kmt (7 downto 0)));-- add  ax,  x     x sabit sayi ile ax toplanir sonuc ax'e yazilir
	
	-- ADDr:    1000  4bitRegAdresi     4bitRegAdresi   	
	-- addr     ax,  bx , cx      cx  bx toplanir sonuc ax'e yaz?l?r
 	When "1000" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			+ unsigned(Reg( to_integer(unsigned(Kmt(8 downto 3)))))  );
	--Buradan itibaren yazdim.
		

	--8 bitlik Ram adresi<=Reg
	When "1001"=> --Ram'in icerigini Register'a aktarip oradan baska bir ram'in icerigine aktariyor
	   Ram( to_integer(unsigned(Kmt(7 downto 0))) ) <= Ram( to_integer(unsigned(Reg( to_integer(unsigned(Kmt(11 downto 8)))))));
 	
	When "1010"=>--iki registerin icerigi toplanip baska bir ram icerigine yazildi
		Ram(  to_integer(unsigned(Kmt(11 downto 8))))  <= std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))+ unsigned(Reg( to_integer(unsigned(Kmt(8 downto 3)))))  );

	When "0100"=>--sayi1+sayi2 yap ve reg'a aktar
		Reg(  to_integer(unsigned(Kmt(11 downto 8))) )   <=std_logic_vector(unsigned(Kmt (7 downto 4)) + unsigned(Kmt (3 downto 0)));

	When "1011"=>--sola kaydir
		Reg(  to_integer(unsigned(Kmt(7 downto 0))))   <= std_logic_vector(Reg( to_integer(unsigned(Kmt(6 downto 0))))&'0' );
	When "1100"=>--saga kaydir
		Reg(  to_integer(unsigned(Kmt(7 downto 0))))   <= std_logic_vector('0'& Reg( to_integer(unsigned(Kmt(7 downto 1)))) );
	When "1101"=>--xor kapisi| 2 sayiyi xorla register'a at
		Reg(  to_integer(unsigned(Kmt(11 downto 8))) )   <=std_logic_vector(unsigned(Kmt (7 downto 4)) xor unsigned(Kmt (3 downto 0)));
	When "1110"=>--nand kapisi| 2 sayiyi nandle register'a at
		Reg(  to_integer(unsigned(Kmt(11 downto 8))) )   <=std_logic_vector(unsigned(Kmt (7 downto 4)) nand unsigned(Kmt (3 downto 0)));
	When "1111"=>--not islemi| Register'in icerigini notla ayni register'a yaz.
		Reg(  to_integer(unsigned(Kmt(7 downto 0))))   <= not(Reg(  to_integer(unsigned(Kmt(7 downto 0)))));

 	When others => 
	    null;
      end case; 
   end if;
end Process;

end struct;

