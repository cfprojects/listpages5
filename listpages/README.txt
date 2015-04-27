<!--- 
listpages.cfc
Author: Lars Gronholt
Date: 29/05/2012

version: 1 - initial creation.




Well I finally got round to converting the horrible old custom tag into a CFC. This new version separates out the HTML from the queries. I have also broken up the HTML portions into 3 separate files:

listpages_search.cfm - which is the search panel
listpages_list.cfm - which is the result display panel
listpages_pages.cfm - which contains the pagination calculation code and links

These pages are supplied to the CFC as arguments, allowing you to create custom pages for use in different searches within your site. This saves having to have multiple versions of the listpages code floating around as per the custom tag variant.

Currently, I do not have access to a modern version of MS SQL Server nor Oracle, so if you would like to use this CFC with either of those, you will need to edit the DBkindSQL or DBkindOracle functions to include the equivalent queries for those languages. I will update this myself if I ever have either DB again.

To use the CFC, see the example.cfm file.

The custom tag is included in this package for those that like a challenge (and legacy applications that may be using it.

--Lars
 --->