<cfcomponent>

    <cffunction name="create" access="remote" returntype="struct" returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
                <cfset result.status = "error">
                <cfset result.message = "Access denied">
                <cfreturn result>
            </cfif>

            <cfset var title = structKeyExists(form, "title") ? trim(form.title) : "">
            <cfset var description = structKeyExists(form, "description") ? trim(form.description) : "">
            <cfset var users = structKeyExists(form, "users") ? form.users : []>

            <cfif NOT isArray(users)>
                <cfset users = [users]>
            </cfif>

            <cfif title EQ "">
                <cfset result.status = "error">
                <cfset result.message = "Title is required">
                <cfreturn result>
            </cfif>

            <cfquery datasource="todo" result="insertResult">
                INSERT INTO projects (title, description)
                VALUES (
                    <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">
                )
            </cfquery>

            <cfset var project_id = insertResult.generatedKey>

            <cfloop array="#users#" index="user_id">
                <cfif len(user_id)>
                    <cfquery datasource="todo">
                        INSERT INTO project_users (project_id, user_id)
                        VALUES (
                            <cfqueryparam value="#project_id#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
                        )
                    </cfquery>
                </cfif>
            </cfloop>

            <cfset result.status = "success">
            <cfset result.message = "Project created successfully">
            <cfreturn result>

            <cfcatch>
                <cfset result.status = "error">
                <cfset result.message = cfcatch.message>
                <cfreturn result>
            </cfcatch>

        </cftry>
    </cffunction>

    <cffunction name="getAll" access="remote" returntype="array" returnformat="json">

        <cfset var result = arrayNew(1)>

        <cftry>

            <cfif NOT structKeyExists(session, "role")>
                <cfreturn result>
            </cfif>

            <cfquery name="qProjects" datasource="todo">
                SELECT id, title, description, created_at
                FROM projects
                ORDER BY id DESC
            </cfquery>

            <cfloop query="qProjects">

                <cfset var project = structNew()>
                <cfset project.id = qProjects.id>
                <cfset project.title = qProjects.title>
                <cfset project.description = qProjects.description>
                <cfset project.created_at = qProjects.created_at>

                <cfset arrayAppend(result, project)>

            </cfloop>

            <cfreturn result>

            <cfcatch>
                <cfset var errorResult = arrayNew(1)>
                <cfreturn errorResult>
            </cfcatch>

        </cftry>
    </cffunction>

    <cffunction name="delete" access="remote" returntype="struct" returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
                <cfset result.status = "error">
                <cfset result.message = "Access denied">
                <cfreturn result>
            </cfif>

            <cfset var id = structKeyExists(form, "id") AND len(trim(form.id)) ? val(form.id) : 0>

            <cfif id EQ 0>
                <cfset result.status = "error">
                <cfset result.message = "Project ID is required">
                <cfreturn result>
            </cfif>

            <cfquery datasource="todo">
                DELETE FROM project_users 
                WHERE project_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfquery datasource="todo">
                DELETE FROM project_tasks 
                WHERE project_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfquery datasource="todo">
                DELETE FROM projects 
                WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.status = "success">
            <cfset result.message = "Project deleted successfully">

            <cfreturn result>

        <cfcatch>
            <cfset result.status = "error">
            <cfset result.message = cfcatch.message>
            <cfreturn result>
        </cfcatch>

        </cftry>
    </cffunction>

    <cffunction name="update" access="remote" returntype="struct" returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
                <cfset result.status = "error">
                <cfset result.message = "Access denied">
                <cfreturn result>
            </cfif>

            <cfset var id = (structKeyExists(form, "id") AND isNumeric(form.id)) ? val(form.id) : 0>
            <cfset var title = structKeyExists(form, "title") ? trim(form.title) : "">
            <cfset var description = structKeyExists(form, "description") ? trim(form.description) : "">
            <cfset var users = structKeyExists(form, "users") ? form.users : []>

            <cfif id EQ 0>
                <cfset result.status = "error">
                <cfset result.message = "Missing or invalid ID">
                <cfreturn result>
            </cfif>

            <cfif title EQ "">
                <cfset result.status = "error">
                <cfset result.message = "Title required">
                <cfreturn result>
            </cfif>

            <cfif NOT isArray(users)>
                <cfset users = [users]>
            </cfif>

            <cfquery datasource="todo">
                UPDATE projects
                SET title = <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,
                    description = <cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">
                WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfquery datasource="todo">
                DELETE FROM project_users
                WHERE project_id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfloop array="#users#" index="user_id">
                <cfif isNumeric(user_id) AND len(user_id)>
                    <cfquery datasource="todo">
                        INSERT INTO project_users (project_id, user_id)
                        VALUES (
                            <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">,
                            <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
                        )
                    </cfquery>
                </cfif>
            </cfloop>

            <cfset result.status = "success">
            <cfset result.message = "Project updated successfully">
            <cfreturn result>

        <cfcatch>
            <cfset result.status = "error">
            <cfset result.message = cfcatch.message>
            <cfreturn result>
        </cfcatch>

        </cftry>
    </cffunction>

    <cffunction name="addUser" access="remote" returntype="struct" returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            
            <cfif NOT structKeyExists(form, "project_id") OR NOT structKeyExists(form, "user_id")>
                <cfset result.status = "error">
                <cfset result.message = "Missing data">
                <cfreturn result>
            </cfif>

            <cfset var project_id = val(form.project_id)>
            <cfset var user_id = val(form.user_id)>

        
            <cfquery name="checkUser" datasource="todo">
                SELECT id
                FROM project_users
                WHERE project_id = <cfqueryparam value="#project_id#" cfsqltype="cf_sql_integer">
                AND user_id = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif checkUser.recordCount GT 0>
                <cfset result.status = "error">
                <cfset result.message = "User already added">
                <cfreturn result>
            </cfif>

        
            <cfquery datasource="todo">
                INSERT INTO project_users (
                    project_id,
                    user_id
                )
                VALUES (
                    <cfqueryparam value="#project_id#" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
                )
            </cfquery>

            <cfset result.status = "success">
            <cfset result.message = "User added successfully">
            <cfreturn result>

        <cfcatch>
            <cfset result.status = "error">
            <cfset result.message = cfcatch.message>
            <cfreturn result>
        </cfcatch>

        </cftry>
    </cffunction>

    <cffunction name="getUsers" access="remote" returntype="array" returnformat="json">

        <cfset var usersArray = arrayNew(1)>

        <cftry>

            <cfset var project_id = structKeyExists(url, "project_id") ? val(url.project_id) : 0>

            <cfif project_id EQ 0>
                <cfreturn usersArray>
            </cfif>

            <cfquery name="getUsersQuery" datasource="todo">
                SELECT
                    u.id,
                    u.name
                FROM project_users pu
                INNER JOIN users u
                    ON pu.user_id = u.id
                WHERE pu.project_id = <cfqueryparam value="#project_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfloop query="getUsersQuery">

                <cfset arrayAppend(usersArray, {
                    "id" = getUsersQuery.id,
                    "name" = getUsersQuery.name
                })>

            </cfloop>

            <cfreturn usersArray>

        <cfcatch>
            <cfreturn usersArray>
        </cfcatch>

        </cftry>
    </cffunction>

    <cffunction name="removeUser" access="remote" returntype="struct" returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            
            <cfif NOT structKeyExists(form, "project_id") OR NOT structKeyExists(form, "user_id")>
                <cfset result.status = "error">
                <cfset result.message = "Missing data">
                <cfreturn result>
            </cfif>

            <cfset var project_id = val(form.project_id)>
            <cfset var user_id = val(form.user_id)>

            
            <cfquery datasource="todo">
                DELETE FROM project_users
                WHERE project_id = <cfqueryparam value="#project_id#" cfsqltype="cf_sql_integer">
                AND user_id = <cfqueryparam value="#user_id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.status = "success">
            <cfset result.message = "User removed successfully">
            <cfreturn result>

        <cfcatch>
            <cfset result.status = "error">
            <cfset result.message = cfcatch.message>
            <cfreturn result>
        </cfcatch>

        </cftry>
    </cffunction>

</cfcomponent>