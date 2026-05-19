<cfcomponent>
    <cffunction name="getProjectDetails"
        access="remote"
        returntype="struct"
        returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            <!--- INPUT --->
            <cfparam name="url.id" default="0">
            <cfset var id = val(url.id)>

            <cfif id EQ 0>
                <cfset result.STATUS = "error">
                <cfset result.MESSAGE = "Invalid ID">
                <cfreturn result>
            </cfif>

            <!--- PROJECT --->
            <cfquery name="qProject" datasource="todo">
                SELECT
                    id,
                    title,
                    description,
                    created_at
                FROM projects
                WHERE id =
                <cfqueryparam
                    value="#id#"
                    cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif qProject.recordCount EQ 0>
                <cfset result.STATUS = "error">
                <cfset result.MESSAGE = "Project not found">
                <cfreturn result>
            </cfif>

            <!--- USERS --->
            <cfquery name="qUsers" datasource="todo">
                SELECT
                    u.id,
                    u.name
                FROM project_users pu
                JOIN users u
                ON u.id = pu.user_id
                WHERE pu.project_id =
                <cfqueryparam
                    value="#id#"
                    cfsqltype="cf_sql_integer">
            </cfquery>

            <!--- TASKS --->
            <cfquery name="qTasks" datasource="todo">
                SELECT
                    t.id,
                    t.task,
                    t.status,
                    t.created_at,
                    t.assigned_user_id,
                    u.name AS assigned_user

                FROM project_tasks t

                LEFT JOIN users u
                ON u.id = t.assigned_user_id

                WHERE t.project_id =
                <cfqueryparam
                    value="#id#"
                    cfsqltype="cf_sql_integer">
            </cfquery>

            <!--- BUILD PROJECT OBJECT --->
            <cfset result.PROJECT = {
                "id" = qProject.ID,
                "title" = qProject.TITLE,
                "description" = qProject.DESCRIPTION,
                "created_at" = qProject.CREATED_AT
            }>

            <!--- USERS ARRAY --->
            <cfset result.USERS = []>

            <cfloop query="qUsers">

                <cfset arrayAppend(
                    result.USERS,
                    {
                        "id"=qUsers.ID,
                        "name"=qUsers.NAME
                    }
                )>

            </cfloop>

            <!--- TASKS ARRAY --->
            <cfset result.TASKS = []>

            <cfloop query="qTasks">

                <cfset arrayAppend(
                    result.TASKS,
                    {
                        "id"=qTasks.ID,
                        "task"=qTasks.TASK,
                        "status"=qTasks.STATUS,
                        "created_at"=qTasks.CREATED_AT,
                        "assigned_user"=qTasks.ASSIGNED_USER
                    }
                )>

            </cfloop>

            <cfset result.STATUS = "success">

            <cfreturn result>

        <cfcatch>

            <cfset result.STATUS = "error">
            <cfset result.MESSAGE = cfcatch.message>

            <cfreturn result>

        </cfcatch>

        </cftry>
    </cffunction>
</cfcomponent>