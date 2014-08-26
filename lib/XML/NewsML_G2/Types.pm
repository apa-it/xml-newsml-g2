package XML::NewsML_G2::Types;

# $Id$

use Moose::Util::TypeConstraints;

use namespace::autoclean;

enum 'XML::NewsML_G2::Types::PictureLayout', [qw(horizontal vertical square unaligned)];

1;
__END__

=head1 NAME

XML::NewsML_G2::Types - various Moose attribute types used by NewsML_G2 classes

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.