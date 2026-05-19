<cfoutput>
Session user_id: #structKeyExists(session,"user_id") ? session.user_id : "NO SESSION"#
</cfoutput>