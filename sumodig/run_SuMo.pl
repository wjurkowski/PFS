#!/usr/bin/perl -w
#
use strict;
use warnings;
#
if ($#ARGV != 1) {die "Program used with parameters [protein list] [ligand ID]\n";}

my @targets=open_file($ARGV[0]);
my $lig=$ARGV[1];

print "{\n";
print "  title = \"Query 1\"\;\n";

for(my $i=0;$i<$#targets+1;$i++){
	my $line=$targets[$i];
	my @pdb=split("_",$line);
	my $pdbid=$pdb[0];
	my $chid=$pdb[1];

print "  {\n";
print "    subtitle = \"SuMo job $pdbid \";\n";
print "    scan = {\n";
print "      database = \"ligands\";\n";
print "      pdb_id = \"$pdbid\";\n";
print "      selection = \"Pdb_chain \\\"$chid\\\"\";\n";
print "      subset = { \"$lig\"\n";
print "      } /subset;\n";
print "      tags = {\n"; 
print "      } /tags\n";
print "    } /scan;\n";
print "  } /;\n";
print "\n";
}

print "}\n";
sub open_file{
        my ($file_name)=@_;
        open(INP1, "< $file_name") or die "Can not open an input file: $!";
        my @file1=<INP1>;
        close (INP1);
        chomp @file1;
        return @file1;
}

