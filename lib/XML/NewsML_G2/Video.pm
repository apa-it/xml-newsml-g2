package XML::NewsML_G2::Video;

# $Id$

use XML::NewsML_G2::Types;

use Moose;
use namespace::autoclean;

has 'size', isa => 'Int', is => 'rw';
has 'width', isa => 'Int', is => 'rw';
has 'height', isa => 'Int', is => 'rw';
has 'duration', isa => 'Str', is => 'rw';
has 'videoframerate', isa => 'Int', is => 'rw';
has 'videoavgbitrate', isa => 'Int', is => 'rw';
has 'mimetype', isa => 'Str', is => 'rw';
has 'audiosamplerate', isa => 'Int', is => 'rw';
has 'audiochannels', isa => 'Str', is => 'rw';


__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Video - a video specification

=head1 SYNOPSIS

    my $pic = XML::NewsML_G2::Video->new
        (size => 2231259,
         width => 1280,
         height => 720,
         duration => 220,
        );

=head1 ATTRIBUTES

=over 4

=item size

The size in bytes of the video file

=item width

The width in pixel of the video 

=item height

The height in pixel of the video

=item duration

The playtime of the video in seconds

=item videoframerate

The frames/second of the video

=item videoavgbitrage

The bit rate of the video

=item audiosamplerate

The sample rate of the audio

=item audiochannels

The number of audio channels (stereo, mono)

=item mimetype

The MIME type of the video file (e.g. image/jpg)

=back

=head1 AUTHOR

Stefan Hrdlicka  C<< <stefan.hrdlicka@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013-2014, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
