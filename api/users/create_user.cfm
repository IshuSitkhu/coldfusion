<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cfheader name="Cache-Control" value="no-store">

<cfset result = structNew()>

<cftry>

<cfif NOT structKeyExists(session, "role") OR session.role NEQ "admin">
    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = "Access denied">

    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfset name = structKeyExists(form, "name") ? trim(form.name) : "">
<cfset email = structKeyExists(form, "email") ? trim(form.email) : "">
<cfset password = structKeyExists(form, "password") ? trim(form.password) : "">

<cfif name EQ "" OR email EQ "" OR password EQ "">
    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = "All fields are required">

    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfif len(name) LT 3>
    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = "Name must be at least 3 characters">

    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfif NOT reFindNoCase("^[a-zA-Z0-9._%+-]+@gmail\.com$", email)>
    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = "Only Gmail allowed">

    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfif len(password) LT 8
    OR NOT reFind("[A-Z]", password)
    OR NOT reFind("[a-z]", password)
    OR NOT reFind("[0-9]", password)
    OR NOT reFind("[@$!%*?&##]", password)>

    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = "Weak password">

    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfquery name="checkEmail" datasource="todo">
    SELECT id
    FROM users
    WHERE email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif checkEmail.recordCount GT 0>
    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = "Email already exists">

    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfabort>
</cfif>

<cfset hashed = hash(password, "SHA-256")>

<cfquery datasource="todo">
    INSERT INTO users (
        name,
        email,
        password,
        role
    )
    VALUES (
        <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#hashed#" cfsqltype="cf_sql_varchar">,
        'staff'
    )
</cfquery>

<cfset result.STATUS = "success">
<cfset result.MESSAGE = "User created successfully">

<cfoutput>#serializeJSON(result)#</cfoutput>

<cfcatch>
    <cfset result.STATUS = "error">
    <cfset result.MESSAGE = cfcatch.message>

    <cfoutput>#serializeJSON(result)#</cfoutput>
</cfcatch>

</cftry>