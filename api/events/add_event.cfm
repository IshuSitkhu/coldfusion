<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

    <!--- SESSION --->
    <cfset user_id = session.user_id>
    <cfset role = session.role>

    <!--- INPUTS --->
    <cfset title = trim(form.title)>
    <cfset start = form.start>
    <cfset end = form.end>

    <!--- users may come as string or array --->
    <cfset users = structKeyExists(form, "users") ? form.users : []>

    <!--- EVENT TYPE --->
    <cfif role EQ "admin">
        <cfset event_type = "admin">
    <cfelse>
        <cfset event_type = "staff">
    </cfif>

    <!--- normalize users --->
    <cfif NOT isArray(users)>
        <cfset users = [users]>
    </cfif>

    <!--- INSERT EVENT --->
    <cfquery name="insertEvent" datasource="todo">

    INSERT INTO events (
        title,
        start_date,
        end_date,
        created_by,
        event_type
    )

    VALUES (

        <cfqueryparam value="#form.title#" cfsqltype="cf_sql_varchar">,

        <cfqueryparam value="#form.start#" cfsqltype="cf_sql_date">,

        <cfqueryparam value="#form.end#" cfsqltype="cf_sql_date">,

        <cfqueryparam value="#session.user_id#" cfsqltype="cf_sql_integer">,

        <cfqueryparam value="#event_type#" cfsqltype="cf_sql_varchar">

    )

</cfquery>

    <!--- GET LAST INSERT ID --->
    <cfquery name="getLastId" datasource="todo">
        SELECT MAX(id) AS id FROM events
    </cfquery>

    <cfset event_id = getLastId.id>

    <!--- ASSIGN USERS --->
    <cfloop array="#users#" index="uid">

        <cfset uid = val(uid)>

        <cfif uid GT 0>

            <cfquery datasource="todo">
                INSERT INTO event_users (event_id, user_id)
                VALUES (
                    <cfqueryparam value="#event_id#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#uid#" cfsqltype="cf_sql_integer">
                )
            </cfquery>

        </cfif>

    </cfloop>

    <cfset result.success = true>
    <cfset result.message = "Event created">

<cfcatch>
    <cfoutput>
        #serializeJSON({
            "success": false,
            "message": cfcatch.message,
            "detail": cfcatch.detail,
            "sqlstate": cfcatch.sqlstate,
            "queryError": cfcatch.queryError,
            "stacktrace": cfcatch.stacktrace
        })#
    </cfoutput>
</cfcatch>

</cftry>

<cfoutput>#serializeJSON(result)#</cfoutput>