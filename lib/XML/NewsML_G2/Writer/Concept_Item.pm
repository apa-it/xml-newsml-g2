package XML::NewsML_G2::Writer::Concept_Item;

use Moose;
use Carp;
use namespace::autoclean;

extends 'XML::NewsML_G2::Writer::Substancial_Item';

has '+_root_node_name',      default => 'conceptItem';
has '+_nature_qcode_prefix', default => 'cinat';

sub _create_rights_info {
}

sub _create_correction {
}

sub _create_subjects {
    my $self = shift;
    my @res;
    push @res, $self->_create_subjects_media_topic();
    push @res, $self->_create_subjects_concepts();
    return @res;
}

sub _create_content_meta {
    my ( $self, $root ) = @_;

    $root->appendChild( my $cm = $self->create_element('contentMeta') );
    my @subjects = $self->_create_subjects();
    $cm->appendChild($_) foreach (@subjects);
    foreach ( @{ $self->_root_item->keywords } ) {
        my %args;
        $args{role} = $_->role if $_->role;
        $cm->appendChild($_)
            foreach $self->_create_multilang_elements( 'keyword', $_->text,
            %args );
    }
    return;
}

sub _create_content {
    my ( $self, $root ) = @_;

    $root->appendChild( my $concept = $self->create_element('concept') );
    $concept->appendChild( $self->_create_id_element() );
    $concept->appendChild( $self->_create_type_element() );
    $self->_create_inner_content($concept);

    return;
}

sub _create_multilang_elements {
    my ( $self, $name, $text, %attrs ) = @_;
    my @result;
    push @result, $self->create_element( $name, _text => $text->text, %attrs )
        if $text->text;
    foreach my $lang ( sort $text->languages ) {
        my $trans = $text->get_translation($lang);
        push @result,
            $self->create_element(
            $name,
            _text      => $trans,
            'xml:lang' => $lang,
            %attrs
            );
    }

    return @result;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

XML::NewsML_G2::Writer::Concept_Item - base class for writers
creating DOM trees conforming to Concept Items

=head1 DESCRIPTION

This module acts as a base class e.g. for event item writers.
See L<XML::NewsML_G2::Writer::Event_Item>.


=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2019, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
