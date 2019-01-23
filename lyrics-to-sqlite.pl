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

my $database = "lyrics.db";
my $dirname  = "../lyrics/database";

my $dbh = DBI->connect("DBI:SQLite:dbname=$database", "", "")
    or die $DBI::errstr;

$dbh->do(q(
         CREATE VIRTUAL TABLE lyrics
         USING fts5(artist, album, title, text UNINDEXED)));
my $insert_q = $dbh->prepare("INSERT INTO lyrics VALUES (?, ?, ?, ?)");

for my $path (glob("$dirname/*/*/*/*")) {
    my $song = basename $path;
    my $album = basename(dirname $path);
    my $artist = basename(dirname(dirname $path));
    my $lyrics = do { local( @ARGV, $/ ) = $path; <> };
    $insert_q->execute($artist, $album, $song, $lyrics);
}

# $dbh->disconnect();
