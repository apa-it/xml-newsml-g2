package XML::NewsML_G2::Scheme_Manager;

# $Id$

use Moose;
use Carp;
use namespace::autoclean;


foreach (qw(desk hltype role ind geo org topic crel svc isbn ean isrol
nprov ninat stat sig iso3166_1a2 genre isin medtop)) {
    has $_, isa => 'XML::NewsML_G2::Scheme', is => 'rw';
}

# public methods

sub get_all_schemes {
    my $self = shift;

    return grep {defined} map {$self->can($_)->($self)} sort $self->meta->get_attribute_list();
}

sub add_qcode_or_literal {
    my ($self, $elem, $name, $value) = @_;
    $self->_add_qcode($elem, $name, $value) or $elem->setAttribute('literal', $name . '#' . $value);
    return 1;
}

sub add_qcode {
    my ($self, $elem, $name, $value) = @_;
    $self->_add_qcode($elem, $name, $value) or die "Specifying a '$name' schema with uri or catalog required\n";
    return 1;
}

sub add_role {
    my ($self, $elem, $name, $value) = @_;
    my $getter = $self->can($name) or croak "No schema named '$name'!";
    my $scheme = $getter->($self);
    return unless $scheme;

    $elem->setAttribute('role', $scheme->alias . ':' . $value);
    return 1;
}

# private methods

sub _add_qcode {
    my ($self, $elem, $name, $value) = @_;

    my $getter = $self->can($name) or croak "No schema named '$name'!";
    my $scheme = $getter->($self);
    return unless ($scheme and ($scheme->uri or $scheme->catalog));

    $elem->setAttribute('qcode', $scheme->alias . ':' . $value);
    return 1;
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

Scheme for editorial desk

=item ean

Scheme for european/international article number

=item geo

Scheme for location information

=item hltype

Scheme for type of headline

=item ind

Scheme for content indicators

=item isbn

Scheme for international standard book number

=item org

Scheme for organisations

=item role

Scheme for editorial note roles

=item svc

Scheme for editorial service

=item topic

Scheme for topics


=item isrol

=item nprov

=item ninat

=item stat

=item sig

=item iso3166_1a2

=item genre

=item isin

=item medtop

=back

=head1 METHODS

=over 4

=item get_all_schemes

Returns a list of all registered L<XML::NewsML_G2::Scheme> instances

=item add_qcode

Add a qcode attribute of the given scheme to the XML element:

    $scheme_manager->add_qcode($element, 'ninat', 'text');

If the schema does not provide a catalog or URI, creating a qcode is
not possible, and this method will die.

=item add_qcode_or_literal

Same as C<add_qcode>, but will create a C<literal> attribute if
creating a qcode is not possible.

=item add_role

If the scheme is defined, add a role attribute to the given XML
element. Else, do nothing.

    $scheme_manager->add_role($element, 'isrol', 'originfo');

=back

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
