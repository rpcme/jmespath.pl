#! /usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Try::Tiny;
use Jmespath::Parser;

my $parser = Jmespath::Parser->new;
isa_ok $parser, 'Jmespath::Parser';

done_testing();
