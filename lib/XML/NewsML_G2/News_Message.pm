package XML::NewsML_G2::News_Message;

# $Id$

use Moose;
use namespace::autoclean;

# header elements
has 'sent', isa => 'DateTime', is => 'ro', lazy => 1, builder => '_build_sent';
#news/package items
has 'anyItems', isa => 'ArrayRef[XML::NewsML_G2::AnyItem]', is => 'rw', default => sub { [] },
    traits => ['Array'], handles => {add_anyItem => 'push'};

sub _build_sent {
    return DateTime->now(time_zone => 'local');
}

1;
