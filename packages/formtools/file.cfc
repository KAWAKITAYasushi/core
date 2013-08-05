<!--- 	
	@@examples:

	<p>Basic</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="1" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" />
	</code>

	<p>Maximum file upload of 1mb</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="1" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftMaxSize="1048576" />
	</code>

	<p>Flash upload</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="2" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftRenderType="flash" />
	</code>

	<p>Secure file upload</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="4" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftSecure="true" />
	</code>

	<p>PDF only (HTML)</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="5" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftAllowedFileExtensions="*.pdf" />
	</code>

	<p>PDF only (jQuery)</p>
	<code>
		<cfproperty 
			name="someFile" type="string" default="" hint="The file to process" 
			ftSeq="6" ftFieldset="General" ftLabel="File" 
			ftType="file" ftDestination="/someDirectory" ftRenderType="jquery" 
			ftFileTypes="*.pdf" />
	</code>

 --->

<cfcomponent name="File" displayname="file" Extends="field" hint="Field component to liase with all File types" bDocument="true"> 

	<!--- edit handler options --->
	<cfproperty name="ftStyle" default="" hint="Custom inline styles" />
	<cfproperty name="ftRenderType" default="html" hint="This formtool offers a number of ways to render the input. (html, flash, jquery)" />
	<cfproperty name="ftAllowedFileExtensions" default="pdf,doc,ppt,xls,docx,pptx,xlsx,jpg,jpeg,png,gif,zip,rar,flv,swf,mpg,mpe,mpeg,m1s,mpa,mp2,m2a,mp2v,m2v,m2s,mov,qt,asf,asx,wmv,wma,wmx,rm,ra,ram,rmvb,mp3,mp4,3gp,ogm,mkv,avi" hint="Used when ftRenderType is set to HTML, extentions allowed to be uploaded." />
	<cfproperty name="ftFacade" default="#chr(35)#application.url.webtop#chr(35)#/facade/fileupload/upload.cfm" hint="location of uploader facade." />
	<cfproperty name="ftFileTypes" default="*.*" hint="Used when ftRenderType is set to flash (default *.*) or jquery (default *.jpg;*.JPG;*.jpeg;*.JPEG;), extentions allowed to be uploaded. " />
	<cfproperty name="ftFileDescription" default="File Types" hint="Used when ftRenderType is set to HTML, text display above upload control." />
	<cfproperty name="ftMaxSize" default="-1" hint="Maximum filesize upload in bytes." />
	<cfproperty name="ftOnComplete" default="" hint="Used when ftRenderType is set to HTML, javascript to execute after file upload." />
					
	<!--- jquery edit handler options --->
	<cfproperty name="ftStartMessage" default="Upload file here." hint="Used when ftRenderType is set to jQuery. Message to display at start of upload." />
	<cfproperty name="ftErrorSizeMessage" default="Maximum filesize is #chr(35)#arguments.stMetadata.ftMaxSize#chr(35)# kb" hint="Used when ftRenderType is set to jQuery. Error to display when max filesize error flagged." />
	<cfproperty name="ftCompleteMessage" default="File upload complete" hint="Used when ftRenderType is set to jQuery. Message to display at end of upload." />
	<cfproperty name="ftAfterUploadJSScript" default="" hint="Used when ftRenderType is set to jQuery. Javascript to execute after upload compeltes. " />

	<!--- validate options --->
	<cfproperty name="ftSecure" default="false" hint="Store files securely outside of public webspace." />
	<cfproperty name="ftDestination" default="" hint="Destination of file store relative of secure/public locations." />

	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >
	<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" >
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.file" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var previewURL = "" />
		<cfset var uploadScript = "" />
		<cfset var swftag = "" />
		<cfset var browseScript = "" />
		<cfset var i = 0 />
		<cfset var facade = "" />
		
		<cfparam name="arguments.stMetadata.ftstyle" default="" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="html" /><!--- html, flash, jquery --->
		<cfparam name="arguments.stMetadata.ftAllowedFileExtensions" default="pdf,doc,ppt,xls,docx,pptx,xlsx,jpg,jpeg,png,gif,zip,rar,flv,swf,mpg,mpe,mpeg,m1s,mpa,mp2,m2a,mp2v,m2v,m2s,mov,qt,asf,asx,wmv,wma,wmx,rm,ra,ram,rmvb,mp3,mp4,3gp,ogm,mkv,avi"><!--- The extentions allowed to be uploaded --->
		
		<skin:loadJS id="jquery" />
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="html">
				
				<cfsavecontent variable="html">
					<grid:div class="multiField">
						<cfoutput>
							<div id="#arguments.fieldname#-wrap">						
								
								<label class="inlineLabel" for="#arguments.fieldname#">
									&nbsp;
									<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
									<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />
									<input type="file" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" fc:fieldname="#arguments.fieldname#" class="fileUpload<cfif arguments.stMetadata.ftValidation eq 'required'> required</cfif>" value="" style="#arguments.stMetadata.ftstyle#" />
									
								</label>						
								
							</div>
						</cfoutput>	
						
						<cfif listLen(arguments.stMetadata.ftAllowedFileExtensions)>
							<skin:onReady>
							<cfoutput>
								$j('###arguments.fieldname#NEW').change(function() {
									var ext = $j(this).val().split('.').pop().toLowerCase();
									var allow = new Array(#ListQualify(arguments.stMetadata.ftAllowedFileExtensions,"'")#);
									if($j.inArray(ext, allow) == -1) {
										$j(this).attr('value', '');
									    alert('Only files with the following extensions are allowed: #arguments.stMetadata.ftAllowedFileExtensions#');
									}
								});
							</cfoutput>
							</skin:onReady>
						</cfif>
						
						<cfif len(arguments.stMetadata.value)>
							<cfoutput>
								<div id="#arguments.fieldname#previewfile">
								
									<a id="#arguments.fieldname#-preview-file" href="#application.url.webroot#/download.cfm?downloadfile=#arguments.stobject.objectid#&typename=#arguments.stobject.typename#&fieldname=#arguments.stmetadata.name#" target="_blank">Preview (#listLast(arguments.stMetadata.value,"/")#)</a> <br />
									<!---#listLast(arguments.stMetadata.value,"/")#--->
									<ft:button type="button" value="Delete" rendertype="link" id="#arguments.fieldname#-delete-btn" onclick="" />
									<ft:button type="button" value="Cancel" rendertype="link" id="#arguments.fieldname#-cancel-delete-btn" onclick="" />
									<ft:button type="button" value="Replace" rendertype="link" id="#arguments.fieldname#-replace-btn" onclick="" />
									<ft:button type="button" value="Cancel" rendertype="link" id="#arguments.fieldname#-cancel-replace-btn" onclick="" />
	
								</div>
							</cfoutput>	
							

							<skin:onReady>
								<cfoutput>
                            	
	                            	$j('###arguments.fieldname#-wrap').css('display','none');		
	                            	$j('###arguments.fieldname#-cancel-delete-btn').css('display','none');	
	                            	$j('###arguments.fieldname#-cancel-replace-btn').css('display','none');	
	                            	
									$j('###arguments.fieldname#NEW').change(function() {
										var id = '#arguments.fieldname#';
										var currentText = $j('##' + id).attr('value');	
										var aCurrentExt = currentText.split(".");	
											
										var newText = $j('##' + id + 'NEW').attr('value');	
										var aNewExt = newText.split(".");	
										
										if (currentText.length > 0 && newText.length > 0) {
											if (aCurrentExt.length > 1 && aNewExt.length > 1){						
												if (aCurrentExt[aCurrentExt.length - 1] != aNewExt[aNewExt.length - 1]){
													$j('##' + id + 'NEW').attr('value', '');
													alert('You must either delete the old file or upload a new one with the same extension (' + aCurrentExt[aCurrentExt.length - 1] + ')');
												}
											}
										}					
									});
									
	                            	$j('###arguments.fieldname#-delete-btn').click(function() {
										$j('###arguments.fieldname#DELETE').attr('value',$j('###arguments.fieldname#').attr('value'));
										$j('###arguments.fieldname#').attr('value','');
										$j('###arguments.fieldname#-wrap').show('fast');								
										$j('###arguments.fieldname#-preview-file').css('display','none');
										$j('###arguments.fieldname#-delete-btn').css('display','none');
										$j('###arguments.fieldname#-replace-btn').css('display','none');
		                            	$j('###arguments.fieldname#-cancel-delete-btn').css('display','inline');
									});		
	                            	$j('###arguments.fieldname#-cancel-delete-btn').click(function() {
										$j('###arguments.fieldname#').attr('value',$j('###arguments.fieldname#DELETE').attr('value'));
										$j('###arguments.fieldname#DELETE').attr('value','');
										$j('###arguments.fieldname#-wrap').hide('fast');							
										$j('###arguments.fieldname#-preview-file').css('display','inline');
										$j('###arguments.fieldname#-delete-btn').css('display','inline');
										$j('###arguments.fieldname#-replace-btn').css('display','inline');
		                            	$j('###arguments.fieldname#-cancel-delete-btn').css('display','none');
									});		
	                            	$j('###arguments.fieldname#-replace-btn').click(function() {
										$j('###arguments.fieldname#-wrap').show('fast');
										$j('###arguments.fieldname#-delete-btn').css('display','none');
										$j('###arguments.fieldname#-replace-btn').css('display','none');
		                            	$j('###arguments.fieldname#-cancel-replace-btn').css('display','inline');
									});		
	                            	$j('###arguments.fieldname#-cancel-replace-btn').click(function() {
										$j('###arguments.fieldname#-wrap').hide('fast');
										$j('###arguments.fieldname#-delete-btn').css('display','inline');
										$j('###arguments.fieldname#-replace-btn').css('display','inline');
		                            	$j('###arguments.fieldname#-cancel-replace-btn').css('display','none');
									});	
                            	</cfoutput>
							</skin:onReady>							
						</cfif>				
					</grid:div>				
				</cfsavecontent>
				
			</cfcase>
			
			<cfcase value="jquery">
				<cfparam name="arguments.stMetadata.ftFacade" default="#application.url.webtop#/facade/jqueryupload/upload.cfm" />
				<cfparam name="arguments.stMetadata.ftFileTypes" default="*.jpg;*.JPG;*.jpeg;*.JPEG;" /><!--- *.abc; *.xyz --->
				<cfparam name="arguments.stMetadata.ftStartMessage" default="Upload file here." />
				<cfparam name="arguments.stMetadata.ftMaxSize" default="-1" />
				<cfparam name="arguments.stMetadata.ftErrorSizeMessage" default="Maximum filesize is #arguments.stMetadata.ftMaxSize# kb" />
				<cfparam name="arguments.stMetadata.ftCompleteMessage" default="File upload complete" />
				<cfparam name="arguments.stMetadata.ftAfterUploadJSScript" default="" />
				
				
				
				<cfset facade = "#arguments.stMetadata.ftFacade#?#session.urltoken#&typename=#arguments.typename#&property=#arguments.stMetadata.name#&fieldname=#arguments.fieldname#&current=#application.fc.lib.esapi.encodeForURL(arguments.stMetadata.value)#&farcryProject=#application.applicationName#">
				
				<skin:loadJS id="jquery" />
				
				<skin:htmlHead><cfoutput>
					<script type="text/javascript" src="#application.url.webtop#/facade/jqueryupload/jquery.flash.js"></script>
					<script type="text/javascript" src="#application.url.webtop#/facade/jqueryupload/jquery.jqUploader.js"></script>
				</cfoutput></skin:htmlHead>
				<cfsavecontent variable="html">
					<cfoutput>
						<table style="border:0 none;">
						<tr>
							<td valign="top" style="border:0 none;">
								<cfif arguments.stMetadata.ftMaxSize gt 0><input name="MAX_FILE_SIZE" value="#arguments.stMetadata.ftMaxSize#" type="hidden" /></cfif>
								<!--- <input type="hidden" name="#arguments.fieldname#NEW" id="#arguments.fieldname#NEW" value="" style="#arguments.stMetadata.ftstyle#" onchange="ftCheckFileName('#arguments.fieldname#');" /> --->
								<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" style="#arguments.stMetadata.ftstyle#" onchange="ftCheckFileName('#arguments.fieldname#');" />
								<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />
								<script type="text/javascript">
									jQ121("###arguments.fieldname#").jqUploader({ 
										src:'#application.url.webtop#/facade/jqueryupload/jqUploader.swf', 
										uploadScript:'http://#cgi.http_host##application.url.webtop#/facade/jqueryupload/upload.cfm?objectid=#arguments.stObject.objectid#&typename=#arguments.typename#&property=#arguments.stMetadata.name#&fieldname=#arguments.fieldname#&current=#arguments.stMetadata.value#&#session.urltoken#', 
										startMessage:'#jsstringformat(arguments.stMetadata.ftStartMessage)#', 
										endMessage:'#jsstringformat(arguments.stMetadata.ftCompleteMessage)#', 
										errorSizeMessage:'#arguments.stMetadata.ftErrorSizeMessage#',
										varName:'#arguments.fieldname#',
										afterFunction:function(containerId,filename,varname){
											$con = jQ121('##'+varname).empty().append("Your file ("+filename+") has been uploaded.");
											$con.append("<input type='hidden' name='"+varname+"' value='#arguments.stMetadata.ftDestination#/"+filename.replace(/[^\w\d\.]/g,'')+"' />");
											jQ121("###arguments.fieldname#previewfile").hide();
											jQ121("###arguments.fieldname#DELETE").val("");
											#arguments.stMetadata.ftAfterUploadJSScript#
										} ,
										allowedExt: "#arguments.stMetadata.ftFileTypes#"
									});
								</script>
							</td>
							
							<cfif len(#arguments.stMetadata.value#)>
								<td valign="top" style="border:0 none;">
									<div id="#arguments.fieldname#previewfile">
										<cfif structKeyExists(arguments.stMetadata, "ftSecure") and arguments.stMetadata.ftSecure>
											<img src="#application.url.farcry#/images/crystal/22x22/actions/lock.png" />
											#listLast(arguments.stMetadata.value, "/")#
										<cfelse>
											<a href="#application.fapi.getFileWebRoot()##arguments.stMetadata.value#" target="preview">#listlast(arguments.stMetadata.value, "/")#</a>
										</cfif>
										
										<ft:button type="button" value="Delete File" confirmText="Are you sure you want to remove this file?" onclick="$j('###arguments.fieldname#DELETE').val($j('###arguments.fieldname#').val());$j('###arguments.fieldname#').val('');$j('###arguments.fieldname#previewfile').hide();" />
										
									</div>
								</td>
							</cfif>	
						</tr>
						</table>
					</cfoutput>
				</cfsavecontent>
			</cfcase>
			
			<cfdefaultcase>
				
				<cfparam name="arguments.stMetadata.ftFacade" default="#application.url.webtop#/facade/fileupload/upload.cfm" />
				<cfparam name="arguments.stMetadata.ftFileTypes" default="*.*" />
				<cfparam name="arguments.stMetadata.ftFileDescription" default="File Types" />
				<cfparam name="arguments.stMetadata.ftMaxSize" default="-1" />
				<cfparam name="arguments.stMetadata.ftOnComplete" default="" />
				
				<skin:loadJS id="jquery" />
				
				<cfset facade = "#arguments.stMetadata.ftFacade#?#session.urltoken#&typename=#arguments.typename#&property=#arguments.stMetadata.name#&fieldname=#arguments.fieldname#&current=#application.fc.lib.esapi.encodeForURL(arguments.stMetadata.value)#&farcryProject=#application.applicationName#">
				
				<cfsavecontent variable="html">
					<cfoutput>
						<input type="hidden" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" />
						<input type="hidden" name="#arguments.fieldname#DELETE" id="#arguments.fieldname#DELETE" value="" />
						<cfif len(arguments.stMetadata.value)>
							<div id="#arguments.fieldname#previewfile">
								<cfif structKeyExists(arguments.stMetadata, "ftSecure") and arguments.stMetadata.ftSecure>
									<img src="#application.url.farcry#/images/crystal/22x22/actions/lock.png" />
									#listLast(arguments.stMetadata.value, "/")#
								<cfelse>
									<a href="#application.fapi.getFileWebRoot()##arguments.stMetadata.value#" target="preview">#listlast(arguments.stMetadata.value, "/")#</a>
								</cfif>
								
								<ft:button type="button" value="Delete File" confirmText="Are you sure you want to remove this file?" onclick="$j('###arguments.fieldname#DELETE').val($j('###arguments.fieldname#').val());$j('###arguments.fieldname#').val('');$j('###arguments.fieldname#previewfile').hide();" />
							</div>
						</cfif>
						<div style="width:420px;height:100px;">
							<cfform name="myform" width="420" format="Flash" timeout="100">
								<ft:flashUpload name="file" actionFile="#facade#" value="#arguments.stMetadata.value#" filetypes="#listchangedelims(arguments.stMetadata.ftFileTypes,';')#" fileDescription="#arguments.stMetadata.ftFileDescription#" maxsize="#arguments.stMetadata.ftMaxSize#" onComplete="getURL('javascript:updateField(\'#arguments.fieldname#\',#arguments.fieldname#.text)');#arguments.stMetadata.ftOnComplete#">
									<ft:flashUploadInput chooseButtonLabel="Browse" uploadButtonLabel="Upload" />
								</ft:flashUpload>
							</cfform>
						</div>
					</cfoutput>
				</cfsavecontent>
			</cfdefaultcase>
		</cfswitch>
	
		<cfreturn html>
	</cffunction>
	
	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
	
		<cfset var html = "" />
	
		<cfsavecontent variable="html">
			<cfoutput><a target="_blank" href="#application.url.webroot#/download.cfm?downloadfile=#arguments.stobject.objectid#&typename=#arguments.typename#&fieldname=#arguments.stmetadata.name#">#listLast(arguments.stMetadata.value,"/")#</a></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type. Includes Value and stSupporting">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var filePath = "" />
		<cfset var stResult = structNew()>	
		<cfset var uploadFileName = "" />
		<cfset var qDuplicates = queryNew("blah") />
		<cfset var cleanFileName = "" />
		<cfset var newFileName = "" />
		<cfset var lFormField = "" />
		<cfset var stObj = application.fapi.getContentObject(objectid=arguments.objectid,typename=arguments.typename) />
		<cfset var filepermission = 0 />
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = stFieldPost.value>
		<cfset stResult.stError = StructNew()>
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		<cfparam name="arguments.stMetadata.ftDestination" default="" />
		<cfparam name="arguments.stMetadata.ftRenderType" default="html" />
		<cfparam name="arguments.stMetadata.ftAllowedFileExtensions" default="pdf,doc,ppt,xls,docx,pptx,xlsx,jpg,jpeg,png,gif,zip,rar,flv,swf,mpg,mpe,mpeg,m1s,mpa,mp2,m2a,mp2v,m2v,m2s,mov,qt,asf,asx,wmv,wma,wmx,rm,ra,ram,rmvb,mp3,mp4,3gp,ogm,mkv,avi"><!--- The extentions allowed to be uploaded --->
		
		<cfif len(arguments.stMetadata.ftDestination) and right(arguments.stMetadata.ftDestination,1) EQ "/">
			<cfset arguments.stMetadata.ftDestination = left(arguments.stMetadata.ftDestination, (len(arguments.stMetadata.ftDestination) - 1)) />
		</cfif>
		
		<sec:CheckPermission objectid="#arguments.objectid#" type="#arguments.typename#" permission="View" roles="Anonymous" result="filepermission" />
		<cfif arguments.stMetadata.ftSecure eq "false" and (not structkeyexists(stObj,"status") or stObj.status eq "approved") and filepermission>
			<cfset filePath = application.path.defaultFilePath />
		<cfelse>
			<cfset filePath = application.path.secureFilePath />
		</cfif>
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfif NOT DirectoryExists("#filePath##arguments.stMetadata.ftDestination#")>
			<cfdirectory action="create" directory="#filePath##arguments.stMetadata.ftDestination#">
		</cfif>	
		
		<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#Delete"]) AND fileExists("#filePath##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#")>
			
			<!--- create media archive directory as required --->
			<cfif NOT DirectoryExists("#application.path.mediaArchive#")>
				<cfdirectory action="create" directory="#application.path.mediaArchive#">
			</cfif>
			
			<!--- create typename/property directory archive as required --->
			<cfif NOT DirectoryExists("#application.path.mediaArchive##arguments.stMetadata.ftDestination#")>
				<cfdirectory action="create" directory="#application.path.mediaArchive##arguments.stMetadata.ftDestination#">
			</cfif>
			
			<!--- generate media archive entry --->
		 	<cffile 
			   action = "move"
			   source = "#filePath##FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete']#"
			   destination = "#application.path.mediaArchive##arguments.stMetadata.ftDestination#/#arguments.objectid#-#DateDiff('s', 'January 1 1970 00:00', now())#-#listLast(FORM['#stMetadata.FormFieldPrefix##stMetadata.Name#Delete'], '/')#">
	
		</cfif>
			
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			<cfcase value="html">
				<cfif len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#New"])>
			
			
					<cfif structKeyExists(form, "#stMetadata.FormFieldPrefix##stMetadata.Name#") AND  len(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#"])>
						<!--- This means there is currently a file associated with this object. We need to override this file --->
						
						<cfset lFormField = replace(FORM["#stMetadata.FormFieldPrefix##stMetadata.Name#"], '\', '/', "all")>			
						<cfset uploadFileName = listLast(lFormField, "/") />
						
						<cffile action="UPLOAD"
							filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
							destination="#filePath##arguments.stMetadata.ftDestination#"		        	
							nameconflict="MakeUnique" mode="664" />
					
						<cfif listFindNoCase(arguments.stMetadata.ftAllowedFileExtensions,cffile.serverFileExt)>
							<cffile action="rename" source="#filePath##arguments.stMetadata.ftDestination#/#cffile.ServerFile#" destination="#uploadFileName#" />
							<cfset newFileName = uploadFileName>
						<cfelse>
							<cffile action="delete" file="#filePath##arguments.stMetadata.ftDestination#/#cffile.ServerFile#" />
						</cfif>
					<cfelse>
						<!--- There is no image currently so we simply upload the image and make it unique  --->
						<cffile action="UPLOAD"
							filefield="#stMetadata.FormFieldPrefix##stMetadata.Name#New" 
							destination="#filePath##arguments.stMetadata.ftDestination#"		        	
							nameconflict="MakeUnique" mode="664">
					
						<cfif listFindNoCase(arguments.stMetadata.ftAllowedFileExtensions,cffile.serverFileExt)>
							<cfset newFileName = cffile.ServerFile>
						<cfelse>
							<cffile action="delete" file="#filePath##arguments.stMetadata.ftDestination#/#cffile.ServerFile#" />
						</cfif>
						
					</cfif>
		
			
					<cfif len(newFileName)>
						<!--- Replace all none alphanumeric characters --->
						<cfset cleanFileName = reReplaceNoCase(newFileName, "[^a-z0-9.\-\_]","", "all") />
						
						<!--- If the filename has changed, rename the file
						Note: doing a quick check to make sure the cleanfilename doesnt exist. If it does, prepend the count+1 to the end.
						 --->
						<cfif cleanFileName NEQ newFileName>
							<cfif fileExists("#filePath##arguments.stMetadata.ftDestination#/#cleanFileName#")>
								<cfdirectory action="list" directory="#filePath##arguments.stMetadata.ftDestination#" filter="#listFirst(cleanFileName, '.')#*" name="qDuplicates" />
								<cfif qDuplicates.RecordCount>
									<cfset cleanFileName = "#listFirst(cleanFileName, '.')##qDuplicates.recordCount+1#.#listLast(cleanFileName,'.')#">
								</cfif>
								 
							</cfif>
							
							<cffile action="rename" source="#filePath##arguments.stMetadata.ftDestination#/#newFileName#" destination="#cleanFileName#" />
						</cfif>			
												
						<!--- </cfif> --->
						<cfset stResult.value = "#arguments.stMetadata.ftDestination#/#cleanFileName#">
					</cfif>
					
				</cfif>
			</cfcase>
		
			<cfdefaultcase><!--- value="flash" --->
				<cfif structkeyexists(session,"#stMetadata.FormFieldPrefix##stMetadata.Name#") and len(session["#stMetadata.FormFieldPrefix##stMetadata.Name#"])>
					<cfset stResult.value = session['#stMetadata.FormFieldPrefix##stMetadata.Name#'] />
					<cfset structdelete(session,"#stMetadata.FormFieldPrefix##stMetadata.Name#") />
				<cfelseif structkeyexists(form,"#stMetadata.FormFieldPrefix##stMetadata.Name#")>
					<cfset stResult.value = form['#stMetadata.FormFieldPrefix##stMetadata.Name#'] />
				</cfif>
			</cfdefaultcase>
		
		</cfswitch>
	
	
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	
	<cffunction name="onDraft" access="public" output="false" returntype="void" hint="Called from setData when an object's status is changed">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="previousStatus" type="string" required="true" hint="The previous status of the object" />
		
		<cfset var filepermission = 0 />
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		
		<!--- Draft content should always be secured --->
		<!--- ftSecure=true will already be secured --->
		<!--- anonymous access=false will already be secured --->
		<sec:CheckPermission objectid="#arguments.stObject.objectid#" type="#arguments.typename#" permission="View" roles="Anonymous" result="filepermission" />
		<cfif len(arguments.stObject[arguments.stMetadata.name]) and arguments.previousStatus eq "approved" and not arguments.stMetadata.ftSecure and filepermission>
			<cfset moveToSecure(argumentCollection=arguments) />
		</cfif>
	</cffunction>
	
	<cffunction name="onApproved" access="public" output="false" returntype="void" hint="Called from setData when an object's status is changed">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="previousStatus" type="string" required="true" hint="The previous status of the object" />
		
		<cfset var filepermission = 0 />
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<!--- Approved content should be moved to public if not secured --->
		<!--- ftSecure=true should not be moved --->
		<!--- anonymous access=false should not be moved --->
		<cfif len(arguments.stObject[arguments.stMetadata.name]) and not isSecured(arguments.stObject,arguments.stMetadata)>
			<cfset moveToPublic(argumentCollection=arguments) />
		</cfif>
	</cffunction>
	
	<cffunction name="onDelete" access="public" output="false" returntype="void" hint="Called from setData when an object is deleted">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stLocation = "" />
		<cfset var filepermission = 0 />
		<cfset var qArchive = "" />
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<cfif not len(arguments.stObject[arguments.stMetadata.name])>
			<cfreturn /><!--- No file attached --->
		</cfif>
		
		<cftry>
			<cfset stLocation = getFileLocation(argumentCollection=arguments) />
			
			<cfcatch>
				<cfset stLocation = structnew() />
			</cfcatch>
		</cftry>
		
		<!--- Delete file --->
		<cfif structKeyExists(stLocation,"fullpath") AND len(stLocation.fullpath)>
			<cftry>
				<cffile action="delete" file="#stLocation.fullpath#" />
				
				<!--- Delete archived files --->
				<cfdirectory action="list" directory="#application.path.mediaArchive##arguments.stMetadata.ftDestination#/" filter="#arguments.stObject.objectid#*" name="qArchive" />
				<cfloop query="qArchive">
					<cffile action="delete" file="#application.path.mediaArchive##arguments.stMetadata.ftDestination#/#qArchive.name#" />
				</cfloop>
				
				<cfcatch><cfdump var="#cfcatch.message#"><cfdump var="#arguments#"><cfdump var="#stLocation#"><cfabort></cfcatch>
			</cftry>
		</cfif>
	</cffunction>
	
	<cffunction name="onSecurityChange" returntype="void" access="public" output="false" hint="Performs any updates necessary for a security change">
		<cfargument name="changetype" type="string" required="true" hint="type | object" />
		<cfargument name="objectid" type="uuid" required="false" hint="Object being changed" />
		<cfargument name="stObject" type="struct" required="false" hint="Object being changed" />
		<cfargument name="typename" type="string" required="false" hint="Type of object being changed" />
		<cfargument name="farRoleID" type="uuid" required="true" hint="The objectid of the role" />
		<cfargument name="farPermissionID" type="uuid" required="true" hint="The objectid of the permission" />
		<cfargument name="oldRight" type="numeric" required="true" hint="The old status" />
		<cfargument name="newRight" type="numeric" required="true" hint="The new status" />
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var access = 0 />
		<cfset var stPermission = "" />
		
		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = getData(objectid=arguments.objectid) />
		</cfif>
		
		<!--- Check for the other permission --->
		<cfset stPermission = application.security.factory.permission.getData(objectid=arguments.farPermissionID) />
		<cfif changetype eq "type">
			<cfset access = arguments.newRight and application.security.checkPermission(object=arguments.stObject.objectid,role=arguments.farRoleID,permission=right(stPermission.shortcut,len(stPermission.shortcut)-len(arguments.stObject.typename))) />
		<cfelse><!--- changetype eq "object" --->
			<cfif arguments.newRight eq -1>
				<cfset access = 0 />
			<cfelse>
				<cfset access = 1 />
			</cfif>
			<cfset access = access and application.security.checkPermission(permission=stPermission.shortcut,type=arguments.stObject.typename,role=arguments.farRoleID) />
		</cfif>
		
		<!--- If it is the anonymous role and the view permission that has changed, move the file --->
		<cfif arguments.farRoleID eq application.security.factory.role.getID("anonymous") 
			and (
				( changetype eq "object" and stPermission.shortcut eq "View" ) or
				( changetype eq "type" and arguments.farPermissionID eq application.security.factory.permission.getTypePermission(arguments.stObject.typename,"View") )
			)>
			<cfif access eq 1>
				<cfset moveToPublic(argumentCollection=arguments) />
			<cfelse>
				<cfset moveToSecure(argumentCollection=arguments) />
			</cfif>
		</cfif>
	</cffunction>
	
	
	<cffunction name="moveToSecure" access="public" output="false" returntype="void" hint="Moves the specified file to the secure location">
		<cfargument name="objectid" type="string" required="false" default="" hint="Object to retrieve" />
		<cfargument name="typename" type="string" required="false" default="" hint="Type of the object to retrieve" />
		<!--- OR --->
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		
		
		<cfset var stLocation = structnew() />
		<cfset var newPath = application.path.secureFilePath />
		
		<!--- Get the object if not passed in --->
		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = application.fapi.getContentObject(objectid=arguments.objectid,typename=arguments.typename) />
		</cfif>
		
		<cfset stLocation = getFileLocation(argumentCollection=arguments,firstLook="public") />
		
		<cfif not structkeyexists(stLocation,"fullpath")>
			<cfreturn />
		</cfif>
		
		<cfif not directoryexists("#newPath##arguments.stMetadata.ftDestination#")>
			<cfdirectory action="create" directory="#newPath##arguments.stMetadata.ftDestination#" mode="777" />
		</cfif>
		
		<cffile action="move" source="#stLocation.fullpath#" destination="#newPath##arguments.stObject[arguments.stMetadata.name]#" />
	</cffunction>
	
	<cffunction name="moveToPublic" access="public" output="false" returntype="void" hint="Moves the specified file to the public location">
		<cfargument name="objectid" type="string" required="false" default="" hint="Object to retrieve" />
		<cfargument name="typename" type="string" required="false" default="" hint="Type of the object to retrieve" />
		<!--- OR --->
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		
		
		<cfset var stLocation = structnew() />
		<cfset var newPath = application.path.defaultFilePath />
		
		<!--- Get the object if not passed in --->
		<cfif not structkeyexists(arguments,"stObject")>
			<cfset arguments.stObject = application.fapi.getContentObject(objectid=arguments.objectid,typename=arguments.typename) />
		</cfif>
		
		<cfset stLocation = getFileLocation(argumentCollection=arguments,firstLook="secure") />
		
		<cfif not structkeyexists(stLocation,"fullpath")>
			<cfreturn />
		</cfif>
		
		<cfif not directoryexists("#newPath##arguments.stMetadata.ftDestination#")>
			<cfdirectory action="create" directory="#newPath##arguments.stMetadata.ftDestination#" mode="777" />
		</cfif>
		
		<cffile action="move" source="#stLocation.fullpath#" destination="#newPath##arguments.stObject[arguments.stMetadata.name]#" />
	</cffunction>
	
	
	<cffunction name="getFileLocation" access="public" output="false" returntype="struct" hint="Returns information used to access the file: type (stream | redirect), path (file system path | absolute URL), filename, mime type">
		<cfargument name="objectid" type="string" required="false" default="" hint="Object to retrieve" />
		<cfargument name="typename" type="string" required="false" default="" hint="Type of the object to retrieve" />
		<!--- OR --->
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		<cfargument name="firstLook" type="string" required="false" hint="Where should we look for the file first. The default is to look based on permissions and status" />
		
		<cfset var stResult = structnew() />
		<cfset var filepermission = 0 />
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<!--- Does the user have access to this object --->
		<sec:CheckPermission objectid="#arguments.stObject.objectid#" type="#arguments.stObject.typename#" permission="View" result="filepermission" />
		<cfif not filepermission>
			<cfset stResult = structnew() />
			<cfset stResult.message = "Permission denied" />
			<cfreturn structnew() />
		</cfif>
		
		<!--- Throw an error if the field is empty --->
		<cfif NOT len(arguments.stObject[arguments.stMetadata.name])>
			<cfset stResult = structnew() />
			<cfset stResult.message = "No file defined" />
			<cfreturn stResult />
		<cfelse>
			<cfset stResult.relativepath = arguments.stObject[arguments.stMetadata.name] />
		</cfif>
		
		<!--- Ensure that the first character of the path in the DB is a  "/" --->
		<cfif left(arguments.stObject[arguments.stMetadata.name],1) NEQ "/">
			<cfset arguments.stObject[arguments.stMetadata.name] = "/#arguments.stObject[arguments.stMetadata.name]#" />
		</cfif>
		<!--- Replace any  "\" with "/" for compatibility with everything --->
		<cfset arguments.stObject[arguments.stMetadata.name] = replace(arguments.stObject[arguments.stMetadata.name],"\","/","all")>
		
		<!--- Determine the ACTUAL filename --->
		<cfset stResult.filename = listLast(arguments.stObject[arguments.stMetadata.name],"/")>
		
		<!--- draft will be secured --->
		<!--- ftSecure=true will always be secured --->
		<!--- anonymous access=false will always be secured --->
		<cfif NOT isSecured(arguments.stObject,arguments.stMetadata)>
			<!--- Objects that are not ALWAYS secured and have been approved should be available under the webroot --->
			
			<!--- check file exists --->
			<cfif structkeyexists(arguments,"firstLook") and arguments.firstLook eq "secure" and fileExists("#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#")>
				<!--- This happens if the file is being moved from secure to public - we expect the file to be in secure --->
				<cfset stResult.location = "secure" />
				<cfset stResult.isCorrectLocation = true />
				<cfset stResult.type = "stream" />
				<cfset stResult.path = "#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#" />
				<cfset stResult.fullpath = "#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#" />
			<cfelseif fileExists("#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#")>
				<cfset stResult.location = "public" />
				<cfset stResult.isCorrectLocation = true />
				<cfset stResult.type = "redirect" />
				<cfset stResult.path = "#application.fapi.getFileWebRoot()##arguments.stObject[arguments.stMetadata.name]#" />
				<cfset stResult.fullpath = "#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#" />
			<cfelseif fileExists("#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#")>
				<cfset stResult.location = "secure" />
				<cfset stResult.isCorrectLocation = false />
				<cfset stResult.locationShouldBe = "public" />
				
				<!--- If the permission gets assigned AFTER the object is sent to approved the file may still be in the secured directory. --->
				<cfset stResult.type = "stream" />
				<cfset stResult.path = "#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#" />
				<cfset stResult.fullpath = "#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#" />
			<cfelse>
				<cfset stResult = structnew() />
				<cfset stResult.message = "File is missing" />
				<cfreturn stResult />
			</cfif>
			
			<!--- determine mime type --->
			<cfset stResult.mimeType=getPageContext().getServletContext().getMimeType("#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#") />
		<cfelse>
			<!--- Everything else must be streamed from a path --->
			<cfset stResult.type = "stream" />
			
			<!--- check file exists --->
			<cfif structkeyexists(arguments,"firstLook") and arguments.firstLook eq "public" and fileexists("#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#")>
				<!--- This happens if the file is being moved from public to secure - we expect the file to be in public --->
				<cfset stResult.location = "public" />
				<cfset stResult.isCorrectLocation = true />
				<cfset stResult.path = "#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#" />
				<cfset stResult.fullpath = stResult.path />
			<cfelseif fileExists("#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#")>
				<cfset stResult.location = "secure" />
				<cfset stResult.isCorrectLocation = true />
				<cfset stResult.path = "#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#" />
				<cfset stResult.fullpath = stResult.path />
			<cfelseif fileexists("#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#")>
				<cfset stResult.location = "public" />
				<cfset stResult.isCorrectLocation = false />
				<cfset stResult.locationShouldBe = "secure" />
				
				<cfset stResult.path = "#application.path.defaultfilepath##arguments.stObject[arguments.stMetadata.name]#" />
				<cfset stResult.fullpath = stResult.path />
			<cfelse>
				<cfset stResult = structnew() />
				<cfset stResult.message = "File is missing" />
				<cfreturn stResult />
			</cfif>
			
			<!--- determine mime type --->
			<cfset stResult.mimeType=getPageContext().getServletContext().getMimeType("#application.path.securefilepath##arguments.stObject[arguments.stMetadata.name]#") />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
	<cffunction name="isSecured" access="private" output="false" returntype="boolean" hint="Encapsulates the security check on the file">
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		
		<cfset var filepermission = false />
		
		
		<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
		
		<sec:CheckPermission objectid="#arguments.stObject.objectid#" type="#arguments.stObject.typename#" permission="View" roles="Anonymous" result="filepermission" />
		<cfparam name="arguments.stMetadata.ftSecure" default="false" />
		<cfif arguments.stMetadata.ftSecure eq "false" and (not structkeyexists(arguments.stObject,"status") or arguments.stObject.status eq "approved") and filepermission>
			<cfreturn false />
		<cfelse>
			<cfreturn true />
		</cfif>
	</cffunction>
	
	<cffunction name="duplicateFile" access="public" output="false" returntype="string" hint="For use with duplicateObject, copies the associated file and returns the new unique filename">
		<cfargument name="stObject" type="struct" required="false" hint="Provides the object" />
		<cfargument name="stMetadata" type="struct" required="false" hint="Property metadata" />
		
		<cfset var stLocation = getFileLocation(argumentCollection=arguments) />
		<cfset var newfilename = "" />
		<cfset var uniquekey = 1 />
		
		<cfif not structkeyexists(stLocation,"fullpath")>
			<cfreturn "" />
		</cfif>
		
		<cfset newfilename = rereplacenocase(arguments.stObject[arguments.stMetadata.name],"((\.[\w\d]+)?)$","#uniquekey#\1") />
		<cfloop condition="fileexists(application.path.defaultfilepath & newfilename) or fileexists(application.path.securefilepathath & newfilename)">
			<cfset uniquekey = uniquekey + 1 />
			<cfset newfilename = rereplacenocase(arguments.stObject[arguments.stMetadata.name],"((\.[\w\d]+)?)$","#uniquekey#\1") />
		</cfloop>
		
		<cfif isSecured(arguments.stObject,arguments.stMetadata)>
			<cffile action="copy" source="#stLocation.fullpath#" destination="#application.path.securefilepath##newfilename#" mode="777" />
		<cfelse>
			<cffile action="copy" source="#stLocation.fullpath#" destination="#application.path.defaultfilepath##newfilename#" mode="777" />
		</cfif>
		
		<cfreturn newfilename />
	</cffunction>
	
</cfcomponent> 
