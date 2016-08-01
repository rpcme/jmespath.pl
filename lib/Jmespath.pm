package Jmespath;
require Exporter;
use Jmespath::Parser;
use Jmespath::Visitor;
use Try::Tiny;

our $VERSION = '0.01';
our $EXPORT = qw(compile search );
our $VERBOSE = 0;

sub compile {
  my ( $class, $expression ) = @_;
  print __PACKAGE__ . ' ' . __LINE__ . " compile $expression\n" if $Jmespath::VERBOSE;
  try {
    return Jmespath::Parser->new->parse( $expression );
  } catch {
    print "caught exception\n";
    $_->throw;
  };
}

sub search {
  my ( $class, $expression, $data, $options ) = @_;
  return Jmespath::Parser->new->parse( $expression )
                              ->search( $data, $options );
}

1;

__END__

=head1 NAME

Jmespath - Enabling easy querying for JSON structures.
