package XML::NewsML_G2::Writer::News_Message;

# $Id$

use Moose;

extends 'XML::NewsML_G2::Writer';

has 'news_message', isa => 'XML::NewsML_G2::News_Message', is => 'ro',
    required => 1;
has '+_root_node_name', default => 'newsMessage';


sub _build__root_item {
    my $self = shift;
    return $self->news_message;
}

sub _create_header {
    my ($self, $root) = @_;
   
    my $header = $self->create_element('header');
    $header->appendChild($self->create_element('sent'
        , _text => $self->news_message->sent));

    $root->appendChild($header);
}

sub _create_itemSet {
    my ($self, $root) = @_;
    my $item_set = $self->create_element('itemSet');
    
    my $writer;
    for my $item (@{$self->news_message->items}){
        if ($item->isa('XML::NewsML_G2::News_Item')) {
            $writer = XML::NewsML_G2::Writer::News_Item->new(
                news_item => $item,
                scheme_manager => $self->scheme_manager,
                g2_version => $self->g2_version);
        } elsif ($item->isa('XML::NewsML_G2::Package_Item')) {
            $writer = XML::NewsML_G2::Writer::Package_Item->new(
                package_item => $item,
                scheme_manager => $self->scheme_manager,
                g2_version => $self->g2_version);
        }

        $item_set->appendChild($writer->create_dom()->documentElement());
    }
    $root->appendChild($item_set);
}

override '_create_root_element' => sub {
    my $self = shift;

    my $root = $self->doc->createElementNS($self->g2_ns, $self->_root_node_name);
    $self->doc->setDocumentElement($root);
    return $root;
};

override 'create_dom' => sub {
    my $self = shift;
    $self->_import_iptc_catalog();

    my $root = $self->_create_root_element();
    $self->_create_header($root);
    $self->_create_itemSet($root);

    return $self->doc;
};

__PACKAGE__->meta->make_immutable;

1;
