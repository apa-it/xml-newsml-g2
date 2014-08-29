package XML::NewsML_G2::News_Item_Graphics;

# $Id$

use Moose;
use namespace::autoclean;

extends 'XML::NewsML_G2::News_Item_Picture';

has '+nature', default => 'graphics';

1;
__END__

=head1 NAME

XML::NewsML_G2::News_Item_Graphics - a picture news item

=for test_synopsis
    my ($provider, $service, $genre1, $genre2);

=head1 SYNOPSIS

    my $ni = XML::NewsML_G2::News_Item_Graphics->new
        (guid => "tag:example.com,2013:service:date:number",
         title => "Story title",
         slugline => "the/slugline",
         language => 'de',
         provider => $provider,
         service => $service,
         photographer => 'Homer Simpson'
        );

    my $pic = XML::NewsML_G2::Graphics->new
        (mimetype => 'image/jpg',
         rendition => 'highRes',
         width => 1600,
         height => 1024
        );

    my $thumb = XML::NewsML_G2::Graphics->new
        (mimetype => 'image/jpg',
         rendition => 'thumb',
         width => 48,
         height => 32
        );
    $ni->add_remote('file://tmp/files/123.ai', $pic);

=head1 ATTRIBUTES

=head1 AUTHOR

Mario Paumann  C<< <mario.paumann@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
