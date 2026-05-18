<cfcomponent>
    <cffunction name="create" access="remote" returntype="struct" returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
                <cfset result.status = "error">
                <cfset result.message = "Access denied">
                <cfreturn result>
            </cfif>

            <cfset var name = structKeyExists(form, "name") ? trim(form.name) : "">
            <cfset var email = structKeyExists(form, "email") ? trim(form.email) : "">
            <cfset var password = structKeyExists(form, "password") ? trim(form.password) : "">

            <cfif name EQ "" OR email EQ "" OR password EQ "">
                <cfset result.status = "error">
                <cfset result.message = "All fields are required">
                <cfreturn result>
            </cfif>

            <cfif len(name) LT 3>
                <cfset result.status = "error">
                <cfset result.message = "Name must be at least 3 characters">
                <cfreturn result>
            </cfif>

            <cfif NOT reFindNoCase("^[a-zA-Z0-9._%+-]+@gmail\.com$", email)>
                <cfset result.status = "error">
                <cfset result.message = "Only Gmail allowed">
                <cfreturn result>
            </cfif>

            <cfif len(password) LT 8
                OR NOT reFind("[A-Z]", password)
                OR NOT reFind("[a-z]", password)
                OR NOT reFind("[0-9]", password)
                OR NOT reFind("[@$!%*?&##]", password)>

                <cfset result.status = "error">
                <cfset result.message = "Weak password">
                <cfreturn result>
            </cfif>

            <cfquery name="checkEmail" datasource="todo">
                SELECT id FROM users
                WHERE email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfif checkEmail.recordCount GT 0>
                <cfset result.status = "error">
                <cfset result.message = "Email already exists">
                <cfreturn result>
            </cfif>

            <cfset var hashed = hash(password, "SHA-256")>

            <cfquery datasource="todo">
                INSERT INTO users (name, email, password, role)
                VALUES (
                    <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#hashed#" cfsqltype="cf_sql_varchar">,
                    'staff'
                )
            </cfquery>

            <cfset result.status = "success">
            <cfset result.message = "User created successfully">
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

        <cfquery name="qUsers" datasource="todo">
            SELECT id, name, email, role
            FROM users
            ORDER BY id DESC
        </cfquery>

        <cfloop query="qUsers">
            <cfset var user = structNew()>
            <cfset user.id = qUsers.id>
            <cfset user.name = qUsers.name>
            <cfset user.email = qUsers.email>
            <cfset user.role = qUsers.role>

            <cfset arrayAppend(result, user)>
        </cfloop>

        <cfreturn result>

    </cffunction>

    <cffunction name="update" access="remote" returntype="struct" returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
                <cfset result.status = "error">
                <cfset result.message = "Access denied">
                <cfreturn result>
            </cfif>

            <cfset var id = structKeyExists(form, "id") AND isNumeric(form.id) ? val(form.id) : 0>
            <cfset var name = structKeyExists(form, "name") ? trim(form.name) : "">
            <cfset var email = structKeyExists(form, "email") ? trim(form.email) : "">
            <cfset var password = structKeyExists(form, "password") ? trim(form.password) : "">

            <cfif id EQ 0>
                <cfset result.status = "error">
                <cfset result.message = "Invalid user ID">
                <cfreturn result>
            </cfif>

            <cfif name EQ "" OR email EQ "">
                <cfset result.status = "error">
                <cfset result.message = "Name and Email required">
                <cfreturn result>
            </cfif>

            <cfif len(name) LT 3>
                <cfset result.status = "error">
                <cfset result.message = "Name must be at least 3 characters">
                <cfreturn result>
            </cfif>

            <cfif NOT reFindNoCase("^[a-zA-Z0-9._%+-]+@gmail\.com$", email)>
                <cfset result.status = "error">
                <cfset result.message = "Only Gmail allowed">
                <cfreturn result>
            </cfif>

            <cfquery name="checkEmail" datasource="todo">
                SELECT id FROM users
                WHERE email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
                AND id != <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfif checkEmail.recordCount GT 0>
                <cfset result.status = "error">
                <cfset result.message = "Email already exists">
                <cfreturn result>
            </cfif>

            <cfif password NEQ "">

                <cfset var hashed = hash(password, "SHA-256")>

                <cfquery datasource="todo">
                    UPDATE users
                    SET name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
                        email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
                        password = <cfqueryparam value="#hashed#" cfsqltype="cf_sql_varchar">
                    WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
                </cfquery>

            <cfelse>

                <cfquery datasource="todo">
                    UPDATE users
                    SET name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
                        email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
                    WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
                </cfquery>

            </cfif>

            <cfset result.status = "success">
            <cfset result.message = "User updated successfully">
            <cfreturn result>

            <cfcatch>
                <cfset result.status = "error">
                <cfset result.message = cfcatch.message>
                <cfreturn result>
            </cfcatch>

        </cftry>

    </cffunction>


    <cffunction name="delete" access="remote" returntype="struct" returnformat="json">

        <cfset var result = structNew()>

        <cftry>

            <cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
                <cfset result.status = "error">
                <cfset result.message = "Unauthorized">
                <cfreturn result>
            </cfif>

            <cfset var id = structKeyExists(form, "id") AND isNumeric(form.id) ? val(form.id) : 0>

            <cfif id EQ 0>
                <cfset result.status = "error">
                <cfset result.message = "ID missing">
                <cfreturn result>
            </cfif>

            <cfquery datasource="todo">
                DELETE FROM users
                WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
            </cfquery>

            <cfset result.status = "success">
            <cfset result.message = "User deleted">
            <cfreturn result>

            <cfcatch>
                <cfset result.status = "error">
                <cfset result.message = cfcatch.message>
                <cfreturn result>
            </cfcatch>

        </cftry>

    </cffunction>

</cfcomponent>