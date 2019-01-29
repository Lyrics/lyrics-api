use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share 'dist';

WriteMakefile(
    NAME         => 'LyricsDB',
    VERSION_FROM => 'LyricsDB/Preprocessing.pm',
    EXE_FILES    => [ 'lyrics-web', 'lyrics-to-sqlite' ],
    PREREQ_PM    => { "DBI" => 0,
                      "DBD::SQLite" => 0,
                      "CGI" => 0,
                      "XML::LibXML" => 0,
                      "XML::LibXSLT" => 0,
                      "URI::Escape" => 0,
                      "File::Basename" => 0,
                      "Text::Unidecode" => 0,
                      "File::ShareDir" => 0,
                    },
);

package MY;
use File::ShareDir::Install qw(postamble);
