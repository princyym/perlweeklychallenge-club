#!/usr/local/bin/perl

use strict;

use warnings;
use feature qw(say);
use Test::More;
use Benchmark qw(cmpthese timethis);
use Data::Dumper qw(Dumper);

my @TESTS = (
  [ [1..3], 3 ],
  [ [2..4], 2 ],
  [ [1..7], 42 ],
  [ [1..15], 420 ],
  [ ['1'..'9','10'..'15'], 420 ],
  [ [1..31], 3720 ],
  [ [5,10,15], 15 ],
  [ [15,16], 0 ],
  [ ['15','16'], 0 ],
  [ [2..4,2..4], 2 ], ## Check uniquification...
                      ## Should fail of bsu & bit_sum_splat_unique
                      ## For last 3 tests
);

is( bit_sum(              @{$_->[0]} ), $_->[1] ) for @TESTS; say'';
is( bit_sum_compact(      @{$_->[0]} ), $_->[1] ) for @TESTS; say'';
is( bit_sum_splat(        @{$_->[0]} ), $_->[1] ) for @TESTS; say'';
is( bsm(                  @{$_->[0]} ), $_->[1] ) for @TESTS; say'';
is( bit_sum_splat_unique( @{$_->[0]} ), $_->[1] ) for @TESTS; say'';
is( bsu(                  @{$_->[0]} ), $_->[1] ) for @TESTS; say'';
done_testing();

cmpthese( 5e4, {
  'bs'  => sub { bit_sum(        @{$_->[0]}) for @TESTS; },
  'bsc' => sub { bit_sum_compact(@{$_->[0]}) for @TESTS; },
  'bss' => sub { bit_sum_splat(  @{$_->[0]}) for @TESTS; },
  'bsm' => sub { bsm(            @{$_->[0]}) for @TESTS; },
});
## Test 15 & 18 will fail as they rely on the list being unique and
## in the 3rd test case it isn't.....

sub bit_sum {
  my $t = 0;                     ## Initialize sum

  my %hash = map { $_ => 1 } @_; ## quick uniquification - if worried
  @_ = map {$_+0} keys %hash;    ## that there may be duplicates and
                                 ## question talks of unique pairs...
                                 ## We need to convert these back
                                 ## to int's otherwise bitwise &
                                 ## will work on strings....

  while(@_>1) {                  ## Loop through array until we have
                                 ## no pairs left
    my $a = shift;               ## we shift off the value;
    $t+= $a&$_ for @_;           ## and and it with all remaining
                                 ## elements for each element in list
  }
  $t;                            ## Return sum
}

sub bit_sum_compact {
  my $t = 0, my %h = map { $_ => 1 } @_;
  @_ = map{0+$_}keys %h;
  while(@_>1) { my $a = shift; $t+= $a&$_ for @_ }
  $t
}


##########----------##########----------##########----------##########----------##########----------
sub bit_sum_splat{for($a=0,(%^H=map{$_,1}@_),(@_=map{$_+0}keys%^H);@_;){$b=shift;$a+=$b&$_ for@_};$a}
#sub bsm{$a=0;%^H=map{$_,1}@_;@_=keys%^H;$b=0+pop,map{$a+=$b&$_}@_ while@_;$a}
#sub bsm{$a=0;%^H=map{$_,1}@_;@_=keys%^H;while(@_){$b=0+pop;$a+=$b&$_ for@_};$a}
sub bsm{my$a=0;my%t=map{$_,1}@_;@_=keys%t;while(@_){my$b=0+pop;$a+=$b&$_ for@_};$a}
sub bit_sum_splat_unique{@_=map{$_+0}@_;for($a=0;@_;){$b=shift;$a+=$b&$_ for@_};$a}
sub bsu{$a=0;$b=pop,map{$a+=$b&$_}@_ while@_;$a}

#### Re-written as perl 1-liners
##########----------##########----------##########----------##########----------##########----------
## BSM  # perl -E '$a=0;%t=map{$_,1}@ARGV;@t=keys%t;$b=0+pop@t,map{$a+=$b&$_}@t while@t;say$a'  ##84 chars
## BSU  # perl -E '$a=0;$b=pop,map{$a+=$b&$_}@ARGV while@ARGV;say$a'                            ##58 chars

