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
        <title>Lyrics</title>
      </head>
      <body>
        <xsl:apply-templates select="lyrics:song" />
      </body>
    </html>
  </xsl:template>

  <xsl:template match="lyrics:song">
    <!-- TODO: add RDFa -->
    <section>
      <h2><xsl:copy-of select="lyrics:title/text()" /></h2>
      <p>
        By <span><xsl:copy-of select="lyrics:artist/text()" /></span>,
        from <span><xsl:copy-of select="lyrics:album/text()" /></span>
      </p>
      <pre>
        <xsl:copy-of select="lyrics:lyrics/text()" />
      </pre>
    </section>
  </xsl:template>

</xsl:stylesheet>
