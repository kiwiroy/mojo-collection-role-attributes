use Mojo::Base -strict;
use Test::More;
use Mojo::Collection 'c';

my $coords = c('foo', 20, 300)->with_roles('+Attributes');
$coords->c_attr(id => 0);
$coords->c_attr(start => 1);
$coords->c_attr(end => 2);

is $coords->id('bar')->start(3e6)->end(4e6), $coords, 'chaining';

is $coords->id, 'bar', 'id set';
is $coords->start, 3e6, 'start set';
is $coords->end, 4e6, 'end set';

is ref($coords->flatten), 'Mojo::Collection', 'break the link';
is ref($coords->reverse), 'Mojo::Collection', 'break the link';
is ref($coords->shuffle), 'Mojo::Collection', 'break the link';
is ref($coords->sort), 'Mojo::Collection', 'break the link';

done_testing;
