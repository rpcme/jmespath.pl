#! /usr/bin/env perl
use Test::More;
use Jmespath::Functions;
use Try::Tiny;
use JSON qw(decode_json);
use v5.12;

my ($v);
# jp_abs
# def: number abs(number $value)
#
# Returns the absolute value of the provided argument. The signature
# indicates that a number is returned, and that the input argument
# $value must resolve to a number, otherwise a invalid-type error is
# triggered.

is jp_abs(1), 1, 'jp_abs 1';
is jp_abs(-1), 1, 'jp_abs 2';

try {
  is jp_abs('s'), undef;
} catch {
  isa_ok $_, 'Jmespath::ValueException', 'jp_abs string';
};

# jp_avg
# def: number avg(array[number] $elements)

$v = decode_json('["10", "15", "20"]');
is jp_avg($v), '15', 'jp_avg 1';

$v = decode_json('["10", false, "20"]');
is_exception ( sub { jp_avg($v) },
               undef, 'Jmespath::ValueException', 'jp_avg false in mixed array');

$v = decode_json('[false]');

try {
  is jp_avg($v), undef;
  fail('jp_avg on boolean evaled ok');
} catch {
  isa_ok $_, 'Jmespath::ValueException';
};

$v = 'false';

try {
  is jp_avg($v), undef;
  fail('jp_avg ran with bareword boolean');
} catch {
  isa_ok $_, 'Jmespath::ValueException';
};

# jp_contains
# def: boolean contains(array|string $subject, any $search)
#
# Returns true if the given $subject contains the provided $search
# string.
#
# If $subject is an array, this function returns true if one of the
# elements in the array is equal to the provided $search value.
#
# If the provided $subject is a string, this function returns true if
# the string contains the provided $search argument.

is jp_contains('foobar', 'foo'), 'true',
  'jp_contains: foo in foobar?';
is jp_contains('foobar', 'not'), 'false',
  'jp_contains: not ! in foobar?';
is jp_contains('foobar', 'bar'), 'true',
  'jp_contains: bar in foobar?';

try {
  is jp_contains('false', 'bar'), undef;
  fail('jp_contains params cannot have bool value');
} catch {
  isa_ok $_, 'Jmespath::ValueException', 'bool string in subject';
};

is jp_contains('foobar', 123), 'false', 'jp_contains: 123 in foobar?';

$v = decode_json('["a", "b"]');
is jp_contains($v, 'a'), 'true', 'jp_contains: a in [a, b]?';

$v = decode_json('["a"]');
is jp_contains($v, 'a'), 'true', 'jp_contains: a in [a]?';

$v = '["a"]';
is jp_contains($v, 'b'), 'false', 'jp_contains: b ! in [a]?';

$v = decode_json('["foo", "bar"]');
is jp_contains($v, 'foo'), 'true', 'jp_contains: [foo,bar] <- foo?';
is jp_contains($v, 'b'), 'false', 'jp_contains: b ! in [foo, bar]?';

# jp_ceil
# def: number ceil(number $value)
#
# Returns the next highest integer value by rounding up if necessary.
is jp_ceil('1.001'), 2, 'jp_ceil: 1.001 -> 2';
is jp_ceil('1.9'), 2, 'jp_ceil: 1.9 -> 2';
is jp_ceil('1'), 1, 'jp_ceil: 1 -> 1';
is jp_ceil('abc'), 'null', 'jp_ceil: abc -> null';

# jp_ends_with
# def: boolean ends_with(string $subject, string $prefix)
#
# Returns true if the $subject ends with the $prefix, otherwise this
# function returns false.
is jp_ends_with('foobarbaz', 'baz'), 'true', 'jp_ends_with: foobarbaz ends with baz';
is jp_ends_with('foobarbaz', 'foo'), 'false', 'jp_ends_with: foobarbaz ! ends with foo';
is jp_ends_with('foobarbaz', 'z'), 'true', 'jp_ends_with: foobarbaz ends with z';

# jp_floor
# def: number floor(number $value)
#
# Returns the next lowest integer value by rounding down if necessary.
is jp_floor('1.001'), 1, 'jp_floor: 1.001 -> 1';
is jp_floor('1.9'), 1, 'jp_floor: 1.9 -> 1';
is jp_floor('1'), 1, 'jp_floor: 1 -> 1';
is jp_floor('2.1'), 2, 'jp_floor: 2.1 -> 2';

# jp_join
# def: string join(string $glue, array[string] $stringsarray)
#
# Returns all of the elements from the provided $stringsarray array
# joined together using the $glue argument as a separator between
# each.
$v = decode_json('["a", "b"]');
is jp_join(', ', $v), '"a, b"',
  'jp_join: \'["a", "b"]\' with ", " -> "a, b"';

is jp_join('', $v), '"ab"',
  'jp_join: \'["a", "b"]\' with "" -> "ab"';

$v = decode_json('["a", false, "b"]');

try {
  is jp_join(', ', $v), undef;
  fail('jp_join: bool value in arr');
} catch {
  isa_ok $_, 'Jmespath::ValueException', 'jp_join: bool value in arr';
};

$v = decode_json('[false]');
is_exception( sub { jp_join(', ', $v) },
              undef, 'Jmespath::ValueException', 'jp_join: bool value in arr');


# jp_keys
# def: array keys(object $obj)
#
# Returns an array containing the keys of the provided object. Note
# that because JSON hashes are inheritently unordered, the keys
# associated with the provided object obj are inheritently
# unordered. Implementations are not required to return keys in any
# specific order.

$v = decode_json('{"foo": "baz", "bar": "bam"}');
is_deeply jp_keys($v), ['bar', 'foo'], 'jp_keys: foo,bar are keys';

$v = decode_json('{}');
is_deeply jp_keys($v), [], 'jp_keys: [] are keys of {}';

try {
  is jp_keys('false'), undef;
  fail('jp_keys passed on boolean value');
} catch {
  isa_ok $_, 'Jmespath::ValueException';
};

try {
is_exception( sub { jp_keys('[b,a,c]') }, undef,
              'Jmespath::ValueException', 'jp_keys: not object with keys');
} catch {

};

# jp_length
# def: number length(string|array|object $subject)
#
# Returns the length of the given argument using the following types rules:
# 1. string: returns the number of code points in the string
# 2. array: returns the number of elements in the array
# 3. object: returns the number of key-value pairs in the object
is jp_length('"abc"'), 3, 'jp_length: abc len 3';
is jp_length('"current"'), 7, 'jp_length: current len 7';

try {
  is jp_length('not_there'), 0;
  fail('did not catch unquoted string');
} catch {
  isa_ok $_, 'Jmespath::ValueException', 'jp_length: not exist value (pathing)';
};

$v = decode_json('["a", "b", "c"]');
is jp_length($v), 3, 'jp_length: valid array len 3';

$v = decode_json('[]');
is jp_length($v), 0, 'jp_length: empty array len 0';

$v = decode_json('{}');
is jp_length($v), 0, 'jp_length: empty object len 0 keys';

$v = decode_json('{"foo": "bar", "baz": "bam"}');
is jp_length($v), 2, 'jp_length: obj with 2 keys';

# jp_map
# def: array[any] map(expression->any->any expr, array[any] elements)
#
# Apply the expr to every element in the elements array and return the
# array of results. An elements of length N will produce a return
# array of length N.
#
# Unlike a projection, ([*].bar), map() will include the result of
# applying the expr for every element in the elements array, even if
# the result if null.



is jp_map('&foo', '[{"foo":"a"}, {"foo": "b"}, {},[], {"foo": "f"}]'),
  '["a", "b", null, null, "f"]', 'jp_map: obj to flat array by key';

is jp_map('&[]', '[[1, 2, 3, [4]], [5, 6, 7, [8, 9]]]'),
  '[[1, 2, 3, 4], [5, 6, 7, 8, 9]]', 'jp_map: flatten array';

# jp_max
# def: number max(array[number]|array[string] $collection)
#
# Returns the highest found number in the provided array argument. An
# empty array will produce a return value of null.

$v = decode_json('[10, 15]');
is jp_max($v), '15', 'jp_max: 15 max of [10,15]';

$v = decode_json('["a", "b"]');
my $res = JSON->new->allow_nonref->encode(jp_max($v)); # need to JSON-ize
is $res, '"b"', 'jp_max: max of [a,b] is b';

$v = decode_json('["a", 2, "b"]');
is_exception( sub { jp_max($v) }, undef,
              'Jmespath::ValueException', 'jp_max: fail jp_max on char and int');

$v = decode_json('[10, false, 20]');
is_exception( sub { jp_max($v) }, undef,
              'Jmespath::ValueException', 'jp_max: fail jp_max on bool and int');

# jp_max_by
# def: max_by(array elements, expression->number|expression->string expr)
#
# Return the maximum element in an array using the expression expr as
# the comparison key. The entire maximum element is returned. Below
# are several examples using the people array (defined above) as the
# given input.

my $block = '[{"age": 50, "age_str": "50", "bool": false, "name": "d"},' .
            ' {"age": 40, "age_str": "40", "bool": false, "name": "c"},' .
            ' {"age": 30, "age_str": "30", "bool": false, "name": "b"},' .
            ' {"age": 20, "age_str": "20", "bool": false, "name": "a"}]';

is jp_max_by($block, '&age'), '{"age": 50, "age_str": "50", "bool": false, "name": "d"}',
  'jp_max_by: max of people array by number';
is jp_max_by($block, '&to_number(age_str)'), '{"age": 50, "age_str": "50", "bool": false, "name": "d"}',
  'jp_max_by: max of people array by number string w to_number';

# jp_merge
# def: object merge([object *argument, [, object $...]])
#
# Accepts 0 or more objects as arguments, and returns a single object
# with subsequent objects merged. Each subsequent object’s key/value
# pairs are added to the preceding object. This function is used to
# combine multiple objects into one. You can think of this as the
# first object being the base object, and each subsequent argument
# being overrides that are applied to the base object.

# jp_min
# def: number min(array[number]|array[string] $collection)
#
# Returns the lowest found number in the provided $collection
# argument.

# jp_min_by
# def: min_by(array elements, expression->number|expression->string expr)
#
# Return the minimum element in an array using the expression expr as
# the comparison key. The entire maximum element is returned. Below
# are several examples using the people array (defined above) as the
# given input.

# jp_not_null
# def: any not_null([any $argument [, any $...]])
#
# Returns the first argument that does not resolve to null. This
# function accepts one or more arguments, and will evaluate them in
# order until a non null argument is encounted. If all arguments
# values resolve to null, then a value of null is returned.

# jp_reverse
# def: reverse(string|array $argument)
#
# Reverses the order of the $argument.

# jp_sort
# def: array sort(array[number]|array[string] $list)
#
# This function accepts an array $list argument and returns the sorted
# elements of the $list as an array.
#
# The array must be a list of strings or numbers. Sorting strings is
# based on code points. Locale is not taken into account.

# jp_sort_by
# def: sort_by(array elements, expression->number|expression->string expr)
#
# Sort an array using an expression expr as the sort key. For each
# element in the array of elements, the expr expression is applied and
# the resulting value is used as the key used when sorting the
# elements.
#
# If the result of evaluating the expr against the current array
# element results in type other than a number or a string, a type
# error will occur.
#
# Below are several examples using the people array (defined above) as
# the given input. sort_by follows the same sorting logic as the sort
# function.

# jp_starts_with
# def: boolean starts_with(string $subject, string $prefix)
#
# Returns true if the $subject starts with the $prefix, otherwise this
# function returns false.

# jp_sum
# def: number sum(array[number] $collection)
#
# Returns the sum of the provided array argument. An empty array will
# produce a return value of 0.

# jp_to_array
# def: array to_array(any $arg)
#
# - array - Returns the passed in value.
#
# - number/string/object/boolean - Returns a one element array
# containing the passed in argument.

# jp_to_string
# def: string to_string(any $arg)
#
# string - Returns the passed in value.
#
# number/array/object/boolean - The JSON encoded value of the
# object. The JSON encoder should emit the encoded JSON value without
# adding any additional new lines.

# jp_to_number
# def: number to_number(any $arg)
#
# string - Returns the parsed number. Any string that conforms to the json-number production is supported. Note that the floating number support will be implementation specific, but implementations should support at least IEEE 754-2008 binary64 (double precision) numbers, as this is generally available and widely used.
#
# number - Returns the passed in value. array - null
#
# object - null
#
# boolean - null
#
# null - null

# jp_type
# def: string type(array|object|string|number|boolean|null $subject)
#
# Returns the JavaScript type of the given $subject argument as a
# string value. The return value MUST be one of the following:
#
# number string boolean array object null

# jp_values
# def: array values(object $obj)
#
# Returns the values of the provided object. Note that because JSON hashes are inheritently unordered, the values associated with the provided object obj are inheritently unordered. Implementations are not required to return values in any specific order. For example, given the input:
#
# {"a": "first", "b": "second", "c": "third"}
#
# The expression values(@) could have any of these return values:
#    ["first", "second", "third"]
#    ["first", "third", "second"]
#    ["second", "first", "third"]
#    ["second", "third", "first"]
#    ["third", "first", "second"]
#    ["third", "second", "first"]
#
# If you would like a specific order, consider using the sort or
# sort_by functions.

  is jp_values('{"foo": "baz", "bar": "bam"}'), '{"baz", "bam"}', 'jp_values: simple';



done_testing();

sub is_exception {
  my ( $call, $result, $exception, $msg ) = @_;
  try {
    is &$call, $result, $msg;
  } catch {
    isa_ok $_, $exception, 'Exception of ' . $msg;
  };
}

