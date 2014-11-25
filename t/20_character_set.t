use strict;
use warnings;
use utf8;
use Regexp::Lexer::TokenType;
use Regexp::Parser::Katana qw(parse);

use Test::More;
use Test::Deep;

subtest 'basic character set' => sub {
    my $ast = parse(qr{[abc][0-9a-z]});

    cmp_deeply $ast, [
        [
            {
                char => 'a',
                type => Regexp::Lexer::TokenType::Character,
            },
            {
                char => 'b',
                type => Regexp::Lexer::TokenType::Character,
            },
            {
                char => 'c',
                type => Regexp::Lexer::TokenType::Character,
            }
        ],
        [
            {
                char => '0-9',
                type => Regexp::Lexer::TokenType::Character,
                is_character_set => 1,
            },
            {
                char => 'a-z',
                type => Regexp::Lexer::TokenType::Character,
                is_character_set => 1,
            },
        ]
    ]
};

subtest 'paren in character set' => sub {
    my $ast = parse(qr{([(].[)])});
    cmp_deeply $ast, [
        [
            1,
            undef,
            [
                [
                    [
                        {
                            char => "(",
                            type => Regexp::Lexer::TokenType::LeftParenthesis,
                        },
                    ],
                    {
                        char => ".",
                        type => Regexp::Lexer::TokenType::MatchAny,
                    },
                    [
                        {
                            char => ")",
                            type => Regexp::Lexer::TokenType::RightParenthesis,
                        },
                    ],
                ],
            ],
        ],
    ];
};

done_testing;

