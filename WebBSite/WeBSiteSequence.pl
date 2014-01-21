#!/usr/bin/perl
use strict;
use LWP;
use URI;
use LWP::Simple;

my $browser = LWP::UserAgent->new;

if ($#ARGV != 2) {die "Program requires parameters! [method] [delay] [fasta] \
available methods:
	1	ELM
	2	Consurf (not working yet)
\n";}
  
my $method = $ARGV[0];
my $delay = $ARGV[1];


#open(INP,"<$list") or die "can't open ", $list;
#@files=<INP>;
#close(INP);
my $file = "lista";
open(OUT,">$file") or die "can't open ", $file;


if($method == 1){
#ELM
	my $URL = "elm.eu.org/cgimodel.py";
	my $seqf=$ARGV[2];
	open(SEQ,"<$seqf");
	my @seki=<SEQ>;
	my $sequence="@seki";
	#my $sequence='DPNSCVDNATVCSGASCVVPESNFNNILSVVLSTVLTILLALVMFSMGCNVEIKKFLGHIKRPWGICVGFLCQFGIMP';
	
	use URI;
	use chilkat;
  	my $url = URI->new('http://elm.eu.org/cgimodel.py');

	$url->query_form(
         'sequence' => $sequence,
	 'userSpecies' => '9606',
	 'userCC' => '1',
         'fun' => 'Submit',
        );
	my $response = $browser->get($url);

        die "$URL error: ", $response->status_line
        unless $response->is_success;
	#print $response->content;

  	unless( $response->content =~ m{.+userId=(.+)r=1.+}) {
		print "dupa $1\n";
		#print $response->content;
    		die "Couldn't find the match-string in the response\n";
	}

	my $wynurl="http://elm.eu.org/cgimodel.py?fun=smartResult&userId=".$1."&r=1&bg=on";
	print "$wynurl\n";
	sleep $delay;
	getprint($wynurl);
}


elsif($method == 2){
#ConSurf
	my $URL = "";
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


