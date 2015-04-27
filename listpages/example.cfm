<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Listpages Example</title>
</head>

<body>

<cfset dsn="legalwarfare">


<cfhtmlhead text='<link rel="STYLESHEET" type="text/css" href="listpages/listpages.css">'>
<cfinvoke 
    component="listpages.listpages" 
    method="listing"
	records="20"
	searchName="Search Comments"
	primaryNamet="pID"
	pageLink="example.cfm"
	iCluster="5"
	dsn="#dsn#"
	tableName="comment"
	primaryID="comment_id"
	selectFields="comment_title, author_id, comment_posted, comic_id"
	displayFields="comment_title, author_id, dtf|comment_posted, comic_id"
	searchFields="comment_title, author_id, comment_posted"
	searchFieldKind="v,i,d"	
	columnNames="Comment Title, Author, Posted, Comic"
	whereStatement=""
	orderBy="comment_posted"
	orderDir="desc"
	groupBy=""
	noResultsMsg="no records found"
	optLink1="index.cfm?attributes.fuseaction=editThing"
	optLink1Name="Edit"
	optLink2=""
	optLink2Name=""
	optLink3=""
	optLink3Name=""
	optLink4=""
	optLink4Name=""
	deleteLink="index.cfm?attributes.fuseaction=deleteScript"
	deleteMsg="Are you sure you want to delete this record?"
	addLink="index.cfm?attributes.fuseaction=AddThing"
	addLinkName="Add Comment"
	searchPanel="listpages_search.cfm"
	listPanel="listpages_list.cfm"
	pagesPanel="listpages_pages.cfm">
	
</body>
</html>