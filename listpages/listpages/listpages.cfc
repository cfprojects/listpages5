<!--- 
listpages.cfc
Author: Lars Gronholt
Date: 29/05/2012

version: 1 - initial creation.
 --->
 <cfcomponent output="true" displayname="Listpages" hint="The Listpages CFC has been built to facilitate easier creation of paginated search lists">
	<cffunction name="listing" access="public" output="true" returntype="any">
	<!--- REQUIRED --->
	<!--- records is the default for how many records to show per page --->
	<cfargument name="records" type="any" default="20">
	<!--- searchName is the name displayed beside the page's search input field --->
	<cfargument name="searchName" type="any" default="Search">
	<!--- primaryName will be the name for the URL.ID value added to urls linking away from individual records in the result list (eg: edit link and delete link) --->
	<cfargument name="primaryName" type="any" default="pID">
	<!--- pagelink is used to set all pagenation links on the page to come back to the listpages.cfc calling page --->
	<cfargument name="pageLink" type="any" default="">
	<!--- iCluster sets maximum grouping of pages links to display at once
	***NOTE called iCluster to avoid any issues with Railo's cluster scope *** --->
	<cfargument name="iCluster" type="any" default="15">
	<!--- datasource - your datasource name in cfadministrator --->
	<cfargument name="dsn" required="Yes" type="any" default="">
	<!--- tablename can be used to specify more than one table comma delimited --->
	<cfargument name="tableName" required="Yes" default="">
	<!--- primaryID this field MUST be filled in and NOT be present in the fieldNames list as this attribute will automatically be included - automatically refered to by the system created URL.<arguments.primaryName> in hyperlinks created by Listpages --->
	<cfargument name="primaryID" required="Yes" default="">
	<!--- selectFields is a comma delimited list of fields for the queries on the page --->
	<cfargument name="selectFields" required="Yes" default="">
	<!--- displayFields is a comma delimited list of fields that must be included in arguments.selectFields (does not need to be all fields that are in arguments.selectFields), place them in the order they will display in output.
	Default HTML version allows for basic format commands to be passed against individual column names:
	When you call the display fields you can (as per this example, now set dollar format, date format, time format, or datetime format - this example shows date time format) - basically, in the list of display fields, if you have a column such as mailout_send that you wish to be formatted differently, add the abreviation to the front of the column name with a pipe (|) to delimit it.

displayFields="mailout_title, dtf|mailout_send,mailout_status, name"

formats are:
datetimeformat = dtf
timeformat = tf
dateformat = df
dollarformat = $--->
	<cfargument name="displayFields" required="Yes">
	<!--- columnNames is a comma delimited list of column titles for the output page, place them in the order they will display in output, must match up with displayFields --->
	<cfargument name="columnNames" required="Yes">
	<!--- whereStatement to be used in queries on the page, can be blank, do not include "where", cannot include coldfusion code--->
	<cfargument name="whereStatement" default="">
	<!--- searchFields comma delimited list of fields used in search. Combined with searchFieldKind, MUST match --->
	<cfargument name="searchFields" default="">
	<!--- searchFieldKind coma delimited list of fields types used in search, combined with searchFields. Allows system to determine if field is date,varchar/char,int, MUST match- format eg: d,v,i, --->
	<cfargument name="searchFieldKind" default="">
	<!--- orderBy standard sql order by code without 'order by', can be blank --->
	<cfargument name="orderBy" default="">
	<!--- orderBy standard sql order by code without 'order by', can be blank --->
	<cfargument name="orderDir" default="asc">
	<!--- groupBy allows setting of group by properties for the 2 queries --->
	<cfargument name="groupBy" default="">
	<!--- variable to set no results found message --->
	<cfargument name="noResultsMsg" default="no records found">
	<!--- optLink1 allows setting of a link to do something relating to that row, will automatically concat arguments.primaryID to the end of the link in url.pID var - will show up in column "Options" --->
	<cfargument name="optLink1" default="">
	<!--- optLink1Name allows setting of a link text for optLink1 --->
	<cfargument name="optLink1Name" default="">
	<!--- optLink2 - as per optLink1--->
	<cfargument name="optLink2" default="">
	<!--- optLink2Name - as per optLinkName1 --->
	<cfargument name="optLink2Name" default="">
	<!--- optLink3 - as per optLink1--->
	<cfargument name="optLink3" default="">
	<!--- optLink3Name - as per optLinkName1 --->
	<cfargument name="optLink3Name" default="">
	<!--- optLink4 - as per optLink1--->
	<cfargument name="optLink4" default="">
	<!--- optLink4Name - as per optLinkName1 --->
	<cfargument name="optLink4Name" default="">
	<!--- deletelink adds a delete link to Options column - triggers CONFIRM javascript onclick --->
	<cfargument name="deleteLink" default="">
	<!--- deleteMsg is the msg displayed when users click the delete button --->
	<cfargument name="deleteMsg" default="Are you sure you want to delete this record?">
	<!--- addLink provides a link to add a new record (specify your own add form url) --->
	<cfargument name="addLink" default="">
	<!--- addLinkName allows setting of a link text for addLink --->
	<cfargument name="addLinkName" default="">
	
	<!--- LAYOUT ARGUMENTS --->
	<!--- searchPanel loads search form --->
	<cfargument name="searchPanel" default="listpages_search.cfm">
	<!--- listPanel loads list output --->
	<cfargument name="listPanel" default="listpages_list.cfm">
	<!--- pagesPanel loads pagination footer output --->
	<cfargument name="pagesPanel" default="listpages_pages.cfm">
	<!--- END LAYOUT ARGUMENTS --->

	<!--- DBsystem this argument is used to identify the set of queries to use for result set and the rowcount responses (an eval("DBkind#arguments.DBsystem#([args...])") is called to establish the set of queries to use). currently listpages.cfc only supports MySQL, but I have written it this way to make it easier for users to plug their own database queries in by addin --->
	<cfargument name="DBsystem" default="MySQL">
	<!--- END OF ARGUMENTS --->

	<!--- variable to set number of columns - sets colspan for rows not associated with queries --->
	<cfset viewColumns= listlen(arguments.columnNames)>

	<!--- variable tells system to add extra column for options --->
	<cfif arguments.deleteLink neq "" or
		arguments.optLink1 neq "" or 
		arguments.optLink2 neq "" or 
		arguments.optLink3 neq "" or
		arguments.optLink4 neq "">
		<cfset optionColumn = "Y">
	<cfelse>
		<cfset optionColumn = "N">
	</cfif>
		
	<!--- check if reinitialisation var passed in URL --->
	<cfif isdefined("url.reinit")>
		<cfset arguments.noResultsMsg = "Please enter your search request into the form above">
	</cfif>
	<cfset url.search="y">	

	<!--- SEARCH VARIABLES --->
	<cfif isdefined("url.search")>
		<cfif isdefined("form.searchby")>
			<cfset url.searchby = "#form.searchby#">
		</cfif>
		<cfif isdefined("form.records")>
			<cfset url.records = "#form.records#">
		</cfif>
	</cfif>
	
	<cfparam name="queries.records.recordcount" default="0">	
	<cfparam name="url.orderby" default="#arguments.orderby#">
	<cfparam name="url.orderDir" default="#arguments.orderDir#">
	<cfif url.orderDir neq "asc" and url.orderDir neq "desc">
	<cfset url.orderDir="#arguments.orderDir#">
	</cfif>
	<cfif not listContains(arguments.searchFields, url.orderby)>
	<cfset url.orderby="#arguments.searchFields#">
	</cfif>
	
	<cfparam name="url.searchby" default="">
	
	<cfparam name="url.records" default="#arguments.records#">
	<cfparam name="url.start" default="1">
	<cfparam name="url.total" default="1">
	<cfparam name="url.current" default="1">
	<cfparam name="form.searchby" default="#url.searchby#">
	<cfparam name="form.records" default="#url.records#">
	<cfif NOT isnumeric(form.records)>
		<cfset form.records=arguments.records>
		<cfset url.records=arguments.records>
	</cfif>
	
	<!--- cluster variables for setting start info for pagination --->
	<cfparam name="iClusterVal" default="#arguments.iCluster#">
	<cfif NOT isdefined("url.iCluster")>
		<cfparam name="iCluster" default="0">
	<cfelse>
		<cfparam name="iCluster" default="#url.iCluster#">
	</cfif>
	<cfset end = url.start + form.records -1>
	
	<!--- subtract 1 from url.page because mysql limit starts with 0 --->
	<cfset realPage=url.start-1>
	<!--- calcualte startpoint for query limitation from page number pased through url.page --->
	<cfset startPoint=realPage*url.records>
	
	<!--- run search --->
	<!--- <cfif isdefined("url.search")> --->
		<!--- run queries --->
		<cfset queries = evaluate("DBkind#arguments.DBsystem#(records=arguments.records,
			dsn=arguments.dsn,
			tableName=arguments.tableName,
			primaryID=arguments.primaryID,
			selectFields=arguments.selectFields,
			whereStatement=arguments.whereStatement,
			searchFields=arguments.searchFields,
			searchFieldKind=arguments.searchFieldKind,
			orderBy=arguments.orderBy,
			orderDir=arguments.orderDir,
			groupBy=arguments.groupBy,
			startPoint=startpoint)")>
		
		<cfinclude template="#arguments.searchPanel#">
		<cfinclude template="#arguments.listPanel#">
		<cfinclude template="#arguments.pagesPanel#">
	</cffunction>
	
	
	<cffunction name="DBkindMySQL" access="private" output="false" returntype="any" hint="MySQL listpages queries">
		<!--- records is the default for how many records to show per page --->
		<cfargument name="records" type="any" default="20">
		<!--- datasource - your datasource name in cfadministrator --->
		<cfargument name="dsn" required="Yes" type="any" default="">
		<!--- tablename can be used to specify more than one table comma delimited --->
		<cfargument name="tableName" required="Yes" default="">
		<!--- primaryID this field MUST be filled in and NOT be present in the fieldNames list as this attribute will automatically be included - automatically refered to by the system created URL.<arguments.primaryName> in hyperlinks created by Listpages --->
		<cfargument name="primaryID" required="Yes" default="">
		<cfargument name="selectFields" required="Yes" default="">
		<cfargument name="whereStatement" default="">
		<cfargument name="searchFields" default="">
		<cfargument name="searchFieldKind" default="">
		<cfargument name="orderBy" default="">
		<cfargument name="orderDir" default="asc">
		<cfargument name="groupBy" default="">
		<cfargument name="startPoint" default="">
	
		<cfquery name="pageQuery" datasource="#arguments.dsn#">
		select #arguments.primaryID#,#replace(arguments.selectFields, "''","'","all")# from #arguments.tableName#
		<cfif arguments.searchFields neq "" or arguments.whereStatement neq "">
		where
			<!--- needs fixing --->
			<cfif arguments.whereStatement neq "">
			#replace(arguments.whereStatement, "''","'","all")# and
			</cfif>
		</cfif>
		<cfif arguments.searchFields neq "">
		<!--- loop through list of chosen fields and check them against the entered search param, includes check for field type --->
		(
		<cfif trim(form.searchby) eq "">
		1=1
		</cfif>
		<cfset sbcount = 1>
		<cfloop list="#form.searchby#" delimiters=" " index="sb">
		<cfset sfcount = 1>
		<cfif sbcount gt 1>
		or
		</cfif>
		<cfset usedsfCount = 1>
		<cfloop list="#arguments.searchFields#" index="s">
			<cfif listgetat(arguments.searchFieldKind, sfcount) eq "i">
				<cfif isnumeric(sb)>
					<cfif usedsfcount gt 1>
						or 
					</cfif>
					#s# like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#sb#%">
					<cfset usedsfcount = usedsfcount +1>
				</cfif>
			<cfelseif listgetat(arguments.searchFieldKind, sfcount) eq "d">
				<cfif isdate(sb)>
					<cfif usedsfcount gt 1>
						or
					</cfif>
					#s# = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#createodbcdate(sb)#">
					<cfset usedsfcount = usedsfcount +1>
				</cfif>
			<cfelse>
			<cfif usedsfcount gt 1>
				or
			</cfif>
				#s# like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#sb#%">
				<cfset usedsfcount = usedsfcount +1>
			</cfif>
		<cfset sfcount = sfcount +1>
		
		</cfloop>
		<cfset sbcount = sbcount +1>
		</cfloop>)
		</cfif>
		<cfif arguments.groupBy neq "">
				group by #arguments.groupBy#
		</cfif>
		order by 
		<cfif url.orderby neq "">
		#url.orderby# #url.orderdir#
		</cfif>
		LIMIT #startPoint#,#url.records#
		</cfquery>
		
		
		<!--- totals query --->
		<cfquery name="countQuery" datasource="#arguments.dsn#">
		select count(distinct(#arguments.primaryId#)) as total
		from #arguments.tableName#
		<cfif arguments.searchFields neq "" or arguments.whereStatement neq "">
		where
			<!--- needs fixing --->
			<cfif arguments.whereStatement neq "">
			#replace(arguments.whereStatement, "''","'","all")# and
			</cfif>
		</cfif>
		<cfif arguments.searchFields neq "">
		<!--- llop through list of chosen fields and check them against the entered search param, includes check for field type --->
		(
		<cfif trim(form.searchby) eq "">
		1=1
		</cfif>
		<cfset sbcount = 1>
		<cfloop list="#form.searchby#" delimiters=" " index="sb">
		<cfset sfcount = 1>
		<cfif sbcount gt 1>
		or
		</cfif>
		<cfset usedsfCount = 1>
		<cfloop list="#arguments.searchFields#" index="s">
			
			<cfif listgetat(arguments.searchFieldKind, sfcount) eq "i">
				<cfif isnumeric(sb)>
					<cfif usedsfcount gt 1>
					or 
					</cfif>
			#s# like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#sb#%">
			<cfset usedsfcount = usedsfcount +1>
				</cfif>
			<cfelseif listgetat(arguments.searchFieldKind, sfcount) eq "d">
				<cfif isdate(sb)>
					<cfif usedsfcount gt 1>
					or
					</cfif>
			#s# = <cfqueryparam cfsqltype="CF_SQL_DATE" value="#createodbcdate(sb)#">
			<cfset usedsfcount = usedsfcount +1>
				</cfif>
			<cfelse>
			<cfif usedsfcount gt 1>
			or
			</cfif>
			#s# like <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="%#sb#%">
			<cfset usedsfcount = usedsfcount +1>
			</cfif>
		<cfset sfcount = sfcount +1>
		</cfloop>
		<cfset sbcount = sbcount +1>
		</cfloop>)
		</cfif>
		</cfquery>

		<cfif countQuery.recordcount neq 0>
			<cfset total=countQuery.total>
		<cfelse>
			<cfset total=0>
		</cfif>
	
		<cfset queryResults.records=pageQuery>
		<cfset queryResults.total=total>
		<cfreturn queryResults>
	</cffunction>
	
	
	<cffunction name="DBkindSQL" access="private" output="false" returntype="any" hint="Microsoft SQL listpages queries">
		<!--- records is the default for how many records to show per page --->
		<cfargument name="records" type="any" default="20">
		<!--- datasource - your datasource name in cfadministrator --->
		<cfargument name="dsn" required="Yes" type="any" default="">
		<!--- tablename can be used to specify more than one table comma delimited --->
		<cfargument name="tableName" required="Yes" default="">
		<!--- primaryID this field MUST be filled in and NOT be present in the fieldNames list as this attribute will automatically be included - automatically refered to by the system created URL.<arguments.primaryName> in hyperlinks created by Listpages --->
		<cfargument name="primaryID" required="Yes" default="">
		<cfargument name="selectFields" required="Yes" default="">
		<cfargument name="whereStatement" default="">
		<cfargument name="searchFields" default="">
		<cfargument name="searchFieldKind" default="">
		<cfargument name="orderBy" default="">
		<cfargument name="orderDir" default="asc">
		<cfargument name="groupBy" default="">
		<cfargument name="startPoint" default="">
		
		
		<!--- up to users to create their own paging queries for this DBE --->
		
	</cffunction>
	
	
	<cffunction name="DBkindOracle" access="private" output="false" returntype="any" hint="Oracle listpages queries">
		<!--- records is the default for how many records to show per page --->
		<cfargument name="records" type="any" default="20">
		<!--- datasource - your datasource name in cfadministrator --->
		<cfargument name="dsn" required="Yes" type="any" default="">
		<!--- tablename can be used to specify more than one table comma delimited --->
		<cfargument name="tableName" required="Yes" default="">
		<!--- primaryID this field MUST be filled in and NOT be present in the fieldNames list as this attribute will automatically be included - automatically refered to by the system created URL.<arguments.primaryName> in hyperlinks created by Listpages --->
		<cfargument name="primaryID" required="Yes" default="">
		<cfargument name="selectFields" required="Yes" default="">
		<cfargument name="whereStatement" default="">
		<cfargument name="searchFields" default="">
		<cfargument name="searchFieldKind" default="">
		<cfargument name="orderBy" default="">
		<cfargument name="orderDir" default="asc">
		<cfargument name="groupBy" default="">
		<cfargument name="startPoint" default="">
		
		
		<!--- up to users to create their own paging queries for this DBE --->
		
	</cffunction>
</cfcomponent>