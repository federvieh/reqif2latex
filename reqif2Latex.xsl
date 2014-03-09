<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="specmode" select="'spec'"/>
  <xsl:output method="text"/>
  <xsl:key name="req_text" match="/REQ-IF/CORE-CONTENT/REQ-IF-CONTENT/SPEC-OBJECTS/SPEC-OBJECT" use="@IDENTIFIER"/>
  <xsl:key name="attr_type" match="/REQ-IF/CORE-CONTENT/REQ-IF-CONTENT/SPEC-TYPES/SPEC-OBJECT-TYPE/SPEC-ATTRIBUTES/ATTRIBUTE-DEFINITION-STRING" use="@IDENTIFIER"/>
  <xsl:key name="obj_type" match="/REQ-IF/CORE-CONTENT/REQ-IF-CONTENT/SPEC-TYPES/SPEC-OBJECT-TYPE" use="@IDENTIFIER"/>

  <xsl:template match="/">
      <xsl:apply-templates select="/REQ-IF/CORE-CONTENT/REQ-IF-CONTENT/SPECIFICATIONS/SPECIFICATION"/>
  </xsl:template>

  <!-- We start with the specification -->
  <xsl:template match="/REQ-IF/CORE-CONTENT/REQ-IF-CONTENT/SPECIFICATIONS/SPECIFICATION">
\documentclass[a4paper,notitlepage]{scrartcl}  
\begin{document}
\title{<xsl:value-of select="VALUES/ATTRIBUTE-VALUE-STRING/@THE-VALUE"/>}
\maketitle
      <xsl:apply-templates select="CHILDREN">
        <xsl:with-param name="level" select="1"/>
      </xsl:apply-templates>
\end{document}
  </xsl:template>

  <xsl:template name="requirements-template-brochure">
    <xsl:text>\pdftooltip{</xsl:text>
    <xsl:value-of select="VALUES/ATTRIBUTE-VALUE-STRING[key('attr_type',DEFINITION/ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='Description']/@THE-VALUE"/>
    <xsl:text>}{</xsl:text>
    <xsl:value-of select="VALUES/ATTRIBUTE-VALUE-STRING[key('attr_type',DEFINITION/ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='ID']/@THE-VALUE"/>
    <xsl:text>}
    </xsl:text>
  </xsl:template>

  <xsl:template name="requirements-template-spec">
    <xsl:text>\begin{description}
\item[</xsl:text>
    <xsl:value-of select="VALUES/ATTRIBUTE-VALUE-STRING[key('attr_type',DEFINITION/ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='ID']/@THE-VALUE"/>
    <xsl:text>]</xsl:text>
    <xsl:value-of select="VALUES/ATTRIBUTE-VALUE-STRING[key('attr_type',DEFINITION/ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='Description']/@THE-VALUE"/>
    <xsl:text>
\end{description}
    </xsl:text>
  </xsl:template>

  <xsl:template name="heading-template">
    <xsl:param name="level"/>
    <xsl:choose>
      <xsl:when test="$level = 1">\section{</xsl:when>
      <xsl:when test="$level = 2">\subsection{</xsl:when>
      <xsl:when test="$level = 3">\subsubsection{</xsl:when>
      <xsl:otherwise>\paragraph{</xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="VALUES/ATTRIBUTE-VALUE-STRING[key('attr_type',DEFINITION/ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='Description']/@THE-VALUE"/>
    <xsl:text>}
    </xsl:text>
  </xsl:template>


  <!-- <CHILDREN> with <SPEC-HIERARCHY> are nested throughout the specification -->
  <xsl:template match="CHILDREN[SPEC-HIERARCHY]">
    <xsl:param name="level"/>
      <xsl:apply-templates select="SPEC-HIERARCHY">
        <xsl:with-param name="level" select="$level"/>
      </xsl:apply-templates>
  </xsl:template>

  <!-- <SPEC-HIERARCHY> with @IDENTIFIER provides the actial content -->
  <xsl:template match="SPEC-HIERARCHY[@IDENTIFIER]">
    <xsl:param name="level" select="0"/>
    <xsl:variable name="item_text"> <xsl:value-of select="OBJECT/SPEC-OBJECT-REF"/></xsl:variable>
    <xsl:for-each select="key('req_text',$item_text)">
      <xsl:variable name="object_type"> <xsl:value-of select="TYPE/SPEC-OBJECT-TYPE-REF"/></xsl:variable>
      <xsl:choose>
        <xsl:when test="key('obj_type',$object_type)/@LONG-NAME = 'Requirement Type'">
          <!-- The current object is a requirement, we want it's ID and description -->
          <xsl:if test="$specmode = 'spec'">
            <xsl:call-template name="requirements-template-spec"/>
          </xsl:if>
          <xsl:if test="$specmode = 'brochure'">
            <xsl:call-template name="requirements-template-brochure"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="key('obj_type',$object_type)/@LONG-NAME = 'Heading Type'">
          <!-- The current object is a requirement, we want it's ID and description -->
          <xsl:call-template name="heading-template">
            <xsl:with-param name="level" select="$level"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:apply-templates select="CHILDREN">
      <xsl:with-param name="level" select="$level+1"/>
    </xsl:apply-templates>
  </xsl:template>

</xsl:stylesheet>

