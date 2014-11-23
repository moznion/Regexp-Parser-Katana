use strict;
use warnings;
use utf8;
use Regexp::Lexer::TokenType;
use Regexp::Parser::Katana qw(parse);

use Test::More;
use Test::Deep;

subtest 'basic case' => sub {
    my $ast = parse(qr{x(.)((.)(?:.))(?:(.)(?:.))x});
    cmp_deeply $ast, [
        {
            capture_group => [],
            non_capture_group => [],
            token => {
                char => "x",
                type => Regexp::Lexer::TokenType::Character,
            },
        },
        {
            capture_group => [1],
            non_capture_group => [],
            token => {
                char => ".",
                type => Regexp::Lexer::TokenType::MatchAny,
            }
        },
        {
            capture_group => [2, 3],
            non_capture_group => [],
            token => {
                char => ".",
                type => Regexp::Lexer::TokenType::MatchAny,
            }
        },
        {
            capture_group => [2],
            non_capture_group => [1],
            token => {
                char => ".",
                type => Regexp::Lexer::TokenType::MatchAny,
            }
        },
        {
            capture_group => [4],
            non_capture_group => [2],
            token => {
                char => ".",
                type => Regexp::Lexer::TokenType::MatchAny,
            }
        },
        {
            capture_group => [],
            non_capture_group => [2, 3],
            token => {
                char => ".",
                type => Regexp::Lexer::TokenType::MatchAny,
            }
        },
        {
            capture_group => [],
            non_capture_group => [],
            token => {
                char => "x",
                type => Regexp::Lexer::TokenType::Character,
            },
        },
    ];
};

# TODO parens in [ ]

done_testing;

