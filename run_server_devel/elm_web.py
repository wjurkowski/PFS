#!/usr/bin/python                                                                                   

import sys,re,os;
from urllib2 import Request;
from urllib2 import urlopen;
import socket;
import urllib;
from ClientForm import ParseResponse


def sendRequest(strFastaFile) :        
    flhFasta = file(strFastaFile);
    strFasta = flhFasta.read();
    flhFasta.close();

    title = strFasta.split('\n')[0].strip();
    name = os.path.basename(strFastaFile)[:-3];

    strUrl = "http://elm.eu.org";

    # timeout in seconds
    timeout = 200;
    socket.setdefaulttimeout(timeout);

    response = urlopen(strUrl);
    forms = ParseResponse(response, backwards_compat=False);
    form = forms[0];

    print form;

    form['sequence'] = strFasta;
    req = form.click();
    response2 = urlopen(req);
    response_html = response2.read();
    
    flhOut = file('./tmp.html', 'w');
    print >>flhOut, response_html;
    flhOut.close();

#     flhOut = file('./tmp/' + os.path.basename(strFastaFile) + '.html', 'w');
#     flhOut.write(response_html);
#     flhOut.close();
        
if __name__ == '__main__' :
    # Check $argv                                                                               
    strUsage = "Usage: %s <fastafile> <outdir>";
    if ( len(sys.argv) < len(strUsage.split('<')) ) :
        print strUsage % os.path.basename(sys.argv[0]);
        sys.exit(1);

    fasta = sys.argv[1];
    outdir = sys.argv[2].rstrip('/');
    
    sendRequest(fasta);

