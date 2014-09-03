package XML::NewsML_G2::News_Message;

# $Id$

use Moose;
use namespace::autoclean;

# header elements
has 'sent', isa => 'DateTime', is => 'ro', lazy => 1, builder => '_build_sent';
#news/package items
has 'items', isa => 'ArrayRef[XML::NewsML_G2::AnyItem]', is => 'rw',
    default => sub { [] }, traits => ['Array'],
    handles => {add_item => 'push'};

sub _build_sent {
    return DateTime->now(time_zone => 'local');
}

1;
__END__

=head1 NAME

XML::NewsML_G2::News_Message - a container that can hold multiple News
or Package Items

=for test_synopsis
    my ($provider, $service, $genre1, $genre2);

=head1 SYNOPSIS

    my $nm = XML::NewsML_G2::News_Message->new();
    my $ni_text = XML::NewsML_G2::News_Item_Text->new(...);
    my $ni_picture = XML::NewsML_G2::News_Item_Picture->new(...);
    $nm->add_item($ni_text);
    $nm->add_item($ni_picture);

=head1 ATTRIBUTES

=over 4

=item sent

Timestemp generated automatically

=item items

A collection of news and/or package items

=head1 AUTHOR

Stefan Hrdlicka  C<< <stefan.hrdlicka@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
