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
   
   <xsl:key name="individual" match="Individual" use="@ID"/>
   <xsl:key name="hyperlink-internal" match="Individual" use="@IndividualInternalHyperlink"/>
   <xsl:key name="family" match="PedigreeLink[@PedigreeLink!='Parent']" use="@Individual"/>
   <xsl:key name="parent" match="PedigreeLink[@PedigreeLink='Parent']" use="@Family"/>
   <xsl:key name="marriage" match="Marriage" use="@ID"/>

   <xsl:template match="/">

      <xsl:variable name="baseIndividual" select="key('individual', $baseId)"/>

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

      <xsl:variable name="individual" select="key('individual', $id)"/>

      <xsl:choose>
         <xsl:when test="$individual/Hyperlink and $second-run != 1">
            <xsl:variable name="xref"
               select="//Individual[starts-with(@ID, substring-before($individual/Hyperlink, '.gno')) and Name/First=$individual/Name/First and Name/Last=$individual/Name/Last and Birth/Date=$individual/Birth/Date]/@ID"/>
            
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
            <xsl:variable name="hyperlink-internal" select="key('hyperlink-internal', $id)"/>
            <xsl:variable name="hyperlink-internal-reverse"
               select="key('individual', $individual/@IndividualInternalHyperlink)"/>

            <xsl:variable name="infoNode">
               <xsl:choose>
                  <xsl:when test="$hyperlink-internal and $hyperlink-internal/Gender">
                     <xsl:copy-of select="$hyperlink-internal"/>
                  </xsl:when>
                  <xsl:when test="$hyperlink-internal-reverse and $hyperlink-internal-reverse/Gender">
                     <xsl:copy-of select="$hyperlink-internal-reverse"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:copy-of select="$individual"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>

            <individual gender="{$infoNode/Individual/Gender}">

               <info>
                  <xsl:call-template name="getInfo">
                     <!-- hyperlinks have reduced info -->
                     <xsl:with-param name="individual" select="$infoNode/Individual"/>
                  </xsl:call-template>
               </info>

               <xsl:variable name="family">
                  <xsl:choose>
                     <xsl:when test="$originalId">
                        <xsl:copy-of select="
                           key('family', $originalId) |
                           key('family', $individual/@ID) | 
                           key('family', $hyperlink-internal/@ID) | 
                           key('family', $hyperlink-internal-reverse/@ID)"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:copy-of select="
                           key('family', $individual/@ID) | 
                           key('family', $hyperlink-internal/@ID) | 
                           key('family', $hyperlink-internal-reverse/@ID)"/>                        
                     </xsl:otherwise>
                  </xsl:choose>                  
               </xsl:variable>
               
               <xsl:variable name="marriage" select="key('marriage', $family/Unions[1])"/>

               <parentInfo>
                  <xsl:call-template name="getParentInfo">
                     <xsl:with-param name="marriage" select="$marriage"/>
                  </xsl:call-template>
               </parentInfo>

               <xsl:for-each select="key('parent', $family/PedigreeLink/@Family)">
                  <xsl:call-template name="getTree">
                     <xsl:with-param name="id" select="@Individual"/>
                  </xsl:call-template>
               </xsl:for-each>

            </individual>
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
