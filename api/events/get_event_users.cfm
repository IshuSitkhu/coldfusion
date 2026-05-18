<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = []>

<cftry>

    <!--- GET EVENT ID --->
    <cfset event_id = val(url.event_id)>

    <!--- QUERY --->
    <cfquery name="qUsers" datasource="todo">
        SELECT user_id
        FROM event_users
        WHERE event_id = <cfqueryparam value="#event_id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- BUILD ARRAY --->
    <cfloop query="qUsers">
        <cfset arrayAppend(result, toString(qUsers.user_id))>
    </cfloop>

<cfcatch>
    <cfset result = []>
</cfcatch>

</cftry>

<cfreturn>#result#</cfreturn>