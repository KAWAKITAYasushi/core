<cfsetting enablecfoutputonly="yes">
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
<!---
|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au)$
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.typename" default="" />
	<cfparam name="attributes.columnlist" default="label,datetimelastupdated" />

   <!---
        get multiple users in pagination
    --->


<!---<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=avnArticle&method=edit&ref=typeadmin&module=customlists/avnArticle.cfm" />
 --->


<cfparam name="form.Criteria" default="" />
<cfparam name="pluginURL" default="" /><!--- used in case we are in a plugin object admin --->


<cfparam name="session.objectadmin" default="#structnew()#" type="struct">

<cfif structkeyexists(application.stCOAPI[attributes.typename],"displayname") and len(application.stCOAPI[attributes.typename].displayname)>
	<cfparam name="attributes.title" default="#application.rb.formatRBString('coapi.#attributes.typename#.headings.typeadministration@text',application.stCOAPI[attributes.typename].displayname,'{1} Administration')#">
<cfelse>
	<cfparam name="attributes.title" default="#application.rb.formatRBString('coapi.#attributes.typename#.headings.typeadministration@text',attributes.typename,'{1} Administration')#">
</cfif>

<cfparam name="attributes.ColumnList" default="" type="string">
<cfparam name="attributes.SortableColumns" default="" type="string">
<cfparam name="attributes.lFilterFields" default="" type="string">
<cfparam name="attributes.description" default="" type="string">
<cfparam name="attributes.datasource" default="#application.dsn#" type="string">
<cfparam name="attributes.aColumns" default="#arrayNew(1)#" type="array">
<cfparam name="attributes.aCustomColumns" default="#arrayNew(1)#" type="array">
<cfparam name="attributes.aButtons" default="#arrayNew(1)#" type="array">
<cfparam name="attributes.bdebug" default="false" type="boolean">
<cfparam name="attributes.bFilterCategories" default="true" type="boolean">
<cfparam name="attributes.bFilterDateRange" default="true" type="boolean">
<cfparam name="attributes.bFilterProperties" default="true" type="boolean">
<cfparam name="attributes.permissionset" default="#attributes.typename#" type="string">
<!--- attributes.query type="query" CF7 specific --->
<cfparam name="attributes.defaultorderby" default="datetimelastupdated" type="string">
<cfparam name="attributes.defaultorder" default="desc" type="string">
<cfparam name="attributes.id" default="#attributes.typename#" type="string">
<cfparam name="attributes.sqlorderby" default="datetimelastupdated desc" type="string" />
<cfparam name="attributes.sqlWhere" default="" />
<cfparam name="attributes.lCategories" default="" />
<cfparam name="attributes.name" default="objectadmin" />

<!--- admin configuration options --->
<cfparam name="attributes.numitems" default="#application.config.general.GENERICADMINNUMITEMS#" type="numeric">
<cfparam name="attributes.numPageDisplay" default="5" type="numeric">

<cfparam name="attributes.lButtons" default="*" type="string">
<cfparam name="attributes.bPaginateTop" default="true" type="boolean">
<cfparam name="attributes.bPaginateBottom" default="true" type="boolean">
<cfparam name="attributes.bSelectCol" default="true" type="boolean">
<cfparam name="attributes.bEditCol" default="true" type="boolean">
<cfparam name="attributes.bViewCol" default="true" type="boolean">
<cfparam name="attributes.bFlowCol" default="true" type="boolean">


<cfparam name="attributes.editMethod" default="edit" type="string">

<cfparam name="attributes.PackageType" default="types" type="string">

<cfparam name="attributes.module" default="customlists/#attributes.typename#.cfm">
<cfparam name="attributes.plugin" default="" />
<cfparam name="attributes.lCustomActions" default="" />
<cfparam name="attributes.stFilterMetaData" default="#structNew()#" />
<cfparam name="attributes.bShowActionList" default="true" />
<cfparam name="attributes.qRecordset" default=""><!--- Used if the developer wants to pass in their own recordset --->

<cfparam name="attributes.rbkey" default="coapi.#attributes.typename#.objectadmin" />

<!--- I18 conversion off text output attributes --->
<cfset attributes.description = application.rb.getResource("#attributes.rbkey#.description@text",attributes.description) />


<cfif NOT structKeyExists(session.objectadmin, attributes.typename)>
	<cfset structInsert(session.objectadmin, attributes.typename, structnew())>
</cfif>

<cfset PrimaryPackage = duplicate(application.stCOAPI[attributes.typename]) />
<cfset PrimaryPackagePath = application.stCOAPI[attributes.typename].packagepath />

<cfif not len(attributes.sqlWhere)>
	<cfset attributes.sqlWhere = "0=0" />
</cfif>

<cfif NOT structKeyExists(PrimaryPackage, "news")>

<!--- this seems to be a problem for custom types when it gets to invocation.cfm. the permission set is not carried
across and could potentially cause major stuff ups if news permissions (which is the default) is set to no for the
user --->
	<cfset structInsert(PrimaryPackage, "permissionset", "news", "yes")>
</cfif>

<!--- Make sure the type is deployed --->
<cfset alterType = createObject("component","farcry.core.packages.farcry.alterType") />

<!--- Deploy type if it has been requested --->
<cfif structkeyexists(url,"deploy") and url.deploy>
	<cfset createobject("component",application.stCOAPI[attributes.typename].packagepath).deployType(btestRun="false") />
	<cflocation url="#cgi.script_name#?#replacenocase(cgi.query_string,'deploy=true','')#" />
</cfif>

<!--- If type isn't deployed, display error --->
<cfif not alterType.isCFCDeployed(typename=attributes.typename)>

	<cfoutput>The '<cfif structkeyexists(application.stCOAPI[attributes.typename],"displayname")>#application.stCOAPI[attributes.typename].displayname#<cfelse>#listlast(application.stCOAPI[attributes.typename].name,'.')#</cfif>' content type has not been deployed yet. Click <a href="#cgi.SCRIPT_NAME#?#cgi.query_string#&deploy=true">here</a> to deploy it now.</cfoutput>

<cfelse>

	<cfset oTypeAdmin = createobject("component", "#application.packagepath#.farcry.objectadmin").init(stprefs=session.objectadmin[attributes.typename], attributes=attributes)>
	
	
	
	
	<!--- check if the type has a status property --->
	<!--- <cfset bUsesStatus = false>
	<cfif structKeyExists(application.types[attributes.typename].STPROPS, "status")>
		<cfset bUsesStatus = true>
		<cfif not findNocase(attributes.ColumnList, "status") or not findNocase(attributes.ColumnList, "*")>
			<cfset attributes.ColumnList = listAppend(attributes.ColumnList,"status")>
		</cfif>
	</cfif> --->
	
	
	
	
	<!---
	 get default grid data 
	<cfset aDefaultColumns=oTypeAdmin.getDefaultColumns()>
	<cfset aDefaultButtons=oTypeAdmin.getDefaultButtons()>
	
	--->
	
	<!--- refactored to here... 
	<cfset session.objectadmin[attributes.typename]=oTypeadmin.getprefs()>
	<cfset stpermissions=oTypeAdmin.getBasePermissions()>
	<!--- <cfdump var="#session.objectadmin[attributes.typename]#"> --->
	 /refactored --->
	
	
	<cfif len(attributes.title)>
		<cfoutput><h1><admin:icon icon="#application.stCOAPI[attributes.typename].icon#" usecustom="true" />#attributes.title#</h1></cfoutput>
	</cfif>
	
	<cfset stPrefs = oTypeAdmin.getPrefs() />
	<cfset stpermissions=oTypeAdmin.getBasePermissions()>
	
	
	
	
	
	<ft:processform action="delete" url="refresh">
		<cfif isDefined("form.objectid") and len(form.objectID)>
			
			<cfloop list="#form.objectid#" index="i">
				<cfset o = createObject("component", PrimaryPackagePath) />
				<cfset stDeletingObject = o.getData(objectid=i) />
				<cfset stResult = o.delete(objectid=i) />
				
				<cfif isDefined("stResult.bSuccess") AND not stResult.bSuccess>
					<extjs:bubble title="Error deleting - #stDeletingObject.label#" bAutoHide="true">
						<cfoutput>#stResult.message#</cfoutput>
					</extjs:bubble>
				<cfelse>
					<extjs:bubble title="Deleted - #stDeletingObject.label#" bAutoHide="true" />
				</cfif>
			</cfloop>
		</cfif>
	</ft:processForm>
	
	<ft:processform action="unlock">
		<cfif isDefined("form.objectid") and len(form.objectID)>
			
			<cfloop list="#form.objectid#" index="i">
				<cfset o = createObject("component", PrimaryPackagePath) />
				<cfset st = o.getData(objectid=i) />
				<cfset o.setlock(locked="false") />
			</cfloop>
		
		</cfif>
		
	</ft:processForm>
	
	
	
	<!--- IF javascript has set the selected objectid, set the form.objectid to it. --->
	<cfif isDefined("FORM.selectedObjectID") and len(form.selectedObjectID)>
		<cfset form.objectid = form.selectedObjectID />
	</cfif>
	
	<cfparam name="session.objectadminFilterObjects" default="#structNew()#" />
	<cfif not structKeyExists(session.objectadminFilterObjects, attributes.typename)>
		<cfset session.objectadminFilterObjects[attributes.typename] = structNew() />
	</cfif>
	
	
	<cfif len(attributes.lFilterFields)>
	
			<cfset oFilterType = createObject("component", PrimaryPackagePath) />
		
	
		
			<cfif not structKeyExists(session.objectadminFilterObjects[attributes.typename], "stObject")>
				
				<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectid="#application.fc.utils.createJavaUUID()#") />
				
							
				<cfset session.objectadminFilterObjects[attributes.typename].stObject.label = "" />
				<cfset stResult = oFilterType.setData(stProperties=session.objectadminFilterObjects[attributes.typename].stObject, bSessionOnly=true) />
		
				<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectID = session.objectadminFilterObjects[attributes.typename].stObject.objectid) />
				
				<!--- The default filter doesn't incorporate the default values specified in stFilterMetadata. This loop handles that gap. --->
				<cfloop collection="#attributes.stFilterMetadata#" item="prop">
					<cfif structkeyexists(attributes.stFilterMetadata[prop],"ftDefault")>
						<cfset session.objectadminFilterObjects[attributes.typename].stObject[prop] = attributes.stFilterMetadata[prop].ftDefault />
					</cfif>
				</cfloop>
				
			</cfif>
			
			<ft:processform action="apply filter" url="refresh">
				<ft:processformObjects objectid="#session.objectadminFilterObjects[attributes.typename].stObject.objectid#" bSessionOnly="true" />	
			</ft:processForm>
			
			<ft:processform action="clear filter" url="refresh">
				<cfset structDelete(session.objectadminFilterObjects, attributes.typename) />
			</ft:processForm>
			
			
			<cfset request.inHead.scriptaculouseffects = 1 />
			<!--- <cfdump var="#session.objectadminFilterObjects[attributes.typename].stObject#">
			<cfdump var="#attributes.lFilterFields#"> --->
			
			<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectID = session.objectadminFilterObjects[attributes.typename].stObject.objectid) />
			<cfset HTMLfiltersAttributes = "">
			<cfloop list="#attributes.lFilterFields#" index="criteria">
				<cfif session.objectadminFilterObjects[attributes.typename].stObject[criteria] neq "">
					<cfset thisCriteria = lcase(criteria)>
					<cfif isDefined("application.types.#attributes.typename#.stProps.#criteria#.metadata.ftLabel")>
						<cfset thisCriteria = lcase(application.types[attributes.typename].stProps[criteria].metadata.ftLabel)>
					</cfif>
					<cfset HTMLfiltersAttributes = listAppend(HTMLfiltersAttributes," "&lcase(thisCriteria)&" ",'&')>
				</cfif>
			</cfloop>
		
			
			<cfif trim(HTMLfiltersAttributes) neq "">
				<cfset HTMLfiltersAttributes = "<div style='display:inline;color:##000'>#application.rb.getResource('objectadmin.messages.resultfilteredby@text','result filtered by')#:</div> " & HTMLfiltersAttributes >
			</cfif>
		
	
			<ft:form style="padding:10px; border: 1px solid ##000;margin-bottom:10px; ">
				<cfoutput>
				<div style="display:inline;color:##E17000">
					#application.rb.getResource('objectadmin.messages.ListingFilter@text','Listing Filter')#:
					<cfif HTMLfiltersAttributes eq "">
						<a onclick="Effect.toggle('filterForm','blind');">set</a>
					<cfelse>
						<a onclick="Effect.toggle('filterForm','blind');">edit</a> 
						
						<div style="font-size:90%;margin-left:10px;border:1px solid ##000;padding:2px;float:right;background-color:##fff">
							#HTMLfiltersAttributes#
							<ft:farcryButton value="clear filter" />
							<br class="clearer" />
						</div>
					</cfif>		
				</div>
				</cfoutput>
				<cfoutput><div id="filterForm" style="display:none;"><div style="padding:5px;"></cfoutput>
				
					<ft:object objectid="#session.objectadminFilterObjects[attributes.typename].stObject.objectid#" typename="#attributes.typename#" lFields="#attributes.lFilterFields#" lExcludeFields="" includeFieldset="false" stPropMetaData="#attributes.stFilterMetaData#" />
					
					<ft:farcryButtonPanel>
						<ft:farcryButton value="apply filter" />
					</ft:farcryButtonPanel>
					
				<cfoutput><br class="clearer" /></div></div></cfoutput>
				
			</ft:form>
	
		
		
	
			<cfset session.objectadminFilterObjects[attributes.typename].stObject = oFilterType.getData(objectID = session.objectadminFilterObjects[attributes.typename].stObject.objectid) />
	
	
		<!------------------------
		SQL WHERE CLAUSE
		 ------------------------>
	
			<cfsavecontent variable="attributes.sqlWhere">
				
				<cfoutput>
					#attributes.sqlWhere#
				</cfoutput>	
					
					
					<cfloop list="#attributes.lFilterFields#" index="i">
						<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
							<cfswitch expression="#PrimaryPackage.stProps[i].metadata.ftType#">
							
							<cfcase value="string,nstring,list,uuid">	
								<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
									<cfloop list="#session.objectadminFilterObjects[attributes.typename].stObject[i]#" index="j">
										<cfset whereValue = ReplaceNoCase(trim(LCase(j)),"'", "''", "all") />
										<cfoutput>AND lower(#i#) LIKE '%#whereValue#%'</cfoutput>
									</cfloop>
								</cfif>
							</cfcase>
							
							<cfcase value="boolean">	
								<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
									<cfloop list="#session.objectadminFilterObjects[attributes.typename].stObject[i]#" index="j">
										<cfset whereValue = ReplaceNoCase(j,"'", "''", "all") />
										<cfoutput>AND lower(#i#) = '#j#'</cfoutput>
									</cfloop>
								</cfif>
							</cfcase>
							
							<cfcase value="category">
								<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
									<cfloop list="#session.objectadminFilterObjects[attributes.typename].stObject[i]#" index="j">
										<cfset attributes.lCategories = listAppend(attributes.lCategories, trim(j)) />
									</cfloop>
								</cfif>
							</cfcase>
		
							<cfdefaultcase>	
								
								<cfif len(session.objectadminFilterObjects[attributes.typename].stObject[i])>
									<cfloop list="#session.objectadminFilterObjects[attributes.typename].stObject[i]#" index="j">
										<cfif listcontains("string,nstring,longchar", PrimaryPackage.stProps[i].metadata.type)>
											<cfset whereValue = ReplaceNoCase(trim(j),"'", "''", "all") />
											<cfoutput>AND lower(#i#) LIKE '%#whereValue#%'</cfoutput>
										<cfelseif listcontains("numeric", PrimaryPackage.stProps[i].metadata.type)>
											<cfset whereValue = ReplaceNoCase(j,"'", "''", "all") />
											<cfoutput>AND #i# = #whereValue#</cfoutput>
										</cfif>
									</cfloop>
								</cfif>
							</cfdefaultcase>
							
							</cfswitch>
							
						</cfif>
					</cfloop>
				
			</cfsavecontent>
	
	</cfif>
	
	
	
		<!------------------------
		SQL ORDER BY CLAUSE
		 ------------------------>
		<cfset session.objectadminFilterObjects[attributes.typename].sqlOrderBy = "" />
		<cfif len(attributes.sortableColumns)>
			<cfif isDefined("form.sqlOrderBy") and len(form.sqlOrderby)>
				<cfset session.objectadminFilterObjects[attributes.typename].sqlOrderBy = form.sqlOrderby />
			</cfif>
		</cfif>
		
		<cfif not len(session.objectadminFilterObjects[attributes.typename].sqlOrderBy) >
			<cfset session.objectadminFilterObjects[attributes.typename].sqlOrderBy = attributes.sqlorderby />
		</cfif>
		
				
		
		
		
		<cfset addURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=#application.fc.utils.createJavaUUID()#&typename=#attributes.typename#&method=#attributes.editMethod#&ref=typeadmin&module=#attributes.module#" />	
		<cfif Len(attributes.plugin)>
			<cfset addURL = addURL&"&plugin=#attributes.plugin#" />
			<cfset pluginURL = "&plugin=#attributes.plugin#" /><!--- we need this when using a plugin like farcrycms, to be able to redirect back to the plugin object admin instead of the project or core object admin --->
		</cfif>
		<ft:processForm action="add" url="#addURL#" />
	
		
		
		<ft:processForm action="overview">
			<!--- TODO: Check Permissions. --->
			<cfset EditURL = "#application.url.farcry#/edittabOverview.cfm?objectid=#form.objectid#&typename=#attributes.typename#&method=#attributes.editMethod#&ref=typeadmin&module=#attributes.module#">
			<cfif Len(attributes.plugin)><cfset EditURL = EditURL&"&plugin=#attributes.plugin#"></cfif>
			<cflocation URL="#EditURL#" addtoken="false">
		</ft:processForm>
		
		<ft:processForm action="edit">
			<!--- TODO: Check Permissions. --->
			<cfset EditURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=#form.objectid#&typename=#attributes.typename#&method=#attributes.editMethod#&ref=typeadmin&module=#attributes.module#">
			<cfif Len(attributes.plugin)><cfset EditURL = EditURL&"&plugin=#attributes.plugin#"></cfif>
			<cflocation URL="#EditURL#" addtoken="false">
		</ft:processForm>
		
		<ft:processForm action="view">
			<!--- TODO: Check Permissions. --->
			<cfoutput>
				<script language="javascript">
					var newWin = window.open("#application.url.webroot#/index.cfm?objectID=#form.objectid#&flushcache=1","viewWindow","resizable=yes,menubar=yes,scrollbars=yes,width=800,height=600,location=yes");
				</script>
			</cfoutput>
			<!--- <cflocation URL="#application.url.webroot#/index.cfm?objectID=#form.objectid#&flushcache=1" addtoken="false" /> --->
		</ft:processForm>
		
		<cfif structKeyExists(application.stPlugins, "flow")>
			<ft:processForm action="flow">
				<!--- TODO: Check Permissions. --->
				<cflocation URL="#application.stPlugins.flow.url#/?startid=#form.objectid#&flushcache=1" addtoken="false" />
			</ft:processForm>
		</cfif>
		
		<ft:processForm action="requestapproval">
			<!--- TODO: Check Permissions. --->
			<cflocation URL="#application.url.farcry#/navajo/approve.cfm?objectid=#form.objectid#&status=requestapproval" addtoken="false" />
		</ft:processForm>
		
		<ft:processForm action="approve">
			<!--- TODO: Check Permissions. --->
			<cflocation URL="#application.url.farcry#/navajo/approve.cfm?objectid=#form.objectid#&status=approved" addtoken="false" />
		</ft:processForm>
		
		<ft:processForm action="createdraft">
			<!--- TODO: Check Permissions. --->
			<cflocation URL="#application.url.farcry#/navajo/createDraftObject.cfm?objectID=#form.objectID#" addtoken="false" />
		</ft:processForm>
		
		<ft:processForm action="Send to Draft">
			<!--- TODO: Check Permissions. --->
			<cflocation URL="#application.url.farcry#/navajo/approve.cfm?objectid=#form.objectid#&status=draft" addtoken="false" />
		</ft:processForm>
	
	
	
		
		<ft:processForm action="properties">
			
			<cfif listLen(form.objectid) EQ 1>
				<extjs:iframeDialog />
				
				<skin:htmlHead>
					<cfoutput>
					<script type="text/javascript">
						openScaffoldDialog('#application.url.farcry#/object_dump.cfm?objectid=#form.objectid#','Properties',500,500,true);
					</script>
					</cfoutput>
				</skin:htmlHead>
			</cfif>
		</ft:processForm>
	
		<!-----------------------------------------------
		    Form Actions for Type Admin Grid
		------------------------------------------------>
		<!--- TODO: retest permissions on form action, otherwise you can circumnavigate permissions with your own dummy form submission GB --->
		<cfscript>
		// response: action message container for objectadmin
		response="";
		message_error = "";
		
		// add: content item added
		// JS window.location from button press
			
		// delete: content items deleted
		if (isDefined("form.delete") AND form.delete AND isDefined("form.objectid")){
			objType = CreateObject("component","#PrimaryPackagePath#");
			aDeleteObjectID = ListToArray(form.objectid);
		
			for(i=1;i LTE Arraylen(aDeleteObjectID);i = i+1){
				returnstruct = objType.delete(aDeleteObjectID[i]);
				if(StructKeyExists(returnstruct,"bSuccess") AND NOT returnstruct.bSuccess)
					message_error = message_error & returnstruct.message;
			}
		}
		</cfscript>
		
		<!---// dump: content items to dump
		// TODO: implement object dump code! --->
		<cfif isDefined("form.dump") AND isDefined("form.objectid") AND len(form.objectid)>
			<!---response="DUMP (field: #form.dump#)actioned for: #form.objectid#."; --->
			<cfsavecontent variable="response">
				<cfloop list="#form.objectid#" index="i">
					<cfset st = createObject("component", PrimaryPackagePath).getData(objectid=i) />
					<cfdump var="#st#" expand="false" label="Dump of #st.label#">
				</cfloop>
				
			</cfsavecontent>
		</cfif>
		
		<cfscript>
		// status: change status of the selected content items
		// todo: make three unique buttons, match on buttontype *not* resource bundle label
		statusurl="";
		if (isDefined("form.status")) {
			if (isDefined("form.objectID")) {
				if (form.status contains application.rb.getResource('objectadmin.buttons.approve@label','Approve')) {
					status = 'approved';
				}	
				else if (form.status contains application.rb.getResource('objectadmin.buttons.sendtodraft@label','Send to Draft')) {
					status = 'draft';
				}
				else if (form.status contains application.rb.getResource('objectadmin.buttons.requestapproval@label','Request Approval')) {
					status = 'requestApproval';
				}
				else {
					status = 'unknown';
				}
				// pass list of objectids to comment template to add user comments
				statusurl = "#application.url.farcry#/conjuror/changestatus.cfm?typename=#attributes.typename#&status=#status#&objectID=#form.objectID#&finishURL=#URLEncodedFormat(cgi.script_name)#?#URLEncodedFormat(cgi.query_string)#";
				if (isDefined("stgrid.approveURL")) {
					statusurl = statusurl & "&approveURL=#URLEncodedFormat(stGrid.approveURL)#";
				}
			} else {
				response = "#application.rb.getResource('objectadmin.messages.noobjectselected@text','No content items were selected for this operation')#";
			}
		}
		</cfscript>
		<!--- redirect user on status change --->
		<cfif len(statusurl)><cflocation url="#statusurl#" addtoken="false"></cfif>
		
		<cfscript>
		// unlock: unlock content items
		if (isDefined("form.unlock") AND isDefined("form.objectid")) {
			aObjectids = listToArray(form.objectid);
			//loop over all selected objects
			for(i = 1;i LTE arrayLen(aObjectids);i=i+1) {
				// set unlock permmission to false by default
				bAllowUnlock=false;
				// get content item data
				o=createobject("component", "#PrimaryPackagePath#");
				stObj = o.getData(objectid=aObjectids[i]);
				if(stObj.locked)
				{
					// allow owner of the object or the person who has locked the content item to unlock
					if (stObj.lockedby IS "#application.security.getCurrentUserID()#"
						OR stObj.ownedby IS "#application.security.getCurrentUserID()#") {
						bAllowUnlock=true;
					// allow users with approve permission to unlock
					} else if (stPermissions.iApprove eq 1) {
						bAllowUnlock=true;
					// if the user doesn't have permission, push error response
					} else {
						response=application.rb.getResource('objectadmin.messages.nopermissionunlockall@text','You do not have permission to unlock all content items');
					}
				}
				if (bAllowUnlock) {
					// TODO: replace with types.setlock()
					oLocking=createObject("component",'#application.packagepath#.farcry.locking');
					oLocking.unLock(objectid=aObjectids[i],typename=stObj.typename);
					// TODO: i18n
					response="#application.rb.getResource('objectadmin.messages.contentitemsunlocked@text','Content items unlocked.')#";
				}
			}
		}
		</cfscript>
		<!--- 
		// custom: custom button action
		--->
		<cfif NOT structisempty(form)>
			<cfif NOT isDefined("form.objectid")>
				<cfscript>
					form.objectid = application.fc.utils.createJavaUUID();
				</cfscript>
			</cfif>
			<cfloop collection="#form#" item="fieldname">
				<!--- match for custom button action --->
				<cfif reFind("^CB.*", fieldname) AND NOT reFind("^CB.*_DATA", fieldname) and structKeyExists(form, "#fieldname#_data")>
					<cfset wcustomdata=evaluate("form.#fieldname#_data")>
					<cfwddx action="wddx2cfml" input="#wcustomdata#" output="stcustomdata">
					<cfif len(stcustomdata.method)>
						<cflocation url="#application.url.farcry#/conjuror/invocation.cfm?objectid=#form.objectID#&typename=#attributes.typename#&ref=typeadmin&method=#stcustomdata.method#" addtoken="false">
					<cfelse>
						<cflocation url="#stcustomdata.url#" addtoken="false">
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
	
	
	<cfif len(attributes.description)>
		<cfoutput>#attributes.description#</cfoutput>
	</cfif>
	
	<ft:form style="width: 100%;" Name="#attributes.name#">
	
		<!--- output user responses --->
		<cfif len(message_error)><cfoutput><p id="error" class="fade"><span class="error">#message_error#</span></p></cfoutput></cfif>
		<cfif len(response)><cfoutput><p id="response" class="fade">#response#</p></cfoutput></cfif>
		
		<!--- delete flag; modified to 1 on delete confirm --->
		<cfoutput><input name="delete" type="Hidden" value="0"></cfoutput>
		
		<cfsavecontent variable="html_buttonbar">
		
			<cfif len(attributes.lButtons)>
				<ft:farcryButtonPanel indentForLabel="false">
				<cfloop from="1" to="#arraylen(attributes.aButtons)#" index="i">
					
					<cfif attributes.lButtons EQ "*" or listFindNoCase(attributes.lButtons,attributes.aButtons[i].value)>
						<!--- (#attributes.aButtons[i].name#: #attributes.aButtons[i].permission#) --->
						<cfif not len(attributes.aButtons[i].permission) or (isboolean(attributes.aButtons[i].permission) and attributes.aButtons[i].permission) or (not isboolean(attributes.aButtons[i].permission) and application.security.checkPermission(permission=attributes.aButtons[i].permission) EQ 1)>
							
							<cfif len(attributes.aButtons[i].onclick)> 
								<cfset onclickJS="#attributes.aButtons[i].onclick#" />
							<cfelse>
								<cfset onclickJS="" />
							</cfif>
							<cfif not structKeyExists(attributes.aButtons[i], "confirmText")> 
								<cfset attributes.aButtons[i].confirmText = "" />
							</cfif>
							
							<ft:farcryButton value="#attributes.aButtons[i].value#"  onclick="#onclickJS#" confirmText="#attributes.aButtons[i].confirmText#" />
							<!---<input type="#attributes.aButtons[i].type#" name="#attributes.aButtons[i].name#" value="#attributes.aButtons[i].value#" class="formButton"<cfif len(attributes.aButtons[i].onclick)> onclick="#attributes.aButtons[i].onclick#"</cfif> /> --->
						</cfif>
					</cfif>
				</cfloop>
				</ft:farcryButtonPanel>
			</cfif>
		</cfsavecontent>
		
		<cfoutput>#html_buttonbar#</cfoutput>

	
	
		<cfif isQuery(attributes.qRecordset)>
			<cfset stRecordSet.q = attributes.qRecordset>
			<cfset stRecordSet.countAll = attributes.qRecordset.recordCount />
			<cfset stRecordSet.currentPage = 0 />
			<cfset stRecordSet.recordsPerPage = attributes.numitems />
		<cfelse>
	
			<cfset oFormtoolUtil = createObject("component", "farcry.core.packages.farcry.formtools") />
			<cfset sqlColumns="objectid,locked,lockedby,#attributes.columnlist#" />		
		
			<cfset stRecordset = oFormtoolUtil.getRecordset(paginationID="#attributes.typename#", sqlColumns=sqlColumns, typename="#attributes.typename#", RecordsPerPage="#attributes.numitems#", sqlOrderBy="#session.objectadminFilterObjects[attributes.typename].sqlOrderBy#", sqlWhere="#attributes.sqlWhere#", lCategories="#attributes.lCategories#", bCheckVersions=true) />	
		</cfif>

	
	<ft:pagination 
		paginationID="#attributes.typename#"
		qRecordSet="#stRecordset.q#"
		typename="#attributes.typename#"
		totalRecords="#stRecordset.countAll#" 
		currentPage="#stRecordset.currentPage#"
		Step="10"  
		pageLinks="#attributes.numPageDisplay#"
		recordsPerPage="#stRecordset.recordsPerPage#" 
		Top="#attributes.bPaginateTop#" 
		Bottom="#attributes.bPaginateBottom#"
		submissionType="form"> 
	
	
		<cfif len(attributes.SortableColumns)>
			<cfoutput><input type="hidden" id="sqlOrderBy" name="sqlOrderBy" value="#session.objectadminFilterObjects[attributes.typename].sqlOrderBy#"></cfoutput>
		</cfif>
		
		<cfoutput>
		<table width="100%" class="objectAdmin">
		<thead>
			<tr>			
		</cfoutput>
		
		 		<cfif attributes.bSelectCol><cfoutput><th>Select</th></cfoutput></cfif>
		 		<cfif listContainsNoCase(stRecordset.q.columnlist,"bHasMultipleVersion")>
			 		<cfoutput><th>#application.rb.getResource('objectadmin.columns.status@label',"Status")#</th></cfoutput>
				</cfif>
				
				<cfif attributes.bShowActionList>
					<cfoutput><th>#application.rb.getResource('objectadmin.columns.action@label','Action')#</th></cfoutput>
				</cfif>
				<!---<cfif attributes.bEditCol><th>Edit</th></cfif>
				<cfif attributes.bViewCol><th>View</th></cfif>
				<cfif attributes.bFlowCol><th>Flow</th></cfif> --->
				
				<cfset o = createobject("component",PrimaryPackagepath) />
				
				<cfif arrayLen(attributes.aCustomColumns)>
					<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
						
						<cfif isstruct(attributes.aCustomColumns[i])>
						
							<cfif structKeyExists(attributes.aCustomColumns[i], "title")>
								<cfoutput><th>#application.rb.getResource("objectadmin.columns.#rereplace(attributes.aCustomColumns[i].title,'[^\w\d]','','ALL')#@label",attributes.aCustomColumns[i].title)#</th></cfoutput>
							<cfelse>
								<cfoutput><th>&nbsp;</th></cfoutput>
							</cfif>
							
						<cfelse><!--- Normal field --->
							
							<cfif isDefined("PrimaryPackage.stProps.#trim(attributes.aCustomColumns[i])#.metadata.ftLabel")>
								<cfoutput><th>#o.getI18Property(attributes.aCustomColumns[i],"label")#</th></cfoutput>
							<cfelse>
								<cfoutput><th>#attributes.aCustomColumns[i]#</th></cfoutput>
							</cfif>
							
							<!--- If this field is in the column list (and it should be) remove it so it won't get displayed elsewhere --->
							<cfif listcontainsnocase(attributes.columnlist,attributes.aCustomColumns[i])>
								<cfset attributes.columnlist = listdeleteat(attributes.columnlist,listfindnocase(attributes.columnlist,attributes.aCustomColumns[i])) />
							</cfif>
							
						</cfif>
						
					</cfloop>
				</cfif>
				
				<cfloop list="#attributes.columnlist#" index="i">				
						
					<cfif isDefined("PrimaryPackage.stProps.#trim(i)#.metadata.ftLabel")>
						<cfoutput><th>#o.getI18Property(i,"label")#</th></cfoutput>
					<cfelse>
						<cfoutput><th>#i#</th></cfoutput>
					</cfif>
					
				</cfloop>
				
			<cfoutput>
			</tr>
			</cfoutput>
			
			
			<cfif len(attributes.SortableColumns)>
				<cfoutput>
				<tr>
				</cfoutput>
				
			 		<cfif attributes.bSelectCol><cfoutput><th>&nbsp;</th></cfoutput></cfif>	 	
			 			
			 		<cfif listContainsNoCase(stRecordset.q.columnlist,"bHasMultipleVersion")>
				 		<cfoutput><th>&nbsp;</th></cfoutput>
					</cfif>
					<cfif attributes.bShowActionList>
						<cfoutput><th>&nbsp;</th></cfoutput>
					</cfif>
					<!---<cfif attributes.bEditCol><th>&nbsp;</th></cfif>
					<cfif attributes.bViewCol><th>&nbsp;</th></cfif>
					<cfif attributes.bFlowCol><th>&nbsp;</th></cfif> --->					
					<cfif arrayLen(attributes.aCustomColumns)>
						<cfset oType = createObject("component", PrimaryPackagePath) />
						<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
							<cfif isstruct(attributes.aCustomColumns[i])>
								<cfif structKeyExists(attributes.aCustomColumns[i],"sortable") and attributes.aCustomColumns[i].sortable>
									<cfoutput>
									<th>
									<select name="#attributes.aCustomColumns[i].property#sqlOrderBy" onchange="javascript:$('sqlOrderBy').value=this.value;submit();" style="width:80px;">
										<option value=""></option>
										<option value="#attributes.aCustomColumns[i].property# asc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i].property# asc">selected</cfif>>asc</option>
										<option value="#attributes.aCustomColumns[i].property# desc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i].property# desc">selected</cfif>>desc</option>
									</select>
									</th>
									</cfoutput>						
								<cfelse>
									<cfoutput><th>&nbsp;</th></cfoutput>
								</cfif>
							<cfelse>
								<cfif listContainsNoCase(attributes.SortableColumns,attributes.aCustomColumns[i])><!--- Normal property in sortablecolumn list --->
									<cfoutput>
									<th>
									<select name="#attributes.aCustomColumns[i]#sqlOrderBy" onchange="javascript:$('sqlOrderBy').value=this.value;submit();" style="width:80px;">
										<option value=""></option>
										<option value="#attributes.aCustomColumns[i]# asc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i]# asc">selected</cfif>>asc</option>
										<option value="#attributes.aCustomColumns[i]# desc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#attributes.aCustomColumns[i]# desc">selected</cfif>>desc</option>
									</select>
									</th>
									</cfoutput>
								<cfelse>
									<cfoutput><th>&nbsp;</th></cfoutput>
								</cfif>
							</cfif>
						</cfloop>
					</cfif>
			
					<cfloop list="#attributes.columnlist#" index="i">
						<cfoutput><th></cfoutput>					
							<cfif listContainsNoCase(attributes.SortableColumns,i)>
								<cfoutput>
								<select name="#i#sqlOrderBy" onchange="javascript:$('sqlOrderBy').value=this.value;submit();" style="width:80px;">
									<option value=""></option>
									<option value="#i# asc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#i# asc">selected</cfif>>asc</option>
									<option value="#i# desc" <cfif session.objectadminFilterObjects[attributes.typename].sqlOrderBy EQ "#i# desc">selected</cfif>>desc</option>
								</select>
								</cfoutput>
							<cfelse>
								<cfoutput>&nbsp;</cfoutput>
							</cfif>
						<cfoutput></th></cfoutput>
					</cfloop>
				<cfoutput>
				</tr>
				</cfoutput>
			</cfif>
	
			<cfoutput>
			</thead>
			</cfoutput>
		
			
			<ft:paginateLoop r_stObject="st" bIncludeFields="true" bIncludeObjects="false" stpermissions="#stpermissions#" lCustomActions="#attributes.lCustomActions#" bTypeAdmin="true">
				
					<cfoutput>
					<tbody>
					<tr>
					</cfoutput>
					
						<cfif attributes.bSelectCol>
							<cfoutput><td nowrap="true">#st.select# #st.currentRow#</td></cfoutput>
						</cfif>
				 		<cfif listContainsNoCase(stRecordset.q.columnlist,"bHasMultipleVersion")>
					 		<cfoutput><td nowrap="true">#application.rb.getResource("constants.status.#st.status#@label",st.status)#</td></cfoutput>
						</cfif>
						<cfif attributes.bShowActionList>
							<cfoutput><td>#st.action#</td></cfoutput>
						</cfif>
						<!---<cfif attributes.bEditCol><td>#st.editLink#</td></cfif>
						<cfif attributes.bViewCol><td>#st.viewLink#</td></cfif>
						<cfif attributes.bFlowCol><td>#st.flowLink#</td></cfif> --->
						<cfif arrayLen(attributes.aCustomColumns)>
							<cfset oType = createObject("component", PrimaryPackagePath) />
							<cfloop from="1" to="#arrayLen(attributes.aCustomColumns)#" index="i">
								
								<cfif isstruct(attributes.aCustomColumns[i])>
									<cfif structKeyExists(attributes.aCustomColumns[i], "webskin")>
										<cfset HTML = oType.getView(objectid="#st.stFields.objectid.value#", template="#attributes.aCustomColumns[i].webskin#")>
										<cfoutput><td>#HTML#</td></cfoutput>
									<cfelse>
										<cfoutput><td>&nbsp;</td></cfoutput>
									</cfif>
								<cfelse><!--- Normal field --->
									<cfif structKeyExists(st.stFields, attributes.aCustomColumns[i])>
										<cfoutput><td>#st.stFields[attributes.aCustomColumns[i]].HTML#</td>	</cfoutput>			
									<cfelse>
										<cfoutput><td>-- not available --</td>	</cfoutput>			
									</cfif>
								</cfif>
								
							</cfloop>
						</cfif>
						<cfloop list="#attributes.columnlist#" index="i">
							<cfif structKeyExists(st.stFields, i)>
								<cfoutput><td>#st.stFields[i].HTML#</td>	</cfoutput>			
							<cfelse>
								<cfoutput><td>-- not available --</td>	</cfoutput>			
							</cfif>
							
						</cfloop>
					<cfoutput>
					</tr>
					</tbody>
					</cfoutput>
				
				
			</ft:paginateLoop>
		
		<cfoutput></table></cfoutput>
	
	
	
	</ft:pagination> 
	
	
	
	
	</ft:form>

</cfif>




</cfif>

<cfif thistag.executionMode eq "End">

</cfif> 

<!---
<cffunction name="getRecordset" access="public" output="No" returntype="struct">
	<cfargument name="typename" required="No" type="string" default="" />
	<cfargument name="sqlColumns" required="No" type="string" default="objectid" />
	<cfargument name="sqlWhere" required="No" type="string" default="" />
	<cfargument name="sqlOrderBy" required="No" type="string" default="label" />
	
	<cfargument name="CurrentPage" required="No" type="numeric" default="1" />
	<cfargument name="RecordsPerPage" required="No" type="numeric" default="5" />
	<cfargument name="PageLinksShown" required="No" type="numeric" default="10" />
	
	<cfset var stReturn = structNew() />
	<cfset var q = '' />
	<cfset var recordcount = '' />
	
	<cfif NOT len(arguments.sqlWhere)>
		<cfset arguments.sqlWhere = "0=0" />
	</cfif>
	
	<!--- query --->
	<cfstoredproc procedure="sp_selectnextn" datasource="#application.dsn#">
	    <cfprocresult name="q" resultset="1">
	    <cfprocresult name="recordcount" resultset="2">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="TableName"  value="#arguments.typename#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="Columns" value="#arguments.sqlColumns#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="IdentityColumn" value="objectid">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupNumber" value="#arguments.CurrentPage#">
	     <cfprocparam type="In"  cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupSize" value="#arguments.recordsPerPage#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_LONGVARCHAR" dbvarname="SqlWhere" value="#arguments.SqlWhere#">
	     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="SqlOrderBy" value="#arguments.sqlOrderBy#">
	</cfstoredproc>
	
	
	<!------------------------------
	DETERMINE THE TOTAL PAGES
	 ------------------------------>
	<cfif isNumeric(recordcount.countAll) AND recordcount.countAll GT 0>
		<cfset stReturn.TotalPages = ceiling(recordcount.countAll / arguments.RecordsPerPage)>
	<cfelse>
		<cfset stReturn.TotalPages = 0>
	</cfif>
		
	<!------------------------------
	IF THE CURRENT PAGE IS GREATER THAN THE TOTAL PAGES, REDO THE RECORDSET FOR PAGE 1
	 ------------------------------>		
	<cfif arguments.CurrentPage GT stReturn.TotalPages and arguments.CurrentPage GT 1>
		
		<cfset arguments.CurrentPage = 1 />
		
		<!--- query --->
		<cfstoredproc procedure="sp_selectnextn" datasource="#application.dsn#">
		    <cfprocresult name="q" resultset="1">
		    <cfprocresult name="recordcount" resultset="2">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="TableName"  value="#arguments.typename#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="Columns" value="#arguments.sqlColumns#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="IdentityColumn" value="objectid">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupNumber" value="#arguments.CurrentPage#">
		     <cfprocparam type="In"  cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupSize" value="#arguments.recordsPerPage#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_LONGVARCHAR" dbvarname="SqlWhere" value="#arguments.SqlWhere#">
		     <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="SqlOrderBy" value="#arguments.sqlOrderBy#">
		</cfstoredproc>
	</cfif>			
	
	<cfif isNumeric(recordcount.countAll) AND recordcount.countAll GT 0>
		<cfset stReturn.TotalPages = ceiling(recordcount.countAll / arguments.RecordsPerPage)>
	<cfelse>
		<cfset stReturn.TotalPages = 0>
	</cfif>
	
	
	<!--- NOW THAT WE HAVE OUR QUERY, POPULATE THE RETURN STRUCTURE --->
	<cfset stReturn.q = q />
	<cfset stReturn.countAll = recordcount.countAll />
	<cfset stReturn.CurrentPage = arguments.CurrentPage />
	
	
	<cfset stReturn.Startpage = 1>
	<cfset stReturn.PageLinksShown = min(arguments.PageLinksShown, stReturn.TotalPages)>
	
	<cfif stReturn.CurrentPage + int(stReturn.PageLinksShown / 2) - 1 GTE stReturn.TotalPages>
		<cfset stReturn.StartPage = stReturn.TotalPages - stReturn.PageLinksShown + 1>
	<cfelseif stReturn.CurrentPage + 1 GT stReturn.PageLinksShown>
		<cfset stReturn.StartPage = stReturn.CurrentPage - int(stReturn.PageLinksShown / 2)>
	</cfif>
	
	<cfset stReturn.Endpage = stReturn.StartPage + stReturn.PageLinksShown - 1>
		
	<cfset stReturn.RecordsPerPage = arguments.RecordsPerPage />
	<cfset stReturn.typename = arguments.typename />
     
	<cfreturn stReturn />
</cffunction> --->



<cfsetting enablecfoutputonly="no">
