package Jmespath::ParsedResult;
use strict;
use warnings;
use Jmespath::TreeInterpreter;

sub new {
  my ( $class, $expression, $parsed ) = @_;
  my $self = bless {}, $class;
  $self->{expression} = $expression;
  $self->{parsed} = $parsed;
  return $self;
}

sub search {
  my ( $self, $data, $options ) = @_;
  $options = $options || undef;
  my $interpreter = Jmespath::TreeInterpreter->new($options);
  return $interpreter->visit( $self->{ parsed }, $data );
}

sub _render_dot_file {
  my ($self) = @_;
  my $renderer = Jmespath::GraphvizVisitor->new;
  my $contents = Jmespath::Renderer->visit( $self->parsed );
  return $contents;
}

# try to emulate __REPR__
sub stringify {
  shift->{parsed};
}

1;
