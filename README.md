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
