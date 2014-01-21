#1usr/bin/perl -w

use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Response;
use URI;

my $browser=LWP::UserAgent->new;
my $list_name=$ARGV[0];
my @list;
my @names;
my $loops;
my @submit;
my $html;
my $download;
#get the  list
	open LIST, "<$list_name" or die "can not open";
	@list=<LIST>;
	chop @list;
	
	for (my $i=0;$i<scalar(@list);$i++){
		if($list[$i]=~/(.{4})\_(.{1})-(.{4})\_(.{1}).*?/){
			#die;
			$names[$i][0]=$1;#ID
			$names[$i][1]=$2;#Chain
			$names[$i][2]=$3;#ID
			$names[$i][3]=$4;#Chain
			#print "$names[$i][0]	$names[$i][1]	$names[$i][2]	$names[$i][3]\n";
		}
	}
#format the list
	$loops=scalar(@list)*2;
	#print "$loops\n";
	for(my $i=0;$i<$loops;$i=$i+2){
		my $j=$i/2;
		$submit[$i][0]="$names[$j][0]";
		$submit[$i][1]="$names[$j][1]";
		$submit[$i+1][0]="$names[$j][2]";
		$submit[$i+1][1]="$names[$j][3]";
	}
#	print "$submit[7][0]	$submit[7][1]\n";



for(my $i=0;$i<scalar(@submit);$i++){
push @{$browser->requests_redirectable}, 'POST';
my $url='http://www.nmr.chem.uu.nl/cgi-bin/whiscy_server.cgi';
my $response=$browser->post($url,[
		'PDB_file'=>'',
		'PDB_format'=>'PDBIDnumber',
		'PDB_IDnumber'=>$submit[$i][0],
		'selected_chain'=>$submit[$i][1],
		'format_alignment'=>'HSSPID',
		'alignment_file'=>'',
		'HSSP_ID'=>$submit[$i][0],
		'alignmenttype'=>'invalid',
		'use_prop'=>'on',
		'use_smooth'=>'on',
		'Submit'=>'Do your prediction!',
	],
		'Content_Type' => 'form-data',
	);

#request# GET http://nmr.chem.uu.nl/favicon.ico

#get the link
$html=$response->content;
my @temp=split(/\n/,$html);
foreach(@temp){
	if($_=~/.*?(ftp.*?$submit[$i][0]\.scores).*?/){$download=$1;}
}
#get the result;
`wget $download`;
`mv *scores* ./whyski/$submit[$i][0]_$submit[$i][1]`;
}

