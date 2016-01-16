<?xml version="1.0" encoding="UTF-8"?>
<!-- Converts the export of open office as a .fods file into the ICS format
works with the XLSX format supplied by Guy. -->
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


	<xsl:output method="text" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
<xsl:variable name="DATE_COL" select="1"/>
<xsl:variable name="END_DATE_COL" select="2"/>
<xsl:variable name="EVENT_NAME_COL" select="3"/>
<xsl:variable name="EVENT_DETAIL_COL" select="4"/>
<xsl:variable name="START_TIME_COL" select="5"/>
<xsl:variable name="END_TIME_COL" select="6"/>
<xsl:variable name="HW_COL" select="7"/>
<xsl:variable name="LW_COL" select="8"/>


<xsl:template match="/">
<xsl:apply-templates select="descendant::office:spreadsheet"></xsl:apply-templates>
</xsl:template>
<xsl:template match="office:spreadsheet">
<xsl:text>BEGIN:VCALENDAR</xsl:text>
VERSION:2.0
X-WR-TIMEZONE:Europe/London<xsl:apply-templates />
END:VCALENDAR
</xsl:template>




<xsl:template match="table:table-row[descendant::text:p]">
	<xsl:variable name="startTimeString" select="table:table-cell[$START_TIME_COL]/text:p"/>
	<xsl:variable name="endTimeString" select="table:table-cell[$END_TIME_COL]/text:p"/>
<xsl:text>
BEGIN:VEVENT</xsl:text>
DESCRIPTION:<xsl:apply-templates select="table:table-cell[$EVENT_DETAIL_COL]/text:p"/>
			<xsl:apply-templates select="table:table-cell[$HW_COL]/text:p"/>
			<xsl:apply-templates select="table:table-cell[$LW_COL]/text:p"/>		
SUMMARY:<xsl:value-of select="table:table-cell[$EVENT_NAME_COL]/text:p"/><xsl:text> </xsl:text>
DTSTART<xsl:call-template name="format-date">
	<xsl:with-param name="date-string"><xsl:value-of select="table:table-cell[$DATE_COL]/text:p"/></xsl:with-param>
	<xsl:with-param name="timeString" select="$startTimeString"/>
	
</xsl:call-template>
	<xsl:text>
DTEND</xsl:text>
	<xsl:call-template name="format-date">
		<xsl:with-param name="date-string"><xsl:value-of select="table:table-cell[$END_DATE_COL]/text:p"/></xsl:with-param>
		<xsl:with-param name="timeString" select="$endTimeString"/>
		
	</xsl:call-template>
	<xsl:text>
END:VEVENT</xsl:text>
</xsl:template>

<xsl:template match="table:table-cell[$EVENT_DETAIL_COL]/text:p">
	<xsl:text>&lt;p&gt;&lt;strong&gt;</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>&lt;/strong&gt;&lt;/p&gt;</xsl:text>
</xsl:template>	

<xsl:template match="table:table-cell[$HW_COL]/text:p">
	<xsl:text>&lt;p&gt;HW: </xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>&lt;/p&gt;</xsl:text>
</xsl:template>	

<xsl:template match="table:table-cell[$LW_COL]/text:p">
	<xsl:text>&lt;p&gt;LW: </xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>&lt;/p&gt;</xsl:text>
</xsl:template>	
	
	<xsl:template name="process-start-time">
	<xsl:if test="string-length(table:table-cell[$START_TIME_COL]/text:p) &gt; 0">
		<xsl:variable name="startTimeStr" select="table:table-cell[8]/text:p"/>
		<xsl:if test="string-length($startTimeStr) &gt; 0">
			<xsl:variable name="startHMStr" select="substring-before($startTimeStr, ' ')"/>
			<xsl:variable name="startHoursStr" select="substring-before($startHMStr, '.')"/>
			<xsl:variable name="startMinsStr" select="substring($startHMStr, string-length($startHMStr) -1)"/>
			<xsl:number format="01" value="number($startHoursStr)"/>:<xsl:value-of 
						select="$startMinsStr"/>:00		
		</xsl:if>
	</xsl:if>
	</xsl:template>



	
		
	<xsl:template name="format-date">
		<xsl:param name="date-string"/>
		<xsl:param name="timeString" />
	
		<xsl:variable name="day-string" select="substring($date-string,1, 2)"/>
		<xsl:variable name="month-string" select="substring($date-string,  4, 2)"/>
		<xsl:variable name="year-string" select="substring($date-string, 7, 4)"/>

	    <xsl:if test="string-length($timeString) &gt; 0">
		    <xsl:variable name="generated-date-string"><xsl:value-of 
		    	select="$year-string"/>-<xsl:value-of 
		    	select="$month-string"/>-<xsl:value-of 
		    	select="$day-string"/>T<xsl:value-of select="$timeString"/>:00</xsl:variable>
		
		    
		    <xsl:if test="string-length($day-string) &gt; 0">
				<xsl:variable name="date" select="xs:dateTime($generated-date-string)"/>
		    	<xsl:text>;TZID=Europe/London:</xsl:text><xsl:value-of select="format-dateTime($date, '[Y0001][M01][D01]T[H01]:[m01]')"/>
		    </xsl:if>
	     </xsl:if>
	    <xsl:if test="string-length($timeString) = 0">
		    <xsl:variable name="generated-date-string"><xsl:value-of 
		    	select="$year-string"/>-<xsl:value-of 
		    	select="$month-string"/>-<xsl:value-of 
		    	select="$day-string"/></xsl:variable>
		
		    
		    <xsl:if test="string-length($day-string) &gt; 0">
				<xsl:variable name="date" select="xs:date($generated-date-string)"/>
		    	<xsl:text>;VALUE=DATE:</xsl:text><xsl:value-of select="format-date($date, '[Y0001][M01][D01]')"/>
		    </xsl:if>
	     </xsl:if>	     
	</xsl:template>
</xsl:stylesheet>
