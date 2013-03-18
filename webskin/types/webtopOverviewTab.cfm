<cfsetting enablecfoutputonly="true">
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
<!--- @@displayname: Render Webtop Overview Tab --->
<!--- @@description: Renders the Tabs for main information of the overview  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid">


<!--- ENVIRONMENT VARIABLES --->
<cfset stLocal.qTabs = getWebskins(typename=stObj.typename,prefix="webtopOverviewTab") />
<cfset stLocal.stTabs = structnew() />


		
			
			
<!--- WORKFLOW --->
<cfset workflowHTML = application.fapi.getContentType("farWorkflow").renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
<cfoutput>#workflowHTML#</cfoutput>

<skin:htmlHead>
<cfoutput>
<style type="text/css">
	.draft {
		float:right;
		outline: none;
		color: ##fff;
		border: 1px solid ##595959;
		background: -webkit-gradient(linear,left bottom,left top,color-stop(1,##D52D2D),color-stop(0,##cc0000));
		font-weight: bold;
		text-shadow: 0 1px 0 ##000;
		font-size: 14px;
		<!--- -webkit-border-radius: 3px; --->
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	.pending {
		float:right;
		outline: none;
		color: ##000;
		border: 1px solid ##8f6e09;
		background: -webkit-gradient(linear,left bottom,left top,color-stop(1,##fede00),color-stop(0,##f6b623));
		font-weight: bold;
		text-shadow: 0 1px 0 rgba(255, 255, 255, 0.6);
		font-size: 14px;
		<!--- -webkit-border-radius: 3px; --->
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	.approved {
		float:right;
		outline: none;
		color: ##000;
		border: 1px solid ##0e7109;
		background: -webkit-gradient(linear,left bottom,left top,color-stop(1,##4ED837),color-stop(0,##00B500));
		font-weight: bold;
		text-shadow: 0 1px 0 rgba(255, 255, 255, 0.6);
		font-size: 14px;
		<!--- -webkit-border-radius: 3px; --->
		padding:5px 10px 5px 10px ;
		text-align:center;
	}
	
	.draft a,
	.pending a,
	.approved a {
		background:transparent;
		text-shadow: none;
		color:##fff;
	}
	
	.draft a:hover,
	.pending a:hover,
	.approved a:hover {
		color:##eee;
	}
</style>
</cfoutput>
</skin:htmlHead>

<cfoutput>
<table class="layout" style="width:100%;padding:5px;table-layout:fixed;margin-bottom:10px;">
<tr>
	<td style="width:35px;"><skin:icon icon="#application.stCOAPI[stobj.typename].icon#" size="32" default="farcrycore" alt="#uCase(application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename))#" /></td>
	<td style="vertical-align:center;"><h1 style="text-align:left;">#stobj.label#</h1></td>
	<td>

		<!--- CONTENT ITEM STATUS --->
		<cfif structKeyExists(stobj,"status")>
			
			
			<cfswitch expression="#stobj.status#">
			<cfcase value="draft">
				
				<grid:div class="draft">
					<cfoutput>
						<div>DRAFT</div>
						<div style="font-size:11px;">last updated <span style="cursor:pointer;" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</span></div>
						
						<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
							<div style="font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="versionID=#stobj.versionID#" linktext="show approved version" /></div>
						</cfif>
					</cfoutput>
				</grid:div>
				
			</cfcase>
			<cfcase value="pending">
				
					<grid:div class="pending">
						<cfoutput>
							<div>PENDING</div>
							<div style="font-size:11px;">awaiting approval since <span style="cursor:pointer;" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</span></div>
							
							<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
								<div style="font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="versionID=#stobj.versionID#" linktext="show approved version" /></div>
							</cfif>
						</cfoutput>
					</grid:div>
			</cfcase>
			<cfcase value="approved">
				
					<grid:div class="approved">
						<cfoutput>
							<div>APPROVED</div> 
							<div style="font-size:11px;">last approved <span style="cursor:pointer;" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</span></div>
							
							<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
								<cfset qDraft = application.factory.oVersioning.checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
								<cfif qDraft.recordcount>
									<div style="font-size:11px;"><skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="versionID=#qDraft.objectid#" linktext="show #qDraft.status# version" /></div>
								</cfif>
							</cfif>	
						</cfoutput>
					</grid:div>
				
			</cfcase>
			</cfswitch>
		
		</cfif>	
	</td>
</tr>
</table>
</cfoutput>

			
			
		<cfset tabID = "directory#replace(stObj.objectid,'-','','ALL')#" />
		<grid:div id="#tabID#">
			<cfoutput>        	
			<ul style="padding-right: 150px;">
				<li><a href="##tabs-summary">General</a></li>
				<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
					<li><a href="##tabs-seo">SEO</a></li>
				</cfif>
				<cfloop query="stLocal.qTabs">
					<cfif stLocal.qTabs.methodname neq "webtopOverviewTab" and isdefined("application.stCOAPI.#stObj.typename#.stWebskins.#stLocal.qTabs.methodname#.displayname")>
						<li><a href="#application.fapi.getLink(objectid=stObj.objectid,view=stLocal.qTabs.methodname,urlparameters='ajaxmode=1')#">#application.stCOAPI[stObj.typename].stWebskins[stLocal.qTabs.methodname].displayname#</a></li>
					</cfif>
				</cfloop>
			</ul>
            </cfoutput>
			
			<skin:onReady>
				<cfoutput>$j("###tabID#").tabs();</cfoutput>
			</skin:onReady>
			
			<grid:div id="tabs-summary">	
				<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
			</grid:div>
			
			
			<!--- FRIENDLY URL --->
			<cfif application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="bFriendly", default="false")>
				<grid:div id="tabs-seo">
					<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewSEO" />
				</grid:div>
			</cfif>
			
			
		</grid:div>
	
<cfsetting enablecfoutputonly="false">
		