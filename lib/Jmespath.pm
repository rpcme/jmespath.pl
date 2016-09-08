package Jmespath;
#require Exporter;
use Jmespath::Parser;
use Jmespath::Visitor;
use JSON qw(encode_json decode_json);
use Try::Tiny;

our $VERSION = '0.01';
#our $EXPORT = qw(compile search);
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
  my $result = Jmespath::Parser->new->parse( $expression )
    ->search( JSON->new->allow_nonref->decode( $data ), $options );

  # JSON block result
  if ( ref $result eq 'HASH' or
       ref $result eq 'ARRAY' ) {
    return JSON->new->allow_nonref->encode( $result ); }

  # Numeric result
  if ( $result =~ /[0-9]+/ ) {
    return $result;
  }
  
  # Unquoted string result
  if ( defined $ENV{JP_UNQUOTED} and $ENV{JP_UNQUOTED} ne '0' ) {
    return $result;
  }

  # Quoted string result
  return q{"} . $result . q{"};
}

1;

__END__

=head1 NAME

Jmespath - Enabling easy querying for JSON structures.
