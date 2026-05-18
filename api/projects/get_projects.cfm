<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">

<cfset result = arrayNew(1)>

<cftry>

    <cfif NOT structKeyExists(session, "role")>
        <cfoutput>#serializeJSON([])#</cfoutput>
        <cfabort>
    </cfif>

    <cfquery name="qProjects" datasource="todo">
        SELECT *
        FROM projects
        ORDER BY id DESC
    </cfquery>

    <cfloop query="qProjects">

        <cfset project = structNew()>
        <cfset project.id = qProjects.id>
        <cfset project.title = qProjects.title>
        <cfset project.description = qProjects.description>
        <cfset project.created_at = qProjects.created_at>

        <cfset arrayAppend(result, project)>

    </cfloop>

    <cfreturn>#result#</cfreturn>

<cfcatch>
    <cfoutput>
        #serializeJSON({
            "status" = "error",
            "message" = cfcatch.message
        })#
    </cfoutput>
</cfcatch>

</cftry>