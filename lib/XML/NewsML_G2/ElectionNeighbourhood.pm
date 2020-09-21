package XML::NewsML_G2::ElectionNeighbourhood;

use Moose;
use namespace::autoclean;

with 'XML::NewsML_G2::Role::HasQCode';

has 'province', isa => 'XML::NewsML_G2::ElectionProvince', is => 'ro';

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::ElectionNeighbourhood - a city region used during an election

=head1 SYNOPSIS

    my $at = XML::NewsML_G2::ElectionNeighbourhood->new
        (name => 'Mistelbach', qcode => 'electionneighbourhood:12345');

    my $vie = XML::NewsML_G2::ElectionNeighbourhood->new
        (name => 'Traun', qcode => 'electionneighbourhood:23455', province => XML::NewsML_G2::ElectionProvince->new(name => 'Oberoesterreich', qcode => 'electionprovince:8765'));

=head1 ATTRIBUTES

=over 4

=item name

Name of Neighbourhood the Election News Item is for

=item province

Optional Province of the Election News Item

=back

=head1 AUTHOR

Mario Paumann  C<< <mario.paumann@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013-2019, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
