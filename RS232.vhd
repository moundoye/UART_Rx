library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RS232 is
port(clock, reset, Rx : in std_logic;
	 internal_clock_generate : out std_logic;
	 word : out std_logic_vector (7 downto 0);
	 clk_input_Rx : out std_logic;
	 data_receive : out std_logic);
end RS232;

architecture dataflow of RS232 is

component div_horloge_gen is
generic (debit : integer := 20);
port(clk, reset, start : in std_logic;
	 horloge_gen : buffer std_logic);
end component;


component UART_Rx is
generic (debit : integer := 2602);
port(clk, reset : in std_logic;
	  Rx : in std_logic;
	  word : out std_logic_vector (7 downto 0);
	  out_clk_sampling : out std_logic;
	  data_receive : out std_logic);
end component;


begin

clock_SigTap : div_horloge_gen generic map (25000000) port map (clock, reset, '1', clk_input_Rx);

UART_Reception : UART_Rx generic map (230400) port map(clock, reset, Rx, word, internal_clock_generate, data_receive);


end dataflow;