#! /usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Try::Tiny;

use Jmespath::ParseException;

my $pe = Jmespath::ParseException->new( message => 'Yikes!',
                                        expression => 'Foo.Bar',
                                        lex_position => '3',
                                        token_type => 'dot',
                                        token_value => '.' );

print $pe->to_string;

use Data::Dumper;
my $e = eval {
print Jmespath::ParseException->throw( message => 'Yikes!',
                                 expression => 'Foo.Bar',
                                 lex_position => '3',
                                 token_type => 'dot',
                                 token_value => '.' )->to_string;
};

print Dumper $@->to_string;


try {
  Jmespath::ParseException->throw( message => 'Yikes!',
                                 expression => 'Foo.Bar',
                                 lex_position => '3',
                                 token_type => 'dot',
                                 token_value => '.' );
} catch {
  print Dumper $@;
};



done_testing();
