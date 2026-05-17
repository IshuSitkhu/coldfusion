<cfcontent type="application/json; charset=utf-8">
<cfsetting showdebugoutput="false">

<cfparam name="form.email" default="">
<cfparam name="form.password" default="">

<cfquery name="getUser" datasource="todo">
    SELECT id, name, email, password, role
    FROM users
    WHERE email =
    <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- user not found --->
<cfif getUser.recordCount EQ 0>
    <cfoutput>#serializeJSON({"status":"error","message":"User not found"})#</cfoutput>
    <cfabort>
</cfif>

<!--- password check --->
<cfset hashedInput = hash(form.password, "SHA-256")>

<cfif hashedInput NEQ getUser.password>
    <cfoutput>#serializeJSON({"status":"error","message":"Invalid password"})#</cfoutput>
    <cfabort>
</cfif>

<!--- session --->
<cfset session.user_id = getUser.id>
<cfset session.name = getUser.name>
<cfset session.role = getUser.role>

<!--- redirect --->
<cfif getUser.role EQ "admin">
    <cfset redirectPage = "dashboard.cfm">
<cfelse>
    <cfset redirectPage = "staff_dashboard.cfm">
</cfif>

<cfoutput>
#serializeJSON({
    "status":"success",
    "message":"Login successful",
    "redirect": redirectPage
})#
</cfoutput>