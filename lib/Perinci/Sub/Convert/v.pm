package Perinci::Sub::Convert::v;

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(convert_property_v);

our $VERSION = '0.01'; # VERSION
our $DATE = '2014-04-30'; # DATE

our %SPEC;

$SPEC{convert_property_v} = {
    v => 1.1,
    summary => 'Convert v1.0 Rinci function metadata to v1.1',
    args => {
        meta => {
            schema  => 'hash*', # XXX defhash
            req     => 1,
            pos     => 0,
        },
        new => {
            summary => 'New version',
            schema  => ['float*', default => '1.1'],
        },
    },
    result_naked => 1,
};
sub convert_property_v {
    my %args = @_;

    my $meta = $args{meta};
    my $old  = $meta->{v} // 1.0;
    my $new  = $args{new} // 1.1;

    die "Can only convert v 1.0 -> 1.1" unless $old == 1.0 && $new == 1.1;

    $meta->{v} = $new;

    # convert args
    if ($meta->{args}) {
        for my $argname (sort keys %{$meta->{args}}) {
            my $oldarg = $meta->{args}{$argname};
            my $newarg = {};
            if (ref($oldarg) eq 'ARRAY') {
                for (qw/summary description/) {
                    $newarg->{$_} = $oldarg->[1]{$_}
                        if defined $oldarg->[1]{$_};
                    delete $oldarg->[1]{$_};
                }
                if (defined $oldarg->[1]{arg_pos}) {
                    $newarg->{pos} = $oldarg->[1]{arg_pos};
                    delete $oldarg->[1]{arg_pos};
                }
                if (defined $oldarg->[1]{arg_greedy}) {
                    $newarg->{greedy} = $oldarg->[1]{arg_greedy};
                    delete $oldarg->[1]{arg_greedy};
                }
                if (defined $oldarg->[1]{arg_complete}) {
                    $newarg->{completion} = $oldarg->[1]{arg_complete};
                    delete $oldarg->[1]{arg_complete};
                }
                if (defined $oldarg->[1]{arg_aliases}) {
                    $newarg->{cmdline_aliases} = $oldarg->[1]{arg_aliases};
                    for my $al (keys %{ $newarg->{cmdline_aliases} }) {
                        my $als = $newarg->{cmdline_aliases}{$al};
                        if ($als->{code}) {
                            die join(
                                "",
                                "Can't convert arg_aliases '$al' because ",
                                "it has 'code', this must be converted ",
                                "manually due to change of arguments ",
                                "(now only receives \\\%args)",
                            );
                        }
                    }
                    delete $oldarg->[1]{arg_aliases};
                }
            } elsif (!ref($oldarg)) {
                # do nothing
            } else {
                die "Can't handle v1.0 args property ".
                    "(arg '$argname' not array/scalar)";
            }
            $newarg->{schema} = $oldarg;
            $meta->{args}{$argname} = $newarg;
        }
    }

    if ($meta->{result}) {
        $meta->{result} = {schema=>$meta->{result}};
    }

    $meta->{_note} = "Converted from v1.0 by ".__PACKAGE__.
        " on ".scalar(localtime);

    $meta;
}

1;
# ABSTRACT: Convert v1.0 Rinci function metadata to v1.1

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Sub::Convert::v - Convert v1.0 Rinci function metadata to v1.1

=head1 VERSION

This document describes version 0.01 of Perinci::Sub::Convert::v (from Perl distribution Perinci-Sub-Convert-v), released on 2014-04-30.

=head1 SYNOPSIS

 use Perinci::Sub::Convert::v qw(convert_property_v);
 convert_property_v(meta => $meta);

=head1 FUNCTIONS


=head2 convert_property_v(%args) -> [status, msg, result, meta]

Convert v1.0 Rinci function metadata to v1.1.

Arguments ('*' denotes required arguments):

=over 4

=item * B<meta>* => I<hash>

=item * B<new> => I<float> (default: 1.1)

New version.

=back

Return value:

Returns an enveloped result (an array).

First element (status) is an integer containing HTTP status code
(200 means OK, 4xx caller error, 5xx function error). Second element
(msg) is a string containing error message, or 'OK' if status is
200. Third element (result) is optional, the actual result. Fourth
element (meta) is called result metadata and is optional, a hash
that contains extra information.

=head1 SEE ALSO

L<Rinci>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Perinci-Sub-Convert-v>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Perinci-Sub-Convert-v>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Perinci-Sub-Convert-v>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
