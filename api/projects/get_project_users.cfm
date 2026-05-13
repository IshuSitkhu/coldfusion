<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset usersArray = []>

<cftry>

    <cfif NOT structKeyExists(url, "project_id")>

        <cfoutput>[]</cfoutput>
        <cfabort>

    </cfif>

    <cfquery name="getUsers" datasource="todo">

        SELECT
            u.id,
            u.name

        FROM project_users pu

        INNER JOIN users u
        ON pu.user_id = u.id

        WHERE pu.project_id =
        <cfqueryparam
            value="#url.project_id#"
            cfsqltype="cf_sql_integer">

    </cfquery>

    <cfloop query="getUsers">

        <cfset arrayAppend(usersArray, {

            "id" = getUsers.id,
            "NAME" = getUsers.name

        })>

    </cfloop>

    <cfoutput>#serializeJSON(usersArray)#</cfoutput>

<cfcatch>

    <cfoutput>[]</cfoutput>

</cfcatch>
</cftry>