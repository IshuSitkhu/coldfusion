<cfif NOT structKeyExists(session, "user_id")>

    <cflocation
        url="../pages/login.cfm"
        addtoken="false">

</cfif>