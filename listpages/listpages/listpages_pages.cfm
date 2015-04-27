<!--- 
listpages_pages.cfm
sample inclusion code for listpages.cfc
Author: Lars Gronholt
Date: 29/05/2012

version: 1 - initial creation.
 --->
<cfoutput>
<cfprocessingdirective  suppresswhitespace="true">
<cfif queries.records.recordcount GT 0>
	<cfparam name="begin" default="1">
	<!--- initialise startpoint for page listing --->
	<cfset currentCluster=ceiling(start / iCluster)>
	<cfset loopstart = ((currentCluster - 1) * iCluster) + 1>
	<!--- vars to check if safe to create links for next and prev clusters --->
	<cfset nextClusterSafe="false">
	<cfset lastClusterSafe="false">
	<!--- check if loopstart + iCluster is less than total records --->
	<cfif (loopstart + iCluster - 1) * form.records lt queries.total>
		<cfset loopend = loopstart + iCluster - 1>
		<cfset nextClusterSafe="true">
	<cfelseif (loopstart + iCluster - 1) * form.records eq queries.total>
		<cfset loopend = loopstart + iCluster - 1>
	<cfelse>
		<cfset loopend = ceiling(queries.total / form.records)>
	</cfif>
	<cfif loopstart gt iCluster>
		<cfset lastClusterSafe="true">
	</cfif>
  <p>Record/s Returned: #queries.total#  (#evaluate(ceiling(queries.total / form.records))# pages)</p>
	<!--- sets records for hyperlinks to other pages of results --->
	<cfset recordGroups = #evaluate(ceiling(queries.total / form.records))#>
	<div class="lp-pagination">
		<cfif lastClusterSafe>
			<a href="#arguments.pageLink#&searchby=#form.searchby#&records=#form.records#&start=#evaluate(loopstart - 1)#&orderby=#url.orderby#&orderDir=#url.orderDir#&search=y"><< last #iClusterVal# pages</a>
		</cfif>
		<cfif url.start gt 1>
			<a href="#arguments.pageLink#&searchby=#form.searchby#&records=#form.records#&start=#evaluate(url.start - 1)#&orderby=#url.orderby#&orderDir=#url.orderDir#&search=y">Previous</a>
		</cfif>
		<cfloop index="i" from="#loopstart#" to="#loopend#">
			<cfif url.start NEQ i>
				<a href="#arguments.pageLink#&searchby=#form.searchby#&records=#form.records#&start=#i#&orderby=#url.orderby#&orderDir=#url.orderDir#&search=y">#i#</a>
			<cfelse>
				<span>#i#</span>
			</cfif>
		</cfloop>
		<cfif #evaluate(url.start * url.records)#  lt queries.total or (#evaluate(url.start * url.records)#  eq total)>
			<a href="#arguments.pageLink#&searchby=#form.searchby#&records=#form.records#&start=#evaluate(url.start + 1)#&orderby=#url.orderby#&orderDir=#url.orderDir#&search=y">Next</a>
		</cfif>
		<cfif nextClusterSafe>
			<a href="#arguments.pageLink#&searchby=#form.searchby#&records=#form.records#&start=#evaluate(loopend + 1)#&orderby=#url.orderby#&orderDir=#url.orderDir#&search=y">next #iClusterVal# pages >></a>
		</cfif>
	</div>
</cfif>
</cfprocessingdirective>
</cfoutput>	