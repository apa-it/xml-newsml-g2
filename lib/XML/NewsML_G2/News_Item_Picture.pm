package XML::NewsML_G2::News_Item_Picture;

# $Id$

use Moose;
use namespace::autoclean;

extends 'XML::NewsML_G2::News_Item';

1;
__END__

=head1 NAME

XML::NewsML_G2::News_Item_Picture - a picture news item (story)

=for test_synopsis
    my ($provider, $service, $genre1, $genre2);

=head1 SYNOPSIS

    my $ni = XML::NewsML_G2::News_Item_Picure->new
        (guid => "tag:example.com,2013:service:date:number",
         title => "Story title",
         slugline => "the/slugline",
         language => 'de',
         provider => $provider,
         service => $service,
        );

    $ni->add_genre($genre1, $genre2);
    $ni->add_source('APA');

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
