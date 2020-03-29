
# Understanding the Monty Hall Problem through code.

The Monty Hall problem is an interesting probability puzzler, made famous by Marilyn vos Savant in 1990. It is a problem that has puzzled many great mathematicians like Paul Erdős but it is easier to understand if you write out the code to simulate it.

[Wikipedia has a lot more detail](https://en.wikipedia.org/wiki/Monty_Hall_problem) but here's the problem as specified by vos Savant:

> Suppose you're on a game show, and you're given the choice of three doors: Behind one door is a car; behind the others, goats. You pick a door, say No. 1, and the host, who knows what's behind the doors, opens another door, say No. 3, which has a goat. He then says to you, "Do you want to pick door No. 2?" Is it to your advantage to switch your choice?

The answer, which is at first counter-intuitive, is that you should always switch.  You are twice as likely to win if you switch, but how can that be?  Let's look at the code...

## The Code

Below is the algorithm written as a method in Ruby. The full program can be found in this repository as [monty_hall.rb](monty_hall.rb).  Note: the code purposefully avoids some Rubyisms to make it easier for non-Rubyists to understand.

```ruby
# Run a single simulation of the Monty Hall problem.
# Returns:
#     'switch' if the contestant should switch doors to win.
#     'stay'   if the contestant should NOT switch doors.
def play
  doors = [ false, false, false ]

  # Randomly choose a winning door.
  winning_door = rand(3)
  doors[ winning_door ] = true

  # Contestant randomly chooses a door.
  contestant_choice = rand(3)
  puts "Contestant chooses door #{contestant_choice}"

  # Randomly choose doors for Monty to open until we find one that is:
  #   - Not the winner
  #   - Not the door the contestant chose.
  monty_opens = nil
  while ( monty_opens == nil )
    temp_door = rand(3)
    if temp_door == contestant_choice
      next # Can't be the contestant's door
    end

    if temp_door == winning_door
      next # Can't be the winning door.
    end

    monty_opens = temp_door
  end

  puts "Monty opens door #{monty_opens}"
  puts "Winning door is #{winning_door}"

  # Determine if the contestant should switch or stay.
  if contestant_choice == winning_door
    return 'stay'
  else
    return 'switch'
  end
end
```

## Run the simulation

To run 1000 simulations of the game execute the program like this:

`ruby monty_hall.rb 1000`

A typical run will look like this:

```
...
{"stay"=>343, "switch"=>657}
```

In this example the contestent would win 343 times (out of a 1000) if they stayed and 657 times if they switched, which is what vos Savant predicted.

## Explanation

There are two areas to pay attention to.  The first area is the logic that chooses what door Monty opens:

```ruby
  monty_opens = nil
  while ( monty_opens == nil )
    temp_door = rand(3)
    if temp_door == contestant_choice
      next # Can't be the contestant's door
    end

    if temp_door == winning_door
      next # Can't be the winning door.
    end

    monty_opens = temp_door
  end
```

It randomly selects a door until it finds an appropriate door.  Note that--as stated by the problem--**Monty never opens the winning door**.  If the game allowed Monty to occasionally open the winning door then the outcomes would be different (we'll discuss that later).

The second area to inspect is the logic that determins if the contestant should switch:

```ruby
  if contestant_choice == winning_door
    return 'stay'
  else
    return 'switch'
  end
```

Note that the variable `monty_opens` isn't used!  In fact, other than printing it out, the door that Monty opens has no bearing on the rest of the code.  The crux of understanding the apparent paradox is this: despite opening a door Monty hasn't given the contestant any new information, which is evident in the code because the variable `monty_opens` is never referenced.

## Refactored

Since we know that `monty_opens` is never used let's refactor the code.  You might have also noticed that the `doors` array isn't really used, either, so we can factor that out.  The method now looks like this:

```ruby
def play
  # Randomly choose a winning door.
  winning_door = rand(3)

  # Contestant randomly chooses a door.
  contestant_choice = rand(3)
  puts "Contestant chooses door #{contestant_choice}"
  puts "Winning door is #{winning_door}"

  # Determine if the contestant should switch or stay.
  if contestant_choice == winning_door
    return 'stay'
  else
    return 'switch'
  end
end
```

If you didn't care about printing the choosen doors, you could get really agressive with refactoring, down to just a few lines:

```ruby
def play
  # If the contestant randomly chooses the winning door they should stay, otherwise switch.
  return rand(3) == rand(3) ? 'stay' : 'switch'
end
```

In the end it only matters if the contestant chose the winning door.  What Monty says matters not at all.

## Whoa

How can this be?  It certainly seems like Monty is giving you new information when he opens a door.  The answer lies in his constraints:

  * Monty will always open a door and make the offer to switch (i.e. we assume no gamemanship from Monty).
  * He will never open the winning door.

The second constraint is the important one.  What if instead of opening a door, Monty just tells the contestant about the other doors:

> *Contestant:* I choose door X

> *Monty:* Would you rather have what's behind door X or behind door Y *and* Z?

> *Contestant:* I'll switch and take doors Y and Z.

> *Monty:* Are you sure?  One of those doors has to be empty.

> *Contestant:* Yes, I still want Y and Z.

In his last statement Monty has not said anything we don't already know: one of the two doors has to be empty. The contestant still wants to switch because they know that the chances of Y and Z both being empty is less than just X being empty.

## What if Monty could open the winning door?

To see why the constraint matters, let's rewrite the code to allow Monty to randomly open the winning door. The code is similar to the original with a few lines removed:

```ruby
  monty_opens = nil
  while ( monty_opens == nil )
    temp_door = rand(3)
    if temp_door == contestant_choice
      next # Can't be the contestant's door
    end

    monty_opens = temp_door
  end
```

But now when we determine if the contestant should switch or not, we also have to factor in the times that Monty opens the winning door, which means the contestant immediate loses:

```ruby
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
```

Unlike the original example, we use `monty_opens` to help determine the final outcome.  In this case Monty has given us new information!  This version is saved as [monty_hall_opens_door.rb](monty_hall_opens_door.rb) and if you run it you get a different outcome:

```
...
{"lose"=>355, "stay"=>322, "switch"=>323}
```

In this scenario it doesn't matter whether the contestant stays or switches.