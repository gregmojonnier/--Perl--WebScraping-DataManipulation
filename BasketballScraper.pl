# Greg Mojonnier
# This program scrapes all of each NBA team's player's statistics for the 1995-96 to 2004-05 season from databasebasketball
# and writes it all to a csv file
use warnings;
use strict;
use WWW::Mechanize;
use HTML::TableExtract;
use Text::Unaccent::PurePerl;

# HTML::TableExtract takes column headers to identify tables
# Table column headers for table listing all NBA team's abbreviations for a year
my @abreviationsTableHeaderID = qw(Team OEFF PPG);
# Table column headers for all player stats for a team
my @playerStatsTableHeaderID = qw(Name G Min Pts PPG FGM FGA FGP FTM FTA FTP 3PM 3PA 3PP REB RPG AST APG STL BLK TO);

# Open file we are going to write player stats to
open(my $playerStatsFile, ">playerStatsByTeam-1995_2005.csv");

# Open file we will write team season/playoff records to
open(my $teamRecordsFile, ">teamRecords-1995_2005.csv");

# At top print what all different columns represent for each file, we are adding year and team
print $playerStatsFile "Year,Team," . join( ",", @playerStatsTableHeaderID )."\n";
print $teamRecordsFile "Year,Team,Swins,Slosses,Pwins,Plosses\n";

for my $yearToGet( 1995..2004 ){

  # From URL below we will grab all the team abbreviations for specified year.( A few teams changed names within this time frame )
	my $teamAbreviationsURL = "http://www.databasebasketball.com/leagues/leagueyear.htm?lg=N&yr=$yearToGet";

	my $htmlContent = getUrlContent( $teamAbreviationsURL );
	my $teamAbrevsTable = getTableObject(\@abreviationsTableHeaderID, $htmlContent);

	# From the Table object record all team abbreviations
	my @allTeamAbreviations;
	for( $teamAbrevsTable->rows() ){
		push @allTeamAbreviations, @$_[0];
	}

	@allTeamAbreviations = sort @allTeamAbreviations;

	for( @allTeamAbreviations ){
		my $teamToGet = $_;
		my $teamPlayerStatsURL = "http://www.databasebasketball.com/teams/teamyear.htm?tm=$teamToGet&lg=n&yr=$yearToGet";
		$htmlContent = getUrlContent( $teamPlayerStatsURL );

		my $seasonWins = 0;
		my $seasonLosses = 0;
		my $playoffWins = 0;
		my $playoffLosses = 0;

		# Seach HTML content using regex for season wins/losses and playoff wins/losses
		# The records are consistently in the same area of text on each page
		if( $htmlContent =~ m/(\d+)\s*-\s*(\d+).*pythagorean.*/ ){
			( $seasonWins, $seasonLosses ) = ($1, $2);
		}

		if( $htmlContent =~ m/\(\s*playoffs:(\d+)\s*-\s*(\d+)\s*\)/ ){
			( $playoffWins, $playoffLosses ) = ($1, $2);
		}
		print $teamRecordsFile "$yearToGet,$teamToGet,$seasonWins,$seasonLosses,$playoffWins,$playoffLosses\n";

		# Create table object from the html which makes grabbing tables worth of data easy
		my $playerStatsTableObj = getTableObject(\@playerStatsTableHeaderID, $htmlContent);

		# Add our year,team before player stats row and print to file
		# Need to unaccent string, spaces in the player names sometimes have accents
		for ( $playerStatsTableObj->rows() ){
			my $entireRow = join( ",", @$_ );
			my $unaccentedRow = unac_string( $entireRow );
			print $playerStatsFile "$yearToGet,$teamToGet,$unaccentedRow\n";
		}
	}
}
close $playerStatsFile;
close $teamRecordsFile;

# Given a URL get the html and return it
sub getUrlContent{
	my $url = shift;

	my $mechObj = WWW::Mechanize->new();
	$mechObj->get( $url );
	return $mechObj->content;
}

# Given a ref to an array which contains table headers to ID a table 
# and HTML to look in, returns table object found
sub getTableObject{
	my $tableHeadersArrayRef = shift;
	my $htmlContent = shift;

	my $et = HTML::TableExtract->new( headers => $tableHeadersArrayRef );
	$et->parse( $htmlContent );

	return $et->first_table_found();
}
