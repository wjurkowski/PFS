#!/usr/bin/perl -w
#parametry programu:[reference file] [sumo list]

# Program parses sumo text output file with multiple solution for given target. Each solution is separated with the dashed line followed by description and predicted residues in separate lines.
# sumo list - list of sumo output txt files
# reference file - each line contains tab separated columns: 1) target PDB ID 2) space separated expected bs residues  


if ($#ARGV != 1) {die "Program uzywany z parametrami!\
	[plik referencyjny] [lista plikow sumo]\n";}

open(INPUT1, "< $ARGV[0]") or die "Can’t open input file: $!";
open(INPUT2, "< $ARGV[1]") or die "Can’t open input file: $!";

my @lisumo=<INPUT2>;
my @refer=<INPUT1>;
close (INPUT1);
close (INPUT2);
chomp @lisumo;

	$pn=0;
foreach $line (@refer) { #reads expected bs residues
	$pn++; #counts protein number
	$i=0;
	while ($line =~/(\s+\d+)/g) {
		$i++;
		$nowy=$1;
		$nowy=~ s/\s+//g;	
		$reftrg[$pn][$i]=$nowy;	#reference (expected) residue numbers
 	}

	if ($line =~/^\w{4}/){
		$refname[$pn]=substr ($line,0,6);	#pdb id and chain id 	
	}
}


foreach $fname (@lisumo) {	#sumo output file list
print "$fname\n";
open(INPUT3, "< $fname") or die "Can’t open input file: $!";
my @sumo=<INPUT3>;
close (INPUT3);
my (@sumtrg);
my $tpdbid=substr($sumo[1],0,4);
my $tn=0;
my $nline=0;
foreach $linia (@sumo) {#iterate sumo output files from the list
	$nline++;
	if($linia =~/-{4,}/){	#zero counter for each found template
	 $tn++;	#increment template number
#print "$tn\n";
	 $j=0; #bs residue counter
	 $nline=0;	
	}	

	if($nline >2 and $nline <6) {	#save pdbid of template protein
		 if(substr($linia,0,5)=~/^\w{4}\:/){
		 $suresn[$tn]=substr($linia,0,4);
		 }
	}

	if($nline>10){	#get predicted bs residues
	if(length $linia >40){
#$kuku=substr($linia,30,5);
#print "$kuku\n";
	 if (substr ($linia,29,6) =~ /(\s\d+\s{1})/){
		$tchid=substr($linia,35,1);	
#print "$tchid\n";
#print "$linia\n";
	 	$j++;
	 	$sumtrg[$tn][$j]=substr($linia,30,4);
	 }
	}		
	}
}
my $sprot=$tpdbid."_".$tchid;

#compares reference (expected) bs residues with predictions
for $k (1..$#reftrg){	#iterate targets list
 if($sprot eq $refname[$k]){	#if reference target is same as sumo target in question
#print "$sprot $refname[$k]\n";
 open(OUTPUT, "> $refname[$k]"."-bs_pred.txt") or die "Can’t open output file: $!";	
 for $m(1..$tn){
 	my (@unique_hits);
	$hit=0;
	$chit=0;
RESZTA: for $l(1..$#{$reftrg[$k]}){ #iterate reference residues
		for $n(1..$#{$sumtrg[$m]}){	#counts all matched residues in solution found based on a given template
		  if($reftrg[$k][$l]==$sumtrg[$m][$n]){
	  		$chit++;	#count all hits		
	  	  }	
		}

	 	for $n(1..$#{$sumtrg[$m]}){	#counts if for given solution is at least one match of reference residue
	  		if($reftrg[$k][$l]==$sumtrg[$m][$n]){
				$hit++;	#count of unique predicted bs residues
				push(@unique_hits,$sumtrg[$m][$n]);
				next RESZTA;
	  		} 
	 	}
  	}
	$diff=$chit-$hit; #number of redundant hits
	$bsn=$#{$sumtrg[$m]}-$diff; #all unique (good and bad) predictions 
	#$proc=$hit/$bsn;	#ratio of unique TP
	#$rproc=$chit/$#{$sumtrg[$m]};	#ratio of all TP
	$TP=$hit;	#number of correctly matched unique residues
	$FP=$bsn-$hit;	#remaining predicted (nmatched)	
	$FN=$#{$reftrg[$k]}-$hit;	#number of not predicted (number of expected - number predicted)
	$rank=$m; #number of sumo solution
#print "$refname[$k],$m,$hit,$#{$sumtrg[$m]},$proc\n";
	printf OUTPUT "$refname[$k]\t$rank\t$suresn[$m]\t$TP\t$FP\t$FN\t";
	foreach my $res(@unique_hits){
		printf OUTPUT "$res\t";
	}
	printf OUTPUT "\n";
 }
	
 }	
 close (OUTPUT);
}


}
