<cfprocessingdirective suppresswhitespace="Yes">
<!--- 
listpages_list.cfm
sample inclusion code for listpages.cfc
Author: Lars Gronholt
Date: 29/05/2012

version: 1 - initial creation.
 --->
 	<cfoutput>
	<form name="search" action="#arguments.pageLink#" method="post">
		<h2>Please enter your search criteria</h2>
		 <div class="lp-search-form-div">
		 	<div class="lp-table-fix">
			<table class="search-form-table" border="0" cellspacing="0" cellpadding="0">
				<tr>	
					<th>
						Search: <input type="text" name="searchby" value="#form.searchby#" size="30" >&nbsp; Records/page <input type="text" name="records" value="#form.records#" size="4">
						 &nbsp; <input type="submit" value="Search"> 
					</th>
				
					
						<td> <cfif arguments.addLink neq "" and arguments.addLinkName neq "">
							<a href="#arguments.addLink#"><input type="button" value="#arguments.addLinkName#"></a></cfif>&nbsp;
						</td>
					
				</tr>
			</table>
			</div>
		</div>
	</form>
	</cfoutput>
</cfprocessingdirective>