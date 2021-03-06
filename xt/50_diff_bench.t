#!perl
use v6;


my $A = ['Chrerrplzon'.comb(/<-[_]>/)];
my $B = ['Choerephon'.comb(/<-[_]>/)];

my $count = 1000;

if (1) {
  use LCS::BV;
  my $startime = time;
    for (1..$count) {
            LCS::BV::LCS($A, $B),
    };
  my $duration = time - $startime;
  my $average = $duration / $count;
  my $rate = 1 / $average;
  say 'LCS::BV avg(sec): ',$average,' rate(Hz): ',$rate;
}


if (0) {
  use Algorithm::Diff;
  my $startime = time;
    for (1..$count) {
            LCSidx($A, $B),
    };
  my $duration = time - $startime;
  my $average = $duration / $count;
  my $rate = 1 / $average;
  say 'Algorithm::Diff avg(sec): ',$average,' rate(Hz): ',$rate;
}

$A = ['ChrerrplzonChrerrplzon'.comb(/<-[_]>/)];
$B = ['ChoerephonChoerephon'.comb(/<-[_]>/)];

if (0) {
  use LCS::BV;
  my $startime = time;
    for (1..$count) {
            LCS::BV::LCS($A, $B),
    };
  my $duration = time - $startime;
  my $average = $duration / $count;
  my $rate = 1 / $average;
  say 'LCS::BV avg(sec): ',$average,' rate(Hz): ',$rate;
}


if (0) {
  use Algorithm::Diff;
  my $startime = time;
    for (1..$count) {
            LCSidx($A, $B),
    };
  my $duration = time - $startime;
  my $average = $duration / $count;
  my $rate = 1 / $average;
  say 'Algorithm::Diff avg(sec): ',$average,' rate(Hz): ',$rate;
}
