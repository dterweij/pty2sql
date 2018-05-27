#!/usr/bin/perl -wT
# eventsource server
# read svxlink state information and distribute to MySQL
# Original by:
# Rob Janssen, PE1CHL
# Written for MySQL by:
# Danny Terweij
# may 2018
# Version 0.1

# Install DBI perl module for MySQL
# sudo apt install libdbi-perl
# sudo apt install libdbd-mysql-perl

# Run as user svxlink

# Libraries
use strict;
use Fcntl;
use Socket;
use DBI;
use IO::Handle;

# Variables
my $database 	= "svxlink";
my $hostname 	= "192.168.0.91";
my $port 	= "3306";
my $username 	= "svxlink";
my $password 	= 'hH6ft6H';
my $dsn 	= "DBI:mysql:database=$database;host=$hostname;port=$port";
my %attr 	= ( PrintError=>0,RaiseError=>1);
my $state_pty 	= "/dev/shm/repeater_info";
my ($pty,$name,$buf,$line,$event,$io,$input);
my (%parsed);
$event 		= "Voter:sql_state";
# Set a new handler for ctrl^C
$SIG{INT} 	= \&cleanup;

# Functions
sub cleanup {
    # Close all
    $io->close;
    undef $io;
    print "\nStopped.\n";
    exit(0);
}


sub parse($) {
    my ($line) = (@_);
    my (@fields,$item,$rx,$sql,$lvl,$sqlquery,$stmt);
    my $receiverscount = 0;
    my $sqlout = "";

    (@fields) = split / /,$line;

    $parsed{"time"} = shift @fields;
    $parsed{"event"} = shift @fields;

    if ($parsed{"event"} eq "Voter:sql_state") {

 	# MySQL processing
	my $dbh  = DBI->connect($dsn,$username,$password, \%attr);

	# Parser for voter squelch and siglev information
	foreach $item (@fields) {
            	$receiverscount ++;
	    	($rx,$sql,$lvl) = ($item =~ m/^(.*)([_:*])([+-]\d\d\d)$/) or next;
	    	$sql = "Closed" if ($sql eq "_");
	    	$sql = "Open" if ($sql eq ":");
	    	$sql = "Active" if ($sql eq "*");

	    	# Level correction 0 - 100 %
            	if ($lvl < 0 ) {
            		$lvl = 0;
            	}
            	if ($lvl > 100 ) {
                	$lvl = 100;
            	}

	    	# Remove plus sign
	    	$lvl = abs($lvl);

            	# MySQL data prepare
            	$sqlout .= "$rx $sql $lvl ";

		# Insert data into the table
		$sqlquery = "INSERT INTO pty(rx,sq,lv,date) VALUES(?,?,?,?)";

		$stmt = $dbh->prepare($sqlquery);

		# Execute the query
		$stmt->execute($rx, $sql, $lvl,time());

		$stmt->finish();
	}
          
	$sqlout = "${receiverscount} ${sqlout}";

	# Insert data into the table
	$sqlquery = "INSERT INTO live(data,date) VALUES(?,?)";

	$stmt = $dbh->prepare($sqlquery);

	# Execute the query
	$stmt->execute($sqlout,time());

	$stmt->finish();

	# Disconnect from the MySQL database
	$dbh->disconnect();

        # Output to screen
	print $parsed{"time"}," ";
 	print $sqlout,"\n";
    } 
    
}


# Main loop

print "Started. ( press ^C to exit )\n";

while (1) {
 
	# Open pty file 
    	while (!open($pty,$state_pty)) {
		sleep 2;
    	}

 	$io = IO::Handle->new();

    for (;;) {

	# Read data from SvxLink pty
	$io->fdopen($pty,"r");
        $buf = $io->getline;

	foreach $line (split /\n/,$buf) {
		parse($line);
		undef %parsed;
	}
	next;
    }

    # Close all
    $io->close;
    undef $io;
    print "Stopped.\n";
}

exit 0;
