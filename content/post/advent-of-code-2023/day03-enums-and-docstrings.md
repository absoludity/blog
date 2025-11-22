---
title: "Day03 Tokens, Enums and Docstrings"
subtitle: "A better way to communicate code"
date: 2024-01-12T06:45:18+11:00
draft: false
categories: [ "rust", "programming" ]
tags: ["article"]
commentable: true
---

The [Day 03 challenge](https://adventofcode.com/2023/day/3) involves the calculating whether a character symbol is adjacent to a part number in a two dimensional map, such as:

```
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
```
and then doing things with the part numbers.

To calculate whether a symbol is adjacent to a part number we're going to need:
- the position of each symbol,
- the position of each number,
- the length of the token for each number.

## Tokenising the input

The simplest way to get this data that I can think of is to parse the map into a list of tokens, where the number and blank tokens contain the info for me to know the length (ie. the `&str`).

There are four different types of tokens in our input:

```rust
#[derive(Debug, PartialEq)]
pub enum Token<'a> {
    Number(&'a str),
    Symbol(char),
    Blank(&'a str),
    NewLine,
}
```

This looks like a job for nom again, so we create a set of parsers that parse each of the above, and combine them in a single `parse` function that parses the input into a vector of tokens.

 **Note**, this time, rather than using `test_case` to write separate test cases for each function, I'm instead using doctests as I think they communicate more clearly the intent of the code as they remain in the context of the code:

```rust
///
/// Parses a number token
///
/// ```
/// # use aoc::{parse_number, Token};
/// let result = parse_number("123..*.456");
/// assert_eq!(result, Ok(("..*.456", Token::Number("123"))));
/// ```
pub fn parse_number(input: &str) -> IResult<&str, Token> {
    map(recognize(digit1), |n: &str| Token::Number(n))(input)
}

///
/// Parses a symbol token
///
/// ```
/// # use aoc::{parse_symbol_token, Token};
/// let result = parse_symbol_token("*?..456");
/// assert_eq!(result, Ok(("?..456", Token::Symbol('*'))));
/// ```
pub fn parse_symbol_token(input: &str) -> IResult<&str, Token> {
    map(one_of("*#+$?/&-=%@"), Token::Symbol)(input)
}

///
/// Parses a blank token
///
/// ```
/// # use aoc::{parse_blank, Token};
/// let result = parse_blank("...456");
/// assert_eq!(result, Ok(("456", Token::Blank("..."))));
/// ```
pub fn parse_blank(input: &str) -> IResult<&str, Token> {
    map(recognize(many1(tag("."))), |s: &str| Token::Blank(s))(input)
}

pub fn parse_newline(input: &str) -> IResult<&str, Token> {
    map(tag("\n"), |_| Token::NewLine)(input)
}

pub fn parse_token(input: &str) -> IResult<&str, Token> {
    alt((parse_number, parse_symbol_token, parse_blank, parse_newline))(input)
}

```

With this, we can now parse the input into a vector of tokens with:

```rust
///
/// Parses text into a vector of Tokens
///
/// ```
/// # use aoc::{parse, Token};
/// let result = parse("123..*.456\n987...");
/// assert_eq!(
///     result,
///     Ok((
///         "",
///         vec![
///             Token::Number("123"),
///             Token::Blank(".."),
///             Token::Symbol('*'),
///             Token::Blank("."),
///             Token::Number("456"),
///             Token::NewLine,
///             Token::Number("987"),
///             Token::Blank("..."),
///         ]
///     ))
/// );
/// ```
pub fn parse(input: &str) -> IResult<&str, Vec<Token>> {
    many1(parse_token)(input)
}

```

## Part 1: the sum of parts

Now that we've got the data tokenised, we can translate the tokens into the data structures that will help us solve the question. For part 1, it involves summing all the part numbers, *but*

> apparently any number adjacent to a symbol, even diagonally, is a "part number" and should be included in your sum

while the other numbers are to be ignored. So we need to be able test, for each number, if it is adjacent to a symbol, which in turn requires testing if a position contains a symbol.

### Testing for a symbol at a certain position

So the first step here is to translate our vector of tokens into a symbol map, a `HashMap<Position, char>`, that we can use to test if a certain position has a symbol.

```rust
#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
pub struct Position {
    x: i32,
    y: i32,
}
impl Position {
    pub fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }
}

///
/// Converts a vector of Tokens into a HashMap of Positions to symbols
///
/// ```
/// # use aoc::{parse, Token, tokens_to_symbol_map, Position};
/// # use std::collections::HashMap;
/// let (_, tokens) = parse("123..*.456\n987.?.").unwrap();
/// assert_eq!(
///     tokens_to_symbol_map(&tokens),
///     HashMap::from_iter(
///         vec![
///            (Position::new(5, 0), '*'),
///            (Position::new(4, 1), '?'),
///         ]
///     )
/// );
pub fn tokens_to_symbol_map(tokens: &Vec<Token>) -> HashMap<Position, char> {
    let mut symbol_map = HashMap::new();
    let mut x = 0;
    let mut y = 0;
    for token in tokens {
        match token {
            Token::Number(l) => {
                x += l.len() as i32;
            }
            Token::Symbol(s) => {
                symbol_map.insert(Position { x, y }, *s);
                x += 1;
            }
            Token::Blank(b) => {
                x += b.len() as i32;
            }
            Token::NewLine => {
                x = 0;
                y += 1;
            }
        }
    }
    symbol_map
}

```

### Iterating a vector of parts

The other data we need is a vector of engine parts - a position and a `&str` label:

```rust
#[derive(Debug, PartialEq)]
pub struct EnginePart<'a> {
    label: &'a str,
    position: Position,
}
impl<'a> EnginePart<'a> {
    pub fn new(label: &'a str, position: Position) -> Self {
        Self { label, position }
    }
}

///
/// Converts a vector of Tokens into a vector of EngineParts with positions
///
/// ```
/// # use aoc::{parse, Token, tokens_to_engine_parts, EnginePart, Position};
/// let (_, tokens) = parse("123..*.456\n987...").unwrap();
/// assert_eq!(
///     tokens_to_engine_parts(&tokens),
///     vec![
///         EnginePart::new("123", Position::new(0, 0)),
///         EnginePart::new("456", Position::new(7, 0)),
///         EnginePart::new("987", Position::new(0, 1)),
///     ]
/// );
pub fn tokens_to_engine_parts<'a>(tokens: &'a Vec<Token<'a>>) -> Vec<EnginePart<'a>> {
    let mut engine_parts = Vec::new();
    let mut x = 0;
    let mut y = 0;
    for token in tokens {
        match token {
            Token::Number(l) => {
                engine_parts.push(EnginePart {
                    label: l,
                    position: Position { x, y },
                });
                x += l.len() as i32;
            }
            Token::Symbol(_) => {
                x += 1;
            }
            Token::Blank(b) => {
                x += b.len() as i32;
            }
            Token::NewLine => {
                x = 0;
                y += 1;
            }
        }
    }
    engine_parts
}

```

### Checking if an engine part is adjacent to a symbol

For a specific `EnginePart`, we can list the positions adjacent to it by defining a rectangle one unit larger than the number token, then checking if an engine part is adjacent to a symbol is simply checking if any adjacent position is a key in the symbol map:

```rust

impl<'a> EnginePart<'a> {
    ...

    pub fn adjacent_positions(&self) -> Vec<Position> {
        // The following calculates the range of positions that compose
        // the area around the number. This is a rectangle that is one
        // unit larger than the number in each direction.
        // This will include the position of the number itself, but that's fine.
        let mut adjacent_positions = Vec::new();
        ((self.position.x - 1)..=(self.position.x + self.label.len() as i32)).for_each(|x| {
            ((self.position.y - 1)..=(self.position.y + 1)).for_each(|y| {
                adjacent_positions.push(Position::new(x, y));
            });
        });
        adjacent_positions
    }

    pub fn adjacent_to_symbol(&self, symbol_map: &HashMap<Position, char>) -> bool {
        self.adjacent_positions()
            .iter()
            .any(|p| symbol_map.contains_key(p))
    }

```

and with that, our part 1 binary can just parse and sum the engine parts that are adjacent to a symbol:

```rust
use std::error::Error;

use aoc::{parse, tokens_to_engine_parts, tokens_to_symbol_map};

fn main() -> Result<(), Box<dyn Error>> {
    let input = include_str!("../../input.txt");
    let (rest, tokens) = parse(input)?;
    assert_eq!(rest, "");

    let engine_parts = tokens_to_engine_parts(&tokens);

    let symbol_map = tokens_to_symbol_map(&tokens);

    let sum_of_engine_parts = engine_parts
        .iter()
        .filter(|ep| ep.adjacent_to_symbol(&symbol_map))
        .map(|ep| ep.label().parse::<u32>().unwrap())
        .sum::<u32>();
    dbg!(sum_of_engine_parts);
    Ok(())
}
```

## Part 2: Gear ratios

Part 2 for this day has us checking for special symbols, gears `*`, that are adjacent to exactly two parts:

> A gear is any * symbol that is adjacent to exactly two part numbers. Its gear ratio is the result of multiplying those two numbers together.
>
> This time, you need to find the gear ratio of every gear and add them all up so that the engineer can figure out which gear needs to be replaced.

Well, that didn't take much more work...we can check if a position is adjacent to an Engine part with the following:

```rust
impl<'a> EnginePart<'a> {
    ...
    ///
    /// Returns true if the given position is adjacent to this EnginePart
    ///
    /// ```
    /// # use aoc::{EnginePart, Position};
    /// let engine_part = EnginePart::new("114", Position::new(5, 0));
    /// assert!(engine_part.adjacent_to_pos(Position::new(4, 1)));
    /// assert!(!engine_part.adjacent_to_pos(Position::new(3, 1)));
    /// ```
    pub fn adjacent_to_pos(&self, pos: Position) -> bool {
        self.adjacent_positions().iter().any(|p| p == &pos)
    }
}
```

and with that, solve part 2 with the binary:

```rust
use std::error::Error;

use aoc::{parse, tokens_to_engine_parts, tokens_to_symbol_map, EnginePart};

fn main() -> Result<(), Box<dyn Error>> {
    let input = include_str!("../../input.txt");
    let (rest, tokens) = parse(input)?;
    assert_eq!(rest, "");

    let engine_parts = tokens_to_engine_parts(&tokens);

    let symbol_map = tokens_to_symbol_map(&tokens);

    let sum_of_gear_ratios = symbol_map
        .iter()
        // We only want the positions of the gear characters...
        .filter_map(|(p, s)| match s {
            '*' => Some(p),
            _ => None,
        })
        // and then, only want the gear ratios of those with exactly
        // two adjacent parts
        .filter_map(|p| {
            let adjacent_parts = engine_parts
                .iter()
                .filter(|ep| ep.adjacent_to_pos(*p))
                .collect::<Vec<&EnginePart>>();
            match adjacent_parts.len() {
                2 => Some(
                    adjacent_parts[0].label().parse::<u32>().unwrap()
                        * adjacent_parts[1].label().parse::<u32>().unwrap(),
                ),
                _ => None,
            }
        })
        .sum::<u32>();

    dbg!(sum_of_gear_ratios);
    Ok(())
}
```

Our binary for part 2 is a little more complicated, but it's nice not having to change much of the existing library code to solve part 2.
