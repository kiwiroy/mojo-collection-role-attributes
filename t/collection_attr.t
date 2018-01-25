## no critic (MultiplePackages, RequireFilenameMatchesPackage)
package Coordinates;

use Mojo::Base qw{Mojo::Collection};
use Mojo::Collection::Role::Attributes;

c_has [qw{id start end}], 0;

1;

package Coordinates::Subclass;

use Mojo::Base qw{Coordinates};
use Mojo::Collection::Role::Attributes;

c_has [qw{ori}], 3;

1;

package CoordinatePair;

use Mojo::Base qw{Mojo::Collection};
use Role::Tiny::With;
with 'Mojo::Collection::Role::Attributes';

__PACKAGE__->c_attr(object    => 0 => sub { 2e6 });
__PACKAGE__->c_attr(component => 1 => sub { 4e6 });

1;

package main;
use Mojo::Base -strict;
use Test::More;

#
# Coordinates
#
my $coords = new_ok('Coordinates');

can_ok $coords, qw{id start end};

is $coords->id('save')->start(1)->end(2000), $coords, 'chaining';
is $coords->id, 'save', 'id set';
is $coords->start, 1, 'start set';
is $coords->end, 2000, 'end set';

#
# Coordinates::Subclass
#
$coords = new_ok('Coordinates::Subclass');

can_ok $coords, qw{ori};

is $coords->id('save')->start(1)->end(2000)->ori('+'), $coords, 'chaining';

#
# CoordinatePair
#
$coords = new_ok('CoordinatePair');

can_ok $coords, qw{object component};

is $coords->object, 2e6, 'default';
is $coords->component, 4e6, 'default';

done_testing;
