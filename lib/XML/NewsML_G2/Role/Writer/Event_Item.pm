package XML::NewsML_G2::Role::Writer::Event_Item;

use Moose::Role;
use namespace::autoclean;

with 'XML::NewsML_G2::Role::Writer';

1;

__END__

=head1 NAME

XML::NewsML_G2::Role::Writer::Event_Item - Role for writing event items

=head1 DESCRIPTION

This module serves as a role for all NewsML-G2 writer classes and get automatically applied when the according news item type is written

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2019, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
