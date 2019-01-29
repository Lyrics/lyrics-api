<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:lyrics="urn:x-lyrics"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">
  <xsl:output method="xml" encoding="UTF-8" />

  <xsl:template match="/lyrics:songs">
    <xsl:copy-of select="." />
  </xsl:template>

</xsl:stylesheet>
