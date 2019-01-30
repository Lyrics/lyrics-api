<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:lyrics="urn:x-lyrics"
                xmlns:mo="http://purl.org/ontology/mo/"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">
  <xsl:output method="xml" encoding="UTF-8" />

  <xsl:template match="/lyrics:songs">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title><xsl:copy-of select="lyrics:song/lyrics:artist/text()"/>:<xsl:copy-of select="lyrics:song/lyrics:title/text()"/> Lyrics -</title>
      </head>
      <body>
        <xsl:text disable-output-escaping='yes'>&lt;div class='lyricbox'&gt;</xsl:text>
        <xsl:copy-of select="lyrics:song/lyrics:lyrics/text()" />
        <xsl:text disable-output-escaping='yes'>&lt;/div&gt;</xsl:text>

        <!-- The ending was changed in Clementine commit 19b5111,
             mimicking both here -->
        <xsl:text disable-output-escaping='yes'>&lt;div class='lyricsbreak' /&gt;</xsl:text>
        <xsl:text disable-output-escaping='yes'>&lt;!--</xsl:text>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
