#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(min);

my %map = ();
my $key = "seeds";
my @seeds = ();
# define the keys so we can process them in order.
my @maps = ("seed-to-soil", "soil-to-fertilizer", "fertilizer-to-water", "water-to-light", "light-to-temperature", "temperature-to-humidity", "humidity-to-location");

sub find_in_map {
  my ($map_key, $seed_no) = @_;
  return find_mapping($map_key, $seed_no);
}

sub find_mapping {
  my ($map_key, $seed_no) = @_;
  foreach my $source (keys %{$map{$map_key}}) {
    my $range = $map{$map_key}{$source}{range};
    my $src_max = $source + $range -1;
    my $dest = $map{$map_key}{$source}{dest};
    my $dest_max = $dest + $range -1;
    my $offset = $seed_no - $source;

    if ($seed_no >= $source && $seed_no <= $src_max) {
      return $dest + $offset;
    }
  }
  return $seed_no + 0;
}



open(FH, "./src/input/day5.txt") or die "$!";
my $seed_input = <FH>;
chomp $seed_input;
@seeds = split(/ /, substr($seed_input, 7));

while (<FH>) {
  chomp;
  if ($_ =~ /^([a-z-]+) map:/) {
    $key = $1;
    $map{$key} = ();
    next;
  }
  if (not $_ =~ /^$/) {
    my @mapdef = split(/ /);
    $map{$key}{$mapdef[1]} = {
      dest => $mapdef[0],
      range => $mapdef[2]
    };
  }
}
close(FH);


my %locations = ();
# right, so we have a map.
# For each seed, find out the location
sub be_farmer {
  my @seed_supply = (@_);map { 
    my $seed_no = $_;
    $locations{$seed_no} = $seed_no unless defined $locations{$seed_no};
    map {
      $locations{$seed_no} = find_in_map($_, $locations{$seed_no})
    } @maps;
  } @seed_supply;
}

be_farmer(@seeds);
my @sorted = sort { $locations{$a} <=> $locations{$b} } keys %locations;
printf("Part 1: %d\n", $locations{$sorted[0]});

sub seed_for_location {
  my $loc = shift;
  $locations{$loc} = $loc unless defined $locations{$loc};
  map { 
    $locations{$loc} = find_reverse_mapping($_, $locations{$loc});
  } reverse @maps;

  if (!is_known_seed($locations{$loc})) {
    delete($locations{$loc});
  }

  if (defined $locations{$loc}) {
    printf("First known seed: %d\n", $locations{$loc});
    return 1;
  }

   return 0;
}

# On with part 2. 
# The seeds are not just seeds, but seed ranges.
# brute-force: 7m34s
# 51752125 was my first answer.
# %locations = ();
# for (my $i = 0; $i < 51752125; $i++) {
#   if (seed_for_location($i)) {
#     last;
#   }
# }


# second attempt, more intelligent.
# go for ranges instead of individual seeds.
# stats for part 1 and part 2:
# ________________________________________________________
# Executed in   16.28 millis    fish           external
#   usr time   11.14 millis    0.12 millis   11.02 millis
#   sys time    4.43 millis    1.15 millis    3.29 millis
map_ranges();

sub find_mapping_for_range {
  my ($map_key, $range_from, $range_to) = (@_);
  # printf("%s (%d - %d)\n", $map_key, $range_from, $range_to);
  foreach my $source_from (keys %{$map{$map_key}}) {
    my $source_to = $source_from + $map{$map_key}{$source_from}{range} - 1;
    my $dest_from = $map{$map_key}{$source_from}{dest};
    my $dest_to   = $dest_from + $map{$map_key}{$source_from}{range} - 1;
    #printf("\tin range (%d - %d)?\n", $source_from, $source_to);
    next unless $range_from <= $source_to && $range_to >= $source_from;
    # printf("yep\n");
    my @result_map;

    # anything below my range?
    if ($range_from < $source_from) {
      # printf("Add results for range (%d - %d)\n", $range_from, $source_from - 1);
      push @result_map, find_mapping_for_range($map_key, $range_from, $source_from - 1)->@*;
      $range_from = $source_from;
    }

    # anything above my range?
    if ($range_to > $source_to) {
      # printf("Add results for range (%d - %d)\n", $source_to+1, $range_to);
      push @result_map, find_mapping_for_range($map_key, $source_to + 1, $range_to)->@*;
      $range_to = $source_to;
    }

    push @result_map, [
      $dest_from + ($range_from - $source_from),
      $dest_from + ($range_to - $source_from),
    ];

    return \@result_map;
  }
  
  # use this to see the unmapped locations;
  # return [[$range_from, $range_to, 'unmapped']];
  return [[$range_from, $range_to]];
}

sub map_ranges {
  my @ranges;
  for (my $i = 0; $i < $#seeds; $i += 2) {
    push @ranges, [$seeds[$i], $seeds[$i] + $seeds[$i+1] - 1];
  }
  # print Dumper(\@ranges);
  # finding ranges that either can or cannot be mapped
  foreach my $map_key (@maps) {
    @ranges = map { find_mapping_for_range($map_key, $_->@*)->@* } @ranges;
  }
  # print Dumper(\@ranges);

  my $lowest;
	foreach my $range (@ranges) {
		$lowest = min $range->[0], ($lowest // $range->[0]);
	}

  printf("Part 2: %d", $lowest);
}