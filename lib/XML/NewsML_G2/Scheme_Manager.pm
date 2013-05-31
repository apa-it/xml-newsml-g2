package XML::NewsML_G2::Scheme_Manager;

# $Id$

use Moose;
use namespace::autoclean;


foreach (qw(desk hltype svc)) {
    has $_, isa => 'XML::NewsML_G2::Scheme', is => 'ro', required => 1;
}

foreach (qw(role ind geo org topic crel)) {
    has $_, isa => 'XML::NewsML_G2::Scheme', is => 'ro';
}

sub get_all_schemes {
    my $self = shift;

    return map {$self->can($_)->($self)} sort $self->meta->get_attribute_list();
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

XML::NewsML_G2::Scheme_Manager - hold all L<XML::NewsML_G2::Scheme> instances

=head1 SYNOPSIS

    my $sm = XML::NewsML_G2::Scheme_Manager->new(desk => $s1, hltype => $s2, svc => $s3);

=head1 ATTRIBUTES

=over 4

=item crel

Scheme for company relations

=item desk

Scheme for editorial desk, required

=item geo

Scheme for location information

=item hltype

Scheme for type of headline, required

=item ind

Scheme for content indicators

=item org

Scheme for organisations

=item role

Scheme for editorial note roles

=item svc

Scheme for editorial service, required

=item topic

Scheme for topics

=back

=head1 METHODS

=over 4

=item get_all_schemes

Returns a list of all registered L<XML::NewsML_G2::Scheme> instances

=back

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
