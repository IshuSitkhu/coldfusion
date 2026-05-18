<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfset result = structNew()>

<cftry>

    <!--- SESSION --->
    <cfset user_id = session.user_id>
    <cfset role = session.role>

    <!--- FORM DATA --->
    <cfset id = val(form.id)>
    <cfset title = trim(form.title)>
    <cfset start_date = form.start>
    <cfset end_date = form.end>

    <!--- users optional --->
    <cfif structKeyExists(form, "users")>
        <cfset users = form.users>
    <cfelse>
        <cfset users = []>
    </cfif>

    <!--- normalize array --->
    <cfif NOT isArray(users)>
        <cfset users = [users]>
    </cfif>

    <!--- GET EVENT --->
    <cfquery name="getEvent" datasource="todo">
        SELECT *
        FROM events
        WHERE id = 
        <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- EVENT NOT FOUND --->
    <cfif getEvent.recordCount EQ 0>

        <cfset result.success = false>
        <cfset result.message = "Event not found">

        <cfreturn>#result#</cfreturn>
        <cfabort>

    </cfif>

    <!--- EVENT DATA --->
    <cfset event_type = getEvent.event_type>
    <cfset created_by = getEvent.created_by>

    <!--- STAFF PERMISSION CHECK --->
    <cfif role NEQ "admin">

        
        <cfif event_type EQ "admin">

            <cfset result.success = false>
            <cfset result.message = "No permission (admin event)">

            <cfreturn>#result#</cfreturn>
            <cfabort>

        </cfif>

        <cfif created_by NEQ user_id>

            <cfset result.success = false>
            <cfset result.message = "No permission (not owner)">

            <cfreturn>#result#</cfreturn>
            <cfabort>

        </cfif>

    </cfif>

    <cfif event_type EQ "staff">
        <cfset users = []>
    </cfif>

    <cfquery datasource="todo">

        UPDATE events

        SET
            title = <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,

            start_date =
            <cfqueryparam value="#start_date#" cfsqltype="cf_sql_date">,

            end_date =
            <cfqueryparam value="#end_date#" cfsqltype="cf_sql_date">

        WHERE id =
        <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">

    </cfquery>

    <cfif role EQ "admin" AND event_type EQ "admin">

        <cfloop array="#users#" index="uid">

            <cfset uid = val(uid)>

            <cfif uid GT 0>

                <cfquery name="checkUser" datasource="todo">

                    SELECT id
                    FROM event_users

                    WHERE event_id =
                    <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">

                    AND user_id =
                    <cfqueryparam value="#uid#" cfsqltype="cf_sql_integer">

                </cfquery>

                <cfif checkUser.recordCount EQ 0>

                    <cfquery datasource="todo">

                        INSERT INTO event_users (
                            event_id,
                            user_id
                        )

                        VALUES (

                            <cfqueryparam
                                value="#id#"
                                cfsqltype="cf_sql_integer"
                            >,

                            <cfqueryparam
                                value="#uid#"
                                cfsqltype="cf_sql_integer"
                            >

                        )

                    </cfquery>

                </cfif>

            </cfif>

        </cfloop>

    </cfif>

    <!--- SUCCESS --->
    <cfset result.success = true>
    <cfset result.message = "Event updated">

<cfcatch>

    <cfset result.success = false>
    <cfset result.message = cfcatch.message>

</cfcatch>

</cftry>

<cfreturn>#result#</cfreturn>