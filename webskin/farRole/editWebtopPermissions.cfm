
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />



<!--- 
ENVIRONMENT VARIABLES
 --->
<cfset form.selectPermission = application.security.factory.permission.getID(name="viewWebtopItem") />

<cfparam name="request.stWebtopPermissions['#form.selectPermission#']" default="#structNew()#" />


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadCSS id="jquery-ui" />




<skin:htmlHead>
<cfoutput>
<style type="text/css">
.inherit {opacity:0.4;}

.ui-button.small.barnacleBox {
	width: 16px;
	height: 16px;
	float:left;
	margin:0px;
}

.ui-button.small.barnacleBox .ui-icon {
	margin-top: -8px;
	margin-left: -8px;
}

.barnacleValue,.inheritBarnacleValue {width:20px;}
</style>
</cfoutput>
</skin:htmlHead>

		
	<!--- WEBTOP PERMISSIONS --->
	<cfset stCurrentPermissionSet = request.stWebtopPermissions['#form.selectPermission#']>
	
	
	
	<cfset stWebtop = application.factory.oWebtop.getItem(honoursecurity="false") />
	<cfset barnacleID = hash(stWebtop.rbKey)>

	<cfquery datasource="#application.dsn#" name="qBarnacles">
	SELECT farBarnacle.referenceID, farBarnacle.barnacleValue, farBarnacle.roleid, farBarnacle.permissionID
	FROM farBarnacle
	WHERE objecttype = <cfqueryparam cfsqltype="cf_sql_varchar" value="webtop">
	AND farBarnacle.roleid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#">
	AND farBarnacle.permissionid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.selectPermission#">
	</cfquery>
	
	<grid:div style="width:100%;float:left;">
	<ft:form>
	
	
		<ft:field label="Webtop Access">
			<cfset accessPermissionID = application.fapi.getContentType("farPermission").getID('admin')>
			<cfif application.fapi.arrayFind(stobj.aPermissions, accessPermissionID)>
				<cfset allowAccess = 1>
			<cfelse>
				<cfset allowAccess = -1>
			</cfif>
			
			<cfif allowAccess EQ 1>
				<cfset priority = "btn-primary">
				<cfset icon = "icon-ok">
			<cfelse>
				<cfset priority = "btn-danger">
				<cfset icon = "icon-remove">
			</cfif>
			
			<cfoutput>
			<button id="bAllowAccess" class="btn btn-small permButton barnacleBox #priority#" value="#allowAccess#" type="button" 
					ftpermissionid="#accessPermissionID#" 
					ftbarnaclevalue="#numberformat(allowAccess)#"><i class=" #icon#"></i></button>
			</cfoutput>
			
			
			<ft:fieldHint>
				<cfoutput>Should this role be allowed to access the webtop?</cfoutput>
			</ft:fieldHint>
		</ft:field>
	
	<cfoutput>
		
	<input type="hidden" name="permissionID" value="#form.selectPermission#" />
	
	<div id="webtopTreeWrap" <cfif allowAccess EQ -1>style="display:none;"</cfif>>


	<ft:field label="Access Permissions" bMultiField="true">
	<ul id="webtopTree" >
	
		<li>
			
			<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
				<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
			<cfelse>
				<cfquery dbtype="query" name="qNodeBarnacle">
				SELECT *
				FROM qBarnacles
				WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
				</cfquery>
				
				<cfif qNodeBarnacle.recordCount>
					<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
				<cfelse>
					<cfset currentBarnacleValue = -1 />
				</cfif>
			</cfif>
			
			
			<!--- We always have webtop permission as checked --->
			<cfset priority = "btn-primary">
			<cfset icon = "icon-ok">
			<cfset class="" />
			
			<ft:button 
				id="webtopRoot"
				value="perm" 
				text="" 
				icon="#icon#" 
				type="button" 
				class="btn btn-small permButton small barnacleBox #class# #priority#"
				onClick="alert('Use the webtop access permission above to turn off access to the webtop.');return false;" />
			
			<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="1">
			<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="1">
		
			<span style="font-size:10px;">
				&nbsp;Webtop
			</span>
			
			
			<cfif listLen(stWebtop.CHILDORDER)>
				<ul>
			</cfif>
			
			<cfloop list="#stWebtop.CHILDORDER#" index="i">
				
				<cfset stLevel1 = stWebtop.children[i] />
				<cfset barnacleID = hash(stLevel1.rbKey)>
				
				<li class="closed">
				
				
		
					<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
						<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
					<cfelse>
						<cfquery dbtype="query" name="qNodeBarnacle">
						SELECT *
						FROM qBarnacles
						WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
						</cfquery>
						
						<cfif qNodeBarnacle.recordCount>
							<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
						<cfelse>
							<cfset currentBarnacleValue = 0 />
						</cfif>
					</cfif>
					
					<cfset priority = "">
					<cfset icon = "icon-remove">
					<cfset class="inherit" />
					<cfif currentBarnacleValue EQ 1>
						<cfset priority = "btn-primary">
						<cfset icon = "icon-ok">
						<cfset class="" />
					<cfelseif currentBarnacleValue EQ -1>
						<cfset priority = "btn-danger">
						<cfset icon = "icon-remove">
						<cfset class="" />
					</cfif>
					
					<ft:button 
						value="perm" 
						text="" 
						icon="#icon#" 
						type="button" 
						class="btn btn-small permButton small barnacleBox #class# #priority#" />
					
					<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
					<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="">
				
					<span style="font-size:10px;">
						&nbsp;#stLevel1.label#
					</span>
					
				
				
				<cfif listLen(stLevel1.CHILDORDER)>
					<ul>
					<cfloop list="#stLevel1.CHILDORDER#" index="j">
					
						<cfset stLevel2 = stLevel1.children[j] />
						<cfset barnacleID = hash(stLevel2.rbKey)>
					
						<li>
							
							

							<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
								<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
							<cfelse>
								<cfquery dbtype="query" name="qNodeBarnacle">
								SELECT *
								FROM qBarnacles
								WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
								</cfquery>
								
								<cfif qNodeBarnacle.recordCount>
									<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
								<cfelse>
									<cfset currentBarnacleValue = 0 />
								</cfif>
							</cfif>
							
							<cfset priority = "">
							<cfset icon = "icon-remove">
							<cfset class="inherit" />
							<cfif currentBarnacleValue EQ 1>
								<cfset priority = "btn-primary">
								<cfset icon = "icon-ok">
								<cfset class="" />
							<cfelseif currentBarnacleValue EQ -1>
								<cfset priority = "btn-danger">
								<cfset icon = "icon-remove">
								<cfset class="" />
							</cfif>
							
							<ft:button 
								value="perm" 
								text="" 
								icon="#icon#" 
								type="button" 
								class="btn btn-small permButton small barnacleBox #class# #priority#" />
							
							<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
							<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="">
						
							<span style="font-size:10px;">
								&nbsp;#stLevel2.label#
							</span>
						
							
							
							<cfif listLen(stLevel2.CHILDORDER)>
								<ul>
								<cfloop list="#stLevel2.CHILDORDER#" index="k">
								
									<cfset stLevel3 = stLevel2.children[k] />
									<cfset barnacleID = hash(stLevel3.rbKey)>
									
									<li>
									
										
							
										<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
											<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
										<cfelse>
											<cfquery dbtype="query" name="qNodeBarnacle">
											SELECT *
											FROM qBarnacles
											WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
											</cfquery>
											
											<cfif qNodeBarnacle.recordCount>
												<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
											<cfelse>
												<cfset currentBarnacleValue = 0 />
											</cfif>
										</cfif>
										
										<cfset priority = "">
										<cfset icon = "icon-remove">
										<cfset class="inherit" />
										<cfif currentBarnacleValue EQ 1>
											<cfset priority = "btn-primary">
											<cfset icon = "icon-ok">
											<cfset class="" />
										<cfelseif currentBarnacleValue EQ -1>
											<cfset priority = "btn-danger">
											<cfset icon = "icon-remove">
											<cfset class="" />
										</cfif>
										
										<ft:button 
											value="perm" 
											text="" 
											icon="#icon#" 
											type="button" 
											class="btn btn-small permButton small barnacleBox #class# #priority#" />
										
										<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
										<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="">
									
										<span style="font-size:10px;">
											&nbsp;#stLevel3.label#
										</span>
										
										
										<cfif listLen(stLevel3.CHILDORDER)>
											<ul>
											<cfloop list="#stLevel3.CHILDORDER#" index="l">
											
												<cfset stLevel4 = stLevel3.children[l] />
												<cfset barnacleID = hash(stLevel4.rbKey)>
												
												
												<li>
													

													<cfif structKeyExists(stCurrentPermissionSet, barnacleID)>
														<cfset currentBarnacleValue = stCurrentPermissionSet[barnacleID] >
													<cfelse>
														<cfquery dbtype="query" name="qNodeBarnacle">
														SELECT *
														FROM qBarnacles
														WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#barnacleID#">
														</cfquery>
														
														<cfif qNodeBarnacle.recordCount>
															<cfset currentBarnacleValue = numberFormat(qNodeBarnacle.barnacleValue) />
														<cfelse>
															<cfset currentBarnacleValue = 0 />
														</cfif>
													</cfif>
													
													<cfset priority = "">
													<cfset icon = "icon-remove">
													<cfset class="inherit" />
													<cfif currentBarnacleValue EQ 1>
														<cfset priority = "btn-primary">
														<cfset icon = "icon-ok">
														<cfset class="" />
													<cfelseif currentBarnacleValue EQ -1>
														<cfset priority = "btn-danger">
														<cfset icon = "icon-remove">
														<cfset class="" />
													</cfif>
													
													<ft:button 
														value="perm" 
														text="" 
														icon="#icon#" 
														type="button" 
														class="btn btn-small permButton small barnacleBox #class# #priority#" />
													
													<input type="hidden" class="barnacleValue" id="barnacleValue-#barnacleID#" name="barnacleValue-#barnacleID#" value="#currentBarnacleValue#">
													<input type="hidden" class="inheritBarnacleValue" id="inheritBarnacleValue-#barnacleID#" value="">
												
													<span style="font-size:10px;">
														&nbsp;#stLevel4.label#
													</span>
														
												</li>
											
											</cfloop>	
											</ul>					
										</cfif>
									
									</li>
									
								
								</cfloop>		
								</ul>	
							</cfif>
						
						</li>
					
					</cfloop>
					</ul>
				</cfif>
				
				</li>
			
			</cfloop>
			
			<cfif listLen(stWebtop.CHILDORDER)>
				</ul>
			</cfif>
			
		</li>
	</ul>
	</ft:field>
	</div>
	</cfoutput>		

	

	<cfoutput>
	<input type="hidden" name="webtopPermissionsSubmitted" value="true">
	</cfoutput>
	
	</ft:form>
	</grid:div>

<skin:onReady>
<cfoutput>
	
	$fc.fixDescendants = function(elParent) {
		
		// loop over all descendants of clicked item and if they are inheriting, adjust inherited value if required
		$j(elParent).closest( 'div,li' ).find( '.permButton' ).each(function (i) {
			
			elDescendant = $j(this);
			var descendantValue = $j(elDescendant).siblings( '.barnacleValue' ).val();
			
			if( $j(elDescendant).attr('id') != $j(elParent).attr('id')) {
				
				$j(this).parents( 'div,li' ).children( '.permButton' ).each(function (i) {
				
					var elDescendantParent = $j(this);
					
					if( $j(elDescendantParent).attr('id') != $j(elDescendant).attr('id')) {
						
						var descendantParentValue = $j(elDescendantParent).siblings( '.barnacleValue' ).val();
						
						
						if (descendantParentValue == 1) {
							$j(elDescendant).siblings( '.inheritBarnacleValue' ).val(1);
							
							if (descendantValue == 0) { //only descendants that inherit
								$j(elDescendant).addClass('btn-primary');
								$j(elDescendant).find('i').removeClass('icon-remove').addClass('icon-ok');
								
							}
							return false;
						};
						if (descendantParentValue == -1) {
							
							$j(elDescendant).siblings( '.inheritBarnacleValue' ).val(-1);
							
							if (descendantValue == 0) { //only descendants that inherit
								$j(elDescendant).removeClass('btn-primary');
								$j(elDescendant).find('i').removeClass('icon-ok').addClass('icon-remove');
								
							}
							return false;
						};
					};
				});
			};
		});				
	};
	
	$j('.permButton').click(function() {
		var el = $j(this);
		var barnacleValue = $j(this).siblings( '.barnacleValue' ).val();
		var inheritBarnacleValue = $j(this).siblings( '.inheritBarnacleValue' ).val();
		
		
		
		switch( $j(this).parents( 'div,li' ).children( '.permButton' ).length ) {
			case 1:
  				<!--- DO NOTHING --->
				break;
			case 2:
				if(barnacleValue == -1) {
					$j(this).siblings( '.barnacleValue' ).val(1);
					$j(this).removeClass('btn-danger').addClass('btn-primary');
					$j(this).find('i').removeClass('icon-remove').addClass('icon-ok');
					$j(this).removeClass('inherit');
				} else {
					$j(this).siblings( '.barnacleValue' ).val(-1);
					$j(this).removeClass('btn-primary').addClass('btn-danger');
					$j(this).find('i').removeClass('icon-ok').addClass('icon-remove');
					$j(this).removeClass('inherit');
				}
				
  				break;
			default:
				if(barnacleValue == 1) {
					if(inheritBarnacleValue == -1) {
						$j(this).siblings( '.barnacleValue' ).val(0);
						$j(this).removeClass('btn-primary');
						$j(this).find('i').removeClass('icon-ok').addClass('icon-remove');
						$j(this).addClass('inherit');
					} else {
						$j(this).siblings( '.barnacleValue' ).val(0);
						$j(this).addClass('btn-primary');
						$j(this).find('i').removeClass('icon-remove').addClass('icon-ok');
						$j(this).addClass('inherit');
					};
				};
				
				if(barnacleValue == -1) {
					if(inheritBarnacleValue == 1) {
						$j(this).siblings( '.barnacleValue' ).val(0);
						$j(this).addClass('btn-primary');
						$j(this).find('i').removeClass('icon-remove').addClass('icon-ok');
						$j(this).addClass('inherit');
					} else {
						$j(this).siblings( '.barnacleValue' ).val(1);
						$j(this).addClass('btn-primary').removeClass('btn-danger');
						$j(this).find('i').removeClass('icon-remove').addClass('icon-ok');
	
						
													
					};
				};
				
				if(barnacleValue == 0) {
					if(inheritBarnacleValue == 1) {
						
						$j(this).siblings( '.barnacleValue' ).val(-1);
						$j(this).removeClass('btn-primary').addClass('btn-danger');
						$j(this).find('i').removeClass('icon-ok').addClass('icon-remove');
					} else {
						$j(this).siblings( '.barnacleValue' ).val(1);
						$j(this).removeClass('btn-danger').addClass('btn-primary');
						$j(this).find('i').removeClass('icon-remove').addClass('icon-ok');
						
					};
					$j(this).removeClass('inherit');
				};
				
			
		}
		
		$fc.fixDescendants(el);
	});
	
		
	$fc.fixDescendants ( $j('##webtopRoot') );
		
	$j("##webtopTree input.barnacleValue[value='1'],##webtopTree input.barnacleValue[value='-1']").each(function (i) {
		$j(this).parents('li').removeClass("closed").addClass("open");
	});
	
	$j("##webtopTree").treeview({
		animated: "fast",
		collapsed: true
	});
	
	
	
	
	<!--- ALLOW WEBTOP ACCESS --->
<!--- 	$j('##bAllowAccess').each(function (i) {
		$j(this).children('i').removeClass().addClass($j(this).attr('fticon'));
   }); --->

	
	$j('##bAllowAccess').click(function() {
		var el = $j(this);
		var permission = $j(this).attr('ftpermissionid');
		var barnacleValue = $j(this).attr('ftbarnaclevalue');
		
		
	
	
		if(barnacleValue == 1) {
			
			$j(this).attr('ftbarnaclevalue', '-1');
			$j(this).removeClass('btn-primary').addClass('btn-danger');
			//$j(this).find('i').removeClass('icon-ok').addClass('icon-remove');
			$j(this).children('i').removeClass().addClass('icon-remove');
			$j(this).removeClass('inherit');
			
			$j('##webtopTreeWrap').hide('fast');
		
		} else {
			
			$j(this).attr('ftbarnaclevalue', '1');
			$j(this).addClass('btn-primary').removeClass('btn-danger');
			//$j(this).find('i').removeClass('icon-remove').addClass('icon-ok');
			$j(this).children('i').removeClass().addClass('icon-ok');
			$j(this).removeClass('inherit');
			
			$j('##webtopTreeWrap').show('fast');
		};
		
		   
	
		$j.ajax({
		   type: "POST",
		   url: '/index.cfm?ajaxmode=1&type=farRole&objectid=#stobj.objectid#&view=editAjaxSaveGenericPermission',
		   dataType: "html",
		   cache: false,
		   context: $j(this),
		   timeout: 15000,
		   data: {
				permissionid: $j(this).attr('ftpermissionid'),
				barnaclevalue: $j(this).attr('ftbarnaclevalue')
			},
		   success: function(msg){
		   		$j(this).find('i').removeClass('icon-caret-right');
		   },
		   error: function(data){	
				alert('change unsuccessful. The page will be refreshed.');
				location=location;
			},
			complete: function(){
				
			}
		 });
			 
			 
		
	});
</cfoutput>
</skin:onReady>


			