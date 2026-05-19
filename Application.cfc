<cfcomponent>

    <cfset this.name = "TodoAppCF">
    <cfset this.sessionManagement = true>
    <cfset this.sessionTimeout = createTimeSpan(0,2,0,0)>

</cfcomponent>