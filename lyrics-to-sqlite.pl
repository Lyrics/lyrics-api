#!/usr/bin/perl

# lyrics-to-sqlite, a tool for filling an SQLite database with lyrics.
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
use File::Basename;
use preprocessing;

die "Usage: lyrics-to-sqlite.pl <database directory> <sqlite db file>"
    unless ($#ARGV >= 1);
my $dirname = shift @ARGV;
my $database = shift @ARGV;

die "The database file already exists" if (-f $database);

my $dbh = DBI->connect("DBI:SQLite:dbname=$database", "", "")
    or die $DBI::errstr;

$dbh->do(q(
         CREATE TABLE lyrics (
         search_artist text NOT NULL,
         search_album text NOT NULL,
         search_title text NOT NULL,
         artist text NOT NULL,
         album text NOT NULL,
         title text NOT NULL,
         text text NOT NULL
         )));
my $insert_q = $dbh->prepare("INSERT INTO lyrics VALUES (?, ?, ?, ?, ?, ?, ?)");

for my $path (glob("$dirname/*/*/*/*")) {
    my $song = basename $path;
    my $album = basename(dirname $path);
    my $artist = basename(dirname(dirname $path));
    my $lyrics = do { local( @ARGV, $/ ) = $path; <> };
    $insert_q->execute(preprocess($artist), preprocess($album),
                       preprocess($song), $artist, $album, $song, $lyrics);
}

$dbh->do("CREATE INDEX idx_artist on lyrics (search_artist)");
$dbh->do("CREATE INDEX idx_album on lyrics (search_album)");
$dbh->do("CREATE INDEX idx_title on lyrics (search_title)");
# compound indexes (add more?)
$dbh->do("CREATE INDEX idx_artist_title on lyrics (search_artist, search_title)");

$dbh->disconnect();
