# NAME

Test::Porky - generate regression tests automatically

# SYNOPSIS

    use Test::Porky;

    ok_regression($obj->hoge(), 'hoge.result');

# DESCRIPTION

Test::Porky helps you generating regression tests. It remember the last results of tests, and compare new result with old ones.
It enable you to develop modules very quickly.

## ok\_regression

Test::Porky writes the result of tests to a file.



the result of coderef execution

    ok_regression($coderef, $output_file);

or scalar, or object.

    ok_regression($string, $output_file);
    ok_regression($obj, $output_file);

if third argument is undefined, $output\_file is also a test\_name.

    ok_regression($coderef, $output_file, $test_name);



# FEATURE PLANS

it will be pluggable. it would test DB query regression or so.

# INSPIRED BY

Test::Porky is inspired by Porky https://github.com/puriketu99/porky
and Test::Regression inspires it also.

# LICENSE

Copyright (C) mosa\_siru.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

mosa\_siru <mosaafi@gmail.com>
