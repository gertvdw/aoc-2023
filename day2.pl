#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

my $games_sum = 0;
my $minimum_dice_count = 0;

open(FH, "./src/input/day2.txt") or die "$!";
while (<FH>) {
  my %dice = ( red => 0, green => 0, blue => 0 );
  my $game_id = $1 if $_ =~ /^Game (\d+)/;  # what could possibly go wrong?
  
  # find all occurrences of a dice roll
  while ($_ =~ /([\d+]{1,3} (green|blue|red))/g) {
    my ($count, $dice_colour) = split(/ /, $1);
    # only note the highest dice count per colour
    $dice{$dice_colour} = $count if ($count > $dice{$dice_colour});
  }
  # part 1: sum all the game IDs
  $games_sum += $game_id if game_is_possible(\%dice) > 0;
  # part 2: multiply the highest rolls per colour and add that total
  $minimum_dice_count += sum_dice(\%dice);
}
close(FH);

printf("Part 1: sum = %d\n", $games_sum);
printf("Part 2: sum = %d\n\n", $minimum_dice_count);

sub game_is_possible {
  my ($hash_ref) = @_;
  my %dice = %$hash_ref;
  return sum_dice(\%dice) if ($dice{red} <= 12 && $dice{blue} <= 14 && $dice{green} <= 13);
  return 0;
}

sub sum_dice {
  my $hash_ref = shift;
  my %dice = %$hash_ref;
  my @values = map { $dice{$_} } keys %dice;
  my $sum = 1;
  map { $sum *= $_ } @values;
  return $sum;
}