library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity digital_watch is
  port (
    -- Inputs
    clk     : in std_logic; -- 1 MHz
    button1 : in std_logic;
    button2 : in std_logic;
    -- Outputs
    hours   : out std_logic_vector(4 downto 0);
    minutes : out std_logic_vector(5 downto 0);
    seconds : out std_logic_vector(5 downto 0);
    bip     : out std_logic
  );
end entity;

architecture rtl of digital_watch is
  -- FSM signals
  type states is (ALARM_OFF, SETTING_HOURS, SETTING_MINUTES, ALARM_ON);
  signal state_r      : states := ALARM_OFF;
  signal next_state_r : states;
  signal rising_b1  : std_logic;
  signal rising_b2  : std_logic;
  -- Time count signals
  signal hours_counter   : integer := 0;
  signal minutes_counter : integer := 0;
  signal seconds_counter : integer := 0;
  signal clocks_counter  : integer := 0;
  constant clocks_to_sec : integer := 1000000;
  -- Button signal detection
  signal button1_reg : std_logic;
  signal button2_reg : std_logic;
  -- Bip signals
  signal enable_bip : boolean := false;
  signal bip_time   : integer := 0;
  signal bip_counter: integer := 0;
  -- Alarm signals
  signal alarm_hour : integer := 0;
  signal alarm_min  : integer := 0;

begin
  -- Assigning time counter to its outputs
  hours   <= std_logic_vector(to_unsigned(hours_counter));
  minutes <= std_logic_vector(to_unsigned(minutes_counter));
  seconds <= std_logic_vector(to_unsigned(seconds_counter));

  -- Detecting rising edge of buttons
  rising_b1 <= button1 and not button1_reg;
  rising_b2 <= button2 and not button2_reg;

  CURRENT_STATE: process (clk)
  begin
    if rising_edge(clk) then
      -- Change state_r
      state_r <= next_state_r;

      -- Storing buttons states
      button1_reg <= button1;
      button2_reg <= button2;
    end if;
  end process CURRENT_STATE;

  NEXT_STATE: process (state_r, button1)
  begin
    next_state_r <= state_r;
    case( state_r ) is

      when ALARM_OFF =>
        if (rising_b1 = '1') then
          next_state_r <= SETTING_HOURS;
        end if;

      when SETTING_HOURS =>
        if (rising_b1 = '1') then
          next_state_r <= SETTING_MINUTES;
        end if;

      when SETTING_MINUTES =>
        if (rising_b1 = '1') then
          next_state_r <= ALARM_ON;
        end if;

      when ALARM_ON =>
        if (enable_bip = false) then
          if (rising_b1 = '1') then
            next_state_r <= ALARM_OFF;
          end if;
        end if;

    end case ;
  end process NEXT_STATE;

  STATE_LOGIC : process (state_r, button1, button2)
  begin
    -- Default of bip disabled
    enable_bip <= false;
    case( state_r ) is

      when ALARM_OFF =>
      -- Set counters to 12:00:00 if both buttons pressed
        if (rising_b1 and rising_b2 = '1') then
          hours_counter <= 12;
          minutes_counter <= 0;
          seconds_counter <= 0;
        end if;

      when SETTING_HOURS =>
      -- Set alarm hour, unable to set counters time in this mode
        if (rising_b2 = '1') then
          if (alarm_hour = 23) then
            alarm_hour <= 0;
          else
            alarm_hour <= alarm_hour + 1;
          end if;
        end if;

      when SETTING_MINUTES =>
      -- Set alarm minute, unable to set counters time in this mode
        if (rising_b2 = '1') then
          if (alarm_min = 59) then
            alarm_min <= 0;
          else
            alarm_min <= alarm_min + 1;
          end if;
        end if;

      when ALARM_ON =>
      -- If the watch is biping, pressing the buttons will only disable the bip
        if (enable_bip) then
          if (rising_b1 or rising_b2 = '1') then
            enable_bip <= false;
          end if;
      -- If the watch isn't biping, set counters to 12:00:00 if both buttons pressed
      -- and start biping if the time is equal to the alarm 
        else
          if (rising_b1 and rising_b2 = '1') then
            hours_counter <= 12;
            minutes_counter <= 0;
            seconds_counter <= 0;
          end if;
          if (alarm_hour = hours_counter) then
            if (alarm_min = minutes_counter) then
              enable_bip <= true;
            end if;
          end if;
        end if;

    end case ;
  end process STATE_LOGIC;

  COUNTERS: process (clk)
  begin
    if rising_edge(clk) then
      -- Counting seconds
      if (clocks_counter = clocks_to_sec) then
        clocks_counter <= 0;
        seconds_counter <= seconds_counter + 1;
        if (enable_bip) then
          bip_time <= bip_time + 1;
        end if;
      else
        clocks_counter <= clocks_counter + 1;
      end if;
      -- Bip logic
      if (enable_bip) then
        case( bip_counter ) is
          -- Bip 5s
          when 0 =>
            if (bip_time = 5) then
              bip_time <= 0;
              bip_counter <= 1;
              bip <= '1';
            end if;
          -- Not bip 1s
          when 1 =>
            if (bip_time = 1) then
              bip_time <= 0;
              bip_counter <= 2;
              bip <= '1';
            end if;
          -- Bip 2s
          when 2 =>
            if (bip_time = 2) then
              bip_time <= 0;
              bip_counter <= 3;
              bip <= '1';
            end if;
          -- Not bip 1s
          when 3 =>
            if (bip_time = 1) then
              bip_time <= 0;
              bip_counter <= 4;
              bip <= '1';
            end if;
          -- Bip 2s
          when 4 =>
            if (bip_time = 2) then
              bip_time <= 0;
              bip_counter <= 0;
              bip <= '1';
            end if;

        end case ;
      else
        bip_time    <= 0;
        bip_counter <= 0;
      end if;

      -- Counting minutes
      if (seconds_counter = 59) then
        seconds_counter <= 0;
        minutes_counter <= minutes_counter + 1;        
      end if;

      -- Counting hours
      if (minutes_counter = 59) then
        minutes_counter <= 0;
        if (hours_counter = 23) then
          hours_counter <= 0;
        else
          hours_counter <= hours_counter + 1;
        end if;
      end if;
    end if;
  end process COUNTERS;

end architecture;