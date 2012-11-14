<cfsetting enablecfoutputonly="Yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: Farcry UD login form --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />



<cfif structKeyExists(url,'returnurl') and len(trim(url.returnurl))>
	<cfset stLocal.loginparams = 'returnurl='&urlEncodedFormat(url.returnurl) />
<cfelse>
	<cfset stLocal.loginparams = '' />
</cfif>

<!------------------ 
START WEBSKIN
 ------------------>	

<skin:view typename="farLogin" template="displayHeaderLogin" />
	
			
		<cfoutput>
		<div class="loginInfo">
		</cfoutput>	
		
			<ft:form>	
				
				<skin:pop tags="security" start="<ul id='errorMsg'>" end="</ul>">
					<cfoutput>
						<li>
							<cfif len(trim(message.title))><strong>#message.title#</strong></cfif><cfif len(trim(message.title)) and len(trim(message.message))>: </cfif>
							<cfif len(trim(message.message))>#message.message#</cfif>
						</li>
					</cfoutput>
				</skin:pop>
				
				<!--- -------------- --->
				<!--- SELECT PROJECT --->
				<!--- -------------- --->
				<cfif structKeyExists(server, "stFarcryProjects") AND structcount(server.stFarcryProjects) GT 1>
					<cfset aDomainProjects = arraynew(1) />
					<cfloop collection="#server.stFarcryProjects#" item="thisproject">
						<cfif isstruct(server.stFarcryProjects[thisproject]) and listcontains(server.stFarcryProjects[thisproject].domains,cgi.http_host)>
							<cfset arrayappend(aDomainProjects,thisproject) />
						</cfif>
					</cfloop>
					
					<cfif arraylen(aDomainProjects) gt 1>
						<ft:fieldset>
							<ft:field label="Project Selection" for="selectFarcryProject" rbkey="security.login.projectselection">
								<cfoutput>
								<select name="selectFarcryProject" id="selectFarcryProject" class="selectInput" onchange="window.location='#application.fapi.getLink(urlParameters=stLocal.loginparams)#&farcryProject='+this.value;">						
									<cfloop from="1" to="#arraylen(aDomainProjects)#" index="i">
										<cfif len(aDomainProjects[i])>
											<option value="#aDomainProjects[i]#"<cfif cookie.currentFarcryProject eq aDomainProjects[i]> selected="selected"</cfif>>#server.stFarcryProjects[aDomainProjects[i]].displayname#</option>
										</cfif>
									</cfloop>						
								</select>
								</cfoutput>
							</ft:field>
						</ft:fieldset>
					</cfif>
				</cfif>			
				
				<!--- --------------------- --->
				<!--- SELECT USER DIRECTORY --->
				<!--- --------------------- --->
				<cfif listlen(application.security.getAllUD()) GT 1>
					<sec:SelectUDLogin />
				</cfif>


				<ft:object typename="farLogin" lFields="username,password" prefix="login" legend="" focusField="username" />
					
				
				<ft:buttonPanel>
				
	
					<cfif isdefined("arguments.stParam.message") and len(arguments.stParam.message)>
						<skin:bubble message="#arguments.stParam.message#" tags="security,information" rbkey="security.message.#rereplace(arguments.stParam.message,'[^\w]','','ALL')#" />
					</cfif>
					
					<ft:button value="Log In" rbkey="security.buttons.login" />
				</ft:buttonPanel>

				
				
				<cfoutput><ul class="loginForgot"></cfoutput>
					<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
						<cfoutput> 
							<li><skin:buildLink type="farUser" view="forgotPassword" rbkey="coapi.farLogin.login.forgotpassword">Forgot Password</skin:buildLink></li></cfoutput>
					</sec:CheckPermission>
					<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
						<cfoutput> 
							<li><skin:buildLink type="farUser" view="forgotUserID" rbkey="coapi.farLogin.login.forgotuserid">Forgot UserID</skin:buildLink></li></cfoutput>
					</sec:CheckPermission>			
					<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
						<cfoutput> 
							<li><skin:buildLink type="farUser" view="registerNewUser" rbkey="coapi.farLogin.login.registernewuser">Register New User</skin:buildLink></li></cfoutput>
					</sec:CheckPermission>
				<cfoutput></ul></cfoutput>

				
			</ft:form>
			

			
		<cfoutput>
		</div>
		</cfoutput>		
				
	

<skin:view typename="farLogin" template="displayFooterLogin" />


<cfsetting enablecfoutputonly="false">