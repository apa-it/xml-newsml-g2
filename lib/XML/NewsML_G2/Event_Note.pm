package XML::NewsML_G2::Event_Note;

use XML::NewsML_G2::Types;

use Moose;
use namespace::autoclean;

has 'text',
    is      => 'ro',
    isa     => 'XML::NewsML_G2::Translatable_Text',
    handles => [qw/add_translation/],
    coerce  => 1;

has 'role',
    is      => 'ro',
    isa     => 'XML::NewsML_G2::QCodeStr',
    default => 'noterole:general';

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

XML::NewsML_G2::Writer::Event_Note - an note for an L<XML::NewsML_G2::Event_Item>

=for test_synopsis
    my ($event_item);

=head1 SYNOPSIS

    my $note = XML::NewsML_G2::Event_Note->new(
        text => 'This is just a test', role => 'noterole:information');
    $event_item->add_note($note);

=head1 ATTRIBUTES

=over 4

=item name

A human-readable (optionally multi-lingual) text

=item role

The role of this note (default: 'noterole:general')

=back

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2020, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
