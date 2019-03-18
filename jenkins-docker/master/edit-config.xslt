<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:domain="urn:jboss:domain:1.4">

  <xsl:param name="use-security"/>
  <xsl:param name="docker-url"/>

  <xsl:template match="*" priority="-1">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="node()|@*" priority="-2">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="hudson/useSecurity">
     <xsl:element name="useSecurity"><xsl:value-of select="$use-security"/></xsl:element>
  </xsl:template>

  <xsl:template match="serverUrl">
     <xsl:element name="serverUrl"><xsl:value-of select="$docker-url"/></xsl:element>
  </xsl:template>

</xsl:stylesheet>
