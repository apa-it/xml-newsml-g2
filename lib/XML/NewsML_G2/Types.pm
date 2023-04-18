package XML::NewsML_G2::Types;

use Moose::Util::TypeConstraints;
use Module::Runtime 'use_module';

use namespace::autoclean;
use warnings;
use strict;

enum 'XML::NewsML_G2::Types::Nature',
    [qw(text picture graphics audio video composite concept)];

enum 'XML::NewsML_G2::Types::Group_Mode', [qw(bag sequential alternative)];

enum 'XML::NewsML_G2::OccurenceStatus', [ map {"eos$_"} ( 0 .. 6 ) ];

enum 'XML::NewsML_G2::SignalTypes', [qw(update correction)];

class_type 'XML::NewsML_G2::Link';
coerce 'XML::NewsML_G2::Link', from 'Str',
    via { use_module('XML::NewsML_G2::Link')->new( residref => $_ ) };

class_type 'XML::NewsML_G2::Destination';
coerce 'XML::NewsML_G2::Destination', from 'Str',
    via { use_module('XML::NewsML_G2::Destination')->new( name => $_ ) };

subtype 'XML::NewsML_G2::ArrayRefOfLinks',
    as 'ArrayRef[XML::NewsML_G2::Link]';
coerce 'XML::NewsML_G2::ArrayRefOfLinks', from 'ArrayRef[HashRef]', via {
    [ map { XML::NewsML_G2::Link->new($_) } @$_ ]
};

class_type 'XML::NewsML_G2::Creator';
coerce 'XML::NewsML_G2::Creator', from 'Str',
    via { use_module('XML::NewsML_G2::Creator')->new( name => $_ ) };
subtype 'XML::NewsML_G2::ArrayRefOfCreators',
    as 'ArrayRef[XML::NewsML_G2::Creator]';
coerce 'XML::NewsML_G2::ArrayRefOfCreators', from 'ArrayRef[Str]', via {
    [ map { XML::NewsML_G2::Creator->new( name => $_ ) } @$_ ]
};

class_type 'XML::NewsML_G2::Translatable_Text';
coerce 'XML::NewsML_G2::Translatable_Text', from 'Str',
    via { use_module('XML::NewsML_G2::Translatable_Text')->new( text => $_ ) };
class_type 'XML::NewsML_G2::Keyword';
coerce 'XML::NewsML_G2::Keyword', from 'Str',
    via { use_module('XML::NewsML_G2::Keyword')->new( text => $_ ) };
subtype 'XML::NewsML_G2::ArrayRefOfKeywords',
    as 'ArrayRef[XML::NewsML_G2::Keyword]';
coerce 'XML::NewsML_G2::ArrayRefOfKeywords', from 'ArrayRef[Str]', via {
    [ map { XML::NewsML_G2::Keyword->new( text => $_ ) } @$_ ]
};

subtype 'XML::NewsML_G2::LanguageCode', as 'Str', where {/^[a-z]{2}$/};
subtype 'XML::NewsML_G2::TransLang', as 'Str',
    where {/^([a-z]{2}|und)-x-mtfrom-([a-z]{2}|und)$/};

subtype 'XML::NewsML_G2::CountryCode', as 'Str', where {/^[A-Z]{2,3}$/};
subtype 'XML::NewsML_G2::RegionCode',  as 'Str', where {/^[-A-Z]{2,7}$/};

subtype 'XML::NewsML_G2::QCodeStr', as 'Str', where {/^[a-z]+:[\w]+$/};

1;

__END__

=head1 NAME

XML::NewsML_G2::Types - various Moose attribute types used by NewsML_G2 classes

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
