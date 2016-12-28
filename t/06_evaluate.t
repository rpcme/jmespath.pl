#!/usr/bin/env perl

use Jmespath;
use Test::More;

cmp_ok(
  Jmespath->evaluate('a', { a => 42 }),
  '==',
  42
);

cmp_ok(
  Jmespath->evaluate('a', { a => "value" }),
  'eq',
  'value'
);

is_deeply(
  Jmespath->evaluate('a', { a => [1,2] }),
  [1,2]
);

is_deeply(
  Jmespath->evaluate('a', { a => { nested => 'hash' } }),
  { nested => 'hash' }
);
