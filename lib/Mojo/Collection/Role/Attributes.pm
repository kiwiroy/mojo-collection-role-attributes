package Mojo::Collection::Role::Attributes;

use Mojo::Base -role;
use Mojo::Collection;
use Sub::Util;

our $VERSION = '0.01';

requires 'new';

foreach my $func (qw(compact flatten map reverse shuffle slice sort)) {
  my $sub = Mojo::Collection->can($func) ||
    die "Function Mojo::Collection::$func not found";
  no strict 'refs';
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
    Carp::croak qq{Attribute "$attr" invalid} unless $attr =~ /^[a-zA-Z_]\w*$/;
    my $index = $i;
    if (ref $value) {
      my $sub = sub {
        return
           exists $_[0][$index] ? $_[0][$index] : ($_[0][$index] = $value->($_[0]))
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
  return ;
}

sub import {
  my ($class, $caller) = (shift, caller);
  Mojo::Util::monkey_patch($caller, c_has => sub { c_attr($caller, @_) });
}

1;

=pod

=head1 NAME

Mojo::Collection::Role::Attributes - Add accessors to a L<Mojo::Collection>

=head1 DESCRIPTION

A L<role|Role::Tiny> to add L<accessors|#c_attr> to a L<Mojo::Collection>.

This is experimental.

=head1 SYNOPSIS


=head1 IMPORTS

=head2 c_has

Like L<has|Mojo::Base#has> from L<Mojo::Base>

=head1 METHODS

=head2 c_attr

  __PACKAGE__->c_attr('attribute' => 0 => sub { rand(100); });

Link an attribute to an index of a L<Mojo::Collection>.

=head1 Mojo::Collection METHODS

=head2 compact

=head2 flatten

=head2 map

=head2 reverse

=head2 shuffle

=head2 slice

=head2 sort

=cut
