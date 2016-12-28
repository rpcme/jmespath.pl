#!/usr/bin/env perl

use Jmespath;
use Test::More;

package MooseObject;
  use Moose;
  has an_attribute => (is => 'ro');
  has an_attribute_with_default => (is => 'ro', default => 'default_value');
  has an_attribute_with_lazy_default => (is => 'ro', lazy => 1,default => sub { 'lazy_default_value' });

  sub a_method {
    return 'method_result';
  }

package main;

{
  # Find an object in the datastructure 
  my $result = Jmespath->evaluate('a', { a => MooseObject->new(an_attribute => 42) });
  isa_ok($result, 'MooseObject');
  cmp_ok($result->an_attribute, '==', 42);
}

cmp_ok(
  Jmespath->evaluate('a.an_attribute', { a => MooseObject->new(an_attribute => 42) }),
  '==',
  42
);

cmp_ok(
  Jmespath->evaluate('a.an_attribute_with_default', { a => MooseObject->new }),
  'eq',
  'default_value'
);

cmp_ok(
  Jmespath->evaluate('a.an_attribute_with_lazy_default', { a => MooseObject->new }),
  'eq',
  'lazy_default_value'
);

cmp_ok(
  Jmespath->evaluate('a.a_method', { a => MooseObject->new }),
  'eq',
  'method_result'
);

done_testing;
