<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cftry>

    <!--- Query users --->
    <cfquery name="qUsers" datasource="todo">
        SELECT id, name
        FROM users
    </cfquery>

    <!--- Convert query to array of structs --->
    <cfset users = []>

    <cfloop query="qUsers">
        <cfset arrayAppend(users, {
            "id": qUsers.id,
            "name": qUsers.name
        })>
    </cfloop>

    <cfoutput>#serializeJSON(users)#</cfoutput>

<cfcatch>
    <cfoutput>#serializeJSON({
        "status": "error",
        "message": cfcatch.message
    })#</cfoutput>
</cfcatch>

</cftry>