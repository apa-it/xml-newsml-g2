package XML::NewsML_G2::Keyword;

use XML::NewsML_G2::Types;

use Moose;
use namespace::autoclean;

has 'text',
    is      => 'ro',
    isa     => 'XML::NewsML_G2::Translatable_Text',
    handles => [qw/add_translation/],
    coerce  => 1;

has 'role',
    is  => 'ro',
    isa => 'XML::NewsML_G2::QCodeStr';

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

XML::NewsML_G2::Writer::Keyword - a keyword for an L<XML::NewsML_G2::Substancial_Item>

=for test_synopsis
    my ($item);

=head1 SYNOPSIS

    my $kw = XML::NewsML_G2::Keywrodk->new(
        text => 'Vienna', role => 'keyrole:city');
    $kw->add_translation('de', 'Wien');
    $item->add_keyword($kw);
    $item->add_keyword('Politics');

=head1 ATTRIBUTES

=over 4

=item text

The (optionally multi-lingual) keyword itself

=item role

The optional role of this keyword

=back

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2020, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.

1;
