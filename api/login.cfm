<cfcontent type="application/json">

<cfparam name="form.email" default="">
<cfparam name="form.password" default="">

<cfquery name="getUser" datasource="todo">

    SELECT
        id,
        name,
        email,
        password,
        role
    FROM users
    WHERE email =
    <cfqueryparam
        value="#form.email#"
        cfsqltype="cf_sql_varchar"
    >

</cfquery>

<cfif getUser.recordCount EQ 0>

    <cfoutput>
    #serializeJSON({
        "status" = "error",
        "message" = "User not found"
    })#
    </cfoutput>

    <cfabort>

</cfif>


<cfif form.password NEQ "admin">

    <cfoutput>
    #serializeJSON({
        "status" = "error",
        "message" = "Invalid password"
    })#
    </cfoutput>

    <cfabort>

</cfif>


<cfset session.user_id = getUser.id>
<cfset session.name = getUser.name>
<cfset session.role = getUser.role>


<cfif getUser.role EQ "admin">

    <cfset redirectPage = "../pages/dashboard.cfm">

<cfelse>

    <cfset redirectPage = "../pages/staff_dashboard.cfm">

</cfif>

<cfoutput>
#serializeJSON({
    "status" = "success",
    "message" = "Login successful",
    "redirect" = redirectPage
})#
</cfoutput>