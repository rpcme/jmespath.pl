package Jmespath;
#require Exporter;
use Jmespath::Parser;
use Jmespath::Visitor;
use JSON qw(encode_json decode_json);
use Try::Tiny;
use v5.14;
our $VERSION = '0.01';
#our $EXPORT = qw(compile search);
our $VERBOSE = 0;
use utf8;

sub compile {
  my ( $class, $expression ) = @_;
  print __PACKAGE__ . ' ' . __LINE__ . " compile $expression\n" if $Jmespath::VERBOSE;
  try {
    return Jmespath::Parser->new->parse( $expression );
  } catch {
    say $_->stringify;
    exit(1)
  };
}

sub search {
  my ( $class, $expression, $data, $options ) = @_;
  my ($result);
  try {
    $result = Jmespath::Parser->new->parse( $expression )
      ->search( JSON->new->allow_nonref->utf8->decode( $data ), $options );
  } catch {
    $_->throw;
  };

  return 'null' if not defined $result;

  # JSON block result
  if ( ( ref ($result) eq 'HASH'  ) or
       ( ref ($result) eq 'ARRAY' ) ) {
    try {
      $result = JSON->new->utf8->allow_nonref->space_after->encode( $result );
      return $result;
    } catch {
      Jmespath::ValueException->new( message => "cannat encode" )->throw;
    };
  }
  
  # Numeric result
  if ( $result =~ /[0-9]+/ ) {
    return $result;
  }
  
  # Unquoted string result
  if ( defined $ENV{JP_UNQUOTED} and $ENV{JP_UNQUOTED} ne '0' ) {
    return $result;
  }

  return $result if $result eq 'false' or $result eq 'true';

  # Quoted string result
  return q{"} . $result . q{"};
}

1;

__END__

=head1 NAME

Jmespath - Enabling easy querying for JSON structures.
