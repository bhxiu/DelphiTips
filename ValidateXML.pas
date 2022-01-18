{
<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://www.ascc.net/xml/schematron" version="1.0">
   <axsl:template match="*|@*" mode="schematron-get-full-path">
      <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <axsl:text>/</axsl:text>
      <axsl:if test="count(. | ../@*) = count(../@*)">@</axsl:if>
      <axsl:value-of select="name()"/>
      <axsl:text>[</axsl:text>
      <axsl:value-of select="1+count(preceding-sibling::*[name()=name(current())])"/>
      <axsl:text>]</axsl:text>
   </axsl:template>
   <axsl:template match="/">
      <errors>
         <axsl:apply-templates select="/" mode="M0"/>
      </errors>
   </axsl:template>
   <axsl:template match="CLAIM" priority="4000" mode="M0">
      <axsl:choose>
         <axsl:when test="/CLAIM/A01 and string-length(/CLAIM/A01) &gt; 0 and string-length(/CLAIM/A01) &lt; 13"/>
         <axsl:otherwise>
            <error code="A01">Field is invalid: Transaction Prefix</error>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:choose>
         <axsl:when test="/CLAIM/A02 and string-length(/CLAIM/A02) &gt; 0 and string-length(/CLAIM/A02) &lt; 7"/>
         <axsl:otherwise>
            <error code="A02">Field is invalid: Office Sequence Number</error>
         </axsl:otherwise>
      </axsl:choose>

      <axsl:choose>
         <axsl:when test="/CLAIM/Procedure/F17 and string-length(/CLAIM/Procedure/F17) &gt; 0 and string-length(/CLAIM/Procedure/F17) &lt; 3"/>
         <axsl:otherwise>
            <error code="F17">Field is invalid: Remarks Code</error>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:choose>
         <axsl:when test="count(Procedure) = /CLAIM/F06"/>
         <axsl:otherwise>
            <error code="F06">Field is invalid: Number of performed procs does not match</error>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:choose>
         <axsl:when test="count(ExtractTeeth) = /CLAIM/F22"/>
         <axsl:otherwise>
            <error code="F22">Field is invalid: Number of performed procs does not match</error>
         </axsl:otherwise>
      </axsl:choose>
      <axsl:apply-templates mode="M0"/>
   </axsl:template>
   <axsl:template match="text()" priority="-1" mode="M0"/>
   <axsl:template match="text()" priority="-1"/>
</axsl:stylesheet>

}


{
    Delphi snippets
}

  errorList := TStringList.Create;
  schematronXSL := CoFreeThreadedDOMDocument60.Create;
  errorsDoc := CoFreeThreadedDOMDocument60.Create;
  LoadDocFromFile( schematronXSL, schemaPath +  schematronFileName );
  errorsMsg := doc.transformNode( schematronXSL );
  LoadDocFromXML( errorsDoc, errorsMsg );
  errCount := errorsDoc.selectNodes( '/errors/error' ).length;
