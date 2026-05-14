<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">


<cftry>

    <cfset user_id = session.user_id>
    <cfset role = session.role>

    <!--- ADMIN QUERY --->
    <cfif role EQ "admin">

        <cfquery name="qEvents" datasource="todo">
            SELECT 
                e.id,
                e.title,
                e.start_date,
                e.end_date,
                e.created_by,
                e.event_type,
                u.name AS created_by_name
            FROM events e
            LEFT JOIN users u ON e.created_by = u.id
        </cfquery>

    <!--- STAFF QUERY --->
    <cfelse>

        <cfquery name="qEvents" datasource="todo">
            SELECT DISTINCT
                e.id,
                e.title,
                e.start_date,
e.end_date,
                e.created_by,
                e.event_type,
                u.name AS created_by_name
            FROM events e
            LEFT JOIN event_users eu ON e.id = eu.event_id
            LEFT JOIN users u ON e.created_by = u.id
            WHERE eu.user_id = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
               OR e.created_by = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

    </cfif>

    <!--- BUILD RESPONSE ARRAY --->
    <cfset events = []>

    <cfloop query="qEvents">

        <!--- handle end date +1 day logic --->
        <cfset startDate = qEvents.start_date>
        <cfset endDate = qEvents.end_date>

        <cfif len(endDate)>
            <cfset endDate = dateAdd("d", 1, endDate)>
        <cfelse>
            <cfset endDate = "">
        </cfif>

        <cfset arrayAppend(events, {
            "id": qEvents.id,
            "title": qEvents.title,
            "start": dateFormat(startDate, "yyyy-mm-dd"),
            "end": len(endDate) ? dateFormat(endDate, "yyyy-mm-dd") : "",

            "extendedProps": {
                "event_type": qEvents.event_type,
                "created_by": qEvents.created_by,
                "created_by_name": qEvents.created_by_name
            }
        })>

    </cfloop>

    <cfoutput>#serializeJSON(events)#</cfoutput>

<cfcatch>
    <cfoutput>
        #serializeJSON({
            "success": false,
            "message": cfcatch.message,
            "detail": cfcatch.detail
        })#
    </cfoutput>
</cfcatch>

</cftry>