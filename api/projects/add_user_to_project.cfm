<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

    <cfif NOT structKeyExists(form, "project_id")
        OR NOT structKeyExists(form, "user_id")>

        <cfset result.status = "error">
        <cfset result.message = "Missing data">

        <cfreturn>#result#</cfreturn>
        <cfabort>

    </cfif>

    <cfquery name="checkUser" datasource="todo">

        SELECT id
        FROM project_users

        WHERE project_id =
        <cfqueryparam
            value="#form.project_id#"
            cfsqltype="cf_sql_integer">

        AND user_id =
        <cfqueryparam
            value="#form.user_id#"
            cfsqltype="cf_sql_integer">

    </cfquery>

    <cfif checkUser.recordCount GT 0>

        <cfset result.status = "error">
        <cfset result.message = "User already added">

        <cfreturn>#result#</cfreturn>
        <cfabort>

    </cfif>

    <cfquery datasource="todo">

        INSERT INTO project_users (
            project_id,
            user_id
        )

        VALUES (

            <cfqueryparam
                value="#form.project_id#"
                cfsqltype="cf_sql_integer">,

            <cfqueryparam
                value="#form.user_id#"
                cfsqltype="cf_sql_integer">

        )

    </cfquery>

    <cfset result.status = "success">
    <cfset result.message = "User added successfully">

    <cfreturn>#result#</cfreturn>

<cfcatch>

    <cfset result.status = "error">
    <cfset result.message = cfcatch.message>

    <cfreturn>#result#</cfreturn>

</cfcatch>
</cftry>