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
        <xsl:choose>
          <!-- Multiple matches, list them -->
          <xsl:when test="lyrics:song[2]">
            <ul>
              <xsl:apply-templates select="lyrics:song" mode="listing" />
            </ul>
          </xsl:when>

          <!-- Single match, show the lyrics -->
          <xsl:when test="lyrics:song">
            <xsl:apply-templates select="lyrics:song" />
          </xsl:when>

          <!-- No matches -->
          <xsl:otherwise>
            No matching lyrics found.
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="lyrics:song" mode="listing">
    <!-- TODO: add RDFa -->
    <li>
      <a href="{lyrics:url/text()}">
        <xsl:copy-of select="lyrics:artist/text()" /> -
        <xsl:copy-of select="lyrics:album/text()" /> -
        <xsl:copy-of select="lyrics:title/text()" />
      </a>
    </li>
  </xsl:template>

  <xsl:template match="lyrics:song">
    <!-- TODO: add RDFa -->
    <h1><xsl:copy-of select="lyrics:title/text()" /></h1>
    <p>
      By <span><xsl:copy-of select="lyrics:artist/text()" /></span>,
      from <span><xsl:copy-of select="lyrics:album/text()" /></span>
    </p>
    <pre>
      <xsl:copy-of select="lyrics:lyrics/text()" />
    </pre>
  </xsl:template>

</xsl:stylesheet>
