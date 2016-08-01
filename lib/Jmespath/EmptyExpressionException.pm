package Jmespath::EmptyExpressionError;
use Moose;
with 'Throwable';
extends 'Jmespath::JMESPathException';

no Moose;
