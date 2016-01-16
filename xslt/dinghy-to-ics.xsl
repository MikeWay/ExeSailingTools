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
	<xsl:variable name="EVENT_NAME_COL" select="1"/>
<xsl:variable name="DATE_COL" select="3"/>
<xsl:variable name="TIDE_TIME_COL" select="4"/>
<xsl:variable name="TIDE_HEIGHT_COL" select="5"/>
<xsl:variable name="RACE_NUM_COLUMN" select="6"/>
<xsl:variable name="START_LOCATION_COL" select="7"/>
<xsl:variable name="RACE_TIME_COL" select="8"/>

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
	<xsl:variable name="durationStr">
		<xsl:call-template name="calculate-duration"></xsl:call-template>
	</xsl:variable>
	<xsl:variable name="duration" as="xs:dayTimeDuration"
		select="xs:dayTimeDuration($durationStr)" />
	<xsl:variable name="startTimeString">
		<xsl:call-template name="process-start-time"></xsl:call-template>
	</xsl:variable>
<xsl:text>
BEGIN:VEVENT</xsl:text>
DESCRIPTION:<xsl:text>&lt;p&gt;&lt;strong&gt;</xsl:text>
			<xsl:value-of select="table:table-cell[1]/text:p"/>
			<xsl:text>&lt;/strong&gt;&lt;/p&gt;</xsl:text>
			<xsl:apply-templates select="table:table-cell[position() &gt; $DATE_COL]/text:p"/>
SUMMARY:<xsl:value-of select="table:table-cell[$EVENT_NAME_COL]/text:p"/><xsl:text> </xsl:text><xsl:call-template name="process-start-location" />
DTSTART<xsl:call-template name="format-date">
	<xsl:with-param name="date-string"><xsl:value-of select="table:table-cell[$DATE_COL]/text:p"/></xsl:with-param>
	<xsl:with-param name="startTimeString" select="$startTimeString"/>
	<xsl:with-param name="duration" as="xs:duration" select="xs:dayTimeDuration('P0DT0H0M')"/>
</xsl:call-template>
	<xsl:text>
DTEND</xsl:text>
	<xsl:call-template name="format-date">
		<xsl:with-param name="date-string"><xsl:value-of select="table:table-cell[$DATE_COL]/text:p"/></xsl:with-param>
		<xsl:with-param name="startTimeString" select="$startTimeString"/>
		<xsl:with-param name="duration" as="xs:duration" select="$duration"/>
	</xsl:call-template>
	<xsl:text>
END:VEVENT</xsl:text>
</xsl:template>


	
	
	<xsl:template name="calculate-duration">
		<xsl:variable name="num-races" select="number(table:table-cell[6]/text:p)"/>
		<xsl:if test="string-length(table:table-cell[6]/text:p) &gt; 0" >
			P0DT0H<xsl:value-of select="$num-races * 50 + 15"/>M
		</xsl:if>
		<xsl:if test="string-length(table:table-cell[6]/text:p) = 0" >
			<!--  If no start or end then make it 24 hours -->
			<xsl:if test="string-length(table:table-cell[8]/text:p) = 0">
				<xsl:text>P0DT24H0M</xsl:text>
			</xsl:if>
			<xsl:if test="string-length(table:table-cell[8]/text:p) != 0">
				<xsl:text>P0DT12H0M</xsl:text>
			</xsl:if>			
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="process-start-time">
	<xsl:variable name="timeString" select="table:table-cell[$RACE_TIME_COL]/text:p"/>
	<xsl:variable name="isPM" select="contains($timeString, 'PM')"/>
	<xsl:if test="string-length(table:table-cell[$RACE_TIME_COL]/text:p) &gt; 0">
		<xsl:variable name="startTimeStr" select="table:table-cell[8]/text:p"/>
		<xsl:if test="string-length($startTimeStr) &gt; 0">
			<xsl:variable name="startHMStr" select="substring-before($startTimeStr, ' ')"/>
			<xsl:variable name="startHoursStr" select="substring-before($startHMStr, '.')"/>
			<xsl:variable name="startMinsStr" select="substring($startHMStr, string-length($startHMStr) -1)"/>
			<xsl:variable name="ISOTimeStr">
				<xsl:if test="$isPM">
				<xsl:number format="01" value="number($startHoursStr) + 12"/>:<xsl:value-of 
						select="$startMinsStr"/>
				</xsl:if>
				<xsl:if test="not($isPM)">
				<xsl:number format="01" value="number($startHoursStr)"/>:<xsl:value-of 
						select="$startMinsStr"/>
				</xsl:if>
			<xsl:text>:00</xsl:text></xsl:variable>		
			<xsl:value-of select="$ISOTimeStr"/>
		</xsl:if>
	</xsl:if>
	<!-- Empty string if no start time
	<xsl:if test="string-length(table:table-cell[$RACE_TIME_COL]/text:p) = 0">
			00:00:00
	</xsl:if>
	 -->
	</xsl:template>
	<!-- tide time -->
	<xsl:template match="table:table-cell[$TIDE_TIME_COL]/text:p">
		<xsl:text>&lt;p&gt;Tide: </xsl:text>
		<xsl:value-of select="." />
	</xsl:template>

	<!-- Tide height -->
	<xsl:template match="table:table-cell[$TIDE_HEIGHT_COL]/text:p">
		<xsl:variable name="height"><xsl:value-of select="number(.)"/></xsl:variable>
		<xsl:if test="$height &gt; 1.5"> HW: <xsl:value-of select="."/>M </xsl:if>
		<xsl:if test="$height &lt;= 1.5"> LW: <xsl:value-of select="."/>M </xsl:if>
		<xsl:text>&lt;/p&gt;</xsl:text>
	</xsl:template>

	<!-- Number of races -->
	<xsl:template match="table:table-cell[$RACE_NUM_COLUMN]/text:p">
		<xsl:value-of select="." />
		<xsl:text>Race(s),</xsl:text>
	</xsl:template>



	<xsl:template name="process-start-location">

		<xsl:if test = "not(table:table-cell[$START_LOCATION_COL]/text:p) and table:table-cell[$RACE_NUM_COLUMN]/text:p">
		<xsl:text>River Start</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="table:table-cell[$START_LOCATION_COL]/text:p"/>

	</xsl:template>
	
	<xsl:template match="table:table-cell[$START_LOCATION_COL]/text:p">
		
		<xsl:choose>
			<xsl:when test="(contains(.,'US'))">
				<xsl:text>Up-Spirits Start.</xsl:text>
			</xsl:when>
			<xsl:when test="(contains(.,'SB'))">
				<xsl:text>Start-Box Start.</xsl:text>
			</xsl:when>

			<xsl:otherwise>
				
				<xsl:value-of select="." />
				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<xsl:template match="table:table-cell[$RACE_TIME_COL]/text:p">
		<xsl:text>&lt;p&gt;Race Time: </xsl:text>
		<xsl:value-of select="." />
		<xsl:text>&lt;p&gt;</xsl:text>
	</xsl:template>	
	
		
	<xsl:template name="format-date">
		<xsl:param name="date-string"/>
		<xsl:param name="duration" as="xs:duration"/>
		<xsl:param name="startTimeString" />
	
		<xsl:variable name="month-string" select="substring($date-string, string-length($date-string)-2)"/>
	
		<xsl:variable name="day-string" select="substring-before($date-string, '-')"/>
		<xsl:variable name="month-number"><xsl:value-of select="format-number(
	                        string-length(substring-before(
	     'JanFebMarAprMayJunJulAugSepOctNovDec',
	         substring($month-string,1,3))) div 3 + 1,'00')"/></xsl:variable>
	         
	    <xsl:if test="string-length($startTimeString) &gt; 0">
		    <xsl:variable name="generated-date-string">2016-<xsl:value-of 
		    	select="$month-number"/>-<xsl:value-of 
		    	select="$day-string"/>T<xsl:value-of select="$startTimeString"/></xsl:variable>
		
		    
		    <xsl:if test="string-length($day-string) &gt; 0">
				<xsl:variable name="date" select="xs:dateTime($generated-date-string)"/>
		    	<xsl:text>;TZID=Europe/London:</xsl:text><xsl:value-of select="format-dateTime($date + $duration, '[Y0001][M01][D01]T[H01]:[m01]')"/>
		    </xsl:if>
	     </xsl:if>
	    <xsl:if test="string-length($startTimeString) = 0">
		    <xsl:variable name="generated-date-string">2016-<xsl:value-of 
		    	select="$month-number"/>-<xsl:value-of 
		    	select="$day-string"/></xsl:variable>
		
		    
		    <xsl:if test="string-length($day-string) &gt; 0">
				<xsl:variable name="date" select="xs:date($generated-date-string)"/>
		    	<xsl:text>;VALUE=DATE:</xsl:text><xsl:value-of select="format-date($date + $duration, '[Y0001][M01][D01]')"/>
		    </xsl:if>
	     </xsl:if>	     
	</xsl:template>
</xsl:stylesheet>
