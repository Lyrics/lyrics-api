# Lyrics search API

This repository contains tools to make the lyrics database accessible
and searchable in ways other than direct file reading:

- `lyrics-to-sqlite.pl` fills an SQLite database.
- `search.pl` is a CGI script that uses that database to search for
  lyrics, and intended to serve as both a website and an API (planning
  (X)HTML+RDF output by default, textual, mimicking other services'
  schema to make scrapers work, or plain XML on request).
- `search.xsl` is a template used by `search.pl` for its default
  output.

It's not stable yet, but the intention is to get a stable database
schema, as well as a stable and specified schema of documents served
by the web API.

## Setup

You will need to install a few perl packages to get the scripts running.

For Arch Linux you will need the following packages: `perl-dbd-sqlite` (which also pulls the needed `perl-dbi`), `perl-cgi`, `perl-xml-libxml`, `perl-xml-libxslt` and `perl-text-unidecode` from AUR.

The example uses the lyrics repo cloned into your $HOME.

Then you can run `perl -I "." lyrics-to-sqlite.pl ~/lyrics/ ./lyrics.db` from the current directory to generate the database.

After the database is generated, you can try searching for Six Shooter by Coyote Kisses via
```
REQUEST_METHOD="GET" QUERY_STRING="title=six shooter&album=six shooter&artist=coyote kissesz" perl -I "." search.pl
```

Using only partial information like 'artist=coyote' will also get you a result, as the search method is quite flexible.

Now you may want to set up a webserver, here's an example server block for nginx. It assumes the repo with db file cloned into /var/www/html/.  
It also assumes that FCGI server is up and running:

```
	server {
		listen 443 ssl http2;
		listen [::]:443 ssl http2;
		server_name lyrics.example.com;
		root /var/www/html/lyrics-api;
		index search.pl;

		location / {
			fastcgi_intercept_errors on;
			include /etc/nginx/fastcgi_params;
			fastcgi_param SCRIPT_FILENAME /var/www/html/lyrics-api/search.pl;
			fastcgi_pass unix:/var/run/fcgiwrap.sock;
		}
}
```
You should be able to load Six Shooter now via https://lyrics.example.com/?title=six%20shooter
