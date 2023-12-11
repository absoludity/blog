---
title: "Day 01 - a Rust Parsing Exercise With Nom"
subtitle: "An exercise in avoiding confirmation bias"
date: 2023-12-10T13:51:15+11:00
draft: false
---

It's been quite some time since I've taken time to enjoy coding challenges primarily for the fun of it. Over the next months, I'm keen to work my way through the [2023 Advent of Code](https://adventofcode.com/2023) - a fun set of problems created by [Eric Wastl](https://adventofcode.com/2023/about) strung together with a seasonal story - and write up a bit about my own learning and fun.

For me it's a chance to keep improving my fluency with various Rust libraries and tools (start [learning the Rust programming language here!](https://www.rust-lang.org/learn)). And the [first day of the 2023 Advent of Code](https://adventofcode.com/2023/day/1) is a parsing exercise - a good opportunity to re-familiarise myself with Rust's [nom](https://docs.rs/nom/latest/nom/) parsing library as well as re-enforce in my head that [confirmation bias](https://en.wikipedia.org/wiki/Confirmation_bias) is strong in this one (me).

For this first problem, day 1, I'm just going to outline the final solutions that I arrived at and note, for my own learning, where I was tripped up, whereas I'll plan my commits a little better for the rest of the problems to learn also from the path I've taken (thanks to [Amos at fasterthanli.me](https://fasterthanli.me/) for the inspiration to start writing about what I learn again).

So first, the actual binary main functions for parts 1 and 2 are similar and straight-forward:

```rust
use aoc::parse_calibration_part1;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    // For each line in the input file, parse and map line of text to a parsed
    // calibration value.
    let calibrations: Vec<_> = include_str!("../../input.txt")
        .lines()
        .map(|line| {
            let (_, calibration) =
                parse_calibration_part1(line).expect("each line should have a valid calibration");
            calibration
        })
        .collect();

    // We don't need to collect the iteration values back into a vec above,
    // to then turn it back into an iterator below to sum, but it's
    // handy for debugging, so I've left it as is.

    println!(
        "Sum of calibrations is {}",
        calibrations.into_iter().sum::<u32>()
    );

    Ok(())
}
```

differing only in that part2 calls `parse_calibration_part2()` instead.

## Part 1 - A calibration value using the first and last digits

The first part of the challenge is to parse the first and last digit when given a string of alphanumeric characters. So a string such as "a1b2c3d4e45f" is parsed as the number 15. Each such line gives a calibration value, with the desired result being the summation of all calibrations for all lines of your input.

I find it useful to add an initial implementation with a `todo!()`:

```rust
pub fn parse_calibration_part1(input: &str) -> IResult<&str, u32> {
    todo!("Start here...");
}
```

so that I can go ahead and write a bunch of failing test cases before hitting confirmation bias as I implement and test further (and no, I didn't come up with all of these before writing - the last one is the result of noticing that I'd missed this explicit case even though it'd been highlighted in the instructions):

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use test_case::test_case;

    #[test_case("1abc2", Ok(("", 12)); "extracts first and last from line")]
    #[test_case("11abc24", Ok(("", 14)); "extracts first and last digits from multidigit numbers on line")]
    #[test_case("11a3399bc24", Ok(("", 14)); "extracts first and last digits from numbers on line ignoring other numbers")]
    #[test_case("pqr3stu8vwx", Ok(("", 38)); "extracts first and last digits from numbers on line ignoring prefix alphas")]
    #[test_case("treb7uchet", Ok(("", 77)); "extracts first and last digits from numbers when only one digit")]
    fn test_parse_calibration_part1(input: &str, want: IResult<&str, u32>) {
        assert_eq!(parse_calibration_part1(input), want);
    }

    ...

```

### Part 1 Step 1 - parsing the numbers amongst alpha characters

[Nom](https://docs.rs/nom/latest/nom/) is a parsing library that allows building combinators of parsers. In this case, we want to:
- capture at least one but possibly many numbers that may be preceeded or terminated with zero or more alpha characters to get a result such as `vec!["26", "45", "98"]` (line 6 below),
- map that result through a function to take the first digit of the first number and the last digit of the last number, eg. `28` for the example above (line 7 below)

```rust
// Parsing the line for the calibration in part one is recognising and
// extracting numbers made of digits, then returning the first digit of the
// first number and the last digit of the last number.
pub fn parse_calibration_part1(input: &str) -> IResult<&str, u32> {
    map(
        many1(preceded(alpha0, terminated(digit1, alpha0))),
        |multidigits: Vec<&str>| first_n_last(multidigits),
    )(input)
}
```

In this case I just moved my `todo();` into a stubbed `first_n_last` function.

### Part 1 Step 2 - first and list digits

Extracting the first and last digits of a vec of numbers to form a new base 10 number is just an exercise in learning/using rust's excellent built-in methods:

```rust
// first_n_last extracts the first digit of the first number in
// a vec of string numbers, together with the last digit of the
// last number.
// So for example, example: given the input vec!["24", "32", "98"],
// the resulting calibration is "28".
fn first_n_last(multidigits: Vec<&str>) -> u32 {
    // First character of the first number string,
    // parsed base 10.
    let first = multidigits
        .first()
        .expect("must be at least one number on a line")
        .chars()
        .nth(0)
        .expect("must be at least one digit in a number")
        .to_digit(10)
        .expect("should be base 10 digit");
    // Last character of the last number string, parsed base 10
    let last = multidigits
        .last()
        .expect("must be at least one number on a line")
        .chars()
        .last()
        .expect("must be at least one digit in a number")
        .to_digit(10)
        .unwrap();
    first * 10 + last
}
```

Tests pass, the example input works, and when run with my own input, I get my first star. Happy days, until...

## Part 2 - including digits spelled out with letters

OK, I admit, initially I thought part 2 would be a trivial addition but I failed to take into account my brain's tendancy to confirm the first solution it finds.

I knew I wanted to reuse my `first_n_last` function, and simply have a new `parse_digits` function which would parse both digits and spelled-out words representing digits, so I started with a stubbed (`todo!()`) `parse_digits` function and a few test cases of what I expect to see:

```rust
    #[test_case("two14", Ok(("", vec!["2", "14"])); "extracts word digit to digit")]
    #[test_case("atwo14", Ok(("", vec!["2", "14"])); "extracts word digit to digit with prefix alpha")]
    #[test_case("atwoa1heightu4", Ok(("", vec!["2", "1", "8", "4"])); "extracts word digit to digit with prefix and postfix alpha")]
    #[test_case("two1nine", Ok(("", vec!["2", "1", "9"])); "extracts word digit and digits together")]
    #[test_case("atwoa1heightu48", Ok(("", vec!["2", "1", "8", "48"])); "extracts word digit to digit with prefix and multi-digit")]
    #[test_case("atwoa1sevenine", Ok(("", vec!["2", "1", "7", "9"])); "extracts word digit to digit with prefix and overlapping word digits")]
    fn test_parse_digits(input: &str, want: IResult<&str, Vec<&str>>) {
        assert_eq!(parse_digits(input), want);
    }
```

Note the last test case above, which is me thinking my genius has realised the trick here: `sevenine` will need to be parsed as `vec!["7", "9"]`. Being very self-satisfied at noticing this, I scanned the other words and didn't immediately see any other exceptions like this and continued on. This cost me time and frustration later when I couldn't get the correct result for my actual input, even though it worked for the example input. Lesson for me to re-learn? **When you find an exception, always check all permutations explicitly for other exceptions**, or even better, find a generalisation that removes the need for exceptions. As it turns out, I missed the following additional test-cases initially:

```rust
    #[test_case("oneight", Ok(("", vec!["1", "8"])); "extracts overlapping word digit oneight")]
    #[test_case("threeight", Ok(("", vec!["3", "8"])); "extracts overlapping word digit threeight")]
    #[test_case("fiveight", Ok(("", vec!["5", "8"])); "extracts overlapping word digit fiveight")]
    #[test_case("nineight", Ok(("", vec!["9", "8"])); "extracts overlapping word digit nineight")]
    #[test_case("eightwo", Ok(("", vec!["8", "2"])); "extracts overlapping word digit eightwo")]
    #[test_case("eighthree", Ok(("", vec!["8", "3"])); "extracts overlapping word digit eighthree")]
```

### Part 2 Step 1: parsing words as well as digits

I added a small function to alternately parse either a word digit or a numerical digit:

```rust
fn parse_word_or_num_digit(input: &str) -> IResult<&str, Vec<&str>> {
    alt((parse_word_digit, map(digit1, |d| vec![d])))(input)
}
```

Note that this function (and the one below) needs to return a `Vec<&str>` rather than just a single `&str` because input such as `sevenine` results in two numbers being returned by `parse_word_digit` (though I could have also chosen to return `"79"` I guess).

The actual implementation of `parse_word_digit` is then pattern matching for quite a few alternatives (updated to include the extra alternatives I'd missed originally):

```rust
// Note that certain words can overlap, the only one I can see is:
// sevenine (correction - there are quite a few, see below).
// LEARN: avoid confirmation bias - finding one exception and thinking that's the
// missing piece, rather than looking exhaustively for all exceptions.
fn parse_word_digit(input: &str) -> IResult<&str, Vec<&str>> {
    map(
        alt((
            tag("oneight"),
            tag("one"),
            tag("twone"),
            tag("two"),
            tag("threeight"),
            tag("three"),
            tag("four"),
            tag("fiveight"),
            tag("five"),
            tag("six"),
            tag("sevenine"),
            tag("seven"),
            tag("eightwo"),
            tag("eighthree"),
            tag("eight"),
            tag("nineight"),
            tag("nine"),
        )),
        |word| match word {
            "oneight" => vec!["1", "8"],
            "one" => vec!["1"],
            "twone" => vec!["2", "1"],
            "two" => vec!["2"],
            "threeight" => vec!["3", "8"],
            "three" => vec!["3"],
            "four" => vec!["4"],
            "fiveight" => vec!["5", "8"],
            "five" => vec!["5"],
            "six" => vec!["6"],
            "sevenine" => vec!["7", "9"],
            "seven" => vec!["7"],
            "eighthree" => vec!["8", "3"],
            "eightwo" => vec!["8", "2"],
            "eight" => vec!["8"],
            "nineight" => vec!["9", "8"],
            "nine" => vec!["9"],
            _ => panic!("non digit word"),
        },
    )(input)
}
```

### Part 2 Step 2: Checking for digits one char at a time...

This step introduced me to a new `nom` function that I needed: `many_till` which will continue consuming from the input (using the first provided argument) until the second provided argument is able to parse something. For this problem, I'm simply consuming a single character until I'm able to parse a word or number digit:

```rust
// parse_digits takes one charachter at a time from the input until
// it is able to parse a word or number digit, ignores the characters that
// weren't part of a word or digit, and returns a single flattened Vec<&str> of
// the result.
fn parse_digits(input: &str) -> IResult<&str, Vec<&str>> {
    let (rest, digit_vecs) = many1(map(
        many_till(take(1u8), parse_word_or_num_digit),
        |(_, word_or_num)| word_or_num,
    ))(input)?;
    Ok((rest, digit_vecs.into_iter().flatten().collect()))
}
```
Note that we need to flatten the returned vector (that is, it's a vector of vectors of calibrations and we want to flatten that result to a simple vector of calibrations) only because `parse_word_or_num_digit` itself returns a vec of calibrations (for the exception cases of `sevenine` etc).

With that we can then write a small `parse_calibration_part2` function that calls `parse_digits` and maps the result through `first_n_last` to get the first and last digits the same as in part 1:

```rust
pub fn parse_calibration_part2(input: &str) -> IResult<&str, u32> {
    map(parse_digits, |digits: Vec<&str>| first_n_last(digits))(input)
}
```

Aaaand with that, tests pass again and my part2 binary (virtually the same as the part1 one at the beginning) gives the correct answer.

## What did I learn here?

So the main point that caused issues for me in this exercise was confirmation bias when I found what I thought was the (single) trick of overlapping word-digits (`sevenine`) and checked too casually for other similar overlapping words, rather than exhaustively checking through the ten options. I need to reinforce that when I discover an interesting or unexpected case, that I exhaustively check for other instances of the same.

And I got to use a new `nom` function, `many_till` which will be incredibly helpful for other parsing situations here in the advent of code, I'm sure.
