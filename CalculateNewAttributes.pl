# Greg mojonnier
use warnings;
use strict;
use Math::Round;

open my $file, "<playerStatsByTeam-1995_2005.csv" or die "The player stats file doesn't even exist!\n";
my @allFileLines = <$file>;
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

# The 1998 season had a lockout, only 50 games were played during that season
my $shortenedTotalSeasonMinutes = 48 * 50;

# For each line, calculate the new attributes,
# append them to the original line, then overwrite the old line in @allFileLines
for my $lineNum( 1..$#allFileLines ){
	my $curLine = $allFileLines[ $lineNum ];

	if( length chomp $curLine ){
		my @curLineAttributes = split /,/, $curLine;
		# For each line(player), add the following attributes
		# MPPS -- Minutes Played Per Season
		#      -> ( total minutes / totalSeasonMinutes )

		# OEPM -- Offensive Efficiency Per Minute 
		#      -> ( (total points + 2.25 * assists + free throws made - turnovers / total minutes) * MPPS )

		# DEPM -- Defensive Efficiency Per Minute 
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

		my $year = $curLineAttributes[ $attributesIndex{ "Year" } ];

		my $MPPS = Math::Round::nearest( .0001, $totalMinutes / ( $year == 1998 ? $shortenedTotalSeasonMinutes : $totalSeasonMinutes ) );
		my $OEPM = Math::Round::nearest( .0001, ( ( $pts + ( 2.25 * $assists ) + $ftm - $turnovers ) / $totalMinutes ) * $MPPS );
		my $DEPM = Math::Round::nearest( .0001, ( ( $rebounds + ( 1.5 * $steals ) + ( 1.25 * $blocks ) ) / $totalMinutes ) * $MPPS );

		$curLine .= ",".$MPPS.",".$OEPM.",".$DEPM."\n";
		$allFileLines[ $lineNum ] = $curLine;
	}
}

# Add our new attribute csv column headers to first line before writing it to the new file
chomp $allFileLines[ 0 ];
$allFileLines[ 0 ] .= ",MPPS,OEPM,DEPM\n";

open my $newFile, ">playerStatsByTeam-1995_2005-newAtts.csv";
print $newFile @allFileLines;
close $newFile;
