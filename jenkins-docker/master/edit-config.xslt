<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:domain="urn:jboss:domain:1.4">

  <xsl:param name="use-security"/>
  <xsl:param name="docker-url"/>
  <xsl:param name="oauth-client-id"/>
  <xsl:param name="oauth-client-secret"/>

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

  <xsl:template match="hudson/securityRealm">
     <xsl:element name="securityRealm">
        <xsl:attribute name="class">org.jenkinsci.plugins.GithubSecurityRealm</xsl:attribute>
        <xsl:element name="githubWebUri">https://github.com</xsl:element>
        <xsl:element name="githubApiUri">https://api.github.com</xsl:element>
        <xsl:element name="clientId"><xsl:value-of select="$oauth-client-id"/></xsl:element>
        <xsl:element name="clientSecret"><xsl:value-of select="$oauth-client-secret"/></xsl:element>
        <xsl:element name="oauthScopes">read:org,user:email</xsl:element>
     </xsl:element>
  </xsl:template>

</xsl:stylesheet>
