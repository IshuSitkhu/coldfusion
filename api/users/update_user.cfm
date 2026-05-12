<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">

<cfset result = structNew()>

<cftry>

<cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
    <cfset result.status = "error">
    <cfset result.message = "Access denied">
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfset id = structKeyExists(form, "id") AND isNumeric(form.id) ? val(form.id) : 0>
<cfset name = structKeyExists(form, "name") ? trim(form.name) : "">
<cfset email = structKeyExists(form, "email") ? trim(form.email) : "">
<cfset password = structKeyExists(form, "password") ? trim(form.password) : "">

<cfset isUpdate = (id GT 0)>

<cfif id EQ 0>
    <cfset result.status = "error">
    <cfset result.message = "Invalid user ID">
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfif isUpdate>

    <cfif name EQ "" OR email EQ "">
        <cfset result.status = "error">
        <cfset result.message = "Name and Email required">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

<cfelse>

    <cfif name EQ "" OR email EQ "" OR password EQ "">
        <cfset result.status = "error">
        <cfset result.message = "All fields are required">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>

</cfif>

<cfif len(name) LT 3>
    <cfset result.status = "error">
    <cfset result.message = "Name must be at least 3 characters">
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfif NOT reFindNoCase("^[a-zA-Z0-9._%+-]+@gmail\.com$", email)>
    <cfset result.status = "error">
    <cfset result.message = "Only Gmail allowed">
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfquery name="checkEmail" datasource="todo">
    SELECT id
    FROM users
    WHERE email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">

    <cfif isUpdate>
        AND id != <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
    </cfif>
</cfquery>

<cfif checkEmail.recordCount GT 0>
    <cfset result.status = "error">
    <cfset result.message = "Email already exists">
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfif isUpdate>

    <cfif password NEQ "">

        <cfset hashed = hash(password, "SHA-256")>

        <cfquery datasource="todo">
            UPDATE users
            SET
                name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
                email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
                password = <cfqueryparam value="#hashed#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
        </cfquery>

    <cfelse>

        <cfquery datasource="todo">
            UPDATE users
            SET
                name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
                email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_integer">
        </cfquery>

    </cfif>

</cfif>

<cfset result.status = "success">
<cfset result.message = "User updated successfully">

<cfoutput>#serializeJSON(result)#</cfoutput>

<cfcatch>
    <cfset result.status = "error">
    <cfset result.message = cfcatch.message>
    <cfoutput>#serializeJSON(result)#</cfoutput>
</cfcatch>

</cftry>