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

is ref($coords->compact), 'Mojo::Collection', 'break the link';
is ref($coords->flatten), 'Mojo::Collection', 'break the link';
is ref($coords->map(sub { 1 })), 'Mojo::Collection', 'break the link';
is ref($coords->reverse), 'Mojo::Collection', 'break the link';
is ref($coords->shuffle), 'Mojo::Collection', 'break the link';
is ref($coords->slice), 'Mojo::Collection', 'break the link';
is ref($coords->sort), 'Mojo::Collection', 'break the link';

#
# alternate types of values
#
$coords = c()->with_roles('+Attributes');
$coords->c_attr(id => 0 => sub { 'alpha' });
$coords->c_attr(start => 1 => 2e6);
$coords->c_attr(end => 2 => undef);

is $coords->id,    'alpha', 'alpha';
is $coords->id('beta')->id, 'beta', 'beta now';
is $coords->start, 2e6, 'like 2000000';
is $coords->start(3e6)->start, 3e6, 'nearer to 3000000';
is $coords->end,   undef, 'not defined';
is $coords->end(4e6)->end, 4e6, '1 million more';


#
# Edge cases
#
eval {
  $coords->c_attr('>>this one<<' => 7);
};
like $@, qr/Attribute.*invalid/, 'match';

eval {
  $coords->c_attr('try' => 7 => []);
};
like $@, qr/Default has to be a code reference or constant/, 'match';


require Mojo::Collection::Role::Attributes;
my $result;
$result = Mojo::Collection::Role::Attributes->c_attr();
is $result, undef, 'nothing';

$result = Mojo::Collection::Role::Attributes->c_attr([qw{one two three}]);
is $result, undef, 'right kind of nothing';

$result = (bless [], 'Mojo::Collection::Role::Attributes')->c_attr();
is $result, undef, 'nothing';

$result = (bless [], 'Mojo::Collection::Role::Attributes')->c_attr('one');
is $result, undef, 'more of the right kind of nothing';


done_testing;
