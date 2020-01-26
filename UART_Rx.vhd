library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_Rx is
generic (debit : integer := 2602);
port(clk, reset : in std_logic;
	  Rx : in std_logic;
	  word : out std_logic_vector (7 downto 0);
	  out_clk_sampling : out std_logic;
	  data_receive : out std_logic);
end UART_Rx;

architecture dataflow of UART_Rx is

component div_horloge_gen is
generic (debit : integer := 0);
port(clk, reset, start : in std_logic;
	 horloge_gen : buffer std_logic);
end component;

type state_type is (pending, start_com, wait_for_repack_1, wait_for_repack_2, repack_bit, data_shifted, full_reception_ACK_1, full_reception_ACK_2);

signal state : state_type; 
signal UART_rx_R : std_logic;
signal UART_rx_RR : std_logic;
signal start :std_logic;
signal clk_sampling : std_logic;
begin

process(clk, reset) is
variable nb_of_shift : integer range 0 to 9;
variable var_word : std_logic_vector (7 downto 0);
begin
	if(reset = '0') then 
		state <= pending;
		word <= (others => '1');
		var_word := (others => '1');
		data_receive <= '0';
		UART_rx_R <= '1';
		UART_rx_RR <= '1';
		nb_of_shift := 0;
		start <= '0';
		elsif (clk'event and clk = '1') then
	
		-------------Avoide unstable value------------
		UART_rx_R <= Rx;
		UART_rx_RR <= UART_rx_R;
		----------------------------------------------
		case state is
			when  pending =>		
								nb_of_shift := 0;	var_word := var_word;	data_receive <= '1'; start <= '0';	
								if (UART_rx_RR = '0')	then
									state <= start_com;
								end if;
			when	start_com =>	
								var_word := (others => '0');	nb_of_shift := 0;	data_receive <= '1';  start <= '1';
								if (clk_sampling = '1') then
									state <= wait_for_repack_1;
								end if;
			when 	wait_for_repack_1 =>	
								var_word := var_word;	nb_of_shift := nb_of_shift;	data_receive <= '1'; start <= '1';
								if (clk_sampling = '0') then
									state <= wait_for_repack_2;
								end if;
			when 	wait_for_repack_2 =>	
								var_word := var_word;	nb_of_shift := nb_of_shift;	data_receive <= '1'; start <= '1';
								if (clk_sampling = '1') then
									state <= repack_bit;
								end if;
			when  repack_bit =>
								var_word := UART_rx_RR & var_word(7 downto 1);	nb_of_shift := nb_of_shift + 1;	data_receive <= '1'; start <= '1';
								state <= data_shifted;	
			when  data_shifted =>
								var_word := var_word;	nb_of_shift := nb_of_shift;	data_receive <= '1'; start <= '1';
								if (clk_sampling = '0' and nb_of_shift = 8) then
									state <= full_reception_ACK_1;
								elsif (clk_sampling = '0' and nb_of_shift < 8) then
									state <= wait_for_repack_2;
								end if;
			when full_reception_ACK_1 =>
								var_word := var_word;	nb_of_shift := nb_of_shift;	data_receive <= '0'; start <= '1';
								if (clk_sampling = '1') then
									state <= full_reception_ACK_2;
								end if;
			when full_reception_ACK_2 =>
								var_word := var_word;	nb_of_shift := nb_of_shift;	data_receive <= '0'; start <= '1';
								if (clk_sampling = '0') then
									state <= pending;
								end if;
								
		end case;
		
		------Generate Outputs----------
		word <= var_word;
	end if;
end process;
clock_Tx : div_horloge_gen generic map (debit) port map (clk, reset, start, clk_sampling);
out_clk_sampling <= clk_sampling;
end dataflow;
