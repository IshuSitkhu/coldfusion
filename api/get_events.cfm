<cfsetting enablecfoutputonly="true">

<!--- QUERY DATABASE --->
<cfquery name="getEvents" datasource="todo">
    SELECT 
        id,
        title,
        start_date,
        end_date
    FROM events
</cfquery>

<!--- BUILD ARRAY --->
<cfset events = []>

<cfloop query="getEvents">
    <cfset arrayAppend(events, {
        id = id,
        title = title,
        start = start_date,
        end = end_date
    })>
</cfloop>

<!--- RETURN JSON --->
<cfcontent type="application/json">
<cfoutput>#serializeJSON(events)#</cfoutput>