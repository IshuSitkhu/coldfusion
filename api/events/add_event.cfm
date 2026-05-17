<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

<cfset user_id = session.user_id>
<cfset role = session.role>

<cfset title = trim(form.title)>
<cfset start = form.start>
<cfset end = form.end>

<cfset users = structKeyExists(form, "users") ? form.users : []>

<cfif NOT isArray(users)>
    <cfset users = [users]>
</cfif>

<cfif role EQ "admin">
    <cfset event_type = "admin">
<cfelse>
    <cfset event_type = "staff">
</cfif>

<cfquery name="insertEvent" datasource="todo" result="qResult">

INSERT INTO events (
    title,
    start_date,
    end_date,
    created_by,
    event_type
)
VALUES (
    <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,
    <cfqueryparam value="#start#" cfsqltype="cf_sql_date">,
    <cfqueryparam value="#end#" cfsqltype="cf_sql_date">,
    <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">,
    <cfqueryparam value="#event_type#" cfsqltype="cf_sql_varchar">
)

</cfquery>

<cfset event_id = qResult.generatedKey>

<cfif NOT len(event_id)>
    <cfset event_id = qResult.identitycol>
</cfif>

<cfif NOT len(event_id)>
    <cfquery name="getLast" datasource="todo">
        SELECT TOP 1 id
        FROM events
        WHERE created_by = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
        ORDER BY id DESC
    </cfquery>

    <cfset event_id = getLast.id>
</cfif>

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

<cfset result.SUCCESS = true>
<cfset result.EVENT_ID = event_id>

<cfcatch>

<cfset result.SUCCESS = false>
<cfset result.MESSAGE = cfcatch.message>

</cfcatch>

</cftry>

<cfoutput>#serializeJSON(result)#</cfoutput>