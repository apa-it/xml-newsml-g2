package XML::NewsML_G2::Writer::Substancial_Item;

use Moose;
use namespace::autoclean;

extends 'XML::NewsML_G2::Writer';

sub _create_subjects {
    my $self = shift;
    my @res;

    return @res;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

XML::NewsML_G2::Writer::Substancial_Item - base class for writers
creating DOM trees conforming to substancial items

=head1 DESCRIPTION

This module acts as a base class e.g. for event item writers and news item
writers.
See L<XML::NewsML_G2::Writer::News_Item>, L<XML::NewsML_G2::Writer::Event_Item>.


=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2019, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
