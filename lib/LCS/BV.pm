use v6;
module LCS::BV:ver<0.1.0>:auth<wollmers> {

my int $width = 64;

# H. Hyyroe. A Note on Bit-Parallel Alignment Computation. In
# M. Simanek and J. Holub, editors, Stringology, pages 79-87. Department
# of Computer Science and Engineering, Faculty of Electrical
# Engineering, Czech Technical University, 2004.

our sub LCS($a, $b) is export {

  my int ($amin, $amax, $bmin, $bmax) = (0, @($a)-1, 0, @($b)-1);

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

    while ($i >= $amin & $j >= $bmin) {
      if ($Vs[$j] +& (1 +< $i)) {
        $i--;
      }
      else {
        unless ($j & +^$Vs[$j-1] +& (1 +< $i)) {
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

