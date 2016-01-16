<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:p="http://www.corbas.co.uk/ns/presentations" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.corbas.co.uk/ns/presentations"
	xmlns:verbatim="http://www.corbas.co.uk/ns/verbatim"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="p xsi"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" 
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" 
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" 
	xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" 
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	
 
  
 	version="2.0">


	<xsl:output method="xml" encoding="utf-8"/>

<xsl:template match="/">
	<xsl:apply-templates select="node()"/>
</xsl:template>


 <xsl:template match="table:table-cell[number(@table:number-columns-repeated) &lt; 10]">
     <xsl:call-template name="applyNTimes">
         <xsl:with-param name="pTimes" select="@table:number-columns-repeated"/>
         <xsl:with-param name="pPosition" select="1"/>
     </xsl:call-template>
 </xsl:template>
 
 
 <xsl:template name="applyNTimes">
     <xsl:param name="pTimes" select="0"/>
     <xsl:param name="pPosition" select="1"/>
     <xsl:if test="$pTimes > 0">
         <xsl:choose>
         <xsl:when test="$pTimes = 1">
        
           <xsl:copy>
             <xsl:copy-of select="@*"/>
             <xsl:attribute name="copied"><xsl:number/></xsl:attribute>
             <xsl:apply-templates/>
          </xsl:copy>
         </xsl:when>
         <xsl:otherwise>
             <xsl:variable name="vHalf" select="floor($pTimes div 2)"/>

             <xsl:call-template name="applyNTimes">
             <xsl:with-param name="pTimes" select="$vHalf"/>
             <xsl:with-param name="pPosition" select="$pPosition"/>
             </xsl:call-template>

             <xsl:call-template name="applyNTimes">
             <xsl:with-param name="pTimes" select="$pTimes - $vHalf"/>
             <xsl:with-param name="pPosition" select="$pPosition + $vHalf"/>
             </xsl:call-template>
         </xsl:otherwise>
         </xsl:choose>
     </xsl:if>
 </xsl:template>



  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
