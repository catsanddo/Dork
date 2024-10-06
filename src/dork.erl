-module(dork).
-export([main/0]).

main() ->
    greeting(),
    {Rooms_Visited, Treasure} = enter_chamber(8, []),  % You start the game with 8 units of fuel and no treasure
    game_over(Rooms_Visited, lists:map(fun(Id) -> lists:nth(Id, treasure_list()) end, Treasure)).

% Issues a greeting message at the start of the game
greeting() ->
    io:format("Welcome to Dork: The Spectacular Subterranean!~n"),
    io:format("You find yourself in the caves of the abandoned Oatmeal Mines.~n"),
    io:format("You've come seeking treasures and fame equipped with nothing but~n"),
    io:format("your trusty brass lamp.~n~n").

% Prints a message at the end of the game with your score
game_over(Rooms, Treasure) ->
    io:format("Your lamp light flickers and goes out. You have run out of fuel.~n"),
    io:format("You meet your end as many rookie adventurers do; in the jaws of a~n"),
    io:format("grue.~n~n"),
    io:format("You bravely traversed through ~w chambers.~n", [Rooms]),
    Total = display_treasure(Treasure),
    io:format("You earned a total of ~w points!~n", [Total]).

display_treasure([]) -> 0;
display_treasure([Item|Treasure]) ->
    {Description, Value} = Item,
    io:format("    You found ~s worth ~w points.~n", [Description, Value]),
    Value + display_treasure(Treasure).

treasure_list() ->
    [
        {"an ornate key", 100},
        {"a gold watch", 200},
        {"a decorated drinking horn", 300},
        {"an ivory jewelry box", 400},
        {"a jewel-encrusted dagger", 500},
        {"a jade lichen figurine", 600},
        {"an embossed tome", 700},
        {"a golden scepter", 800},
        {"an opal-studded coronet", 900},
        {"a rare comic book", 1000}
    ].

% Generates and then guides the player through a room
enter_chamber(0, Treasure) -> {0, Treasure};
enter_chamber(Fuel, Treasure) ->
    io:format("Lamp oil: ~w~n", [Fuel]),
    
    Type = gen_room_type(),
    describe_room(Type),
 
    {Left, Middle, Right} = gen_room_exits(Type),
    describe_exits({Left, Middle, Right}),

    io:format("~n"),
    select_direction(),

    {Rooms, New_Treasure} = enter_chamber(max(0, min(Fuel + fuel_bonus(Type), 8)), get_treasure(Type, Treasure)),  % Constrain fuel to [0, 8]
    {Rooms + 1, New_Treasure}.

% Prompts the user for a valid direction
select_direction() ->
    {ok, Input} = io:fread("Which direction do you choose? (r/m/l) ", "~s"),
    if
        Input == ["r"] -> ok;
        Input == ["m"] -> ok;
        Input == ["l"] -> ok;
        true -> select_direction()
    end.

% Adds a piece of treasure to list if Type == dark
get_treasure(maze, Treasure) -> [rand:uniform(10)|Treasure];
get_treasure(_, Treasure) -> Treasure.

% Generates an atom representing the type of room
%    dark    ~ 40%
%    rest    ~ 20%
%    crystal ~ 30%
%    maze    ~ 10%
gen_room_type() ->
    Choice = rand:uniform(10),
    if
        Choice =< 4 -> dark;
        Choice =< 6 -> rest;
        Choice =< 8 -> crystal;
        true -> maze
    end.

% Prints a description of the room for the player
describe_room(dark) ->
    io:format("Long shadows stretch outward in this eerie and spacious chamber.~n"),
    io:format("A chill runs down your spine as you the hear sounds of unseen~n"),
    io:format("creatures slithering in the inky gloom around you.~n");
describe_room(rest) ->
    io:format("This chamber is smaller and cozier than the others. Someone has~n"),
    io:format("left a small cache of supplies here. Judging by the thick layer of~n"),
    io:format("dust, they won't be coming back. Might as well help yourself.~n"),
    io:format("You refill your lamp with some leftover oil here.~n");
describe_room(crystal) ->
    io:format("You put out your lamp as you enter this chamber. Millions of~n"),
    io:format("crystals stud the walls here, each faintly glowing. You take a~n"),
    io:format("moment to rest under this breathtaking display and drink some~n"),
    io:format("refreshing water from a clear pool before continuing.~n");
describe_room(maze) ->
    io:format("You have stumbled your way through a twisting maze of narrow~n"),
    io:format("passages. Precious time and oil was lost. Though you found some~n"),
    io:format("treasure for your trouble. You must now press on.~n").
    

% This function will generate the randomized room exits for every type of room
% Since only dark and crystal rooms are randomized, only they match the first clause
gen_room_exits(Type) when Type =:= dark; Type =:= crystal ->
    case rand:uniform(4) of
        1 -> {true, true, false};
        2 -> {true, false, true};
        3 -> {false, true, true};
        4 -> {true, true, true}
    end;
gen_room_exits(rest) -> {false, false, false};
gen_room_exits(maze) -> {true, true, true}.

% Prints a description of the exits for the player
describe_exits({false, false, false}) -> ok;
describe_exits({true, Middle, Right}) ->
    io:format("    There is a passage to the Left.~n"),
    describe_exits({false, Middle, Right});
describe_exits({Left, true, Right}) ->
    io:format("    There is a passage to the Middle.~n"),
    describe_exits({Left, false, Right});
describe_exits({Left, Middle, true}) ->
    io:format("    There is a passage to the Right.~n"),
    describe_exits({Left, Middle, false}).

% Gets the delta of fuel consumed in this room
fuel_bonus(dark) -> -1;
fuel_bonus(rest) -> 2;
fuel_bonus(crystal) -> 0;
fuel_bonus(maze) -> -2.
