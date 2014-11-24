use strict;
use warnings;
use utf8;
use Regexp::Lexer::TokenType;
use Regexp::Parser::Katana qw(parse);

use Test::More;
use Test::Deep;

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

