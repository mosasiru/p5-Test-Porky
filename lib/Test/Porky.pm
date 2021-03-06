package Test::Porky;
use 5.008005;
use strict;
use warnings;
use utf8;

our $VERSION = "0.01";


our @EXPORT = qw(ok_regression);

use File::Slurp;
use Test::Differences;
use Data::Util qw(:check);
use Data::Dumper;

use base qw(Test::Builder::Module);

my $CLASS = __PACKAGE__;

#my $json = JSON::XS->new;

my ($read_cb, $write_cb) = @_;
sub import {
    my ($package, %args) = @_;

    $package->export_to_level(1);

    $read_cb  = $args{read_cb} || sub {
        my ($file_name) = @_;
        read_file($file_name, binmode => ':utf8');
    };
    $write_cb = $args{write_cb} || sub {
        my ($file_name, $output) = @_;
        write_file($file_name, +{ binmode => ':utf8' }, $output, );
    };
}

sub ok_regression {
    my ($tested, $file_name, $test_name) = @_;
    $test_name ||= $file_name;

    my $output = eval {
        my $res = (is_code_ref $tested) ? &$tested : $tested;
        local $Data::Dumper::Indent   = 1;
        local $Data::Dumper::Terse    = 1;
        local $Data::Dumper::Deparse  = 1;
        (is_string $res) ? $res : Dumper $res;
    };
    my $tb = $CLASS->builder;
    if ($@) {
        $tb->diag($@);
        return $tb->ok( 0, $test_name );
    }
    $tb->note($output);

    # generate the output files if required
    if ( ! -e $file_name || $ENV{TEST_PORKY_INIT} ) {
        eval {
            $write_cb->($file_name, $output);
        };
        if ($@) {
            return $tb->ok( 0, sprintf('actual write failed: %s (%s)', $file_name, $@) );
        }
        return $tb->skip(sprintf('(%s is generated)', $test_name));
    }

    # compare the files
    my $content = eval { $read_cb->($file_name) };
    if ($@) {
        return $tb->ok( 0, sprintf('%s: cannot open %s (%s)', $test_name, $file_name, $@) )
    };
    eq_or_diff( $output, $content, $test_name );
    return $output eq $content;
}
1;
__END__

=encoding utf-8

=head1 NAME

Test::Porky - generate regression tests automatically

=head1 SYNOPSIS

    use Test::Porky;

    ok_regression($obj->hoge(), 'hoge.result');

=head1 DESCRIPTION

Test::Porky helps you generating regression tests. It remember the last results of tests, and compare new result with old ones.
It enable you to develop modules very quickly.

=head2 ok_regression

Test::Porky writes the result of tests to a file.


the result of coderef execution

    ok_regression($coderef, $output_file);

or scalar, or object.

    ok_regression($string, $output_file);
    ok_regression($obj, $output_file);

if third argument is undefined, $output_file is also a test_name.

    ok_regression($coderef, $output_file, $test_name);


=head1 FEATURE PLANS

it will be pluggable. it would test DB query regression or so.

=head1 INSPIRED BY

Test::Porky is inspired by Porky https://github.com/puriketu99/porky
and Test::Regression inspires it also.

=head1 LICENSE

Copyright (C) mosa_siru.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

mosa_siru E<lt>mosaafi@gmail.comE<gt>

=cut

