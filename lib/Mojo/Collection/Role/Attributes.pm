package Mojo::Collection::Role::Attributes;

use Carp qw{croak};
use Mojo::Base -role;
use Mojo::Collection;
use Sub::Util;

our $VERSION = '0.02';

requires 'new';

foreach my $func (qw(compact flatten map reverse shuffle slice sort)) {
  my $sub = Mojo::Collection->can($func)
    || croak "Function Mojo::Collection::$func not found";
  no strict 'refs'; ## no critic (NoStrict)
  *$func = Sub::Util::set_subname __PACKAGE__ . "::$func", sub {
    return Mojo::Collection->new(shift->each)->$sub(@_);
  };
}

sub c_attr {
  my ($self, $attrs, $i, $value) = @_;
  return unless ((my $class = ref $self || $self) && $attrs);
  $i ||= 0;

  Carp::croak 'Default has to be a code reference or constant value'
    if ref $value && ref $value ne 'CODE';

  for my $attr (@{ref $attrs eq 'ARRAY' ? $attrs : [$attrs]}) {
    Carp::croak qq{Attribute "$attr" invalid}
      unless $attr =~ /^[a-zA-Z_]\w*$/xs;
    my $index = $i;
    if (ref $value) {
      my $sub = sub {
        return
          exists $_[0][$index]
          ? $_[0][$index]
          : ($_[0][$index] = $value->($_[0]))
          if @_ == 1;
        $_[0][$index] = $_[1];
        $_[0];
      };
      Mojo::Util::monkey_patch($class, $attr, $sub);
    }
    elsif (defined $value) {
      my $sub = sub {
        return exists $_[0][$index] ? $_[0][$index] : ($_[0][$index] = $value)
          if @_ == 1;
        $_[0][$index] = $_[1];
        $_[0];
      };
      Mojo::Util::monkey_patch($class, $attr, $sub);
    }
    else {
      Mojo::Util::monkey_patch($class, $attr,
        sub { return $_[0][$index] if @_ == 1; $_[0][$index] = $_[1]; $_[0] });
    }
    $i++;
  }
  return;
}

sub import {
  my ($class, $caller) = (shift, caller);
  Mojo::Util::monkey_patch($caller, c_has => sub { c_attr($caller, @_) });
  return;
}

1;

__END__

=pod

=head1 NAME

Mojo::Collection::Role::Attributes - Add accessors to a L<Mojo::Collection>

=begin html

<!-- Travis CI -->
<a href="https://travis-ci.org/kiwiroy/mojo-collection-role-attributes">
  <img src="https://travis-ci.org/kiwiroy/mojo-collection-role-attributes.svg?branch=master"
       alt="Build Status"/>
</a>

<!-- Coveralls -->
<a href="https://coveralls.io/github/kiwiroy/mojo-collection-role-attributes?branch=master">
  <img src="https://coveralls.io/repos/github/kiwiroy/mojo-collection-role-attributes/badge.svg?branch=master"
       alt="Coverage Status" />
</a>

<!-- Kritika -->
<a href="https://kritika.io/users/kiwiroy/repos/4848001605520575/heads/master/">
  <img src="https://kritika.io/users/kiwiroy/repos/4848001605520575/heads/master/status.svg"
       alt="Kritika Analysis Status" />
</a>

=end html

=head1 DESCRIPTION

A L<role|Role::Tiny> to add L<accessors|/"c_attr"> to a L<Mojo::Collection>.

=over 4

=item This is B<experimental>.

=item This is just named accessors for array elements

=item This could be done with C<use constant> defining indices on any collection.

=item The chaining is nice side effect.

=back

=head1 SYNOPSIS

Class attributes

  package ArrayWithAttributes;
  use Mojo::Base qw{Mojo::Collection};
  use Role::Tiny::With;
  with 'Mojo::Collection::Role::Attributes';

  __PACKAGE__->c_attr(id    => 0 => sub { join "", map { ("a".."z")[rand(26)] } 0 .. 26 });
  __PACKAGE__->c_attr(start => 1 => sub { 1 });
  __PACKAGE__->c_attr(end   => 2 => sub { 1e6 });

Or import

  package ArrayWithAttributes;
  use Mojo::Base qw{Mojo::Collection};
  use Mojo::Collection::Role::Attributes;

  c_has id    => 0 => sub { join "", map { ("a".."z")[rand(26)] } 0 .. 26 };
  c_has [qw{start end}], 1;

Per instance attributes

  use Mojo::Collection 'c';

  my $coords = c('foo', 20, 300)->with_roles('+Attributes');
  $coords->c_attr(id => 0);
  $coords->c_attr(start => 1);
  $coords->c_attr(end => 2);

  # foo-bar
  say $coords->id('foo-bar')->id();

=head1 IMPORTS

=head2 c_has

Like L<has|Mojo::Base/"has"> from L<Mojo::Base> and delegates to L</"c_attr">.

=head1 METHODS

=head2 c_attr

  # add accessor to class
  __PACKAGE__->c_attr('attribute' => 0 => sub { rand(100); });
  # add accessor to instance
  $instance->c_attr(name => 1);

Link an attribute to an index of a L<Mojo::Collection>.

=head1 Mojo::Collection METHODS

The following L<Mojo::Collection> methods are reimplemented here to demote the
role blessed object to a L<Mojo::Collection>. This is because they are likely to
have altered the array positions to change the meanings of the indicies used in
the L</"c_attr"> call.

=head2 compact

See L<Mojo::Collection/"compact">.

=head2 flatten

See L<Mojo::Collection/"flatten">.

=head2 map

See L<Mojo::Collection/"map">.

=head2 reverse

See L<Mojo::Collection/"reverse">.

=head2 shuffle

See L<Mojo::Collection/"shuffle">.

=head2 slice

See L<Mojo::Collection/"slice">.

=head2 sort

See L<Mojo::Collection/"sort">.

=cut
