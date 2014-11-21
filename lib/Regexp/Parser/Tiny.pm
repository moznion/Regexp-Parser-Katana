package Regexp::Parser::Tiny;
use 5.008001;
use strict;
use warnings;
use Regexp::Lexer;
use Regexp::Lexer::TokenType;

use parent qw(Exporter);
our @EXPORT_OK = qw(parse);

our $VERSION = '0.01';

my $CAPTURE     = 1;
my $NON_CAPTURE = 2;

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

    my @capture_history;
    my $capture_group_num     = 0;
    my $non_capture_group_num = 0;

    my %capture_group;
    my %non_capture_group;

    my $next_token;
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
                        $non_capture_group{++$non_capture_group_num} = 1;
                        push @capture_history, {
                            type  => $NON_CAPTURE,
                            index => $non_capture_group_num,
                        };
                        $i += 2;
                        next;
                    }
                }
                else {
                    die 'invalid syntax!'; # TODO
                }
            }

            $capture_group{++$capture_group_num} = 1;
            push @capture_history, {
                type  => $CAPTURE,
                index => $capture_group_num,
            };
            next;
        }

        if ($token_type_id == Regexp::Lexer::TokenType::RightParenthesis->{id}) {
            my $current_capture = pop @capture_history;

            if (!defined $current_capture) {
                die 'invalid syntax!'; # TODO
            }

            my $current_capture_index = $current_capture->{index};
            my $current_capture_type  = $current_capture->{type};
            if ($current_capture_type == $CAPTURE) {
                delete $capture_group{$current_capture_index};
            }
            elsif ($current_capture_type == $NON_CAPTURE) {
                delete $non_capture_group{$current_capture_index};
            }
            else {
                # fail safe
                die 'invalid syntax!'; # TODO
            }

            $lpnum--;

            next;
        }

        push @ast, {
            token             => $token,
            capture_group     => [sort {$a <=> $b} keys %capture_group],
            non_capture_group => [sort {$a <=> $b} keys %non_capture_group],
        };
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

Regexp::Parser::Tiny - It's new $module

=head1 SYNOPSIS

    use Regexp::Parser::Tiny;

=head1 DESCRIPTION

Regexp::Parser::Tiny is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

