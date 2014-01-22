#!/usr/bin/perl -w
# seraph.pl - search for Codex Seraphinianus on abebooks
 
use strict;
my $out_file = "result_seraph.html";  # where to save it
 
use LWP;
my $browser = LWP::UserAgent->new;
my $response = $browser->post(
  'http://www.abebooks.com',
   # That's the URL that the real form submits to.
  [
    "ph" => "2",
    "an" => "",
    "tn" => "Codex Seraphinianus",
    "pn" => "",
    "sn" => "",
    "gpnm" => "All Book Stores",
    "cty" => "All Countries",
    "bi" => "Any Binding",
    "prl" => "",
    "prh" => "",
    "sortby" => "0",
    "ds" => "100",
    "bu" => "Start Search",
  ]
);
 
die "Error: ", $response->status_line, "\n"
 unless $response->is_success;
 
open(OUT, ">$out_file") || die "Can't write-open $out_file: $!";
binmode(OUT);
print OUT $response->content;
close(OUT);
print "Bytes saved: ", -s $out_file, " in $out_file\n";
