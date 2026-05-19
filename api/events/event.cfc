<cfcomponent output="false">

<cffunction name="addEvent"
    access="remote"
    returntype="struct"
    returnformat="json"
    output="false">

    <cfset var result = structNew()>

    <cfif NOT structKeyExists(session, "user_id") OR NOT structKeyExists(session, "role")>
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = "Session expired. Please login again.">
        <cfreturn result>
    </cfif>

    <cftry>

        <cfset var user_id = session.user_id>
        <cfset var role = session.role>

        <cfset var title = trim(form.title)>
        <cfset var start = form.start>
        <cfset var end = form.end>

        <cfset var users = []>

        <cfif structKeyExists(form,"users")>
            <cfif isArray(form.users)>
                <cfset users = form.users>
            <cfelseif len(form.users)>
                <cfset users = listToArray(form.users)>
            </cfif>
        </cfif>

        <cfif NOT isArray(users)>
            <cfset users = [users]>
        </cfif>

        <cfif role EQ "admin">
            <cfset var event_type = "admin">
        <cfelse>
            <cfset var event_type = "staff">
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

        <cfset var event_id = qResult.generatedKey>

        <cfif NOT len(event_id)>
            <cfset event_id = qResult.identitycol>
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

    <cfreturn result>

</cffunction>


<cffunction name="getEvents"
    access="remote"
    returntype="array"
    returnformat="json"
    output="false">

    <cfset var events = []>

    <cfif NOT structKeyExists(session, "user_id") OR NOT structKeyExists(session, "role")>
        <cfreturn events>
    </cfif>

    <cfset var user_id = session.user_id>
    <cfset var role = session.role>

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
        LEFT JOIN users u ON u.id = e.created_by
        <cfif role NEQ "admin">
            INNER JOIN event_users eu ON eu.event_id = e.id
            WHERE eu.user_id = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
        </cfif>
        ORDER BY e.start_date
    </cfquery>

    <cfloop query="qEvents">

        <cfset arrayAppend(events, {
            "id": qEvents.id,
            "title": qEvents.title,
            "start": dateFormat(qEvents.start_date, "yyyy-mm-dd"),
            "end": dateFormat(qEvents.end_date, "yyyy-mm-dd"),
            "extendedProps": {
                "created_by": qEvents.created_by,
                "created_by_name": qEvents.created_by_name,
                "event_type": qEvents.event_type
            }
        })>

    </cfloop>

    <cfreturn events>

</cffunction>

<cffunction name="updateEvent"
    access="remote"
    returntype="struct"
    returnformat="json"
    output="false">

    <cfset var result = structNew()>

    <!--- SESSION CHECK --->
    <cfif NOT structKeyExists(session, "user_id") OR NOT structKeyExists(session, "role")>
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = "Session expired">
        <cfreturn result>
    </cfif>

    <cftry>

        <!--- SESSION DATA --->
        <cfset var user_id = session.user_id>
        <cfset var role = session.role>

        <!--- FORM DATA --->
        <cfset var id = val(form.id)>
        <cfset var title = trim(form.title)>
        <cfset var start_date = form.start>
        <cfset var end_date = form.end>

        <!--- NORMALIZE USERS --->
        <cfset var users = []>

        <cfif structKeyExists(form, "users") AND len(trim(form.users))>
            <cfset users = listToArray(form.users)>
        </cfif>

        <cfif NOT isArray(users)>
            <cfset users = [users]>
        </cfif>

        <!--- GET EVENT --->
        <cfquery name="getEvent" datasource="todo">
            SELECT *
            FROM events
            WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfif getEvent.recordCount EQ 0>
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = "Event not found">
            <cfreturn result>
        </cfif>

        <!--- EVENT DATA --->
        <cfset var event_type = getEvent.event_type>
        <cfset var created_by = getEvent.created_by>

        <!--- PERMISSION CHECK --->
        <cfif role NEQ "admin">
            <cfif event_type EQ "admin" OR created_by NEQ user_id>
                <cfset result.SUCCESS = false>
                <cfset result.MESSAGE = "No permission">
                <cfreturn result>
            </cfif>
        </cfif>

        <!--- UPDATE EVENT TABLE --->
        <cfquery datasource="todo">
            UPDATE events
            SET
                title = <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,
                start_date = <cfqueryparam value="#start_date#" cfsqltype="cf_sql_date">,
                end_date = <cfqueryparam value="#end_date#" cfsqltype="cf_sql_date">
            WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- 🔥 UPDATE ASSIGNMENTS (SAFE MERGE STYLE) --->
        
        <!--- GET EXISTING USERS --->
        <cfquery name="existingUsers" datasource="todo">
            SELECT user_id
            FROM event_users
            WHERE event_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset var existingList = []>

        <cfloop query="existingUsers">
            <cfset arrayAppend(existingList, existingUsers.user_id)>
        </cfloop>

        <!--- NEW USERS --->
        <cfset var newList = []>

        <cfloop array="#users#" index="u">
            <cfset u = val(u)>
            <cfif u GT 0>
                <cfset arrayAppend(newList, u)>
            </cfif>
        </cfloop>

        <!--- MERGE (NO DUPLICATES) --->
        <cfset var finalList = duplicate(existingList)>

        <cfloop array="#newList#" index="u">
            <cfif NOT arrayContains(finalList, u)>
                <cfset arrayAppend(finalList, u)>
            </cfif>
        </cfloop>

        <!--- INSERT ONLY MISSING USERS --->
        <cfloop array="#finalList#" index="uid">

            <cfquery name="checkUser" datasource="todo">
                SELECT id
                FROM event_users
                WHERE event_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
                AND user_id = <cfqueryparam value="#uid#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif checkUser.recordCount EQ 0>
                <cfquery datasource="todo">
                    INSERT INTO event_users (event_id, user_id)
                    VALUES (
                        <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value="#uid#" cfsqltype="cf_sql_integer">
                    )
                </cfquery>
            </cfif>

        </cfloop>

        <!--- SUCCESS --->
        <cfset result.SUCCESS = true>
        <cfset result.MESSAGE = "Event updated successfully">

    <cfcatch>
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="deleteEvent"
    access="remote"
    returntype="struct"
    returnformat="json"
    output="false">

    <cfset var result = structNew()>

    <cfif NOT structKeyExists(session, "user_id") OR NOT structKeyExists(session, "role")>
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = "Session expired. Please login again.">
        <cfreturn result>
    </cfif>

    <cftry>

        <cfset var id = val(form.id)>

        <cfquery datasource="todo">
            DELETE FROM event_users
            WHERE event_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfquery datasource="todo">
            DELETE FROM events
            WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.SUCCESS = true>
        <cfset result.MESSAGE = "Deleted">

    <cfcatch>
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

<cffunction name="getEventUsers"
    access="remote"
    returntype="array"
    returnformat="json"
    output="false">

    <cfset var result = []>

    <!--- Validate input --->
    <cfif NOT structKeyExists(url, "event_id")>
        <cfreturn result>
    </cfif>

    <cfset var event_id = val(url.event_id)>

    <cftry>

        <cfquery name="qUsers" datasource="todo">
            SELECT user_id
            FROM event_users
            WHERE event_id = <cfqueryparam value="#event_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfloop query="qUsers">
            <!-- IMPORTANT: keep numeric -->
            <cfset arrayAppend(result, qUsers.user_id)>
        </cfloop>

    <cfcatch>
        <cfset result = []>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>


<cffunction name="getUsers"
    access="remote"
    returntype="array"
    returnformat="json"
    output="false">

    <cfset var users = []>

    <cftry>

        <cfquery name="qUsers" datasource="todo">
            SELECT id, name
            FROM users
            ORDER BY name
        </cfquery>

        <cfloop query="qUsers">
            <cfset arrayAppend(users, {
                "id": qUsers.id,
                "name": qUsers.name
            })>
        </cfloop>

    <cfcatch>
        <cfset users = []>
    </cfcatch>

    </cftry>

    <cfreturn users>

</cffunction>


<cffunction name="removeUser"
    access="remote"
    returntype="struct"
    returnformat="json"
    output="false">

    <cfset var result = structNew()>

    <cftry>

        <cfset var event_id = val(form.event_id)>
        <cfset var user_id = val(form.user_id)>

        <cfif event_id LTE 0 OR user_id LTE 0>
            <cfset result.SUCCESS = false>
            <cfset result.MESSAGE = "Invalid input">
            <cfreturn result>
        </cfif>

        <cfquery datasource="todo">
            DELETE FROM event_users
            WHERE event_id = <cfqueryparam value="#event_id#" cfsqltype="cf_sql_integer">
            AND user_id = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfset result.SUCCESS = true>
        <cfset result.MESSAGE = "User removed">

    <cfcatch>
        <cfset result.SUCCESS = false>
        <cfset result.MESSAGE = cfcatch.message>
    </cfcatch>

    </cftry>

    <cfreturn result>

</cffunction>

</cfcomponent>