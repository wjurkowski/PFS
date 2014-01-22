use strict;
  use warnings;
  use LWP 5.64;
  my $browser = LWP::UserAgent->new;
  
  my $word = 'tarragon';
  
  my $url = 'http://www.altavista.com/';
  my $response = $browser->post( $url,
    [ 'q' => $word,  # the Altavista query string
      #'pg' => 'q', 'avkw' => 'tgz', 'kl' => 'XX',
    ]
  );
  die "$url error: ", $response->status_line
   unless $response->is_success;

  if( $response->decoded_content =~ m{AltaVista found ([0-9,]+) results} ) {
    # The substring will be like "AltaVista found 2,345 results"
   print "$word: $1\n";
   }
   else {
   print "Couldn't find the match-string in the response\n";
      }
