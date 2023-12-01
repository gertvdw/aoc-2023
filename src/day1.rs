//mod day1 {
use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use substring::Substring;

// The output is wrapped in a Result to allow matching on errors
// Returns an Iterator to the Reader of the lines of the file.
fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}

pub fn outermost_numbers(line: &str) -> i32 {
    let numbers = solve_digits(line.to_string().clone());
    return format!("{}{}", numbers[0], numbers[1]).parse().unwrap();
}

pub fn outermost_numbers_and_words(line: &str) -> i32 {
    let mut whoa = "".to_string();  // this will hold the numbers we found
    const NUMBER_NAMES: [&str; 9] = [
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
    ];
    const NUMBER_REPL: [char; 9] = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

    // loop through the string.
    // advance 1 char at a time. We need to check if e.g. 'three' is in there,
    // but 'twone' should match 'two' and 'one' as well. No rush..
    for (idx, c) in line.char_indices() {
        if c.is_numeric() {
            // numbers are useful..
            whoa.push(c);
        }
        // see if we can map anything in here to a number
        for (n_idx, name) in NUMBER_NAMES.iter().enumerate() {
            // the only useful bit of string here is the last bit.
            // see if it matches anything we can map.
            if line.substring(0, idx + 1).ends_with(name) {
                whoa.push(NUMBER_REPL[n_idx]);
                // no use to check other mappings.
                break;
            }
        }
    }
    let numbers = solve_digits(whoa.clone());

    // println!("{line} -> {whoa} -> {}+{}", numbers[0], numbers[1]);
    
    return format!("{}{}", numbers[0], numbers[1]).parse().unwrap();
}

fn solve_digits(whoa: String) -> [u32; 2] {
    let charlist = whoa.chars();
    let mut numbers: [u32; 2] = [0, u32::MIN];
    let mut index = 0;

    for c in charlist {
        match c {
            '0'..='9' => { 
                numbers[index] = c.to_digit(10).unwrap_or(0);
                index = 1;
            },
            _ => ()
        }
    }
    if numbers[1] == u32::MIN {
        numbers[1] = numbers[0];
    }
    return numbers;
}

pub fn part1() {
    let mut sum = 0;
    let data = read_lines("./src/input/day1.txt");
    match data {
        Ok(lines) => {
            for line in lines {
                if let Ok(word) = line {
                    let function_result = outermost_numbers(&word);
                    sum += function_result;
                }
            }
            println!("part 1 :: sum={}", sum);
        },
        Err(e) => println!("Failed to open input: {e}")
    }
}

pub fn part2() {
    let mut sum = 0;
    
    let data = read_lines("./src/input/day1.txt");
    match data {
        Ok(lines) => {
            for line in lines {
                if let Ok(word) = line {
                    let function_result = outermost_numbers_and_words(&word);
                    sum += function_result;
                }
            }
            println!("part 2 :: sum={}", sum);
        },
        Err(e) => println!("Failed to open input: {e}")
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    

    #[test]
    fn it_works() {
        const SOLUTIONS: [i32; 4] = [12, 38, 15, 77];
        const LINES: [&str; 4] = ["1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet"];
        let mut index = 0;
        let mut sum = 0;
        for line in LINES {
            let function_result = outermost_numbers(line);
            assert_eq!(function_result, SOLUTIONS[index]);
            index += 1;
            sum += function_result;
        }
        assert_eq!(sum, 142);
        println!("sum: {}", sum);
    }

    #[test]
    fn it_works_2() {
        const SOLUTIONS: [i32; 7] = [29,83,13,24,42,14,76];
        const LINES: [&str; 7] = ["two1nine", "eightwothree", "abcone2threexyz", "xtwone3four", "4nineeightseven2", "zoneight234", "7pqrstsixteen"];
        let mut index = 0;
        let mut sum = 0;
        for line in LINES {
            let function_result = outermost_numbers_and_words(line);
            assert_eq!(function_result, SOLUTIONS[index]);
            index += 1;
            sum += function_result;
        }
        assert_eq!(sum, 281);
        println!("sum: {}", sum);
    }
}
//}