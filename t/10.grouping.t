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
            char => "x",
            type => Regexp::Lexer::TokenType::Character,
        },
        [
            1,
            undef,
            [
                [
                    {
                        char => ".",
                        type => Regexp::Lexer::TokenType::MatchAny,
                    },
                ],
            ],
        ],
        [
            2,
            undef,
            [
                3,
                undef,
                [
                    [
                        {
                            char => ".",
                            type => Regexp::Lexer::TokenType::MatchAny,
                        },
                    ],
                ],
            ],
            [
                undef,
                1,
                [
                    [
                        {
                            char => ".",
                            type => Regexp::Lexer::TokenType::MatchAny,
                        },
                    ]
                ],
            ],
        ],
        [
            undef,
            2,
            [
                4,
                undef,
                [
                    [
                        {
                            char => ".",
                            type => Regexp::Lexer::TokenType::MatchAny,
                        },
                    ],
                ],
            ],
            [
                undef,
                3,
                [
                    [
                        {
                            char => ".",
                            type => Regexp::Lexer::TokenType::MatchAny,
                        },
                    ],
                ],
            ],
        ],
        {
            char => "x",
            type => Regexp::Lexer::TokenType::Character,
        },
    ];
};

done_testing;

