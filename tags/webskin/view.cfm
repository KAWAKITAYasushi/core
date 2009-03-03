<cfsetting enablecfoutputonly="true">
<cfsilent>
<!--- @@displayname: Embedded View Tag --->
<!--- @@description: 
	This tag will run the view on an object with the same objectid until it is saved to the database.
 --->
<!--- @@author:  Mat Bryant (mat@daemon.com.au) --->
</cfsilent>
<cfif thistag.executionMode eq "Start">

	<cfsilent>
	<cfparam name="attributes.stObject" default="#structNew()#"><!--- use to get an existing object that has already been fetched by the calling page. --->
	<cfparam name="attributes.typename" default=""><!--- typename of the object. --->
	<cfparam name="attributes.objectid" default=""><!--- used to get an existing object --->
	<cfparam name="attributes.key" default=""><!--- use to generate a new object --->
	<cfparam name="attributes.template" default=""><!--- can be used as an alternative to webskin. Best practice is to use webskin. --->
	<cfparam name="attributes.webskin" default=""><!--- the webskin to be called with the object --->
	<cfparam name="attributes.OnExit" default="" />
	<cfparam name="attributes.stProps" default="#structNew()#">
	<cfparam name="attributes.stParam" default="#structNew()#">
	<cfparam name="attributes.r_html" default=""><!--- Empty will render the html inline --->
	<cfparam name="attributes.r_objectid" default=""><!--- Allows the return of the objectid usefull if it is generated by the tag in the case of when passing a key. --->
	<cfparam name="attributes.hashKey" default="" /><!--- Pass in a key to be used to hash the objectBroker webskin cache --->
	<cfparam name="attributes.bAjax" default="0" /><!--- Flag to determine whether to render an ajax call to load the webskin instead of inline. --->
	<cfparam name="attributes.ajaxID" default="" /><!--- The id to give the div that will call the ajaxed webskin --->
	<cfparam name="attributes.ajaxShowloadIndicator" default="false" /><!--- Should the ajax loading indicator be shown --->
	<cfparam name="attributes.ajaxindicatorText" default="loading..." /><!--- What should be text of the loading indicator --->
	<cfparam name="attributes.bIgnoreSecurity" default="false" /><!--- Should the getView() ignore webskin security --->
	
	
	<cfset lAttributes = "stobject,typename,objectid,key,template,webskin,stprops,stparam,r_html,r_objectid,hashKey,alternateHTML,OnExit,dsn,bAjax,ajaxID,ajaxShowloadIndicator,ajaxindicatorText,bIgnoreSecurity" />
	<cfset attrib = "" />
	
	<!--- Setup custom attributes passed into view in stParam structure --->
	<cfloop collection="#attributes#" item="attrib">
		<cfif not listFindNoCase(lAttributes, attrib)>
			<cfset attributes.stParam[attrib] = attributes[attrib] />
		</cfif>
	</cfloop>

	<cfparam name="session.tempObjectStore" default="#structNew()#">
	
	<!--- use template if its passed otherwise webskin. --->
	<cfif len(attributes.template)>
		<cfset attributes.webskin = attributes.template />
	</cfif>
	
	<cfif not len(attributes.typename)>
		<cfif structKeyExists(attributes.stObject, "typename")>
			<cfset attributes.typename = attributes.stobject.typename />
		<cfelseif len(attributes.objectid)>
			<cfset attributes.typename = application.coapi.coapiUtilities.findType(objectid=attributes.objectid) />
		</cfif>
	</cfif>
	
	<cfif not len(attributes.typename)>
		<cfabort showerror="invalid typename passed" />
	</cfif>	
	
	<cfif attributes.typename EQ "farCoapi">
		<cfif structKeyExists(attributes.stObject, "objectid") and len(attributes.stObject.objectid)>
			<cfset attributes.objectid = attributes.stObject.objectid />
		</cfif>
		<!--- If we are calling a view directly on a farCoapi object, we need to change to a typeskin view on the relevent content type. --->
		<cfset stCoapiObject = createObject("component", application.stcoapi["farCoapi"].packagePath).getData(objectid="#attributes.objectid#") />
		<cfset attributes.typename = stCoapiObject.name />
		<cfset attributes.stObject = structNew() />
		<cfset attributes.objectid = ""/>
	</cfif>
	
	<cfif structKeyExists(application.stCoapi, attributes.typename)>
		<!--- Initialise variables --->
		<cfset st = structNew() />
		<cfset o = createObject("component", application.stcoapi["#attributes.typename#"].packagePath) />
	
		<cfif structKeyExists(attributes.stObject, "objectid") and len(attributes.stObject.objectid)>
			<cfset st = attributes.stObject />	
		<cfelseif len(attributes.objectID)>
			<cfset st = o.getData(objectID = attributes.objectid) />	
		<cfelseif len(attributes.key)>
			<cfparam name="session.stTempObjectStoreKeys" default="#structNew()#" />
			<cfparam name="session.stTempObjectStoreKeys[attributes.typename]" default="#structNew()#" />
			
			<cfif structKeyExists(session.stTempObjectStoreKeys[attributes.typename], attributes.key)>
				<cfif structKeyExists(Session.TempObjectStore, session.stTempObjectStoreKeys[attributes.typename][attributes.key])>
					<cfset attributes.objectid = session.stTempObjectStoreKeys[attributes.typename][attributes.key] />
				</cfif>
			</cfif>		
			
			<cfif not len(attributes.objectid)>
				<cfset attributes.objectid = application.fc.utils.createJavaUUID() />
				<cfset session.stTempObjectStoreKeys[attributes.typename][attributes.key] = attributes.objectid>
				<cfset st = o.getData(objectID = attributes.objectid) />
				<cfset stResult = o.setData(stProperties=st, bSessionOnly="true") />
			</cfif>		
		</cfif>
		
			
		<cfif not structIsEmpty(st)>			
			
			<cfset attributes.objectid = st.objectid />
			
			<cfif not structIsEmpty(attributes.stProps)>
				<cfif structKeyExists(attributes.stProps, "objectid") or structKeyExists(attributes.stProps, "typename")>
					<cfthrow type="application" message="You can not override the objectid or typename with attributes.stProps" />
				</cfif>
				<!--- If attributes.stProps has been passed in, then append them to the struct --->
				<cfset StructAppend(attributes.stProps, st, false)>
				
				<cfset stResult = o.setData(stProperties=attributes.stProps, bSessionOnly=true) />
			</cfif>
		</cfif>	
		
		<cfinvoke component="#o#" method="getView" returnvariable="html">
			<cfinvokeargument name="typename" value="#attributes.typename#" />
			<cfinvokeargument name="objectid" value="#attributes.objectid#" />
			<cfinvokeargument name="template" value="#attributes.webskin#" />
			<cfinvokeargument name="onExit" value="#attributes.onExit#" />
			<cfinvokeargument name="stParam" value="#attributes.stParam#" />
			<cfinvokeargument name="hashKey" value="#attributes.hashKey#" />
			<cfinvokeargument name="bAjax" value="#attributes.bAjax#" />
			<cfinvokeargument name="ajaxID" value="#attributes.ajaxID#" />
			<cfinvokeargument name="ajaxShowloadIndicator" value="#attributes.ajaxShowloadIndicator#" />
			<cfinvokeargument name="ajaxIndicatorText" value="#attributes.ajaxIndicatorText#" />
			<cfinvokeargument name="bIgnoreSecurity" value="#attributes.bIgnoreSecurity#" />
			<!--- Developer can pass in alternate HTML to render if the webskin does not exist --->
			<cfif structKeyExists(attributes, "alternateHTML")>
				<cfinvokeargument name="alternateHTML" value="#attributes.alternateHTML#" />
			</cfif>
		</cfinvoke>

	<cfelse>
		<cfif structKeyExists(attributes, "alternateHTML")>
			<cfset html = "#attributes.alternateHTML#" />
		<cfelse>
			<cfabort showerror="Typename is not available: #attributes.typename#" />
		</cfif>	
	</cfif>	
	</cfsilent>
	
	<cfif len(attributes.r_html)>
		<cfset caller[attributes.r_html] = html />
	<cfelse>
		<cfoutput>#html#</cfoutput>	
	</cfif>
	
	<cfif len(attributes.r_objectID)>
		<cfset caller[attributes.r_objectID] = st.objectid />
	</cfif>		
</cfif>

<cfif thistag.executionMode eq "End"><!--- DO NOTHING ---></cfif>

<cfsetting enablecfoutputonly="false">