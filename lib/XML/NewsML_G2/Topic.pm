package XML::NewsML_G2::Topic;

# $Id$

use Moose;
use namespace::autoclean;


has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Topic - a temporary topic covered in the news item,
used to group related stories

=head1 SYNOPSIS

    my $topic = XML::NewsML_G2::Topic->new(name => 'Swine Flu', qcode => 'h1n1');

=head1 ATTRIBUTES

=over 4

=item name

=item qcode

=back

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
