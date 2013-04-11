# Greg mojonnier
use warnings;
use strict;

open my $file, "<playerStatsByTeam-1995_2005.csv" or die "The player stats file doesn't even exist!\n";
my @allFilelines = <$file>;
close $file;

my @columnHeaders = split /,/, $allFileLines[ 0 ];
chomp $columnHeaders[ $#columnHeaders ];

my %attributesIndex;

# Map all the attribute indexes by their abbreviation
# to the index their located at for make our calculations more readable
for my $index( 0..$#columnHeaders ){
	$attributesIndex{ $columnHeaders[ $index ] } = $index;
}

my $totalSeasonMinutes = 48 * 82;

# For each line, calculate the new attributes,
# append them to the original line, then overwrite the old line in @allFileLines
for my $lineNum( 1..$#allFileLines ){
	my $curLine = $allFileLines[ $lineNum ];

	if( length chomp $curLine ){
		my @curLineAttributes = split /,/, $curLine;
		# For each line(player), will be adding the following attributes
		# MPPS -- Minutes Played Per Seaseon
		#      -> ( total minutes / (48*82) )

		# OEPM -- Offensive Effiency Per Minute 
		#      -> ( (total points + 2.25 * assists + free throws made - turnovers, / total minutes) * MPPS )

		# DEPM -- Defensive Effiency Per Minute 
		#      -> ( (rebounds + 1.5 * steals + 1.25 * blocks / total minutes) * MPPS )


		# Get each value we need from appropriate index
		my $totalMinutes = $curLineAttributes[ $attributesIndex{ "Min" } ];

		my $pts = $curLineAttributes[ $attributesIndex{ "Pts" } ];
		my $assists = $curLineAttributes[ $attributesIndex{ "AST" } ];
		my $ftm = $curLineAttributes[ $attributesIndex{ "FTM" } ];
		my $turnovers = $curLineAttributes[ $attributesIndex{ "TO" } ];

		my $rebounds = $curLineAttributes[ $attributesIndex{ "REB" } ];
		my $steals = $curLineAttributes[ $attributesIndex{ "STL" } ];
		my $blocks = $curLineAttributes[ $attributesIndex{ "BLK" } ];


	}
}
