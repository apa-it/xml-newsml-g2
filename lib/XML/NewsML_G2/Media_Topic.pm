package XML::NewsML_G2::Media_Topic;

# $Id$

use Moose;
use namespace::autoclean;


has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;
has 'translations', isa => 'HashRef', is => 'rw', default => sub { {} }, traits => ['Hash'],
  handles => {add_translation => 'set'};
has 'parent', isa => __PACKAGE__, is => 'rw';
has 'direct', isa => 'Bool', is => 'rw', default => '';

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Media_Topic - a subject covered in the news item,
taken from a standardized controlled vocabulary

=head1 SYNOPSIS

    my $mm = XML::NewsML_G2::Media_Topic->new
        (name => 'mass media', qcode => 20000045);
    my $tv = XML::NewsML_G2::Media_Topic->new
        (name => 'television', qcode => 20000051, parent => $mm);
    $tv->add_translation(de => 'Fernsehen')

=head1 ATTRIBUTES

=over 4

=item name

=item qcode

=item translations

hash mapping IANA language codes to the translation of the name in that language

=item parent

points to the broader media topic

=item direct

whether the media topic has been manually specified by the editor

=back

=head1 METHODS

=over 4

=item add_translation

=back

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.