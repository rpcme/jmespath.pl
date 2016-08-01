package Jmespath::Exceptions::IncompleteExpressionError;

sub new {
  my ($class, $expression) = @_;
  my $self = bless {}, $class;
  $self->{ expression } = $expression;
  $self->{ lex_position } = length $expression;
  $self->{ token_type } = undef;
  $self->{ token_value } = undef;
  return $self;
}

sub to_string {
  my ( $self ) = @_;
  my $underline = ' ' * ( $self->{ lex_position } + 1 ) + '^';
  return "Invalid jmespath expression: Incomplete expression:\n" .
    '"' . $self->{expression} . '"' . "\n" . $underline;
}

1;
