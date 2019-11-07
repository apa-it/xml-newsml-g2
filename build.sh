#!/bin/sh

set -e

. /appl/sw/perl-default/env.rc

# how $WORKSPACE is set
# http://hudson.cs.apa.at/env-vars.html/?
JENKINSPERLINC="$WORKSPACE/crs/src/perllib"

# build the project with libray path
perl -I "$JENKINSPERLINC" Build.PL

./Build distmeta
./Build

./Build test merge=1 tap_harness_args=formatter_class=TAP::Formatter::JUnit > test_results.xml

cover -test
