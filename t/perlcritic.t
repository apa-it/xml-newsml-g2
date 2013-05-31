#! /usr/bin/perl

use Test::More;

if (!eval {require Test::Perl::Critic}) {
    Test::More::plan(
        skip_all => "Test::Perl::Critic required for testing PBP compliance"
    );
}

Test::Perl::Critic->import(-severity => 3);

Test::Perl::Critic::all_critic_ok();
