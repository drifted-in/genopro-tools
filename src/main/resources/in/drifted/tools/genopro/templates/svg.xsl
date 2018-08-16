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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://exslt.org/math"
   xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:d="http://drifted.in"
   exclude-result-prefixes="xs math svg d" version="2.0">

   <xsl:output indent="yes"/>

   <xsl:param name="generations" as="xs:integer" select="8"/>
   <xsl:param name="width" as="xs:integer" select="420"/>
   <xsl:param name="units" as="xs:string">mm</xsl:param>
   <xsl:param name="font-size" as="xs:double" select="$size div (18.75 * $generations)"/>
   <xsl:param name="font-family" as="xs:string">sans-serif</xsl:param>
   <xsl:param name="grid-color" as="xs:string">navy</xsl:param>

   <xsl:variable name="height" as="xs:integer" select="xs:integer(round($width div 2))"/>
   <xsl:variable name="size" as="xs:integer" select="1000"/>
   <xsl:variable name="pi" select="math:constant('PI', 8)" as="xs:double"/>

   <xsl:variable name="multipliers">
      <multiplier generation="0">1</multiplier>
      <multiplier generation="1">1</multiplier>
      <multiplier generation="2">1</multiplier>
      <multiplier generation="3">1</multiplier>
      <multiplier generation="4">2</multiplier>
      <multiplier generation="5">2</multiplier>
      <multiplier generation="6">2</multiplier>
      <multiplier generation="7">2</multiplier>
      <multiplier generation="8">2</multiplier>
   </xsl:variable>

   <xsl:variable name="step" as="xs:double">
      <xsl:value-of select="0.5 * $size div (1 + sum($multipliers/multiplier[@generation &lt;= $generations]))"/>
   </xsl:variable>

   <xsl:template match="/">
      <svg:svg version="1.1" width="{concat($width, $units)}" height="{concat($height, $units)}"
         viewBox="{-$size div 2} {-$size div 2} {$size} {$size div 2}">
         <svg:style xml:space="preserve">
            path {
               fill: none;
            }
            circle {
               fill: <xsl:value-of select="$grid-color"/>;
            }
            text{
               font: <xsl:value-of select="$font-size"/>px <xsl:value-of select="$font-family"/>;
            }
            .grid {
               stroke-width: <xsl:value-of select="$size div (750 * $generations)"/>px;
               stroke: <xsl:value-of select="$grid-color"/>;
               fill: none;
            }
         </svg:style>
         <svg:g transform="translate(0, {-$step div 2})">
            <xsl:apply-templates>
               <xsl:with-param name="n" select="0"/>
            </xsl:apply-templates>
         </svg:g>
      </svg:svg>
   </xsl:template>

   <xsl:template match="individual">
      <xsl:param name="n"/>
      <xsl:if test="normalize-space(info) != ''">
         <xsl:variable name="generation" select="count(ancestor::individual)" as="xs:integer"/>
         <xsl:variable name="correction" as="xs:integer">
            <xsl:choose>
               <xsl:when test="$generation = 0 or @gender = 'M'">0</xsl:when>
               <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="segment" select="$n * 2 + $correction" as="xs:integer"/>
         <xsl:call-template name="renderSegment">
            <xsl:with-param name="generation" select="$generation"/>
            <xsl:with-param name="segment" select="$segment"/>
            <xsl:with-param name="content" select="info"/>
            <xsl:with-param name="hasChildren">
               <xsl:choose>
                  <xsl:when test="individual">1</xsl:when>
                  <xsl:otherwise>0</xsl:otherwise>
               </xsl:choose>
            </xsl:with-param>
         </xsl:call-template>
         <xsl:apply-templates select="individual">
            <xsl:with-param name="n" select="$segment"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>

   <xsl:template name="getRadiusOuter">
      <xsl:param name="generation"/>
      <xsl:value-of select="$step * sum($multipliers/multiplier[@generation &lt;= $generation])"/>
   </xsl:template>

   <xsl:template name="getRadiusInner">
      <xsl:param name="generation"/>
      <xsl:value-of select="$step * sum($multipliers/multiplier[@generation &lt; $generation])"/>
   </xsl:template>

   <xsl:template name="renderSegment">

      <xsl:param name="generation" select="0"/>
      <xsl:param name="segment" select="1"/>
      <xsl:param name="content">content</xsl:param>
      <xsl:param name="hasChildren" select="0"/>

      <xsl:variable name="id" select="concat('i', $generation, '_', $segment)" as="xs:string"/>

      <xsl:choose>
         <xsl:when test="$generation = 0">
            <xsl:variable name="stepRounded" select="d:round($step)" as="xs:double"/>
            <xsl:variable name="y1" select="d:round((-0.25 * $step - 1.2 * $font-size))" as="xs:double"/>
            <xsl:variable name="y2" select="d:round((-0.25 * $step))" as="xs:double"/>

            <svg:path d="M{-$stepRounded} 0 A{$stepRounded} {$stepRounded} 0 0 1 {$stepRounded} 0z" class="grid"/>
            <svg:text x="0" y="{$y1}" text-anchor="middle">
               <xsl:value-of select="$content/firstname"/>
            </svg:text>
            <svg:text x="0" y="{$y2}" text-anchor="middle">
               <xsl:value-of select="$content/lastname"/>
            </svg:text>
         </xsl:when>
         <xsl:when test="$generation > $generations"/>

         <xsl:otherwise>

            <xsl:variable name="radiusOuter" as="xs:double">
               <xsl:call-template name="getRadiusOuter">
                  <xsl:with-param name="generation" select="$generation"/>
               </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="radiusInner" as="xs:double">
               <xsl:call-template name="getRadiusInner">
                  <xsl:with-param name="generation" select="$generation"/>
               </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="angle" select="$pi div math:power(2, $generation)" as="xs:double"/>
            <xsl:variable name="angleStart" select="$pi - $segment * $angle" as="xs:double"/>
            <xsl:variable name="angleEnd" select="$pi - ($segment + 1) * $angle" as="xs:double"/>
            <xsl:variable name="angleMiddle" select="($angleStart + $angleEnd) div 2" as="xs:double"/>

            <xsl:call-template name="renderSegmentBorder">
               <xsl:with-param name="radiusOuter" select="$radiusOuter"/>
               <xsl:with-param name="radiusInner" select="$radiusInner"/>
               <xsl:with-param name="angleStart" select="$angleStart"/>
               <xsl:with-param name="angleEnd" select="$angleEnd"/>
            </xsl:call-template>

            <xsl:if test="$generation = $generations and $hasChildren = 1">
               <xsl:variable name="cx" select="d:round(($step * 0.2 + $radiusOuter) * math:cos($angleMiddle))" as="xs:double"/>
               <xsl:variable name="cy" select="d:round(($step * 0.2 + $radiusOuter) * math:sin($angleMiddle))" as="xs:double"/>
               <svg:circle cx="{$cx}" cy="{-$cy}" r="{$size div (125 * $generations)}"/>
            </xsl:if>

            <xsl:choose>
               <xsl:when test="$generation > 3">

                  <xsl:variable name="mox" select="d:round($radiusOuter * math:cos($angleMiddle))" as="xs:double"/>
                  <xsl:variable name="moy" select="d:round($radiusOuter * math:sin($angleMiddle))" as="xs:double"/>
                  <xsl:variable name="mix" select="d:round($radiusInner * math:cos($angleMiddle))" as="xs:double"/>
                  <xsl:variable name="miy" select="d:round($radiusInner * math:sin($angleMiddle))" as="xs:double"/>

                  <xsl:variable name="segmentCount" select="math:power(2, $generation)" as="xs:integer"/>

                  <xsl:choose>
                     <xsl:when test="$segment >= ($segmentCount div 2)">
                        <svg:path id="{$id}_m" d="M{$mix} {-$miy} L{$mox} {-$moy}"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <svg:path id="{$id}_m" d="M{$mox} {-$moy} L{$mix} {-$miy}"/>
                     </xsl:otherwise>
                  </xsl:choose>

                  <xsl:variable name="font-size-current" as="xs:double">
                     <xsl:choose>
                        <xsl:when test="$generation > 6">
                           <xsl:value-of select="0.7 * $font-size"/>
                        </xsl:when>
                        <xsl:when test="$generation > 5">
                           <xsl:value-of select="0.8 * $font-size"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="$font-size"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:variable>

                  <xsl:choose>
                     <xsl:when test="$generation > 6">
                        <svg:text text-anchor="middle" style="font-size:{$font-size-current}px">
                           <svg:textPath xlink:href="#{$id}_m" startOffset="50%">
                              <svg:tspan dy="{d:round(0.5 * $font-size-current)}">
                                 <xsl:value-of select="$content/firstname"/>
                                 <xsl:text> </xsl:text>
                                 <xsl:value-of select="$content/lastname"/>
                              </svg:tspan>
                           </svg:textPath>
                        </svg:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <svg:text text-anchor="middle" style="font-size:{$font-size-current}px">
                           <svg:textPath xlink:href="#{$id}_m" startOffset="50%">
                              <svg:tspan dy="{d:round(-0.1 * $font-size-current)}">
                                 <xsl:value-of select="$content/firstname"/>
                              </svg:tspan>
                           </svg:textPath>
                        </svg:text>

                        <svg:text text-anchor="middle" style="font-size:{$font-size-current}px">
                           <svg:textPath xlink:href="#{$id}_m" startOffset="50%">
                              <svg:tspan dy="{d:round(1.1 * $font-size-current)}">
                                 <xsl:value-of select="$content/lastname"/>
                              </svg:tspan>
                           </svg:textPath>
                        </svg:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:call-template name="renderArc">
                     <xsl:with-param name="id" select="concat($id, '_f')"/>
                     <xsl:with-param name="radius" select="($radiusOuter + $radiusInner) div 2 + 0.1 * $font-size"/>
                     <xsl:with-param name="angleStart" select="$angleStart"/>
                     <xsl:with-param name="angleEnd" select="$angleEnd"/>
                  </xsl:call-template>

                  <svg:text text-anchor="middle">
                     <svg:textPath xlink:href="#{$id}_f" startOffset="50%">
                        <xsl:value-of select="$content/firstname"/>
                     </svg:textPath>
                  </svg:text>

                  <xsl:call-template name="renderArc">
                     <xsl:with-param name="id" select="concat($id, '_l')"/>
                     <xsl:with-param name="radius" select="($radiusOuter + $radiusInner) div 2 - 1.1 * $font-size"/>
                     <xsl:with-param name="angleStart" select="$angleStart"/>
                     <xsl:with-param name="angleEnd" select="$angleEnd"/>
                  </xsl:call-template>

                  <svg:text text-anchor="middle">
                     <svg:textPath xlink:href="#{$id}_l" startOffset="50%">
                        <xsl:value-of select="$content/lastname"/>
                     </svg:textPath>
                  </svg:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="renderSegmentBorder">

      <xsl:param name="radiusOuter" as="xs:double"/>
      <xsl:param name="radiusInner" as="xs:double"/>
      <xsl:param name="angleStart" as="xs:double"/>
      <xsl:param name="angleEnd" as="xs:double"/>

      <xsl:variable name="ox1" select="d:round($radiusOuter * math:cos($angleStart))" as="xs:double"/>
      <xsl:variable name="oy1" select="d:round($radiusOuter * math:sin($angleStart))" as="xs:double"/>
      <xsl:variable name="ox2" select="d:round($radiusOuter * math:cos($angleEnd))" as="xs:double"/>
      <xsl:variable name="oy2" select="d:round($radiusOuter * math:sin($angleEnd))" as="xs:double"/>
      <xsl:variable name="ix1" select="d:round($radiusInner * math:cos($angleStart))" as="xs:double"/>
      <xsl:variable name="iy1" select="d:round($radiusInner * math:sin($angleStart))" as="xs:double"/>
      <xsl:variable name="ix2" select="d:round($radiusInner * math:cos($angleEnd))" as="xs:double"/>
      <xsl:variable name="iy2" select="d:round($radiusInner * math:sin($angleEnd))" as="xs:double"/>

      <xsl:variable name="radiusOuterRounded" select="d:round($radiusOuter)" as="xs:double"/>
      <xsl:variable name="radiusInnerRounded" select="d:round($radiusInner)" as="xs:double"/>

      <svg:path
         d="M{$ox1} {-$oy1} A{$radiusOuterRounded} {$radiusOuterRounded} 0 0 1 {$ox2} {-$oy2} L{$ix2} {-$iy2} A{$radiusInnerRounded} {$radiusInnerRounded} 0 0 0 {$ix1} {-$iy1}z"
         class="grid"/>

   </xsl:template>

   <xsl:template name="renderArc">

      <xsl:param name="id" as="xs:string"/>
      <xsl:param name="radius" as="xs:double"/>
      <xsl:param name="angleStart" as="xs:double"/>
      <xsl:param name="angleEnd" as="xs:double"/>

      <xsl:variable name="fnx1" select="d:round($radius * math:cos($angleStart))" as="xs:double"/>
      <xsl:variable name="fny1" select="d:round($radius * math:sin($angleStart))" as="xs:double"/>
      <xsl:variable name="fnx2" select="d:round($radius * math:cos($angleEnd))" as="xs:double"/>
      <xsl:variable name="fny2" select="d:round($radius * math:sin($angleEnd))" as="xs:double"/>

      <xsl:variable name="radiusRounded" select="d:round($radius)" as="xs:double"/>

      <svg:path id="{$id}" d="M{$fnx1} {-$fny1} A{$radiusRounded} {$radiusRounded} 0 0 1 {$fnx2} {-$fny2}"/>

   </xsl:template>

   <xsl:function name="d:round" as="xs:double">
      <xsl:param name="number"/>
      <xsl:value-of select="round($number * 1000) div 1000"/>
   </xsl:function>

</xsl:stylesheet>
