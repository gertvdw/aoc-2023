#!/usr/bin/env perl

use strict;
use warnings;

my %numbers = (
    one => 1,
    two => 2,
    three => 3,
    four => 4,
    five => 5,
    six => 6,
    seven => 7,
    eight => 8,
    nine => 9,
);

sub digitize {
    my $word = shift;
    if ($word =~ /^\d+$/) {
        return $word;
    }
    return $numbers{$word};
}

open(FH, "./src/input/day1.txt") or die "$!";
my $sum = 0;
while (<FH>) {
    my @occ = ($_ =~ /(?=([\d]|one|two|three|four|five|six|seven|eight|nine))/g);
    my @numbers = map { digitize($_) } @occ;
    # only 1 number? duplicate it.
    if (scalar @numbers == 1) { push(@numbers, $numbers[0]); }
    my @first_last = ($numbers[0], $numbers[-1]);
    $sum += join("", @first_last);
}
printf("Part 2 :: Sum: %d\n", $sum);
close(FH);
