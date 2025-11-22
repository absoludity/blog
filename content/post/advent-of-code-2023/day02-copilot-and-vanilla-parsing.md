---
title: "Day02 Copilot and Vanilla Parsing"
subtitle: "Look mum, no imports!"
date: 2024-01-07T06:13:31+11:00
draft: false
categories: [ "rust", "programming" ]
tags: ["article"]
commentable: true
---

After refreshing my knowledge of [the rust parsing library 'nom' with the day01 challenge]({{<ref "day01-a-rust-parsing-exercise-with-nom">}}), I was keen to do the second challenge without, simply using the standard library's string manipulation and default parsing for this simpler parsing problem.

At the same time, I was keen to work more with [GitHub Copilot](https://github.com/features/copilot) since I've not been able to use copilot at my most recent job due to potential legal issues.

The [Elf's game for day 02](https://adventofcode.com/2023/day/2) consists of pulling out multiple combinations of red, green and blue balls from a sack - and the parsing looks quite straight forward.

**What did I learn from this challenge?** This one was pretty straight forward (simpler than the [day01 parsing challenge]({{<ref "day01-a-rust-parsing-exercise-with-nom">}})) and a good chance to solve **without any imports** other than `std::error::Error`. What I learned was how **copilot and similar technology can make programming even more fun** by suggesting a lot of boiler plate when you express your intent clearly.

## Parsing the data without nom

Each game has an id and a number of rounds:

```
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
```

Starting with the "3 blue", a number associated with one of three colours, an enum is rust seemed most appropriate (given that [Rust enum variants can contain data](https://doc.rust-lang.org/book/ch06-01-defining-an-enum.html)):

```rust
// A Cube represensts a colour and how many times it appears
#[derive(Clone, Copy, Debug, PartialEq)]
enum Cube {
    Red(u32),
    Green(u32),
    Blue(u32),
}
```

I then began with some failing test cases, which copilot helped make much less tedious, suggesting most of the boiler plate:

```rust
    #[test_case("1 red", Ok(Cube::Red(1)); "Cube parsing red")]
    #[test_case("28 green", Ok(Cube::Green(28)); "Cube parsing green")]
    #[test_case("99 blue", Ok(Cube::Blue(99)); "Cube parsing blue")]
    #[test_case("1", Err("Invalid cube: incorrect number of parts"); "Cube parsing invalid")]
    fn test_cube_from_str(input: &str, want: Result<Cube, &'static str>) {
        assert_eq!(Cube::try_from(input), want);
    }
```

and then began implementing the `TryFrom<&str>` trait and again had copilot do most of the boring boiler plate, which after a few small tweaks, enabled tests to pass:

```rust
// Parse "3 red" into Cube::Red(3)
impl TryFrom<&str> for Cube {
    type Error = &'static str;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        let parts: Vec<_> = value.split_ascii_whitespace().collect();
        if parts.len() != 2 {
            return Err("Invalid cube: incorrect number of parts");
        };
        let (num, colour) = (parts[0], parts[1]);

        let num = num
            .parse::<u32>()
            .map_err(|_| "Invalid cube: error parsing integer")?;

        match colour {
            "red" => Ok(Cube::Red(num)),
            "green" => Ok(Cube::Green(num)),
            "blue" => Ok(Cube::Blue(num)),
            _ => Err("Invalid cube: unsupported colour"),
        }
    }
}

```

The process for the parsing a set of coloured cubes:

```rust
// A CubeSet is a set of cubes with a count of how many of each colour
// E.g. "3 blue, 4 red"
#[derive(Clone, Copy, Debug, PartialEq)]
pub struct CubeSet {
    red: u32,
    green: u32,
    blue: u32,
}
```

and a game of multiple sets:

```rust
// A Game has an id and a list of CubeSets
// such as "Game 1: 3 blue, 4 red; 5 green, 6 blue" into
#[derive(Clone, Debug, PartialEq)]
pub struct Game {
    pub id: u32,
    cubesets: Vec<CubeSet>,
}
```

was so similar, it's not worth repeating.

## Part 1: which games are possible for a given set of cubes

The first problem says

> The Elf would first like to know which games would have been possible if the bag contained only **12 red cubes, 13 green cubes, and 14 blue cubes**?

with the answer being the sum of the valid games. OK, so a game is only valid for a particular cube set, if each cubset of the game is also valid. And according to the Elf, a particular set of cubes is only possible if it does not have more of a certain colour than the set he provides, so:

```rust
impl Game {
    // Return whether the game (a list of cubesets) is valid for a given Cubeset.
    pub fn is_valid(&self, cubeset: &CubeSet) -> bool {
        self.cubesets.iter().map(|c| c.is_valid(cubeset)).all(|v| v)
    }
    ...
}

impl CubeSet {
    // Return whether this CubeSet can be pulled out of a bag that contains the
    // given CubeSet.
    pub fn is_valid(&self, cubeset: &CubeSet) -> bool {
        self.blue <= cubeset.blue && self.green <= cubeset.green && self.red <= cubeset.red
    }
```

and with those, part 1 is solved by mapping the valid games to sum the game id's, without external imports other than `std::error::Error`:

```rust
use aoc::{CubeSet, Game};
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    let elf_cubeset = CubeSet::new(12, 13, 14);

    // For each line in the input file, parse and map line of text to a parsed
    // Game.
    let valid_games_sum: u32 = include_str!("../../input.txt")
        .lines()
        .map(|line| Game::try_from(line).expect("each line should have a valid game"))
        .filter(|game| game.is_valid(&elf_cubeset))
        .map(|game| game.id)
        .sum();

    println!("Part 1 sum of valid games is {}", valid_games_sum);

    Ok(())
}

```

## Part 2: fewest cubes per game

The second part to the day's problem is only a little trickier, requiring for each game (a list of cube sets), we calculate the minimum cubeset - that is, the minimum number of cubes of each colour for that game to be possible. This is a nice way to see the default Rust reduce/fold functionality to iterate through the list of cubesets and remember the minimum number of cubes:

```rust

impl Game {
    ...
    // Return the minimum cubeset that could be used for all rounds of a game.
    pub fn min_cubeset(&self) -> CubeSet {
        self.cubesets
            .iter()
            .fold(CubeSet::new(0, 0, 0), |acc, &c| CubeSet {
                red: acc.red.max(c.red),
                green: acc.green.max(c.green),
                blue: acc.blue.max(c.blue),
            })
    }
}
```

To provide an answer to the problem, we need to sum the "power" of each minimum cubeset, where the power is just:

```rust
impl CubeSet {
    ...
    // pow returns the num red * num green * num blue for a cubeset
    pub fn pow(&self) -> u32 {
        self.red * self.green * self.blue
    }
}
```

enabling the part 2 solution to map each minimum cubeset to the power and sum them, again without any external imports other than `std::error::Error`:

```rust
use aoc::Game;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    // Game.
    let sum_game_pows: u32 = include_str!("../../input.txt")
        .lines()
        .map(|line| Game::try_from(line).expect("each line should have a valid game"))
        .map(|game| game.min_cubeset())
        .map(|c| c.pow())
        .sum();

    println!("Part 1 sum of game powers is {}", sum_game_pows);

    Ok(())
}

```

Pretty straight-forward once simple data structures are chosen and the data parsed.
