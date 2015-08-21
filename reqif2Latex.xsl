<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:reqif="http://www.omg.org/spec/ReqIF/20110401/reqif.xsd">
  <xsl:param name="specmode" select="'spec'"/>
  <xsl:output method="text"/>
  <xsl:key name="req_text" match="/reqif:REQ-IF/reqif:CORE-CONTENT/reqif:REQ-IF-CONTENT/reqif:SPEC-OBJECTS/reqif:SPEC-OBJECT" use="@IDENTIFIER"/>
  <xsl:key name="attr_type" match="/reqif:REQ-IF/reqif:CORE-CONTENT/reqif:REQ-IF-CONTENT/reqif:SPEC-TYPES/reqif:SPEC-OBJECT-TYPE/reqif:SPEC-ATTRIBUTES/reqif:ATTRIBUTE-DEFINITION-STRING" use="@IDENTIFIER"/>
  <xsl:key name="obj_type" match="/reqif:REQ-IF/reqif:CORE-CONTENT/reqif:REQ-IF-CONTENT/reqif:SPEC-TYPES/reqif:SPEC-OBJECT-TYPE" use="@IDENTIFIER"/>

  <xsl:template match="/">
      <xsl:apply-templates select="/reqif:REQ-IF/reqif:CORE-CONTENT/reqif:REQ-IF-CONTENT/reqif:SPECIFICATIONS/reqif:SPECIFICATION"/>
  </xsl:template>

  <!-- We start with the specification -->
  <xsl:template match="/reqif:REQ-IF/reqif:CORE-CONTENT/reqif:REQ-IF-CONTENT/reqif:SPECIFICATIONS/reqif:SPECIFICATION">
\documentclass[a4paper,notitlepage]{scrartcl}  
\begin{document}
\title{<xsl:value-of select="reqif:VALUES/reqif:ATTRIBUTE-VALUE-STRING/@THE-VALUE"/>}
\maketitle
      <xsl:apply-templates select="reqif:CHILDREN">
        <xsl:with-param name="level" select="1"/>
      </xsl:apply-templates>
\end{document}
  </xsl:template>

  <xsl:template name="requirements-template-brochure">
    <xsl:text>\pdftooltip{</xsl:text>
    <xsl:value-of select="reqif:VALUES/reqif:ATTRIBUTE-VALUE-STRING[key('attr_type',reqif:DEFINITION/reqif:ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='Description']/@THE-VALUE"/>
    <xsl:text>}{</xsl:text>
    <xsl:value-of select="reqif:VALUES/reqif:ATTRIBUTE-VALUE-STRING[key('attr_type',reqif:DEFINITION/reqif:ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='ID']/@THE-VALUE"/>
    <xsl:text>}
    </xsl:text>
  </xsl:template>

  <xsl:template name="requirements-template-spec">
    <xsl:text>\begin{description}
\item[</xsl:text>
    <xsl:value-of select="reqif:VALUES/reqif:ATTRIBUTE-VALUE-STRING[key('attr_type',reqif:DEFINITION/reqif:ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='ID']/@THE-VALUE"/>
    <xsl:text>]</xsl:text>
    <xsl:value-of select="reqif:VALUES/reqif:ATTRIBUTE-VALUE-STRING[key('attr_type',reqif:DEFINITION/reqif:ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='Description']/@THE-VALUE"/>
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
    <xsl:value-of select="reqif:VALUES/reqif:ATTRIBUTE-VALUE-STRING[key('attr_type',reqif:DEFINITION/reqif:ATTRIBUTE-DEFINITION-STRING-REF)/@LONG-NAME='Description']/@THE-VALUE"/>
    <xsl:text>}
    </xsl:text>
  </xsl:template>


  <!-- <CHILDREN> with <SPEC-HIERARCHY> are nested throughout the specification -->
  <xsl:template match="reqif:CHILDREN[reqif:SPEC-HIERARCHY]">
    <xsl:param name="level"/>
      <xsl:apply-templates select="reqif:SPEC-HIERARCHY">
        <xsl:with-param name="level" select="$level"/>
      </xsl:apply-templates>
  </xsl:template>

  <!-- <SPEC-HIERARCHY> with @IDENTIFIER provides the actial content -->
  <xsl:template match="reqif:SPEC-HIERARCHY[@IDENTIFIER]">
    <xsl:param name="level" select="0"/>
    <xsl:variable name="item_text"> <xsl:value-of select="reqif:OBJECT/reqif:SPEC-OBJECT-REF"/></xsl:variable>
    <xsl:for-each select="key('req_text',$item_text)">
      <xsl:variable name="object_type"> <xsl:value-of select="reqif:TYPE/reqif:SPEC-OBJECT-TYPE-REF"/></xsl:variable>
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
    <xsl:apply-templates select="reqif:CHILDREN">
      <xsl:with-param name="level" select="$level+1"/>
    </xsl:apply-templates>
  </xsl:template>

</xsl:stylesheet>

