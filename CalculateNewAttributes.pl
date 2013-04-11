# Greg mojonnier
use warnings;
use strict;

open my $file, "<playerStatsByTeam-1995_2005.csv" or die "The player stats file doesn't even exist!\n";
my @allFilelines = <$file>;
close $file;

my @columnHeaders = split /,/, $allFileLines[ 0 ];
chomp $columnHeaders[ $#columnHeaders ];

my %attributesIndex;

for my $index( 0..$#columnHeaders ){
	$attributesIndex{ $columnHeaders[ $index ] } = $index;
}
