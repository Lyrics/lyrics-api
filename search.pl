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
use Getopt::Long;

my $namespace = "urn:x-lyrics";
my $search_template = "search.xsl";
my $database = $ENV{"LYRICS_DB"};

die "The LYRICS_DB environment variable is not set"
    unless ($database);

# TODO: add --help, --version, etc.
GetOptions ("search-template=s" => \$search_template)
    or die("Error in command line arguments");

sub fts5_condition {
    my ($column, $query) = @_;
    # Escape double quotes in the query. Not great, but regular query
    # templates only escape it for SQL, not for FTS5 queries, and
    # there doesn't seem to be a function to escape those.
    $query =~ s/"/""/g;
    my @words = split / /, $query;
    my @pieces;
    while (@words) {
        push @pieces, $column . ' : ^"' . (join " ", @words) . '"';
        pop @words;
    }
    return ("(" . (join " OR ", @pieces) . ")");
}

sub fts5_query {
    my ($artist, $album, $song) = @_;
    my @pieces;
    push @pieces, fts5_condition "artist", $artist if $artist;
    push @pieces, fts5_condition "album", $album if $album;
    push @pieces, fts5_condition "title", $song if $song;
    return ("(" . (join " AND ", @pieces) . ")");
}

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
    $song->appendChild($artist_elem);
    $song->appendChild($album_elem);
    $song->appendChild($title_elem);
    $song->appendChild($lyrics_elem);
    return $song;
}


my $q = CGI->new;
my $artist = $q->param('artist');
my $album = $q->param('album');
my $title = $q->param('title');

if ($artist || $album || $title) {
    # TODO: would be nice to open the database in read-only mode.
    # Apparently there's a few ways to do so, but relying on newer
    # DBD::SQLite versions.
    my $dbh = DBI->connect("DBI:SQLite:dbname=$database", "", "")
        or die $DBI::errstr;

    my $sth = $dbh->prepare(
        q(
        select artist,album,title,text
        from lyrics
        where lyrics match ?
        order by rank
        limit 10
        ));
    my $rv = $sth->execute(fts5_query $artist, $album, $title)
        or die $DBI::errstr;

    # Compose an XML document out of the query results
    my $doc = XML::LibXML::Document->new('1.0', "utf-8");
    my $songs = $doc->createElementNS($namespace, "songs");
    $doc->setDocumentElement($songs);
    while(my @row = $sth->fetchrow_array()) {
        $songs->appendChild(song_element($doc, @row));
    }

    # Disconnect is commented out, since it leads to a segfault with a
    # new sqlite library and an old perl module.
    # $dbh->disconnect();

    # Apply a template
    my $xslt = XML::LibXSLT->new();
    my $template = XML::LibXML->load_xml(location => $search_template);
    my $stylesheet = $xslt->parse_stylesheet($template);
    my $result = $stylesheet->transform($doc);

    # Respond
    print $q->header(
        -type=>'application/xhtml+xml',
        -charset=>'utf-8');
    print $result->toString();
}
