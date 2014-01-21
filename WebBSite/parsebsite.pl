#!/usr/bin/perl
use strict;

my $metapocket=$ARGV[0];
my $pockets=substr($metapocket,0,rindex($metapocket,".")).".out";
open (HTML, "<$metapocket") or die "can't open ", $metapocket;
my @tresc=<HTML>;
chomp @tresc;

my $nums=0;
my %bsajt;
foreach my $line(@tresc){
	if($line=~m/^Binding/){
		$nums++;
	}
	if($nums>0){
	if($line=~m{^ATOM\s+\d+\s+\S+\s+([A-Z]{3})\s+(\d+)}){
		my $res=$1.$2;
		unless(exists $bsajt{$res}){
		$bsajt{$res}=$nums;
		} 
	}
	}
}

open (OUT, ">$pockets") or die "can't open ", $pockets;

for (my $v=1;$v<=$nums;$v++){
	print OUT "$v\t";
	foreach my $key (keys %bsajt){
		if($bsajt{$key}==$v){
        	print OUT "$key\t";
		}
	}
	print OUT "\n";	
}
close(OUT);
