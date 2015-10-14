package Option;

use strict;
use warnings;

sub import {
    return unless $_[0] eq __PACKAGE__;

    no strict 'refs';

    my $pkg = caller;
    *{$pkg . '::Some'} = sub ($) { Option::Some->new($_[0]) };
    *{$pkg . '::None'} = sub ()  { Option::None->new        };
}

sub new { die 'Option is abstract, you want Option::Some or Option::None' }
sub get;
sub get_or_else;
sub or_else;
sub is_defined;
sub is_empty;
sub map;
sub flatmap;
sub flatten;
sub foreach;
sub forall;
sub exists;

package Option::None;

use strict;
use warnings;

our @ISA; BEGIN { @ISA = ('Option') }

sub new         { bless \(my $x) => $_[0] }
sub get         { die __PACKAGE__.'->get' }
sub get_or_else { $_[1]->() }
sub or_else     { $_[1]->() }
sub is_defined  { 0 }
sub is_empty    { 1 }
sub map         { ref($_[0])->new }
sub flatmap     { ref($_[0])->new }
sub flatten     { ref($_[0])->new }
sub filter      { ref($_[0])->new }
sub foreach     {}
sub forall      { 1 }
sub exists      { 0 }

package Option::Some;

use strict;
use warnings;

our @ISA; BEGIN { @ISA = ('Option') }

sub new         { bless \(my $x = $_[1]) => $_[0] }
sub get         { ${ $_[0] } }
sub get_or_else { ${ $_[0] } }
sub or_else     { Option::Some->new( ${ $_[0] } ) }
sub is_defined  { 1 }
sub is_empty    { 0 }
sub map         { Option::Some->new( $_[1]->( ${ $_[0] } ) ) }
sub flatmap     { $_[1]->( ${ $_[0] } ) }
sub flatten     { Option::Some->new( ${ $_[0] } ) }
sub filter      { $_[1]->( ${ $_[0] } ) ? Option::Some->new( ${ $_[0] } ) : Option::None->new }
sub foreach     { $_[1]->( ${ $_[0] } ) }
sub forall      { $_[1]->( ${ $_[0] } ) }
sub exists      { $_[1]->( ${ $_[0] } ) }

1;

__END__

=pod

=over 4

=item C<get>

  match $option {
    case None    => die 'Cannot call ->get on None'
    case Some(x) => x
  }

=item C<get_or_else( $f )>

  match $option {
    case None    => $f->()
    case Some(x) => x
  }

=item C<or_else( $f )>

  match $option {
    case None    => $f->()
    case Some(x) => Some(x)
  }

=item C<is_defined>

  match $option {
    case None    => false
    case Some(_) => true
  }

=item C<is_empty>

  match $option {
    case None    => true
    case Some(_) => false
  }

=item C<map( $f )>

  match $option {
    case None    => None
    case Some(x) => Some($f->(x))
  }

=item C<flatmap( $f )>

  match $option {
    case None    => None
    case Some(x) => $f->(x)
  }

=item C<flatten>

  match $option {
   case None    => None
   case Some(x) => x
  }

=item C<filter( $f )>

  match $option {
   case None    => None
   case Some(x) => $f->( x ) == true ? Some(x) : None
  }  

=item C<foreach( $f )>

  match $option {
    case None    => ()
    case Some(x) => $f->(x)
  }

=item C<forall( $f )>

  match $option {
    case None    => true
    case Some(x) => $f->(x)
  }


=item C<exists( $f )>

  match $option {
    case None    => false
    case Some(x) => $f->(x)
  }

=back

=cut
