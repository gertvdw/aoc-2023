const fs = require("fs");
const data = fs.readFileSync("./src/input/day3.txt", "utf8");
const lines = [];
const field = [];
const numbers = [];
const gears = [];

const make_match = (text, index, line) => ({
  number: text,
  len: text.length,
  index,
  end: index + text.length,
  line,
});

const numbers_in_row = (y) => {
  return Array.from(
    lines[y].matchAll(/(\d+)/g),
    ({ [0]: text, index = throwError() }) => make_match(text, index, y)
  );
};

const gears_in_row = (y) =>
  Array.from(lines[y].matchAll(/\*/g), ({ [0]: text, index = throwError() }) =>
    make_match(text, index, y)
  );

const is_gear = (gear) => numbers.flat().filter((n) => adjacent_to(gear, n));

const adjacent_to = (a, b) => {
  return (
    a.line - 1 <= b.line &&
    a.line + 1 >= b.line &&
    a.index <= b.end &&
    a.end >= b.index
  );
};

// from start index to end index of number,
// look around for a symbol.
// left, right, diagonally
// probably bettter to use adjacent_to(), but I'll keep this in here
// as my first attempt.
const adjacent_to_symbol = (x, y, num_length = 1, number = -1) => {
  const look_around = [-1, 0, 1];
  let x2, y2;

  for (const modifier_y of look_around) {
    y2 = y + modifier_y;
    for (let i = 0; i < num_length; i++) {
      for (const modifier_x of look_around) {
        x2 = x + modifier_x + i;
        if (x2 >= 0 && y2 >= 0 && x2 < field[y].length && y2 < field.length) {
          if (!field[y2][x2].match(/[0-9\.]/)) {
            return true;
          }
        }
      }
    }
  }
  return false;
};

// Justice friends: assemble!
// Make the lines, field and numbers dataset
for (const l of data.split("\n")) {
  lines.push(l);
  field.push(l.split(""));
  numbers.push(numbers_in_row(lines.length - 1));
}

const z = lines.map((_, index) => {
  const a = numbers_in_row(index)
    .map((number_result) =>
      adjacent_to_symbol(
        number_result.index,
        index,
        number_result.len,
        number_result.number
      )
        ? number_result.number
        : null
    )
    .filter((n) => n !== null);
  return a;
});
console.log(
  "part 1",
  z.flat().reduce((acc, cur) => acc + parseInt(cur), 0)
);

const x = lines.map((_, index) => {
  const a = gears_in_row(index).map((number_result) => {
    const parts = is_gear(number_result);
    return parts.length === 2
      ? parts.map((p) => parseInt(p.number)).reduce((acc, cur) => acc * cur, 1)
      : 0;
  });
  return a;
});
console.log(
  "part 2",
  x.flat().reduce((acc, cur) => acc + cur, 0)
);
