package XML::NewsML_G2::Roles::Writer::News_Item_Picture;

# $Id$

use Moose::Role;
use namespace::autoclean;

with 'XML::NewsML_G2::Roles::Writer';

sub _set_item_class {
    my ($self, $ic) = @_;
    $self->scheme_manager->add_qcode($ic, 'ninat', 'picture');
};

sub _set_author_role {
    my ($self, $author) = @_;
    $self->scheme_manager->add_qcode($author, 'crol', 'photographer');
};

1;
__END__

=head1 NAME

XML::NewsML_G2::Roles::Writer::News_Item_Picture - Role for writing news items of type 'picture'

=head1 DESCRIPTION

This module serves as a role for all NewsML-G2 writer classes and get automatically applied when the according news item type is written

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
