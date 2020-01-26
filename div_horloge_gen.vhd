library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity div_horloge_gen is
generic (debit : integer := 20);
port(clk, reset, start : in std_logic;
	 horloge_gen : out std_logic);
end div_horloge_gen;

architecture dataflow of div_horloge_gen is
constant half_periode : integer := integer(ceil((real(50000000)/real(debit))/real(2)));
signal cpt : integer range 0 to 50000;
signal sig_horloge : std_logic;
begin
	
process(clk, reset)
variable var_horloge_gen : std_logic;
begin
	if(reset = '0')	then
		horloge_gen <= '0';
		cpt <= 0;
		sig_horloge <= '0';
	elsif(clk'event and clk = '1') then
		if (start = '1') then
			cpt <= cpt + 1;
		else
			cpt <= cpt;
		end if;
		
		if(cpt = half_periode) then
			sig_horloge <= not(sig_horloge);
			cpt <= 0;
		end if;
		horloge_gen <= sig_horloge;
	end if;
end process;

end dataflow;