#!perl

use strict;
use warnings;

use Data::Dumper;
use Test::More;

BEGIN {
    use_ok( 'Option' );
}

=pod

val name: Option[String] = request getParameter "name"
val upper = name map { _.trim } filter { _.length != 0 } map { _.toUpperCase }
println(upper getOrElse "")

=cut

sub request_param {
    my ($req, $key) = @_;
    exists $req->{ $key } ? Some( $req->{ $key } ) : None;
}

my $req = { name => 'Stevan' };

my $upper = request_param($req, 'name') # get value from hash
    ->map   (sub { $_[0] =~ s/\s$//r }) # trim any trailing whitespace
    ->filter(sub { length $_[0] != 0 }) # ignore if length == 0
    ->map   (sub { uc $_[0]          }) # uppercase it
;

is($upper->get_or_else(''), 'STEVAN', '... got the result we expected');

done_testing;