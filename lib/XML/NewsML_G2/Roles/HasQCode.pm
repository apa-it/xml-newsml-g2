package XML::NewsML_G2::Roles::HasQCode;

# $Id$

use Moose::Role;
use namespace::autoclean;

has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;

1;
__END__

=head1 NAME

XML::NewsML_G2::Roles::HasQCode - Role for item types that have a QCode

=head1 SYNOPSIS

    my $desk = XML::NewsML_G2::Desk->new
        (name => 'Sports', qcode => 'spo');

=head1 DESCRIPTION

This module serves as a role for all NewsML-G2 item type classes which have
a qcode (and a human readable name)

=head1 ATTRIBUTES

=over 4

=item name

=item qcode

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013-2014, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
