#!/usr/bin/env perl
#
# Some changes from the original version:
# Now use uri_escape_utf8() instead of individual substitutions.
# The Freebase RDF dump used tab characters for s/p/o separation.
# Don't print out errors on each empty object, there are lots and lots
# of them.

use URI::Escape;

$line = 0 ;
while(<>)
{
    $line++ ;
    if ( /^\s*$/ )
    {
	print ;
	next ;
    }
    if ( /^\@/ )
    {
	# Directive
	print ;
	next ;
    }
    # Fixup broken lines - all of the form of raw newline at the end of a literal
    # with the next line being ".
    if ( ! /\.$/ )
    {
	$X = $_ ;
	chomp($X) ;
	$Y = <> ;
	$line++ ;
	$_=$X.$Y ;
    }

    # Parse line into subject/predicate/rest.
    if ( ! /^([^\t]+)\t([^\t]+)\t(.*)$/ )
    {
	print STDERR "ERROR: $line: Failed to parse the line\n" ;
	print STDERR $_ ;
	next ;
    }

    $subj = $1 ;
    $pred = $2 ;
    $obj = $3 ; # Remainder, to be sorted out.

    # End in DOT?
    if ( $obj !~ /\.$/ )
    {
	print STDERR "ERROR: $line: $obj\n" ;
	print STDERR $_ ;
	next ;
    }
    # Remove leading white space, DOT and newline
    chomp($obj) ;
    $obj =~ s/^\s*// ;
    $obj =~ s/\s*\.$// ;

    # No object.
    # This is seen a lot for predicate ns:common.topic.notable_for.
    if ( $obj eq '' )
    {
	    #print STDERR "ERROR: $line: Unexpected empty object\n" ;
	    #print STDERR $_ ;
    }

    next if ( $obj eq '' ) ;

    # Fixups.
    # Some prefixed names $ is used as a unicode escape (?)
    # \$ is legal in RDF 1.1/Turtle.
    # Alt: convert to %xx%xx.

    # Subject - always a prefix name
    $subj =~ s/\$/\\\$/g ;
    # Predicate - always a prefix name
    $pred =~ s/\$/\\\$/g ;

    # Object - various
    # Fix up URIs (only found in object position)
    if ( $obj =~ m/^<(.*)>$/ )
    {
	$X = $1 ;
	# There were some funny URIs in the dump that had "http:// http://" at
	# the start, so those are fixed.
	$X =~ s/http:\/\/[\s]+http:\/\//http:\/\// ;
	$X = uri_escape_utf8($X) ;
	$X =~ s/\\.//g ;
 	$obj = "<".$X.">" ;
    }
    elsif ( $obj =~ /^"/ )
    {
	# Literal
    }
    else # prefixed name
    {
	$obj =~ s/\$/\\\$/g ;
    }

    print "$subj\t$pred\t$obj .\n" ;
}
