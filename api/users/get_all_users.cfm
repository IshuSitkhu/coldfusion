<cfcontent type="application/json">

<cfset result = arrayNew(1)>

<cfquery name="qUsers" datasource="todo">
    SELECT id, name, email, role
    FROM users
    ORDER BY id DESC
</cfquery>

<cfloop query="qUsers">

    <cfset user = structNew()>
    <cfset user.id = qUsers.id>
    <cfset user.name = qUsers.name>
    <cfset user.email = qUsers.email>
    <cfset user.role = qUsers.role>

    <cfset arrayAppend(result, user)>

</cfloop>

<cfoutput>#serializeJSON(result)#</cfoutput>