package Regexp::Parser::Katana;
use 5.010001;
use strict;
use warnings;
use Regexp::Lexer;
use Regexp::Lexer::TokenType;

use parent qw(Exporter);
our @EXPORT_OK = qw(parse);

our $VERSION = '0.01';

sub parse {
    my ($re) = @_;

    my $tokens_obj = Regexp::Lexer::tokenize($re);
    return parse_tokens($tokens_obj);
}

sub parse_tokens {
    my ($tokens_obj) = @_;

    my $tokens = $tokens_obj->{tokens};
    my $num_of_tokens = scalar @$tokens;

    my @ast;

    my $lpnum = 0;

    my $capture_group_num     = 0;
    my $non_capture_group_num = 0;

    my $next_token;

    my @subtrees;

    for (my $i = 0; my $token = $tokens->[$i]; $i++) {
        my $token_type_id = $token->{type}->{id};
        if ($token_type_id == Regexp::Lexer::TokenType::LeftParenthesis->{id}) {
            $lpnum++;

            $next_token = $tokens->[$i+1];
            if (!defined $next_token) {
                die 'invalid syntax!'; # TODO
            }

            # check should capture or not
            if ($next_token->{type}->{id} eq Regexp::Lexer::TokenType::Question->{id}) {
                # now: (?
                $next_token = $tokens->[$i+2];

                if (defined $next_token) {
                    if ($next_token->{type}->{id} == Regexp::Lexer::TokenType::Colon->{id}) {
                        # now: (?:
                        push @subtrees, [
                            undef,
                            ++$non_capture_group_num,
                        ];
                        $i += 2;
                        next;
                    }
                }
                else {
                    die 'invalid syntax!'; # TODO
                }
            }

            push @subtrees, [
                ++$capture_group_num,
                undef,
            ];

            next;
        }

        if ($token_type_id == Regexp::Lexer::TokenType::RightParenthesis->{id}) {
            my $subtree = pop @subtrees;

            if (!defined $subtree) {
                die 'invalid syntax!'; # TODO
            }

            $lpnum--;

            if (my $last_subtree = $subtrees[-1]) {
                push @$last_subtree, $subtree;
            }
            else {
                push @ast, $subtree;
            }

            next;
        }

        if ($token_type_id == Regexp::Lexer::TokenType::LeftBracket->{id}) {
            my @character_set_tokens;

            $i++;

            # Negate
            # TODO Now is NOP, must be property of something
            if ($tokens->[$i]->{type}->{id} == Regexp::Lexer::TokenType::Cap->{id}) {
                $i++;
            }

            for (; $token = $tokens->[$i]; $i++) {
                if ($token->{type}->{id} == Regexp::Lexer::TokenType::RightBracket->{id}) {
                    last;
                }

                # Check range notation or not
                # TODO support \x{xxx} and etc...
                $next_token = $tokens->[$i+1];
                if ($next_token->{type}->{id} == Regexp::Lexer::TokenType::Minus->{id}) {
                    my $character_set = $token->{char};
                    $character_set .= $next_token->{char};

                    $next_token = $tokens->[$i+2];
                    if (!defined $next_token) {
                        die 'invalid syntax!'; # TODO
                    }

                    if ($next_token->{type}->{id} != Regexp::Lexer::TokenType::RightBracket->{id}) {
                        $character_set .= $next_token->{char};

                        push @character_set_tokens, {
                            char => $character_set,
                            type => Regexp::Lexer::TokenType::Character,
                            is_character_set_range => 1,
                        };

                        $i += 2;

                        next;
                    }
                }

                push @character_set_tokens, {
                    char => $token->{char},
                    type => Regexp::Lexer::TokenType::Character,
                };
            }

            $token = \@character_set_tokens;
        }

        # Filter out `index` from token object
        if (ref $token eq 'HASH') {
            delete $token->{index};
        }

        if (my $last_subtree = $subtrees[-1]) {
            if (ref $last_subtree->[-1] ne 'ARRAY') {
                push @$last_subtree, [[]]; # XXX ?
            }

            push @{$last_subtree->[-1]->[-1]}, $token;
        }
        else {
            push @ast, $token;
        }
    }

    if ($lpnum != 0) {
        die 'invalid syntax!'; # TODO
    }

    return \@ast;
}

1;
__END__

=encoding utf-8

=head1 NAME

Regexp::Parser::Katana - It's new $module

=head1 SYNOPSIS

    use Regexp::Parser::Katana;

=head1 DESCRIPTION

Regexp::Parser::Katana is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

