<?xml version="1.0" ?>
<xsl:transform
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <xsl:param name="file1"/>
    <xsl:param name="file2"/>
    
    <xsl:template match="/CruisersDinghies">
        <xsl:copy>
            <xsl:copy-of select="document($file1)" />
            <xsl:copy-of select="document($file2)" />
        </xsl:copy>
    </xsl:template>
</xsl:transform>