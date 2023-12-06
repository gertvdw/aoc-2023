#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(min reduce product);
use Data::Dumper;

open(FH, "./src/input/day6.txt") or die "$!";
my $timestr = <FH>;
my $distancestr = <FH>;
close(FH);

my @times = $timestr =~ /(\d+)/g;
my @distances = $distancestr =~ /(\d+)/g;
my @races = map { [$times[$_], $distances[$_]] } (0..$#times);
my $win_sum = 1;

# let's try race one
# using travel_distance to get the distance we travel,
# find the number of ms we can press the button and travel
# further than $races[0][1].
# Count the number of ways we can win
# Multiply the winnig pressing times together.

foreach my $race (0..$#races) {
  my @travels = map { travel_distance($_,@{$races[$race]}) } (0..$races[$race][0]);
  my $ways_to_win = grep { $_->[0][1] > $races[$race][1] } @travels;
  $win_sum *= $ways_to_win;
}

printf("Part 1: %d\n", $win_sum);

# Part 2
# Obviously, massive again, against brute forcing
# Let's try to find a pattern
# We can see that the distance travelled is a quadratic function
# of the time we press the button.

my $racetime = join("", @times);
my $racedistance = join("", @distances);
printf("Racing time: %d for distance %d\n", $racetime, $racedistance);

# brute forcing again!
my @travels2 = map { travel_distance($_,$racetime, $racedistance) } (0..$racetime);
my $winning_travels = grep { $_->[0][1] > $racedistance } @travels2;
printf("Part 2: %d\n", $winning_travels);

sub travel_distance {
  my ($press_time, $time, $distance) = @_;
  # printf("wait: t=%d p=%d %d\n\n", $time, $press_time, $press_time * ($time - $press_time));
  my @result = [$press_time, $press_time * ($time - $press_time)];
  return \@result;
}
