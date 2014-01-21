#!/usr/bin/perl -w

# $ARGV[0] $pairs is the list of chain pairs
# $AARGV[1] $dir is the directory for native pdb files(seperated by chain IDs)

use strict;
use warnings;
use lib './Modules';
use flying_mouse;
use Parallel::ForkManager;

my $run_dir=$ARGV[0];#run dir
my $cut_off=$ARGV[1];#cut-off value for whysci
my $range=$ARGV[2];#range for interface defination
my $MAX_THREAD=$ARGV[3];
my @directorys;
my @names;
my $date;
my $native_R;
my $native_L;
my @submit;
my @predicted_filenames;
my @temp;
my @whysky_first;
my @whysky_second;

#program starting time
	chomp($date = `date`);
	print "program for $ARGV[0] started at time $date\n";

#result place
	`mkdir $ARGV[0]\_whysci`;

#to the working directory
	chdir "$ARGV[0]"or die "can not change dir to $ARGV[0]:$!";

#read in the file names
	@directorys=`ls`;
	chop @directorys;

for (my $i=0;$i<scalar(@directorys);$i++){
	if($directorys[$i]=~/DP\_(.+?)-(.+)/){
		$names[$i][0]=$1;#Receptor name
		$names[$i][1]=$2;#ligand name
	}
}
#foreach single run of the pairs
for (my $j=0;$j<scalar(@directorys);$j++){
		chdir"$directorys[$j]"or die "can not change to $directorys[$j] : $!";
		#get the model file
		$native_R=get_pdb("pdb$names[$j][0]\_m.pdb");
		$native_L=get_pdb("pdb$names[$j][1]\_m.pdb");
		#get the chain IDs
			open TEMP,">$names[$j][0]\-$names[$j][1]"or die;
			print TEMP "$names[$j][0]\-$names[$j][1]\n";
			close TEMP;
			
		   @submit=read_names("$names[$j][0]\-$names[$j][1]");
			`rm $names[$j][0]\-$names[$j][1]`;
			
		#run whysci
		@whysky_first=whyscy($native_R,$submit[0][0],$submit[0][1],$cut_off);
		@whysky_second=whyscy($native_L,$submit[1][0],$submit[1][1],$cut_off);		
		#next set if got error here
		if($whysky_first[0]=~/error/){chdir "../"or die"hell:$!"; next;}
		if($whysky_second[0]=~/error/){chdir "../"or die"hell:$!"; next;}
		#get the file names
			@predicted_filenames=get_file("file_name");
			chomp @predicted_filenames;
			
			open OUT,">../../$ARGV[0]\_whysci/$names[$j][0]\-$names[$j][1]"or die "hell:$!";
		#get the result
			my $pm = new Parallel::ForkManager($MAX_THREAD);
			
			#my @pdb_one=get_file("pdb$names[$j][0]\_m.pdb");
			for(my $i=0;$i<scalar(@predicted_filenames);$i++){
				my $pid = $pm->start and next;
				#my @pdb_two=get_file("$predicted_filenames[$i]");
				#my @pdb=(@pdb_one,@pdb_two);
				my @interface=cmapper_interface($range,"pdb$names[$j][0]\_m.pdb",$predicted_filenames[$i]);
				my $whysky_first=scalar(@whysky_first);
				my $whysky_second=scalar(@whysky_second);
				my $interface=scalar(@interface);
				my @result=percent($whysky_first,$whysky_second,$interface,\@whysky_first,\@whysky_second,\@interface);
				printf OUT "%s\t%2.2f\t%2.2f\n",$predicted_filenames[$i],$result[0],$result[1];
				print "$i\n";
				$pm->finish; # Terminates the child process

			}
			close OUT;
		chdir"../"or die"$!";
}

#program ending time
	chomp($date = `date`);
	print "program for $ARGV[0] ended at time $date\n";



