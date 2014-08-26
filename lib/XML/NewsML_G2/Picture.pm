package XML::NewsML_G2::Picture;

# $Id$

use XML::NewsML_G2::Types;

use Moose;
use namespace::autoclean;

has 'rendition', isa => 'Str', is => 'rw', required => 1;
has 'mimetype', isa => 'Str', is => 'rw', required => 1;
has 'size', isa => 'Int', is => 'rw';
has 'width', isa => 'Int', is => 'rw';
has 'height', isa => 'Int', is => 'rw';
has 'orientation', isa => 'Int', is => 'rw', default => 1;
has 'layout', isa => 'XML::NewsML_G2::Types::PictureLayout', is => 'rw',
    default => 'unaligned';
has 'colorspace', isa => 'Str', is => 'rw';

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Picture - a picture specification

=head1 SYNOPSIS

    my $pic = XML::NewsML_G2::Picture->new
        (rendition => 'highRes',
         mimetype => 'image/jpg',
         size => 21123
        );

=head1 ATTRIBUTES

=over 4

=item mimetype

The MIME type of the picture file (e.g. image/jpg)

=item size

The size in bytes of the picture file

= item width

The width in pixel of the picture

= item height

The height in pixel of the picture

= item orientation

The picture orientation (1 is 'upright')

= item layout

The layout of the picture (horizontal, vertical, square, unaligned)

= item colorspace

The colorspace used by this picture (e.g. AdobeRGB)

=back

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013-2014, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
