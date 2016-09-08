package Jmespath::Functions;
use strict;
use warnings;
use parent 'Exporter';
use JSON;
use Try::Tiny;
use POSIX qw(ceil floor);
use Jmespath::ValueException;
use v5.12;

our @EXPORT = qw( jp_abs
                  jp_avg
                  jp_contains
                  jp_ceil
                  jp_ends_with
                  jp_eq
                  jp_floor
                  jp_gt
                  jp_join
                  jp_keys
                  jp_length
                  jp_map
                  jp_max
                  jp_max_by
                  jp_merge
                  jp_min
                  jp_min_by
                  jp_not_null
                  jp_reverse
                  jp_sort
                  jp_sort_by
                  jp_starts_with
                  jp_sum
                  jp_to_array
                  jp_to_string
                  jp_to_number
                  jp_type
                  jp_values );

# jp_abs
#
# Absolute value of provided value.  Throws exception if value is not
# a signed integer.
sub jp_abs {
  my ( $arg ) = @_;
  Jmespath::ValueException->throw({ message => 'Not a number: ' . $arg })
      if $arg !~ /[0-9]/g;
  return abs( $arg );
}

sub jp_avg {
  my ($values) = @_;
  Jmespath::ValueException->throw({ message => 'Required argument not array ref' })
      if ref $values ne 'ARRAY';
  
  foreach (@$values) {
    Jmespath::ValueException->throw({ message => 'Not a number: ' . $_ })
        if $_ !~ /[0-9]/g;
  }
  return jp_sum($values) / scalar(@$values);
}


sub jp_contains {
  my ( $subject, $search ) = @_;
  Jmespath::ValueException->throw({ message => 'contains() cannot be passed booleans' })
      if $subject eq 'true' or $subject eq 'false';
  if ( ref $subject eq 'ARRAY' ) {
    foreach (@$subject) {
      return 'true' if ( $_ eq $search ); #must be exact string match
    }
    return 'false';
  }
  elsif ( ref $subject eq '' ) { # straight string
    return 'true' if $subject =~ /$search/;
  }
  return 'false';
}


sub jp_ceil {
  my ($value) = @_;
  Jmespath::ValueException->throw({ message => 'ceil() requires one argument' })
      if not defined $value;
  return 'null' if $value !~ /[0-9]/g;
  return ceil($value);
}

sub jp_ends_with {
  my ( $subject, $prefix ) = @_;
  return 'true' if $subject =~ /$prefix$/;
  return 'false';
}

sub jp_eq {
  my ($left, $right) = @_;
  return 1 if $left eq $right;
  return 0;
}

sub jp_floor {
  my ($value) = @_;
  return 'null' if $value !~ /[0-9]/g;
  return floor($value);
}


sub jp_gt {
  my ($left, $right) = @_;
  return 1 if ($left > $right);
  return 0;
}

sub jp_join {
  my ( $glue, $array ) = @_;
  Jmespath::ValueException->throw({ message => 'Not an array: ' . $array })
      if ref $array ne 'ARRAY';

  foreach (@$array) {
    Jmespath::ValueException->throw({message =>'Cannot join boolean'})
      if ref $_ eq 'JSON::PP::Boolean';
  }
  return '"' . join ( $glue, @$array ) . '"';
}


sub jp_keys {
  my ( $obj ) = @_;
  Jmespath::ValueException->throw({ message => 'keys() takes single JSON object as arg' })
      if ref $obj ne 'HASH';
  my @objkeys = sort keys %$obj;
  return \@objkeys;
}

sub jp_length {
  my ( $subject ) = @_;
  my ( $length ) = 0;

  if ( ref $subject eq '' ) {    # simple scalar
    if ( substr($subject, 0, 1) ne qq/"/ or substr($subject, -1, 1) ne qq/"/ ) {
      Jmespath::ValueException->throw({ message => 'Cannot call length on unquoted string' });
    }
    $subject = substr $subject, 1, -1;       # quoted string remove quotes
    return length $subject;
  }
  elsif ( ref $subject eq 'ARRAY' ) {
    return scalar @$subject;
  }
  elsif ( ref $subject eq 'HASH' ) {
    return scalar keys %$subject;
  }

  return $length;
}

sub jp_map { }

# must be all numbers or strings in order to work
sub jp_max {
  my ( $collection ) = @_;
  return undef if scalar( @$collection ) == 0;
  my $found_type = @{$collection}[0] =~ /^[0-9]+$/ ? 'int' : 'str';
  foreach ( @$collection ) {
    Jmespath::ValueException->throw({ message => 'max(): Boolean is invalid' } )
        if ref $_ eq 'JSON::PP::Boolean';
    Jmespath::ValueException->throw({ message => 'max(): null is invalid' } )
        if not defined $_;
    my $typ = $_ =~ /^[0-9]+$/ ? 'int' : 'str';
    Jmespath::ValueException->throw({ message => 'max(): mixed int and str disallowed' })
        if $found_type ne $typ;
  }
  my @sorted = sort( @$collection );
  return pop @sorted;
}

sub jp_max_by {
  my ($array, $expref) = @_;
  my $keyfunc = _create_key_func($expref, ['number', 'string'], 'min_by');
  return jp_keyed_max($array, $keyfunc);
}

# this needs to be a comparison function based on the "type" that is
# being sorted so the correct min/max will be taken by type.

sub jp_keyed_max {}

sub _create_key_func {
  my ($expref, $allowed_types, $function_name) = @_;
  my $keyfunc = sub {
    my $result = $expref->visit($expref->expression, shift);
  };
  return $keyfunc;
}

sub jp_merge {}
sub jp_min {}
sub jp_min_by {}

#
#
sub jp_not_null {
  my @arguments = @_;
  foreach my $argument (@arguments) {
    return $argument if defined $argument;
  }
}

sub jp_reverse {
  my ( $self, $argument ) = @_;
  return reverse $argument;
}

sub jp_sort {}
sub jp_sort_by {}
sub jp_starts_with {}

sub jp_sum {
  my $data = shift;
  my $result = 0;
  foreach my $value (@$data) {
    $result += $value;
  }
  return $result;
}

sub jp_to_array {}
sub jp_to_string {}
sub jp_to_number {}
sub jp_type {}
sub jp_values {}

1;

__END__

=head1 NAME

Functions.pm : JMESPath Built-In Functions

=head1 EXPORTED FUNCTIONS


=head2 jp_map($expr, $elements)

Implements the L<JMESPath Built-In
Function|http://jmespath.org/specification.html#built-in-functions>
L<map()|http://jmespath.org/specification.html#map>

