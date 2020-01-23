package XML::NewsML_G2::Language;

use XML::NewsML_G2::Types;

use Moose;
use namespace::autoclean;

has 'name', is => 'ro', isa => 'Str', required => 1;
has 'code', is => 'ro', isa => 'XML::NewsML_G2::LanguageCode';

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Language - a language

=head1 SYNOPSIS

    my $lang = XML::NewsML_G2::Language->new
        (name => 'English', code => 'en');


=head1 ATTRIBUTES

=over 4

=item name

The human readable name of the language

= item code

The 2-letter ISO code of the language

=back

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2020, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
