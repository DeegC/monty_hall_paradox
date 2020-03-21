#!/usr/bin/env ruby

# This program simulates the "Monty Hall" brain teaser with a difference:  Monty will
# randomly open a door and sometimes it is the winner.  Run with
#
#    ruby monty_hall_opens_door.rb [ COUNT ]
#
# This program purposefully avoids some Rubyisms to make it easier for non-Rubyists
# to understand.

# Run a single simulation of the Monty Hall problem.
# Returns:
#     'switch' if the contestant should switch doors to win.
#     'stay'   if the contestant should NOT switch doors.
#     'lose'   if Monty opens the winning door.
def play
  # Randomly choose a winning door.
  winning_door = rand(3)

  # Contestant randomly chooses a door.
  contestant_choice = rand(3)
  puts "Contestant chooses door #{contestant_choice}"

  # Randomly choose doors for Monty to open until we find one that is:
  #   - Not the door the contestant chose.
  monty_opens = nil
  while ( monty_opens == nil )
    temp_door = rand(3)
    if temp_door == contestant_choice
      next # Can't be the contestant's door
    end

    monty_opens = temp_door
  end

  puts "Monty opens door #{monty_opens}"
  puts "Winning door is #{winning_door}"

  # If Monty opened the winning door the contestant loses.
  if monty_opens == winning_door
    return 'lose'
  end

  # Determine if the contestant should switch or stay.
  if contestant_choice == winning_door
    return 'stay'
  else
    return 'switch'
  end
end

if ARGV[ 0 ] == nil
  num_plays = 1  # If user didn't specify a count we'll assume 1
else
  num_plays = ARGV[ 0 ].to_i
end

# Initialize the final totals as a hash map.
totals = {
  'lose' => 0,
  'stay' => 0,
  'switch' => 0
}

# Simulate the game
(1..num_plays).each do
  contestant_should = play
  puts "Contestant should #{contestant_should}"
  totals[contestant_should] += 1
end

puts "#{totals}"
