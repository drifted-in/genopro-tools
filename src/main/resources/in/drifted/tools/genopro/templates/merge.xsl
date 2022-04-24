<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright (c) 2015-present Jan Tošovský <jan.tosovsky.cz@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

   <xsl:param name="parts"/>

   <xsl:template match="/">
      <GenoPro>
      <xsl:for-each select="document(tokenize($parts, ';'))">
         <xsl:variable name="document-uri" select="document-uri(.)"/>
         <xsl:variable name="filename" select="(tokenize($document-uri,'/'))[last()]"/>
         <xsl:apply-templates select="node()">
            <xsl:with-param name="prefix" select="$filename"/>
         </xsl:apply-templates>
      </xsl:for-each>
      </GenoPro>
   </xsl:template>

   <xsl:template match="Software|GenoPro/Date|Global|GenoMaps|Places|Occupations|Bookmarks|Twins|Labels"/>
   <xsl:template match="Individual/Position|Individual/Display|Individual/Comment|Individual/child_no"/>
   <xsl:template match="Birth/Comment|Death/Comment"/>
   <xsl:template match="Family/Position"/>
   <xsl:template match="PedigreeLink/Position"/>

   <xsl:template match="GenoPro">
      <xsl:param name="prefix"/>
      <xsl:apply-templates>
         <xsl:with-param name="prefix" select="$prefix"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="node()">
      <xsl:param name="prefix"/>
      <xsl:copy>
         <xsl:copy-of select="@*[not(name()='ID' or name()='IndividualInternalHyperlink' or name()='Family' or name()='Individual')]"/>
         <xsl:if test="@ID">
            <xsl:attribute name="ID" select="concat($prefix, '-', @ID)"/>
         </xsl:if>
         <xsl:if test="@IndividualInternalHyperlink">
            <xsl:attribute name="IndividualInternalHyperlink" select="concat($prefix, '-', @IndividualInternalHyperlink)"/>
         </xsl:if>
         <xsl:if test="@Family">
            <xsl:attribute name="Family" select="concat($prefix, '-', @Family)"/>
         </xsl:if>
         <xsl:if test="@Individual">
            <xsl:attribute name="Individual" select="concat($prefix, '-', @Individual)"/>
         </xsl:if>
         <xsl:apply-templates>
            <xsl:with-param name="prefix" select="$prefix"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>

</xsl:stylesheet>
