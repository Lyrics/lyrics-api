# Lyrics search API

This repository contains tools to make the lyrics database accessible
and searchable in ways other than direct file reading:

- `lyrics-to-sqlite` fills an SQLite database.
- `lyrics-web` is a CGI script that uses that database to search for
  lyrics, and intended to serve as both a website and an API (planning
  (X)HTML+RDF output by default, textual, mimicking other services'
  schema to make scrapers work, or plain XML on request).

It's not stable yet, but the intention is to get a stable database
schema, as well as a stable and specified schema of documents served
by the web API.


## Dependencies

SQLite3, a Perl interpreter, and the following modules are required:
`DBI`, `DBD::SQLite`, `CGI`, `XML::LibXML`, `XML::LibXSLT`,
`URI::Escape`, `File::Basename`, `Text::Unidecode`, `File::ShareDir`,
`File::ShareDir::Install`, `ExtUtils::MakeMaker`.

For Arch Linux you will need the following packages: `perl-dbd-sqlite` (which also pulls the needed `perl-dbi`), `perl-cgi`, `perl-xml-libxml`, `perl-xml-libxslt` and `perl-text-unidecode` from AUR. (TODO: add MakeMaker and ShareDir packages)


## Installation

`perl Makefile.PL && make && sudo make install` installs the
executables and data files.

`make uninstall` and `INSTALL_BASE` are currently broken.


## Usage

### Database generation

`lyrics-to-sqlite <lyrics database directory> <sqlite3 database file>`

### Web interface setup

After the database is generated, you can try searching for Six Shooter by Coyote Kisses via

```
LYRICS_DB="./lyrics.db" REQUEST_METHOD="GET" QUERY_STRING="title=six shooter&album=six shooter&artist=coyote kisses" lyrics-web
```

Now you may want to set up a webserver, here's an example server block for nginx. It assumes the repo with db file cloned into /var/www/html/.  
It also assumes that FCGI server is up and running:

```
	server {
		listen 443 ssl http2;
		listen [::]:443 ssl http2;
		server_name lyrics.example.com;
		root /var/www/html/lyrics-api;
		index lyrics-web;

		location / {
			fastcgi_intercept_errors on;
			include /etc/nginx/fastcgi_params;
			fastcgi_param SCRIPT_FILENAME /var/www/html/lyrics-api/lyrics-web;
			fastcgi_param PERL5LIB "/var/www/html/lyrics-api/";
			fastcgi_param LYRICS_DB "/var/www/html/lyrics-api/lyrics.db";
			fastcgi_param XSLT_DIR "/var/www/html/lyrics-api/format";
			fastcgi_pass unix:/var/run/fcgiwrap.sock;
		}
}
```
You should be able to load Six Shooter now via https://lyrics.example.com/?title=six%20shooter

## Web interface

The following parameters are recognized:

- `artist`, `album`, `title`: search filters.
- `errors=on`: throw error 404 in case if nothing is found.
- `format={xhtml,text,xml}`: a stylesheet (from `XSLT_DIR` or the
  default data directory) to use.
