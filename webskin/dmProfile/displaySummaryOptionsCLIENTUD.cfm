<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: Farcry UD specific options --->

<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(listdeleteat(stObj.username,listlen(stObj.username,"_"),"_")) />

<cfoutput>
	<li>
		<small>
			<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stUser.objectid#&typename=farUser&method=editOwnPassword" target="content" title="#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#">#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#</a>
		</small>
	</li>
</cfoutput>

<cfsetting enablecfoutputonly="false" />