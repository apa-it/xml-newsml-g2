package NewsML_G2_Test_Helpers;

# $Id$

use Exporter 'import';
use File::Spec::Functions qw(catfile);
use XML::LibXML;
use Test::More;
use Test::Exception;

use warnings;
use strict;

our @EXPORT_OK = qw(validate_g2);

sub validate_g2 {
    my ($dom, $version) = @_;

  SKIP: {
        skip 'libxml2 before 2.8 reports bogus violation on children of "broader"', 2 if (20800 > XML::LibXML::LIBXML_RUNTIME_VERSION);
        my $xsd = catfile('t', 'xsds', "NewsML-G2_$version-spec-All-Power.xsd");
        ok(my $xmlschema = XML::LibXML::Schema->new(location => $xsd), "parsing $version XSD");

        lives_ok(sub {$xmlschema->validate($dom)}, "XML validates against $version XSD");
    }

    return;
}

1;
