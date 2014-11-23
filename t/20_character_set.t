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
        {
            capture_group => [1],
            non_capture_group => [],
            token => [{
                char => "(",
                type => Regexp::Lexer::TokenType::LeftParenthesis,
            }],
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
            capture_group => [1],
            non_capture_group => [],
            token => [{
                char => ")",
                type => Regexp::Lexer::TokenType::RightParenthesis,
            }],
        },
    ];
};

done_testing;

