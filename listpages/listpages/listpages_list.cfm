<cfprocessingdirective suppresswhitespace="Yes">
<!--- 
listpages_list.cfm
sample inclusion code for listpages.cfc
Author: Lars Gronholt
Date: 29/05/2012

version: 1 - initial creation.
 --->
<cfif isdefined("url.search")>
 <!--- delete confirmation script, loads only if deleteLink is entered --->
<cfif arguments.deleteLink neq "">
	<cfoutput>
		<script language="JavaScript">
		function deletesure(gotoloc)
		{
			if(confirm("#arguments.deleteMsg#"))
			{
				document.location=gotoloc;
			}
		
		}
		</script>
	</cfoutput>
</cfif>
	
	
	
<cfoutput>
<p>
  	Search Results for : [" #form.searchby# "] - Displaying #queries.records.recordCount# record(s) of #queries.total# record(s).
</p>
</cfoutput>
<cfif queries.records.recordCount GT 0>
	<cfoutput>
	<div class="lp-table-fix">
	<table cellpadding="0" cellspacing="0" class="lp-resultset-table">
		<thead>
				<tr>
				<cfset colLoc=1>
				<cfloop list="#arguments.columnNames#" index="c">
				<cfset ord=trim(listGetAt(replace(arguments.displayFields, "''","'","all"), colLoc))>
					<cfif listLen(ord, "|") gt 1>
					<cfset ord=trim(listGetAt(ord,2,"|"))>
					</cfif>
				<cfif ord neq url.orderby or url.orderDir neq "asc">
				<cfset ordDir="asc">
				<cfelse>
				<cfset ordDir="desc">
				</cfif>
				<th><a href="#arguments.pageLink#&searchby=#form.searchby#&records=#form.records#&start=#evaluate(url.start)#&iCluster=#iCluster#&search=y&orderby=#ord#&orderDir=#ordDir#&search=y" class="pageLink">#c#</a></th>
				<cfset colLoc=colLoc+1>
				</cfloop>
				<!--- check if page needs option column --->
				<cfif optionColumn eq "Y">
				<th>Options</th>
				</cfif>
				</tr>
				</thead>
				<tbody>
				<cfloop query="queries.records">
				<!--- output of results follows this TR tag, can be modded if need be to achieve highlighting for various conditions chosen by coder --->
				<tr <cfif currentrow mod 2>class="alternate"</cfif>>
					<cfloop from="1" to="#viewColumns#" index="v">
					<cfset currentVal = #listGetAt(arguments.displayFields, v)#>
					<td>
					<cfif listLen(currentVal, "|") eq 1>
					#evaluate(currentVal)#
					<cfelseif listFirst(currentVal, "|") eq "$" and  isnumeric(trim(evaluate(currentVal))) and find(".", evaluate(currentVal))>
					#dollarformat(evaluate(listGetAt(currentVal, 2, "|")))#
					<cfelseif listFirst(currentVal,"|") eq "hexClr">
					<div style="background:###evaluate(listGetAt(currentVal,2,"|"))#;float:left;margin-right:0.5em;border:1px solid black;width:10px;height:10px;"></div>
					###evaluate(listGetAt(currentVal,2,"|"))#
					<cfelseif isDate(evaluate(listGetAt(currentVal, 2, "|"))) and trim(listFirst(currentVal, "|")) eq "df">
					#dateFormat(evaluate(listGetAt(currentVal, 2, "|")), "dd-mmm-yyyy")#
					<cfelseif isDate(evaluate(listGetAt(currentVal, 2, "|"))) and trim(listFirst(currentVal, "|")) eq "tf">
					#timeFormat(evaluate(listGetAt(currentVal, 2, "|")), "HH:mm")#
					<cfelseif isDate(evaluate(listGetAt(currentVal, 2, "|"))) and trim(listFirst(currentVal, "|")) eq "dtf">
					#dateFormat(evaluate(listGetAt(currentVal, 2, "|")), "dd-mmm-yyyy")# #timeFormat(evaluate(listGetAt(currentVal, 2, "|")), "HH:mm")#
					<cfelseif listLen(currentVal,"|") gt 1>
					#evaluate(listGetAt(currentVal, 2, "|"))#
					<cfelse>
					#evaluate(currentVal)#
					</cfif>
					</td>
					</cfloop>
					<!--- check if page needs option column --->
					<cfif optionColumn eq "Y">
					<td  nowrap><cfif arguments.optLink1 neq "">[<a href="#arguments.optLink1#&#arguments.primaryName#=#evaluate(arguments.primaryID)#"<cfif currentrow mod 2> class="menuFront"</cfif>>#arguments.optLink1Name#</a>]</cfif>
					<cfif arguments.optLink2 neq "">[<a href="#arguments.optLink2#&#arguments.primaryName#=#evaluate(arguments.primaryID)#"<cfif currentrow mod 2> class="menuFront"</cfif>>#arguments.optLink2Name#</a>]</cfif>
					<cfif arguments.optLink3 neq "">[<a href="#arguments.optLink3#&#arguments.primaryName#=#evaluate(arguments.primaryID)#"<cfif currentrow mod 2> class="menuFront"</cfif>>#arguments.optLink3Name#</a>]</cfif>
					<cfif arguments.optLink4 neq "">[<a href="#arguments.optLink4#&#arguments.primaryName#=#evaluate(arguments.primaryID)#"<cfif currentrow mod 2> class="menuFront"</cfif>>#arguments.optLink4Name#</a>]</cfif>
					
					<cfif arguments.deleteLink neq "">[<a href="javascript:deletesure('#arguments.deleteLink#&#arguments.primaryName#=#evaluate(arguments.primaryID)#')"<cfif currentrow mod 2> class="menuFront"</cfif>>Delete</a>]</cfif></td>
					</cfif>
				</tr>
				</cfloop>
				</tbody>
	</table>
	</div>
	</cfoutput>

	<cfelseif #queries.records.recordCount# eq 0>
			<cfif isdefined("url.search")>
				<cfoutput><p>#arguments.noResultsMsg#</p></cfoutput>
			<cfelse>
				<p>Please enter your search criteria in the form above</p>
			</cfif>
	</cfif>

	
<cfelse>
		<p>Please enter your search criteria in the form above</p>
</cfif>
</cfprocessingdirective>