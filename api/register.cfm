<cfcontent type="application/json; charset=utf-8">

<cfparam name="form.name" default="">
<cfparam name="form.email" default="">
<cfparam name="form.password" default="">

<!--- validation --->
<cfif len(trim(form.name)) LT 3>
    <cfoutput>#serializeJSON({"status":"error","message":"Name too short"})#</cfoutput>
    <cfabort>
</cfif>

<cfif NOT isValid("email", form.email)>
    <cfoutput>#serializeJSON({"status":"error","message":"Invalid email"})#</cfoutput>
    <cfabort>
</cfif>

<!--- check duplicate email --->
<cfquery name="checkEmail" datasource="todo">
    SELECT id FROM users WHERE email =
    <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif checkEmail.recordCount GT 0>
    <cfoutput>#serializeJSON({"status":"error","message":"Email already exists"})#</cfoutput>
    <cfabort>
</cfif>

<!--- hash password (CF equivalent of password_hash) --->
<cfset hashedPassword = hash(form.password, "SHA-256")>

<!--- default role --->
<cfset role = "staff">

<!--- insert user --->
<cfquery datasource="todo">
    INSERT INTO users (name, email, password, role)
    VALUES (
        <cfqueryparam value="#form.name#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#role#" cfsqltype="cf_sql_varchar">
    )
</cfquery>

<cfoutput>#serializeJSON({"status":"success"})#</cfoutput>