#! /usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Try::Tiny;
use Jmespath::Lexer;

isa_ok my $lexer = Jmespath::Lexer->new, 'Jmespath::Lexer';

#is_deeply $lexer->tokenize(''), [], 'test_empty_string';

is_deeply $lexer->tokenize('foo'),
  [ { type => 'unquoted_identifier', value => 'foo', start => 0, end => 3, },
    { type => 'eof',                 value => '',    start => 3, end => 3 }, ],
  'test_field';

is_deeply $lexer->tokenize('24'),
  [ { type => 'number', value => 24, start => 0, end => 2 },
    { type => 'eof',    value => '', start => 2, end => 2 }, ],
  'test_number';

is_deeply $lexer->tokenize('-24'),
  [ { type => 'number', value => -24, start => 0, end => 3 },
    { type => 'eof',    value => '',  start => 3, end => 3 }, ],
  'test_negative_number';

is_deeply $lexer->tokenize('"foobar"'),
  [ { type => 'quoted_identifier', value => 'foobar', start => 0, end => 8 },
    { type => 'eof',               value => '',       start => 8, end => 8 }, ],
  'test_quoted_identifier';

is_deeply $lexer->tokenize('"\u2713"'),
  [ { type => 'quoted_identifier', value => "\x{2713}", start => 0, end => 8 },
    { type => 'eof',               value => '',         start => 8, end => 8 }, ],
  'test_json_escaped_value';

is_deeply $lexer->tokenize('foo.bar.baz'),
  [ { type => 'unquoted_identifier', value => 'foo', start => 0,  end => 3  },
    { type => 'dot',                 value => '.'  , start => 4,  end => 4  },
    { type => 'unquoted_identifier', value => 'bar', start => 4,  end => 7  },
    { type => 'dot',                 value => '.'  , start => 8,  end => 8  },
    { type => 'unquoted_identifier', value => 'baz', start => 9,  end => 11 },
    { type => 'eof',                 value => '',    start => 11, end => 11 },
  ], 'test_number_expressions';

is_deeply $lexer->tokenize('foo.bar[*].baz | a || b'),
  [ { type => 'unquoted_identifier', value => 'foo'},
    { type => 'dot',                 value => '.'},
    { type => 'unquoted_identifier', value => 'bar'},
    { type => 'lbracket',            value => '['},
    { type => 'star', value => '*'},
    { type => 'rbracket', value => ']'},
    { type => 'dot', value => '.'},
    { type => 'unquoted_identifier', value => 'baz'},
    { type => 'pipe', value => '|'},
    { type => 'unquoted_identifier', value => 'a'},
    { type => 'or', value => '||'},
    { type => 'unquoted_identifier', value => 'b'},
  ], 'test_space_separated';

is_deeply $lexer->tokenize('`[0, 1]`'),
  [ { type => 'literal', value => [0, 1] },
  ], 'test_literal';

is_deeply $lexer->tokenize('`foobar`'),
  [ {type => 'literal', value => "foobar"},
  ], 'test_literal_string';

is_deeply $lexer->tokenize('`2`'),
  [ { type => 'literal', value => 2,  start => 0, end => 3 },
    { type => 'eof',     value => '', start => 3, end => 3 }, ],
  'test_literal_number';

#        with self.assertRaises(LexerError):
is_deeply $lexer->tokenize('`foo"bar`'),
  [ { type => 'literal', value => 'foo"bar', start => 0, end => 9 },
    { type => 'eof',     value => '',    start => 9, end => 9 }, ],
  'test_literal_with_invalid_json';

is $lexer->tokenize('``'),
  [ { type => 'literal', value => ''}
  ], 'test_literal_with_empty_string';

is $lexer->tokenize('foo'),
  [ { type => 'unquoted_identifier', value => 'foo', start => 0, end => 3},
    { type => 'eof', value => '', start => 3, end => 3}
  ], 'test_position_information';


is $lexer->tokenize('foo.bar'),
  [ { type => 'unquoted_identifier', value => 'foo', start => 0, end => 3},
    { type => 'dot', value => '.', star => 3, end => 4 },
    { type => 'unquoted_identifier', value => 'bar', start => 4, end => 7},
    { type => 'eof', value => '', start => 7, end => 7},
  ], 'test_position_multiple_tokens';

is $lexer->tokenize('`{{}`'),
  [ { type => 'literal', value => '{{}', start => 0, end => 4},
    { type => 'eof', value => '', start => 5, end => 5}
  ], 'test_adds_quotes_when_invalid_json';

try {
  $lexer->tokenize('foo[0^]');
  fail('test_unknown_charater');
} catch {
  isa_ok $_, 'Jmespath::Exceptions::LexerError', 'test_unknown_charater';
};

try {
  $lexer->tokenize('^foo[0]');
  fail('test_bad_first_character');
} catch {
  isa_ok $_, 'Jmespath::Exceptions::LexerError', 'test_bad_first_character';
};

try {
  $lexer->tokenize('foo-bar');
  fail('test_unknown_character_with_identifier');
} catch {
  isa_ok $_, 'Jmespath::Exceptions::LexerError',
    'test_unknown_character_with_identifier';
};


done_testing();

