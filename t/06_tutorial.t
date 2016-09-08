#! /usr/bin/env perl
use Test::More;
use Jmespath;
use Try::Tiny;
use JSON qw(decode_json);
use v5.12;
$| = 1;

# Test all the examples on the tutorials page at
# http://jmespath.org/tutorial.html

my ($r, $text);

$r = Jmespath->search('a', '{"a": "foo", "b": "bar", "c": "baz"}');
is $r, '"foo"', 'T1';

$r = Jmespath->search('a.b.c.d', '{"a": {"b": {"c": {"d": "value"}}}}');
is $r, '"value"', 'T2';

$r = Jmespath->search('[1]', '["a", "b", "c", "d", "e", "f"]');
is $r, '"b"', 'T3';

$text = <<TEXT;
{"a": {
  "b": {
    "c": [
      {"d": [0, [1, 2]]},
      {"d": [3, 4]}
    ]
  }
}}
TEXT

$r = Jmespath->search('a.b.c[0].d[1][0]', $text);
is $r, 1, 'T4';

$r = Jmespath->search('[0:5]', '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]');
is $r, '[0,1,2,3,4]', 'T5';

$r = Jmespath->search('[5:10]', '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]');
is $r, '[5,6,7,8,9]', 'T6';

$r = Jmespath->search('[:5]', '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]');
is $r, '[0,1,2,3,4]', 'T7';

$r = Jmespath->search('[::2]', '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]');
is $r, '[0,2,4,6,8]', 'T8';

$r = Jmespath->search('[::-1]', '[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]');
is $r, '[9,8,7,6,5,4,3,2,1,0]', 'T9';

$text = <<TEXT;
{
  "people": [
    {"first": "James", "last": "d"},
    {"first": "Jacob", "last": "e"},
    {"first": "Jayden", "last": "f"},
    {"missing": "different"}
  ],
  "foo": {"bar": "baz"}
}
TEXT

$r = Jmespath->search('people[*].first', $text);
is $r, '["James","Jacob","Jayden"]', 'T10';

$r = Jmespath->search('people[:2].first', $text);
is $r, '["James","Jacob"]', 'T11';

$text = <<TEXT;
{
  "ops": {
    "functionA": {"numArgs": 2},
    "functionB": {"numArgs": 3},
    "functionC": {"variadic": true}
  }
}
TEXT

# Object Projection
$r = Jmespath->search('ops.*.numArgs', $text);
is $r, '[2,3]', 'T12';

# Flatten Projection
$text = <<TEXT;
{
  "reservations": [
    {
      "instances": [
        {"state": "running"},
        {"state": "stopped"}
      ]
    },
    {
      "instances": [
        {"state": "terminated"},
        {"state": "running"}
      ]
    }
  ]
}
TEXT

$r = Jmespath->search('reservations[*].instances[*].state', $text);
is $r, '[["running","stopped"],["terminated","running"]]', 'T13';

$text = <<TEXT;
[
  [0, 1],
  2,
  [3],
  4,
  [5, [6, 7]]
]
TEXT

$r = Jmespath->search('[]', $text);
is $r, '[0,1,2,3,4,5,[6,7]]', 'T14';

# Filter projections
$text = <<TEXT;
{
  "machines": [
    {"name": "a", "state": "running"},
    {"name": "b", "state": "stopped"},
    {"name": "b", "state": "running"}
  ]
}
TEXT

$r = Jmespath->search(q{machines[?state=='running'].name}, $text);
is $r, '["a","b"]', 'T15';

# Pipe Expressions
$text = <<TEXT;
{
  "people": [
    {"first": "James", "last": "d"},
    {"first": "Jacob", "last": "e"},
    {"first": "Jayden", "last": "f"},
    {"missing": "different"}
  ],
  "foo": {"bar": "baz"}
}
TEXT

$r = Jmespath->search('people[*].first | [0]', $text);
is $r, '"James"', 'T16';

# Multiselect
$text = <<TEXT;
{
  "people": [
    {
      "name": "a",
      "state": {"name": "up"}
    },
    {
      "name": "b",
      "state": {"name": "down"}
    },
    {
      "name": "c",
      "state": {"name": "up"}
    }
  ]
}
TEXT

# List
$r = Jmespath->search('people[].[name, state.name]', $text);
is $r, '[["a","up"],["b","down"],["c","up"]]', 'T17';

# Hash
# We have to decode_json because we can't rely on the ordering.
$r = Jmespath->search('people[].{Name: name, State: state.name}', $text);
is_deeply decode_json($r), decode_json('[{"Name":"a","State":"up"},{"Name":"b","State":"down"},{"Name":"c","State":"up"}]'), 'T18';

# Functions

$text = <<TEXT;
{
  "people": [
    {
      "name": "b",
      "age": 30,
      "state": {"name": "up"}
    },
    {
      "name": "a",
      "age": 50,
      "state": {"name": "down"}
    },
    {
      "name": "c",
      "age": 40,
      "state": {"name": "up"}
    }
  ]
}
TEXT

$r = Jmespath->search('length(people)', $text);
is $r, 3, 'T19';

$text = <<TEXT;
  {
  "people": [
    {
      "name": "b",
      "age": 30
    },
    {
      "name": "a",
      "age": 50
    },
    {
      "name": "c",
      "age": 40
    }
  ]
}
TEXT

# $r = Jmespath->search('max_by(people, &age).name', $text);
# is $r, '"a"';

done_testing();
