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
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://exslt.org/math"
   exclude-result-prefixes="xs math" version="2.0">

   <xsl:output indent="yes"/>

   <xsl:param name="baseId"/>

   <xsl:key name="individual-by-id" match="Individual" use="@ID"/>
   <xsl:key name="individual-by-hyperlink" match="Individual" use="@IndividualInternalHyperlink"/>
   <xsl:key name="family-child-link-by-child-id" match="PedigreeLink[@PedigreeLink!='Parent']" use="@Individual"/>
   <xsl:key name="family-parent-link-by-family-id" match="PedigreeLink[@PedigreeLink='Parent']" use="@Family"/>
   <xsl:key name="marriage" match="Marriage" use="@ID"/>

   <xsl:template match="/">

      <xsl:variable name="baseIndividual" select="key('individual-by-id', $baseId)"/>

      <xsl:choose>
         <xsl:when test="$baseIndividual">
            <xsl:call-template name="getTree">
               <xsl:with-param name="id" select="$baseId"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">Individual with the specified ID hasn't been found:
                  <xsl:value-of select="$baseId"/></xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getTree">
      <xsl:param name="id"/>
      <xsl:param name="second-run" select="0"/>
      <xsl:param name="originalId"/>

      <!--
      <xsl:value-of select="concat('&#10;', 'PROCESSING_ID: ', $id, '&#10;')"/>
      -->

      <xsl:variable name="individual" select="key('individual-by-id', $id)"/>
      <xsl:variable name="referenced-individual-id" select="$individual/@IndividualInternalHyperlink"/>
      <xsl:variable name="hyperlink" select="$individual/Hyperlink"/>

      <xsl:choose>
         <xsl:when test="$hyperlink and not(contains($hyperlink, 'nofollow')) and $second-run != 1">
            <xsl:variable name="individuals">
               <xsl:if test="contains($hyperlink, '?id=')">
                  <xsl:variable name="id" select="concat(substring-before($hyperlink, '.gno'), '-', substring-after($hyperlink, '?id='))"/>
                  <xsl:copy-of select="key('individual-by-id', $id)"/>
               </xsl:if>
               <xsl:copy-of select="//Individual[starts-with(@ID, substring-before($hyperlink, '.gno')) and Name/First=$individual/Name/First and Name/Last=$individual/Name/Last and Birth/Date=$individual/Birth/Date]"/>
            </xsl:variable>
            <xsl:variable name="xref" select="$individuals/Individual[1]/@ID"/>
            <xsl:call-template name="getTree">
               <xsl:with-param name="second-run" select="1"/>
               <xsl:with-param name="id">
                  <xsl:choose>
                     <xsl:when test="$xref">
                        <xsl:value-of select="$xref"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$id"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:with-param>
               <xsl:with-param name="originalId">
                  <xsl:if test="$xref">
                     <xsl:value-of select="$id"/>
                  </xsl:if>
               </xsl:with-param>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="individual-by-hyperlink" select="key('individual-by-hyperlink', $id)"/>
            <xsl:variable name="individual-by-reverse-hyperlink" select="key('individual-by-id', $referenced-individual-id)"/>

            <xsl:variable name="infoNode">
               <xsl:choose>
                  <xsl:when test="$individual-by-hyperlink and $individual-by-hyperlink/Gender">
                     <xsl:copy-of select="$individual-by-hyperlink"/>
                  </xsl:when>
                  <xsl:when test="$individual-by-reverse-hyperlink and $individual-by-reverse-hyperlink/Gender">
                     <xsl:copy-of select="$individual-by-reverse-hyperlink"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:copy-of select="$individual"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>

            <xsl:variable name="info">
               <info>
                  <xsl:call-template name="getInfo">
                     <!-- hyperlinks have reduced info -->
                     <xsl:with-param name="individual" select="$infoNode/Individual"/>
                  </xsl:call-template>
               </info>
            </xsl:variable>

            <xsl:variable name="family-child-link">
               <xsl:if test="$originalId">
                  <xsl:copy-of select="key('family-child-link-by-child-id', $originalId)"/>
               </xsl:if>
               <xsl:copy-of select="
                  key('family-child-link-by-child-id', $id) |
                  key('family-child-link-by-child-id', $individual-by-hyperlink/@ID) |
                  key('family-child-link-by-child-id', $individual-by-reverse-hyperlink/@ID)"/>
            </xsl:variable>

            <!-- this simplification doesn't produce the same result -->
            <!--
            <xsl:variable name="family-child-link">
               <xsl:copy-of select="key('family-child-link-by-child-id', $infoNode/Individual/@ID)"/>
            </xsl:variable>
            -->

            <xsl:variable name="marriage" select="key('marriage', $family-child-link/Unions[1])"/>

            <xsl:variable name="parentInfo">
               <parentInfo>
                  <xsl:call-template name="getParentInfo">
                     <xsl:with-param name="marriage" select="$marriage"/>
                  </xsl:call-template>
               </parentInfo>
            </xsl:variable>

            <xsl:if test="normalize-space($info) != '' or normalize-space($parentInfo) != ''">

               <individual gender="{$infoNode/Individual/Gender}">

                  <xsl:copy-of select="$info"/>
                  <xsl:copy-of select="$parentInfo"/>

                  <xsl:for-each select="key('family-parent-link-by-family-id', $family-child-link/PedigreeLink/@Family)">
                     <xsl:call-template name="getTree">
                        <xsl:with-param name="id" select="@Individual"/>
                     </xsl:call-template>
                  </xsl:for-each>

               </individual>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>

   <xsl:template name="getInfo">
      <xsl:param name="individual"/>
      <firstname>
         <xsl:value-of select="$individual/Name/First"/>
      </firstname>
      <lastname>
         <xsl:value-of select="$individual/Name/Last"/>
      </lastname>
      <birthdate>
         <xsl:value-of select="$individual/Birth/Date"/>
      </birthdate>
      <deathdate>
         <xsl:value-of select="$individual/Death/Date"/>
      </deathdate>
   </xsl:template>

   <xsl:template name="getParentInfo">
      <xsl:param name="marriage"/>

      <xsl:value-of select="$marriage/Date"/>

   </xsl:template>

</xsl:stylesheet>
