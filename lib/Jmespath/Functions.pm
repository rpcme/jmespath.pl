package Jmespath::Functions;
use strict;
use warnings;
use parent 'Exporter';
use JSON;
use Try::Tiny;
use POSIX;
use Jmespath::ValueException;

our @EXPORT = qw( jp_abs
                  jp_avg
                  jp_contains
                  jp_ceil
                  jp_ends_with
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
  Jmespath::ValueException->new( message => 'Not a number' )->throw
      if $arg !~ /[0..9]/;
  return abs( $arg );
}

# @signature({'types': ['array-number']})
sub jp_avg {
  my ($values) = @_;
  return jp_sum($values) / scalar(@$values);
}


sub jp_contains {}
sub jp_ceil {}
sub jp_ends_with {}
sub jp_floor {}
sub jp_gt {
  my ($left, $right) = @_;
  return 1 if ($left > $right);
  return 0;
}

sub jp_join {}
sub jp_keys {}
sub jp_length {}
sub jp_map {}
sub jp_max {}
sub jp_max_by {}
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
  my $json = shift;
  my $data = decode_json($json);
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
