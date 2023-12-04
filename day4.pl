#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

my $card_sum = 0;
my $pile_sum = 0;
my %card_holder = ();
my %pile = ();

open(FH, "./src/input/day4.txt") or die "$!";
while (<FH>) {
  chomp;
  my $card_no = $1 if $_ =~ /^Card[ ]+(\d+)/;
  my ($w, $c) = split(/ \| /, substr($_, 8)); # the first 8 chars are 'Card xxx: '
  my %winners = extract_numbers($w);
  my %card = extract_numbers($c);
  my @nice = map { exists $winners{$_} } keys %card;  # see if this number is a winning number
  $card_holder{$card_no} = join("", @nice) =~ tr/1//;
  $card_sum += card_value($card_holder{$card_no}); # count the number of 1's
}
close(FH);

printf("Part 1: %d\n", $card_sum);

map { $pile{$_} = 1 } keys %card_holder;  # one for every card in my pile
map { winnings($_, $card_holder{$_}) } sort { $a <=> $b } keys %card_holder; # throw cards on me
map { $pile_sum += $pile{$_} } keys %pile;

printf("Part 2: %d\n", $pile_sum);

sub winnings {
  my ($card_no, $lucky_numbers) = @_;
  my $stack = $pile{$card_no};
  for my $i (($card_no+1..$card_no+$lucky_numbers)) {
    $pile{$i} += $stack;
  }
}

sub extract_numbers {
  my $line = shift;
  my %numbers = ();
  $numbers{$1} = 1 while ($line =~ /(\d+)/g);
  return %numbers;
}

sub card_value {
  my $correct_number_count = shift;
  return $correct_number_count < 3 ? $correct_number_count : 1 * 2**($correct_number_count-1);
}