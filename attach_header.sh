#!/bin/bash -x

# This assumes the freebase turtle dump has been split into
# small chunks: "fb-aaa", "fb-aab", "fb-aac", ...
# using the Unix 'split' command.  So the prefixes need to be attached
# to each fragment.

for frag in fb-???
do
    cp freebase_prefixes.ttl ${frag}.ttl
    fix_triples.pl < ${frag} >> ${frag}.ttl
done
