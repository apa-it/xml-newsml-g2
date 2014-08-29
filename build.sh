#!/bin/sh

set -e

. /appl/sw/perl-default/env.rc

# how $WORKSPACE is set
# http://hudson.cs.apa.at/env-vars.html/?
JENKINSPERLINC="$WORKSPACE/crs/src/perllib"

# build the project with libray path
perl -I "$JENKINSPERLINC" Build.PL
./Build
# ./Build install # don't
prove -I "$JENKINSPERLINC" -mr --timer --formatter=TAP::Formatter::JUnit -b t > test_results.xml
