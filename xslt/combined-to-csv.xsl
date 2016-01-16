<?xml version="1.0" encoding="UTF-8"?>
<!-- Converts the export of open office as a .fods file into the ICS format
works with the XLSX format supplied by Guy. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:p="http://www.corbas.co.uk/ns/presentations" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:verbatim="http://www.corbas.co.uk/ns/verbatim"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="p xsi"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" 
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" 
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" 
	xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" 
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
 	version="2.0">


	<xsl:output method="text" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template match="/CruisersDinghies"><xsl:apply-templates select="//event">
		<xsl:sort select="dateStart/sortBy"></xsl:sort>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="event"><xsl:value-of 
			select="normalize-space(type)"/>;<xsl:value-of 
			select="normalize-space(summary)"/>;<xsl:value-of 
			select="normalize-space(dateStart/text())"/>;<xsl:value-of  
			select="normalize-space(dateEnd/text())"/>;<xsl:value-of  
			select="normalize-space(description)"/>
<xsl:text>
</xsl:text>			
	</xsl:template>
 
 <!-- 
	<xsl:template match="event/*[position() ne last()]"><xsl:value-of select="normalize-space(.)"/><xsl:text>;</xsl:text></xsl:template>
	
	<xsl:template match="event/*[position() = last()]"><xsl:value-of 
	select="normalize-space(.)"/>
<xsl:text>
</xsl:text></xsl:template>
 -->

<xsl:template match="p"><xsl:text> </xsl:text></xsl:template>
<xsl:template match="sortBy"/>
	
</xsl:stylesheet>
