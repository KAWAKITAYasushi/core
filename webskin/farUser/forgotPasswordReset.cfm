<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Reset password --->
<!--- @@description: Checks sent has to let the user reset his password --->
<!--- @@author:  Fredi (fredi@daemon.com.au) --->

<!--- @@viewBinding: type --->
<!--- @@viewStack: page --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<ft:processForm action="Reset Password">
	<!--- check user again --->
	<cfif StructKeyExists(session,"resetPWUserID")
			AND structKeyExists(FORM, "#FORM.farcryFormPrefixes#objectid") 
			AND session.resetPWUserID eq FORM["#FORM.farcryFormPrefixes#objectid"]
		>
		
		<ft:validateFormObjects typename="farUser" objectid="#session.resetPWUserID#" />
		
		<cfif request.stFarcryFormValidation.bSuccess>
			<ft:processFormObjects typename="farUser" r_stProperties="stProperties">
				<cfif structKeyExists(stProperties, "password")>
				
					<cfset structDelete(session,"resetPWUserID")>
				
					<cfset request.pwchanged = true />
					
					<!--- Clear out the password reset key --->
					<cfset stProperties.forgotPasswordHash = "" />
				<cfelse>
					<cfset request.error = true />
				</cfif>
			</ft:processFormObjects>
		<cfelse>
			<cfset request.error = true />
		</cfif>
	<cfelse>
		<cfset request.error = true />
	</cfif>	
		
</ft:processForm>

<skin:view typename="farUser" template="displayHeaderLogin" />


<cfoutput><div class="loginInfo"></cfoutput>
	<ft:form>
		
		<cfif structKeyExists(request, "error")>
			<cfoutput><p id="errorMsg">Password reset failed</p></cfoutput>
		</cfif>	
			
		<cfif structKeyExists(request, "pwchanged")>
			<cfoutput>
				<p id="OKMsg">
					<admin:resource key="coapi.farUser.forgotpassword.passwordchanged@text">Your password has been changed!</admin:resource><br/>
					<skin:buildLink href="#application.url.webtoplogin#" rbkey="coapi.farLogin.login.login">Login</skin:buildLink>
				</p>
			</cfoutput>
		<cfelse>
			<cfif StructKeyExists(session,"resetPWUserID")> <!--- typed in a wrong password --->
				<ft:object typename="farUser" objectid="#session.resetPWUserID#" lfields="password" />

				<ft:buttonPanel>
					<ft:button value="Reset Password" />
				</ft:buttonPanel>
			<cfelseif StructKeyExists(url,"rh") and application.fc.utils.isGeneratedRandomString(url.rh)> <!--- coming from email --->
				<!--- check which user it is --->
				<cfquery datasource="#application.dsn#" name="qFarUser">
					SELECT objectid
					FROM farUser
					WHERE forgotPasswordHash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.rh#">
				</cfquery>
				
				<cfif qFarUser.recordCount eq 1>
					<!--- Set reset hash into session to make sure it is still the same user when updating --->
					<cfset session.resetPWUserID = qFarUser.objectid>
					
					<ft:object typename="farUser" objectid="#qFarUser.objectid#" lfields="password" />
	
					<ft:buttonPanel>
						<ft:button value="Reset Password" />
					</ft:buttonPanel>
				<cfelse>
					<cfoutput><p id="errorMsg"><admin:resource key="coapi.farUser.forgotpassword.resetfailed@text">Password reset failed</admin:resource></p></cfoutput>
				</cfif>			
			<cfelseif NOT structKeyExists(request, "error")> <!--- page called without valid reset hash --->
				<cfoutput><p id="errorMsg"><admin:resource key="coapi.farUser.forgotpassword.resetfailed@text">Password reset failed</admin:resource></p></cfoutput>
			</cfif>
			
		</cfif>
	
		<cfoutput><ul class="loginForgot"></cfoutput>
		<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
			<cfoutput>
				<li><skin:buildLink type="farUser" view="forgotPassword" rbkey="coapi.farLogin.login.forgotpassword">Forgot Password</skin:buildLink></li></cfoutput>
		</sec:CheckPermission>		
		<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
			<cfoutput>
				<li><skin:buildLink type="farUser" view="registerNewUser" rbkey="coapi.farLogin.login.registernewuser">Register New User</skin:buildLink></li></cfoutput>
		</sec:CheckPermission>			
			
		<cfoutput>
			<li><skin:buildLink href="#application.url.webtoplogin#" rbkey="coapi.farLogin.login.login">Login</skin:buildLink></li></cfoutput>
		<cfoutput></ul></cfoutput>
	
			
	</ft:form>

	
<cfoutput></div></cfoutput>


<skin:view typename="farUser" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">