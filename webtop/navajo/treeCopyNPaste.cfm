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
$Header: /cvs/farcry/core/webtop/navajo/treeCopyNPaste.cfm,v 1.3 2004/07/15 01:51:08 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:08 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfparam name="url.srcObjectId" >
<cfparam name="url.destObjectId">
<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">

<cffunction name="generateUniqueFilename">
	<cfargument name="filename" required="yes">
	
	<cfscript>
		aFilename = listToArray(arguments.filename,".");
		uniqueFilename = aFileName[1] & right(application.fc.utils.createJavaUUID(),4);
		uniqueFilename = uniqueFilename & "." & afilename[arrayLen(aFilename)];
	</cfscript>
	<cfreturn uniqueFilename>
</cffunction>

<cffunction name="copyFile" returntype="string">
	<cfargument name="filename" required="yes">
	<cfargument name="filepath" required="yes">
	
	<cfset var filenameCopy = generateUniqueFilename(arguments.filename)>
	<cfif fileExists("#arguments.filepath#\#arguments.filename#")>
		<cffile action="copy" source="#arguments.filepath#\#arguments.filename#" destination="#arguments.filepath#\#filenameCopy#" mode="664"> 
	</cfif>
	<cfreturn filenameCopy>
</cffunction>

<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="10" throwontimeout="Yes">
<cfscript>
	
	// get descendants
	q4 =createObject("component","farcry.core.packages.fourq.fourq");
	qGetDescendants = application.factory.oTree.getDescendants(objectid=URL.srcobjectID,bIncludeSelf=1);
	oNav = createObject("component", application.types.dmNavigation.typePath);
	oTree = createObject("component", "#application.packagepath#.farcry.tree");

	//creating a look up struct, so we can reference new objects with there source
	stBranch = structNew();
	for(i=1;i LTE qGetDescendants.recordCount;i=i+1)
	{
		stBranch[qGetDescendants.objectid[i]] = application.fc.utils.createJavaUUID();
	}
	//dump(stBranch);
	stNewBranch = structNew();
	stDesc = QueryToStructureOfStructures(qGetDescendants);
	//holds a struct of all images/files that will need to be duplicated.
	stFileAssets = structNew();
	//dump(stDesc); 
	stAllObjects = structNew();//structure of all new objects to create
	aDesc = arrayNew(1);//array to hold new NTM objects
	// loop over descendants
	if (qGetDescendants.recordcount)
	{
		for(x=1; x LTE qGetDescendants.recordcount; x=x+1)
		{
			a[x] = duplicate(stDesc[qGetDescendants.objectid[x]]);
			if(x EQ 1)
				a[x].parentid = URL.destObjectid;
			else
				a[x].parentid = stBranch[stDesc[qGetDescendants.objectid[x]].parentid];
			a[x].objectid = stBranch[qGetDescendants.objectid[x]];	
			//build dmNavigation objects to create
			stObj = oNav.getData(qGetDescendants.objectid[x]);
			stAllObjects[stBranch[qGetDescendants.objectid[x]]] = duplicate(stObj);				
			stAllObjects[stBranch[qGetDescendants.objectid[x]]].objectid = a[x].objectid;
			st = stAllObjects[stBranch[qGetDescendants.objectid[x]]];
			//dump(st);
			// Make duplicates of child objects
			if (arrayLen(st.aObjectIds))
			{
				// loop over associated objects
				for(y=1; y LTE arrayLen(st.aObjectIds); y=y+1)
				{
					// work out typename
					objType = q4.findType(st.aObjectIds[y]);
					if (len(objType))
					{
						o = createObject("component",application.types[objType].typepath);
						stObj = o.getData(st.aObjectIds[y]);
						//build struct with all file assets to be duped 
						switch(objType)
						{
							case "dmFile" :
							{
								if(len(trim(stObj.filename)))
									stObj.filename = copyFile(filename=stObj.filename,filepath=application.defaultfilepath);
								if(isDate(stObj.documentDate))
									stObj.documentDate=createODBCDateTime(stObj.documentDate);	
								break;
							}
							case "dmImage" :
							{
								if(len(trim(stObj.sourceImage)))
								{
									if(len(stObj.sourceImage))
										stObj.sourceImage = copyFile(filename=stObj.sourceImage,filepath=application.defaultimagepath);
									if(len(stObj.thumbnailImage))	
										stObj.thumbnailImage = copyFile(filename=stObj.thumbnailImage,filepath=application.defaultimagepath);
									if(len(stObj.standardImage))	
										stObj.standardImage = copyFile(filename=stObj.standardImage,filepath=application.defaultimagepath);	
										
								}
								break;
							}
							case "dmFlash" :
							{
								if(len(trim(stObj.flashMovie)))
									stObj.flashMovie = copyFile(filename=stObj.flashMovie,filepath=application.defaultfilepath);
								break;
							}
						}
						stObj.objectid = application.fc.utils.createJavaUUID();
						//update the parent objects reference
						st.aObjectids[y] = stObj.objectid;
						//and add to the collection of objects to be created
						stAllObjects[stObj.objectid] = duplicate(stobj);
						
					}
				}
			}
		}
	//	dump(stNewBranch,'newbranch');
	//	dump(stAllObjects,'allobjects');
	}
	//create nested tree objects
	//dump(a);
	for(i = 1;i LTE arrayLen(a);i = i+1)
	{	
		oTree.setYoungest(objectid=a[i].objectid,typename='dmNavigation',parentid=a[i].parentid,dsn=application.dsn,objectname=a[i].objectname);
	}
	for (key IN stAllObjects)
	{
		o = createObject("component",application.types[stAllObjects[key].typename].typepath);
		structDelete(stAllObjects[key],"datetimelastupdated");
		structDelete(stAllObjects[key],"datetimecreated");
		structDelete(stAllObjects[key],"lastupdatedby");
		structDelete(stAllObjects[key],"createdby");
		o.createData(stProperties=stAllObjects[key]);
	}
	
</cfscript>
</cflock>