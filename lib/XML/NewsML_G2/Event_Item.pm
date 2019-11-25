package XML::NewsML_G2::Event_Item;

use Moose;
use namespace::autoclean;

### XXX t.b.i:
### XXX eventid
### XXX title, description
### XXX mediatopics
### XXX date/time, series
### XXX coverage
### XXX location
### XXX language, translations
### XXX usable/canceled

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Event_Item - an event as concept item

=head1 SYNOPSIS

    my $event = XML::NewsML_G2::Event_Item->new();

=head1 DESCRIPTION

An event item is an event as described in
https://iptc.org/std/NewsML-G2/guidelines/#events-in-newsml-g2
that can be published standalone

=head1 ATTRIBUTES

=over 4

=back

=head1 METHODS

=over 4

=back

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2019, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
