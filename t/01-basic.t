use v6;
use Test;
use LCS::BV;

plan *;

is-deeply([LCS([<A B C>], [<D E F>])], [[]], 'the lcs of two sequences with nothing in common should be empty');


done-testing;
