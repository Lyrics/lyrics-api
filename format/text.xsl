<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lyrics="urn:x-lyrics"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">
  <xsl:output method="text" omit-xml-declaration="yes" />

  <xsl:template match="/lyrics:songs">
    <xsl:apply-templates select="lyrics:song" />
  </xsl:template>

  <xsl:template match="lyrics:song">
    <xsl:copy-of select="lyrics:lyrics/text()" />
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
