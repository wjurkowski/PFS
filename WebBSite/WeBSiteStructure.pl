#!/usr/bin/perl
use strict;
use LWP;
use URI;
use LWP::Simple;

my $browser = LWP::UserAgent->new;

if ($#ARGV != 2) {die "Program requires parameters! [method] [delay] [pdb file] \n";}
  
my $method = $ARGV[0];
my $delay = $ARGV[1];


#open(INP,"<$list") or die "can't open ", $list;
#@files=<INP>;
#close(INP);
my $file = "lista";
open(OUT,">$file") or die "can't open ", $file;

if($method == 1){
	my $pdb = $ARGV[2];
	unless (-e $pdb){
		die "File: $pdb not found\n";
	}
	my $URL = "http://metapocket.eml.org/cgi-bin/findPockets.cgi";
	my $numb = 4;
	#PDB file   ->filename 
	#How many pockets do you want?	 ->number
	#Radius of the probe to get potential binding sites:		 ->radius
	my $response = $browser->post( $URL,
	[ 'filename' => ["/home/wiktor/Projects/EDICT/WP1.4/".$pdb],
	  #'chain' => 'A',	 
	  'number' => '10',
	  'radius' => '5.0', 
	  'submit' => 'Find pockets',
	],
	'Content_Type' => 'form-data',
	);
	
	die "$URL error: ", $response->status_line
   	unless $response->is_success;

  	unless( $response->content =~ m{upload.([0-9.]+).output.html}) {
    		die "Couldn't find the match-string in the response\n";
	}

	my $wynurl="http://metapocket.eml.org/upload/".$1."/output.html";
	print OUT "$wynurl\n";
	sleep 120;	
	getprint($wynurl);
	
	`echo 1 | perl grabit.pl lista`

}

elsif($method == 2){ #SitesIdentify	problemy chyba z php!!!
	my $pdb = $ARGV[2];
	unless (-e $pdb){
		die "File: $pdb not found\n";
	}
	my $URL = "http://www.bioinf.manchester.ac.uk/sitesidentify/index.php?c=2";
	my $response = $browser->post( $URL,
	[ 'userfile' => ["/home/wiktor/Projects/EDICT/WP1.4/".$pdb],
	  'radius' => '10.0', 
	  'emailaddress' => 'jurkow@cbr.su.se',
	  'submit' => 'Submit',
	],
	'Content_Type' => 'form-data',
	);
	
	die "$URL error: ", $response->status_line
   	unless $response->is_success;

  	unless( $response->content =~ m{JobID:\s+(\w+)\s+}) {
		print $1;
    		die "Couldn't find the match-string in the response\n";
	}

	my $wynurl="http://www.bioinf.manchester.ac.uk/sitesidentify/results.php?jobid=".$1;
	sleep $delay;
	#getprint($wynurl);
}

elsif($method == 3){
#THEMATICS
	my $URL = "http://pfweb.chem.neu.edu/thematics/submit.html";
	my $sequence=$ARGV[2];
	my $response = $browser->post( $URL,
        [ 'sequence' => $sequence,
          'fun' => 'Submit',
        ],
        'Content_Type' => 'form-data',
        );

        die "$URL error: ", $response->status_line
        unless $response->is_success;

	my $wynurl="";
	sleep $delay;
	getprint($wynurl);
}

