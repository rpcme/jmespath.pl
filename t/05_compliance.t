#! /usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename;
use File::Slurp qw(slurp);
use Jmespath;
use JSON;
$ENV{JP_UNQUOTED} = 1;
use Try::Tiny;

my $cdir = dirname(__FILE__) . '/compliance';
print "$cdir\n";
opendir(my $dh, $cdir) || die "can't opendir $cdir: $!";
my @files = grep { /json$/ && -f "$cdir/$_" } readdir($dh);
closedir $dh;

foreach my $file ( @files ) {
  next if $file eq 'benchmarks.json';
  my $json_data = slurp("$cdir/$file");
  my $perl_data = JSON->new->decode($json_data);
  my @parts = split /\./, $file;
  my $n = $parts[0];
  my $cn = 1;
  foreach my $block ( @$perl_data ) {
    my $text = JSON->new->allow_nonref->space_after->encode($block->{ given });
    foreach my $case ( @{ $block->{cases} } ) {
      my $comment = exists $case->{comment} ? $case->{ comment } : $case->{ expression };
      my $msg = $n . ' case ' . $cn . ' : ' . $comment;

      my $expr   = sq(JSON->new->allow_nonref->space_after->encode($case->{expression}));
      $expr = eval("\"$expr\"");
      my $expect = sq(JSON->new->allow_nonref->space_after->encode($case->{result}));
      my $r;
      try {
        my $r = Jmespath->search($expr, $text);
        is $r, $expect, $msg;
      } catch {
      };
      $cn++;
    }
  }
}


sub sq {
  my $string = shift;
  $string =~ s/^"|"$//g;
  return $string;
}

sub load_json {
}

sub test {
}

done_testing();
