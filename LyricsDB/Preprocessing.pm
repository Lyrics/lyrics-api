# preprocessing, a module for artist/album/song name preprocessing.
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

package LyricsDB::Preprocessing 0.01;

use Text::Unidecode;
use base 'Exporter';
our @EXPORT = ('preprocess');

sub preprocess {
    my $str = shift @_;
    my %aliases;
    $aliases{'original'} = $str;
    # remove trailing marks
    $str =~ s/(\(|feat\.|ft\.).*$//g;
    $aliases{'no_marks'} = $str;
    # filter alphanumeric characters
    $str =~ s/[^\p{Alpha}\p{Number}]//g;
    $aliases{'no_marks+alphanum'} = $str;
    # encode as ASCII, lower-case
    $str = lc(unidecode $str);
    $aliases{'no_marks+alphanum+unidecode+lc'} = $str;
    return %aliases;
}
