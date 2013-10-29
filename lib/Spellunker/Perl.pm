package Spellunker::Perl;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Spellunker;
use PPI;

use Mouse;

has spellunker => (
    is => 'ro',
    default => sub { Spellunker->new() },
    handles => [qw(add_stopwords load_dictionary)],
);

has ppi => (
    is => 'ro',
    isa => 'PPI::Document',
    required => 1,
);

no Mouse;

sub new_from_file {
    my ($class, $filename) = @_;

    my $ppi = PPI::Document->new($filename);
    return $class->new(ppi => $ppi);
}

sub new_from_string {
    my ($class, $string) = @_;
    my $ppi = PPI::Document->new(\$string);
    return $class->new(ppi => $ppi);
}

# TEST:
# the real defaults are dfined in the parser

# tokens: [$line_number, $content]
sub _check_parser {
    my ($self, $token, $method) = @_;

    my @err = $self->{spellunker}->check_line($token->$method);
    if (@err) {
        return ([$token->line_number, $token->$method, \@err]);
    }
    return ();
}

sub check_comment {
    my ($self) = @_;

    my $comments = $self->ppi->find( sub { $_[1]->isa('PPI::Token::Comment') } );
    return map { $self->_check_parser($_, 'content') } @$comments;
}

sub check_sub_name {
    my ($self) = @_;

    my $comments = $self->ppi->find( sub { $_[1]->isa('PPI::Statement::Sub') } );
    return map { $self->_check_parser($_, 'name') } @$comments;
}

# TEST:
sub agument { }

# TEST:
# template agument

1;

