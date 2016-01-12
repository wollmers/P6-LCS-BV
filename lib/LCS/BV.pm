use v6;
module LCS::BV:ver<0.2.0>:auth<wollmers> {

my int $width = 64;

# H. Hyyroe. A Note on Bit-Parallel Alignment Computation. In
# M. Simanek and J. Holub, editors, Stringology, pages 79-87. Department
# of Computer Science and Engineering, Faculty of Electrical
# Engineering, Czech Technical University, 2004.

#our sub bug($a, $b) is export {
our sub bug($a) is export { say $a," ",$a.elems - 1; }

our sub LCS($a, $b) is export {

  my $amin = 0;
  my $amax = $a.elems - 1;
  my $bmin = 0;
  my $bmax = $b.elems - 1;

  if (0) {
    say '$a: ',$a;
    say '$b: ',$b;
    say '$amin: ',$amin;
    say '$amax: ',$amax;
    say '$bmin: ',$bmin;
    say '$bmax: ',$bmax;
  }

  while ($amin <= $amax and $bmin <= $bmax and $a[$amin] eqv $b[$bmin]) {
    $amin++;
    $bmin++;
  }
  while ($amin <= $amax and $bmin <= $bmax and $a[$amax] eqv $b[$bmax]) {
    $amax--;
    $bmax--;
  }

  my $positions;
  my @lcs;

  if ($amax < $width ) {
    $positions{$a[$_]} +|= 1 +< ($_ % $width) for $amin..$amax;

    my uint64 $S = +^0;

    my $Vs = [];
    my uint64 ($y,$u);

    # outer loop
    for ($bmin..$bmax) -> $j {
      $y = $positions{$b[$j]} // 0;
      $u = $S +& $y;               # [Hyy04]
      $S = ($S + $u) +| ($S - $u); # [Hyy04]
      $Vs[$j] = $S;
    }

    # recover alignment
    my $i = $amax;
    my $j = $bmax;

    while ($i >= $amin && $j >= $bmin) {
      if ($Vs[$j] +& (1 +< $i)) {
        $i--;
      }
      else {
        unless ($j && +^$Vs[$j-1] +& (1 +< $i)) {
           unshift @lcs, [$i,$j];
           $i--;
        }
        $j--;
      }
    }
  }
  else {
    $positions{$a[$_]}[$_ / $width] +|= 1 +< ($_ % $width) for $amin..$amax;

    my $S;
    my $Vs = [];
    my ($y,$u,$carry);
    my $kmax = $amax / $width + 1;

    # outer loop
    for ($bmin..$bmax) -> $j {
      $carry = 0;

      loop (my $k=0; $k < $kmax; $k++ ) {
        $S = ($j) ?? $Vs[$j-1][$k] !! +^0;
        $S //= +^0;
        $y = $positions{$b[$j]}[$k] // 0;
        $u = $S +& $y;             # [Hyy04]
        $Vs[$j][$k] = $S = ($S + $u + $carry) +| ($S +& +^$y);
        $carry = (($S +& $u) +| (($S +| $u) +& +^($S + $u + $carry))) +> 63;
      }
    }

    # recover alignment
    my $i = $amax;
    my $j = $bmax;

    while ($i >= $amin & $j >= $bmin) {
      my $k = $i / $width;
      if ($Vs[$j][$k] +& (1 +< ($i % $width))) {
        $i--;
      }
      else {
        unless ($j & +^$Vs[$j-1][$k] +& (1 +< ($i % $width))) {
           unshift @lcs, [$i,$j];
           $i--;
        }
        $j--;
      }
    }
  }

  return [
    (
      map({$[$_, $_]}, (0..($bmin-1))),
      @lcs,
      map({$[++$amax, $_]}, (($bmax+1)..@($b)-1)),
    ).flat
  ];
}


}

=begin pod

=head1 NAME

LCS::BV - Bit Vector (BV) implementation of the
                 Longest Common Subsequence (LCS) Algorithm

=begin html

<a href="https://travis-ci.org/wollmers/P6-LCS-BV"><img src="https://travis-ci.org/wollmers/P6-LCS-BV.png" alt="P6-LCS-BV"></a>

=end html

=head1 SYNOPSIS

=begin code
  use LCS::BV;

  $alg = LCS::BV->new;
  @lcs = $alg->LCS(\@a,\@b);
=end code

=head1 ABSTRACT

LCS::BV implements the Longest Common Subsequence (LCS) Algorithm and should
be faster than Algorithm::Diff or Algorithm::Diff.

=head1 DESCRIPTION

=head2 CONSTRUCTOR

=over 4

=item new()

Creates a new object which maintains internal storage areas
for the LCS computation.  Use one of these per concurrent
LCS() call.

=back

=head2 METHODS

=over 4


=item LCS(\@a,\@b)

Finds a Longest Common Subsequence, taking two arrayrefs as method
arguments. It returns an array reference of corresponding
indices, which are represented by 2-element array refs.

=back

=head2 EXPORT

None by design.

=head1 SEE ALSO

Algorithm::Diff

=head1 AUTHOR

Helmut Wollmersdorfer E<lt>helmut.wollmersdorfer@gmail.comE<gt>

=begin html

<a href='http://cpants.cpanauthors.org/author/wollmers'><img src='http://cpants.cpanauthors.org/author/wollmers.png' alt='Kwalitee Score' /></a>

=end html

=end pod
