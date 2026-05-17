<cfcontent type="application/json; charset=utf-8">

<cfset structClear(session)>

<cfoutput>
#serializeJSON({"status":"success"})#
</cfoutput>