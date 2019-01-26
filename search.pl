#!/usr/bin/perl

# search.pl, a CGI script providing lyrics search.
# Copyright (C) 2019 defanor <defanor@uberspace.net>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use DBI;
use CGI;
use XML::LibXML;
use XML::LibXSLT;
use URI::Escape;
use preprocessing;

my $namespace = "urn:x-lyrics";
my $database = $ENV{"LYRICS_DB"};
my $xslt_dir = ($ENV{"XSLT_DIR"} or ".");

die "The LYRICS_DB environment variable is not set"
    unless ($database);

sub song_element {
    my ($doc, $artist, $album, $title, $lyrics) = @_;
    my $song = $doc->createElementNS($namespace, "song");
    my $artist_elem = $doc->createElementNS($namespace, "artist");
    $artist_elem->appendTextNode($artist);
    my $album_elem = $doc->createElementNS($namespace, "album");
    $album_elem->appendTextNode($album);
    my $title_elem = $doc->createElementNS($namespace, "title");
    $title_elem->appendTextNode($title);
    my $lyrics_elem = $doc->createElementNS($namespace, "lyrics");
    $lyrics_elem->appendTextNode($lyrics);
    my $url_elem = $doc->createElementNS($namespace, "url");
    $url_elem->appendTextNode("?artist=" . uri_escape($artist) .
                              "&album=" . uri_escape($album) .
                              "&title=" . uri_escape($title));
    $song->appendChild($artist_elem);
    $song->appendChild($album_elem);
    $song->appendChild($title_elem);
    $song->appendChild($lyrics_elem);
    $song->appendChild($url_elem);
    return $song;
}


my $q = CGI->new;
my $artist = $q->param('artist');
my $album = $q->param('album');
my $title = $q->param('title');
my $format = $q->param('format');
my $errors = $q->param('errors');

if ($artist || $album || $title) {
    # TODO: would be nice to open the database in read-only mode.
    # Apparently there's a few ways to do so, but relying on newer
    # DBD::SQLite versions.
    my $dbh = DBI->connect("DBI:SQLite:dbname=$database", "", "")
        or die $DBI::errstr;

    my @conditions;
    my @parameters;
    if ($artist) {
        push @conditions, "search_artist = ?";
        push @parameters, preprocess($artist);
    }
    if ($album) {
        push @conditions, "search_album = ?";
        push @parameters, preprocess($album);
    }
    if ($title) {
        push @conditions, "search_title = ?";
        push @parameters, preprocess($title);
    }

    my $sth = $dbh->prepare(
        "select artist,album,title,text from lyrics where " .
        join(" and ", @conditions));
    my $rv = $sth->execute(@parameters)
        or die $DBI::errstr;

    # Compose an XML document out of the query results
    my $doc = XML::LibXML::Document->new('1.0', "utf-8");
    my $songs = $doc->createElementNS($namespace, "songs");
    $doc->setDocumentElement($songs);
    while(my @row = $sth->fetchrow_array()) {
        $songs->appendChild(song_element($doc, @row));
    }

    $dbh->disconnect();

    # Return an error if it's requested to do so when nothing is
    # found.
    if (! $songs->hasChildNodes() && $errors) {
        print $q->header(-status=>'404 Not Found');
        exit;
    }

    # Respond depending on requested format.
    if ($format eq "xml") { # Serve plain XML
        print $q->header(-type=>'application/xml', -charset=>'utf-8');
        print $doc->toString();
    } else { # Transform using an XSL file
        $format =~ s/[^a-z\.-]//g;
        my $xslt_path = "$xslt_dir/$format.xsl";

        # Default to search.xsl if no file is found
        if (! -f $xslt_path) {
            $xslt_path = "$xslt_dir/search.xsl";
        }

        # Apply a template
        my $xslt = XML::LibXSLT->new();
        my $template = XML::LibXML->load_xml(location => $xslt_path);
        my $stylesheet = $xslt->parse_stylesheet($template);
        my $result = $stylesheet->transform($doc);

        print $q->header(-type=>'application/xhtml+xml',
                         -charset=>'utf-8');
        print $result->toString();
    }
}
