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

For Arch Linux you will need the following packages: `perl-dbd-sqlite` (which also pulls the needed `perl-dbi`), `perl-cgi`, `perl-xml-libxml` and `perl-xml-libxslt`.

You need to clone the lyrics repo into the folder above lyrics-api.

Then you can run `perl lyrics-to-sqlite.pl` to generate the database.

After the database is generated, you can try searching for Six Shooter by Coyote Kisses via `REQUEST_METHOD="GET" QUERY_STRING="title=six shooter&album=six shooter&artist=coyote kissesz" perl search.pl`
Using only partial information like 'artist=coyote' will also get you a result, as the search method is quite flexible.

Now you may want to set up a webserver, the example will use nginx:

TODO