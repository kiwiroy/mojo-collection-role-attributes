## -*- mode: perl; -*-
# You can install this project with
# curl -L http://cpanmin.us | perl - https://github.com/kiwiroy/mojo-collection-role-attributes/archive/master.tar.gz
requires "perl" => "5.10.0";
requires "Mojolicious" => "7.43";
requires 'Role::Tiny' => '2.000001';
requires "Sub::Util" => "1.40";

test_requires "Test::More" => "0.88";

on develop => sub {
  requires 'Test::Pod';
  requires 'Test::Pod::Coverage';
  requires 'Test::CPAN::Changes';
  requires 'Devel::Cover';
  requires 'Devel::Cover::Report::Coveralls' => '0.11';
  requires 'Devel::Cover::Report::Kritika' => '0.05';
};
