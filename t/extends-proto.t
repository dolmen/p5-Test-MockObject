use 5.010;
use strict;
use warnings;

use Test::More tests => 2*3+1;
use Test::NoWarnings;
use Test::MockObject::Extends;

# RT #73556
#
# Prototypes are never checked by Perl when calling a sub as a method
# Anyway, it is possible to define prototypes on methods, so we should support
# this.
{
    package MethodsWithProto;
    sub new { bless \my $a, shift }
    sub proto_scalar ($$) { 1+$_[1] }
    sub proto_no_arg ($) { ${$_[0]}++ }
    sub proto_lvalue ($) : lvalue { ${$_[0]} }
}

my $o = MethodsWithProto->new;
$o = Test::MockObject::Extends->new($o);

# We must call the sub at least once, else the prototype check does not occurs
pass 'proto_scalar';
$o->proto_scalar(1);
$o->mock(proto_scalar => sub ($$) { pass 'Mock proto_scalar called' });
$o->proto_scalar(1);

pass 'proto_no_arg';
$o->proto_no_arg;
$o->mock(proto_no_arg => sub ($) { pass 'Mock proto_no_arg called' });
$o->proto_no_arg;

pass 'proto_lvalue';
$o->proto_lvalue = 6;
$o->mock(proto_lvalue => sub ($) : lvalue { pass 'Mock proto_lvalue called'; ${$_[0]} });
{
    local $TODO = "attributes not implemented";
    eval { $o->proto_lvalue = 5; 1 }
    or do
    {
	fail "Mock proto_lvalue called";
	diag "$@";
    }
}

