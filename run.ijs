load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'gl2'
coinsert 'jgl2'
NB. A Items
NB. Ensure that the frame rate stays above 30 fps.
NB. Look for more database caching/indexing opportunities.
NB. Scroll behavior for long subject- and author lists in forum browser.
NB. Can we ensure that forum posts are in order?
NB. Solve the "SQLITE" "SQLITE on Android" TOC search problem.  Recursive "sort"?  End fullpaths with '/'?
NB. Some of the category links in the search results aren't working/specified properly.
NB. Newcomers N and Notices N share a tag.  This creates confusion for the sortKey in the categories table.

NB. B Items
NB. Support parallel download of forum posts.
NB. Animate scroll rather than jumping when the travel is too high.
NB. Saved pages mechanism.  "Save" button next to the url field?
NB. Can we present user-defined categories?
NB. Add a "Search" label.
NB. Crawl the category pages--don't download the site archive.  (It's nearly 10k pages)
NB. Sometimes there's a stray category link at the end of a category's pages.

NB. January/2016 has a huge forum thread on frames.
NB. https://www.jsoftware.com/pipermail/programming/2008-January/009364.html
NB. http://www.jsoftware.com/pipermail/chat/2022-May/009097.html
appDir =: jpath '~temp/jwikiviz'
wikiDir =: appDir , '/code.jsoftware.com/wiki'
codeSearchFile =: appDir , '/codesearch.html'
forumFilesDir =: appDir , '/forums'

NB. ============= Database ===============
dbFile =: jpath '~temp/cache.db'
db =: ''

dbError =: 3 : 0
sqlerror__db ''
)

dbOpenDb =: 3 : 0
db =: sqlopen_psqlite_ dbFile
)
NB. =======================================

NB. ==================== Form =====================
FormMouseXY =: 0 0
VocMouseXY =: 0 0

buildForm =: 3 : 0 
wd 'pc vizform;'
wd 'bin h;'
wd   'bin v;'
wd     'bin h;'
wd       'cc clearSearches button;cn Clear *Searches;'
wd       'cc searchBox edit;'
wd      'bin z'
wd     'cc vocContext isigraph;'
wd   'bin z;'
wd   'bin v;'
wd      'cc urlBox edit;'
wd     'cc browser webview;'
wd   'bin z;'
wd 'bin z;'
)

layoutForm =: 3 : 0
'w h' =. ". wd 'getp wh'
winW =: w - 20
winH =: h - 20
controlHeight =. 30
wd 'set searchBox maxwh ' , (": <. (winW * 0.3) , controlHeight) , ';'
wd 'set clearSearches maxwh ' , (": <. (winW * 0.09) , controlHeight) , ';'
wd 'set urlBox maxwh ' , (": <. (winW * 0.5) , controlHeight) , ';'
wd 'set vocContext maxwh ' , (": (<. winW * 0.5) , winH - controlHeight) , ';'
wd 'set browser maxwh ' , (": (<. winW * 0.5) , winH - controlHeight) , ';'
DisplayListRect =: <. 10 , controlHeight , 175 , winH - 80
DisplayDetailRect =: <. h , controlHeight , ((winW * 0.5) - h =. 190) , winH - 80
NB. wd 'timer 250'
)

vizform_default =: 3 : 0
eventType =. > {: 5 { wdq
if. eventType -: 'close' do. wd 'pclose ;' end.
(> {: 5 { wdq) (1!:2) 2
)

vizform_mmove =: 3 : 0
FormMouseXY =: 0 1 { ". > 1 { 13 { wdq
)

vizform_resize =: 3 : 0
layoutForm ''
)

vizform_close =: 3 : 0
wd 'timer 0'
wd 'pclose'
)

vizform_clearSearches_button =: 3 : 0
clearSearches ''
)

vizform_vocContext_mmove =: 3 : 0
VocMouseXY =: 0 1 { ". > 1 { 13 { wdq
queueLoadPage DefaultUrl
invalidateDisplay ''
)

vizform_vocContext_paint =: 3 : 0
trigger_paint ''
)

vizform_vocContext_mwheel =: 3 : 0
sysdata =. ". > 1 { 13 { wdq
direction =. * 11 { sysdata
smoutput 'mwheel' ; direction
NB. previewBrowserMouseWheel direction
)

vizform_vocContext_mblup =: 3 : 0
DefaultUrl =: LastUrlLoaded
smoutput DefaultUrl
wd 'set urlBox text "' , DefaultUrl , '"'
)

vizform_vocContext_mbldbl =: 3 : 0
if. IFUNIX do. (2!:1) 'open -a Safari "' , LastUrlLoaded , '"' end.
)

vizform_searchBox_button =: 3 : 0
NB. wd 'set categoryList select 0'
search searchBox
wd 'set searchBox text ""'
)

sys_timer_z_ =: 3 : 0
NB. wd 'set vocContext invalid'
)

wd 'timer 0'

trigger_paint =: 3 : 0
try.
'w h' =. ". wd 'get vocContext wh'
if. (w > 300) *. h > 300 do.
	scheduleBackgroundRender ''
	clearLoadPageQueue ''
	queueLoadPage DefaultPage
 	glfill 255 255 255 255
	drawVoc ''
 	drawToc ''
	drawFrameRate ''
	backgroundRenderComplete ''
NB.	manageMouseMove VocMouseXY
	loadQueuedPage ''
end.
glclip 0 0 10000 10000
NB. wd 'msgs' NB. Message pump.  This really screws things up when it's uncommented.
catch.
smoutput (13!:12) ''
end.
)

invalidateDisplay =: 3 : 0
wd 'set vocContext invalid'
wd 'msgs'
)
NB. ======================================================

NB. =================== Search ===========================
clearSearches =: 3 : 0
sqlcmd__db 'delete from categories where fullpath like "/*Search/%"'
sqlcmd__db 'delete from wiki where fullpath like "/*Search/%"'
resetTocOutlineRailEntries ''
invalidateDisplay ''
)

addSearchToToc =: 3 : 0
NB. y A search string
NB. sqlcmd__db 'begin transaction'
term =. y
cols =. ;: 'level parent child fullpath count link'
sqlupsert__db 'categories' ; 'fullpath' ; cols ; < 1 ; '*Search' ; y ; ('/*Search/' , term) ; 0 ; ''
sqlupsert__db 'categories' ; 'fullpath' ; cols ; < 2 ; y ; 'Wiki' ; ('/*Search/' , term , '/Wiki') ; _1 ; 'Special:JwikiSearch'
sqlupsert__db 'categories' ; 'fullpath' ; cols ; < 2 ; y ; 'Forums' ; ('/*Search/' , term , '/Forums') ; _1 ; 'https://www.jsoftware.com/forumsearch.htm'
resetTocOutlineRailEntries ''
invalidateDisplay ''
return.
)

updateSearchTotals =: 3 : 0
NB. y A search term
NB. Determine the total number of hits for y (across the wiki and the forums) and update the corresponding Categories row.
cols =. ;: 'level parent child fullpath count link'
count =.  sqlreadm__db 'select count (*) from wiki where fullpath like "/*Search/' , y , '/%"'
sqlupsert__db 'categories' ; 'fullpath' ; cols ; < 1 ; '*Search' ; y ; ('/*Search/' , y) ; count ; ''
)

searchWiki =: 3 : 0
NB. y Search term
NB. Perform the search, parse the results, and update the "categories" and "wiki" table.
html =. (2!:0) 'curl "https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=70&offset=0&profile=default&search=' , (urlencode y) , '"'
pat =. rxcomp 'mw-search-result-heading''><a href="([^"]+)" title="([^"]+)"'
offsetLengths =.  pat rxmatches html
categoriesCols =. ;: 'level parent child fullpath count link'
if. 0 = # offsetLengths do.
	sqlupsert__db 'categories' ; 'fullpath' ; categoriesCols ; < 2 ; y ; 'Wiki' ; ('/*Search/' , y , '/Wiki') ; 0 ; ''
else.
	ol =. 1 2 {"2 offsetLengths
	linkOffsets =. 0 {"(1) 0 {"2 ol
	titleOffsets =. 0 {"(1) 1 {"2 ol
	linkLengths =. 1 {"(1) 0 {"2 ol
	titleLengths =. 1 {"(1) 1 {"2 ol
	links =. 'https://code.jsoftware.com'&, &. > linkLengths <@{."0 1 linkOffsets }."0 1 html
	titles =. titleLengths <@{."0 1 titleOffsets }."0 1 html
	wikiCols =. ;: 'level title category fullpath link'
	data =. (2 #~ # titles) ; titles ; ((# titles) # < y) ; ((< fullpath =. '/*Search/' , y , '/Wiki') #~ # titles) ; < links
	sqlcmd__db 'delete from wiki where fullpath = "' , fullpath , '"'
	sqlinsert__db 'wiki';wikiCols;<data
	sqlupsert__db 'categories' ; 'fullpath' ; categoriesCols ; < 2 ; y ; 'Wiki' ; ('/*Search/' , y , '/Wiki') ; (# titles) ; 'Special:JwikiSearch'
end.
resetTocOutlineRailEntries ''
invalidateDisplay ''
)

searchForums =: 3 : 0
NB. y Search term
NB. Perform the search, parse the results, and update the "categories" and "wiki" table.
categoriesCols =. ;: 'level parent child fullpath count link'
wikiCols =. ;: 'level title category fullpath link'
html =. (2!:0) 'curl "https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2030"'
pat =. rxcomp '(http://www.jsoftware.com/pipermail[^"]+)">\[([^\]]+)\] ([^<]+)</a>'
offsetLengths =.  pat rxmatches html
if. 0 = # offsetLengths do.
	sqlupsert__db 'categories' ; 'fullpath' ; categoriesCols ; < 2 ; y ; 'Forum' ; ('/*Search/' , y , '/Forums') ; 0 ; ''
else.
	ol =. 1 2 3 {"2 offsetLengths
	linkOffsets =. 0 {"(1) 0 {"2 ol
	forumOffsets =. 0 {"(1) 1 {"2 ol
	titleOffsets =. 0 {"(1) 2 {"2 ol
	linkLengths =. 1 {"(1) 0 {"2 ol
	forumLengths =. 1 {"(1) 1 {"2 ol
	titleLengths =. 1 {"(1) 2 {"2 ol
	links =. linkLengths <@{."0 1 linkOffsets }."0 1 html
	links =. ('http://' ; 'https://')&rxrplc &. > links
	forums =. forumLengths <@{."0 1 forumOffsets }."0 1 html
	titles =. titleLengths <@{."0 1 titleOffsets }."0 1 html
	titleGroups =. forums </. titles
	linkGroups =. forums </. links
	fullpath =. '/*Search/' , y , '/Forums'
	sqlcmd__db 'delete from wiki where fullpath = "' , fullpath , '"'
	sqlupsert__db 'categories' ; 'fullpath' ; categoriesCols ; < 2 ; y ; 'Forums' ; ('/*Search/' , y , '/Forums') ; (# titles) ; ''
	for_index. i. # titleGroups do.
		fname =. > index { ~. forums
		forumLinks =. > index { linkGroups
		forumTitles =. > index { titleGroups
		data =. (3 #~ # forumTitles) ; forumTitles ; ((# forumTitles) # < fname) ; ((<'/*Search/' , y , '/Forums/' , fname) #~ # forumTitles) ; < forumLinks
		sqlinsert__db 'wiki';wikiCols;<data
		sqlupsert__db 'categories' ; 'fullpath' ; categoriesCols ; < 3 ; y ; 'Forums' ; ('/*Search/' , y , '/Forums/' , fname) ; (# forumLinks) ; 'https://www.jsoftware.com/forumsearch.htm'
	end.
end.
resetTocOutlineRailEntries ''
invalidateDisplay ''
)

search =: 3 : 0
NB. y A search string.
NB. https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=500&offset=0&profile=default&search=complex
NB. Do a web search and set the highlights to the results.
NB. curl  "https://app.zenserp.com/api/v2/search?apikey=a9f7c2d0-bc41-11ed-9f40-21b580af7851&q=Pied%20Piper&num=50" 
NB. curl  "https://app.zenserp.com/api/v2/search?apikey=a9f7c2d0-bc41-11ed-9f40-21b580af7851&q=site%3Acode.jsoftware.com%20OR%20www.jsoftware.com%20socket&num=100" 
addSearchToToc y
searchWiki y
searchForums y
updateSearchTotals ''
return.
SearchResultsTable =: ''
query =. urlencode y
smoutput 'Searching for ' , query
logFile =: appDir , '/curl.log'
NB. (2!:0) 'curl -o "' , SearchResultsFilename , '" --stderr "' , logFile , '" https://code.jsoftware.com/mediawiki/index.php?title=Special%3AJwikiSearch&blk=50&pos=0&for=complex'
NB. (2!:1) 'open -a Safari "file:/' , SearchResultsFilename , '"'
k =: (2!:0) 'curl "https://code.jsoftware.com/mediawiki/index.php?title=Special%3AJwikiSearch&blk=50&pos=0&for=complex"'
	NB. if. IFUNIX do.
NB. (2!:1) 'curl -o ' , SearchResultsFilename , ' "https://app.zenserp.com/api/v2/search?apikey=a9f7c2d0-bc41-11ed-9f40-21b580af7851&q=site%3Acode.jsoftware.com%20' , query , '&num=100"'
NB.	(2!:0) 'curl -H "blk:500" -H "pos:0" -o ' , SearchResultsFilename , ' --stderr ' , logFile , ' https://code.jsoftware.com/mediawiki/index.php?title=Special%3AJwikiSearch&blk=500&pos=0&for=' , query
NB. request =: 'https://app.zenserp.com/api/v2/search?apikey=a9f7c2d0-bc41-11ed-9f40-21b580af7851&q=site%3Acode.jsoftware.com%20OR%20www.jsoftware.com%20' , query
NB. (2!:0) 'curl --stderr ' , logFile , ' -o ' , SearchResultsFilename , ' -H "num:100" ' , request
NB. end.
NB. s =. (' -H apikey:' , 'a9f7c2d0-bc41-11ed-9f40-21b580af7851') gethttp 'https://app.zenserp.com/api/v2/search?q=' , query
NB. request =. 'https://app.zenserp.com/api/v2/search?apikey=a9f7c2d0-bc41-11ed-9f40-21b580af7851&q=site%3Acode.jsoftware.com%20OR%20www.jsoftware.com%20' , query , '&num=100'
NB. request =. 'https://app.zenserp.com/api/v2/search?q=site%3Acode.jsoftware.com%20' , query , '&num=100&start=0'
NB. ('-o ' , SearchResultsFilename , ' --stderr /Users/edgottsman/Documents/gethttp.log -H "num:100" -H "apikey:' , 'a9f7c2d0-bc41-11ed-9f40-21b580af7851"') gethttp request
)
NB. curl  "https://app.zenserp.com/api/v2/search?apikey=a9f7c2d0-bc41-11ed-9f40-21b580af7851&q=Pied%20Piper&num=100" 
NB. curl  "https://app.zenserp.com/api/v2/search?apikey=a9f7c2d0-bc41-11ed-9f40-21b580af7851&q=Pied%20Piper&num=100&start=0" 
NB. --stderr ',jpath '~temp/gethttp.log
NB. zenserpKey =: 0 : 0
NB. a9f7c2d0-bc41-11ed-9f40-21b580af7851


NB. ======================================================

NB. ================== Categories ========================
categoryTest =: 3 : 0
NB. y A full url, including https://...
NB. Return 1 if this url is in the current category (which includes search results)
if. 0 = # y do. 0 return. end.
urls =. {:"1 HighlightUrls
r1 =. (# urls) > urls i. <y
r2 =. (# urls) > urls i. < (y i. '#') {. y  NB. Drop any # anchors.
r1 +. r2
)

categoryGlyphTest =: 3 : 0
NB. y a Glyph
NB. Return 1 if any of the glyph's valence links is in the current category.
entries =. VocTable #~ (< y) -:"(0 0) 3 {"1 VocTable NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
links =. 7 {"1 entries
+./ > categoryTest &. > links
)
NB. ======================================================


NB. ============================ Bob's Categories ================================
buildBobToc =: 3 : 0
NB. Build a BobToc: Full Path ; Document Name ; Link
NB. dbOpenDb ''
return.
catTree =. getBobsCategoryTree ''
table =. ,: a: , a: , a:
try.
	pat =. rxcomp 'href="/wiki/Category:([^"]+)"'
	links =. , > {: sqlreadm__db 'select url from page_cache'
	for_link. links do.
		html =. , > > {: sqlreadm__db 'select html from page_cache where url = "' , (, > link) , '"'
		matches =. pat rxmatches html
		if. 0 = # matches do. continue. end.
		offsetLengths =. 1 {"2 matches
		offsets =. 0 {"1 offsetLengths
		lengths =. 1 {"1 offsetLengths
		rawCategories =. lengths <@{."0 1 offsets }."0 1 html
		categories =. (i:&' ' {. ]) &. > ('_' ; ' ')&rxrplc &. >  rawCategories
		indexes =. (# catTree) -.~ (1 {"1 catTree) i."_ 0 categories
		paths =. ,. 2 {"1 indexes { catTree
		titleIndex =. (2 {"1 Toc) i. < (i.&'#' {. ]) > link
		if. titleIndex = # Toc do. title =. < '????' else. title =. 1 { , titleIndex { Toc end.
		table =. table , paths ,"1 1 title , link
	end.
catch.
	smoutput 'Thrown error' ; (13!:12) ''
	smoutput 'Db Error' ; dbError ''	
end.
/:~ }. table
)

loadLinksTable =: 3 : 0
try.
	dbOpenDb''
	links =. > {: sqlreadm__db 'select url from page_cache'
	loadCategories &. > links
catch.
	smoutput (13!:12) ''
	smoutput dbError ''
end.
)

getBobsCategoryTree =: 3 : 0
NB. 
pat =. 'Category:([^\]]+)'
lines =. <;._2 BobsCategoryStrings
table =. ,: 0 ; 'N' ; ''
for_line. lines do.
	l =. > line
	level =. +/ '*' = l
	offsetLength =. pat rxmatch l
	offset =. 0 { 1 { offsetLength
	length =. 1 { 1 { offsetLength
	rawNodeName =. length {. offset }. l
	nodeName =. (i:&' ' {. ]) rawNodeName
	parentPath =. > 2 { table {~ (> {."1 table) i: level - 1
	fullyQualifiedPath =. parentPath , '/' , nodeName
	table =. table , level ; nodeName ; fullyQualifiedPath
end.
(0 1 {"1 table) ,. '*'&, &. > }. &. > 2 {"1 table
)

BobsCategories =: '' NB. Table of Level ; Node Name N ; Fully-Qualified Path

NB. ==============================================================================
foo =: 3 : 0
UrlsToAvoid =: ''
cacheLinks =: 3 : 0
dbOpenDb ''
cols =. ;: 'url html'
allUrls =. (7 {"1 VocTable) , 2 {"1 getToc ''
currentCache =. > {: sqlreadm__db 'select url from page_cache'
urls =. allUrls -. currentCache
urls =. urls -. UrlsToAvoid
smoutput 'Skipping ' ; (# currentCache) ; 'Loading' ; # urls
try.
for_url. urls do.
	openUrl =. > url
	html =. gethttp openUrl
	sqlinsert__db 'page_cache';cols;<openUrl;html
end.
catch.
	smoutput (13!:12) ''
	smoutput 'Failed with ' , openUrl
	UrlsToAvoid =: UrlsToAvoid , <openUrl
	smoutput dbError ''
	cacheLinks ''
end.
)

normalizeUrl =: 3 : 0
NB. y A url
NB. If necessary, add the https://... prefix.
if. -. 'http' -: 4 {. y do.
	'https://code.jsoftware.com' , y
else.
	y
end.
)

CachedTocChildren =: ''
CachedTocPartialPath =: ''

getTocChildren =: 3 : 0
NB. y A partial path (unboxed)
NB. Return all of the toc entries that match the partial path.
NB. Level ; Title ; Category ; Full Path ; Link 
if. -. y -: CachedTocPartialPath do.
	CachedTocChildren =: > 1 { sqlreadm__db 'select level, title, category, fullpath, link from wiki where fullpath like "' , y , '%" order by fullpath asc'
end.
CachedTocChildren
)

getLinkForCategory =: 3 : 0
NB. y The name of a category from the "categories" table
NB. Return the corresponding link.
, > > 1 { sqlreadm__db 'select link from categories where child ="' , y , '"'
)

NB. ================== Drawing ====================
MaxCellWidth =: 100
MinColWidth =: 200
CellMargin =: 5
CellLineHeight =: 25
DocumentLineHeight =: 26
DocumentFont =: 'arial bold 18'
DocumentColumnFont =: 'arial 18'
SectionFont =: 'arial bold 16'
SectionColor =: 0 180 0
CurrentVocGeometry =: '' NB. Table of glyph x y width height.
NewVocGeometry =: ,: '' ; _1 ; 0 ; 0 ; 0
VocSelectedGlyph =: ''
DocumentSelectedIsletIndex =: _1
DocumentSectionGeometry =: '' NB. index x y width height label sectionName columnId url
DocumentSectionSelectedIndex =: _1
VocTable =: '' NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
VocSelectionGeometry =: 0 ; 0 ; 0 ; 0 ; ''  NB. Table of x y w h link
POSColors =: 221 204 255 , 204 238 255 , 238 255 204 , 255 204 238 , 221 221 221 ,: 238 170 170
POSNames =: ;: 'Verb Adverb Conjunction Noun Copula Control'
VocCellFont =: 'consolas 16 bold'
CategoryIndex =: 0
CategoryTable =: ''
HighlightTocColor =: 255 63 63
HighlightColor =: 192 64 64
SelectionColor =: 0 0 192
HighlightUrls =: '' NB. Holds the labels ; URLs to be used for highlighting the map. 
DefaultUrl =: '' NB. 'https://www.jsoftware.com' NB. The URL to load when no link is being hovered over. 
LastUrlLoaded =: ''
Toc =: '' NB. path ; doc name ; document link
TocOutline =: '' NB. level ; path component ; full path
TocFont =: 'arial 16'
TocBoldFont =: 'arial bold 16'
TocItalicFont =: 'arial italic 16'
TocBoldItalicFont =: 'arial bold italic 16'
TocLineHeight =: 21
TocSelectedTopCategory =: '*NuVoc'
TocScrollIndex =: 0
ScrollColor =: 230 230 230
DisplayMode =: 'V' NB. Values are (V)oc, (C)ategories, (T)ree, (S)aved
DisplayListRect =: 10 10 100 100
DisplayDetailRect =: 100 10 100 100
UseHtmlCache =: 0
SearchString =: ''
SearchResultsTable =: '' NB. Path ; doc name ; document link
Months =: ;:'January February March April May June July August September October November December'

getPosColor =: 3 : 0
NB. y The boxed name of a pos
NB. Return the corresponding color.
POSColors {~ POSNames i. y
)

setDisplayMode =: 3 : 0
if. -. DisplayMode -: y do.
	DisplayMode =: y
	invalidateDisplay ''
end.
)

drawStringAt =: 4 : 0
NB. x originX originY
NB. y A string
gltextxy x
gltext y
)

drawHighlight =: 4 : 0 
NB. x xx yy w h
NB. y color (r g b) but no (a)
NB. glrgb y
color =. y , 255 NB. <. 255 * | 1 o. 2 * {: (6!:0) ''
glrgba color
glpen 2
glrgba 0 0 0 0
glbrush ''
glrect x
)

pointInRect =: 4 : 0
NB. x A point
NB. y A rect (x y w h)
'px py' =. x
'rx ry rw rh' =. y
(rx <: px) *. (px <: rx + rw) *. (py >: ry) *. (py <: ry + rh)
)

getDocumentSectionGeometryForMouseXY =: 3 : 0
, DocumentSectionGeometry #~ VocMouseXY pointInRect"1 1 (1 2 3 4) {"1 DocumentSectionGeometry
)

checkDefaultUrl =: 3 : 0
if. LastUrlLoaded -: '' do. loadPage DefaultUrl end. 
)

queueLoadPage =: 3 : 0
QueuedLoadUrl =: y
)
 
clearLoadPageQueue =: 3 : 0
QueuedLoadUrl =: ''
)
NB. https://code.jsoftware.com/wiki/User:Andrew_Nikitin
loadQueuedPage =: 3 : 0
NB. loadPage QueuedLoadUrl
if. -. QueuedLoadUrl -: '' do. loadPage QueuedLoadUrl else. loadPage DefaultUrl end.
)

loadPage =: 3 : 0
NB. y A url
url =. y
if. url -: '' do. url =. DefaultUrl end.
url =. ('User_' ; 'User:') rxrplc url
if. 0 = # url do. return. end.
if. -. 'http' -: 4 {. url do.
	url =. ('.html' ; '') rxrplc 'https://code.jsoftware.com/wiki/' , url
end.
if. LastUrlLoaded -: url do. return. end.
wd 'set browser url *' , url 
LastUrlLoaded =: url
)

NB. ======================== Cached Drawing ===========================
BackgroundRenderRequired =: 1
CachedRectsAndLinks =: ''  NB. Table of rect ; url
ReversibleSelections =: '' NB. Table of rect

registerRectLink =: 4 : 0
NB. x xx yy width height
NB. y A url or * to be evaluated.
NB. Record this for mouse processing: highlighting and loading urls.
NB. Note that since we're frame-based, we re-register rect/links on every frame.  So we 
NB. just check immediately to see whether the mouse is inside the rect and activate accordingly.
if. -. VocMouseXY pointInRect x do. return. end.
if. '*' = {. y do. 
	". }. y 
else. 
	queueLoadPage y 
end.
x drawReversibleSelection SelectionColor
)

drawReversibleSelection =: 4 : 0
NB. x xx yy width height
NB. y color
NB. Draw an outline around xx yy width height.  Remember it so it can be erased later.
x drawHighlight y
if. ReversibleSelections -: '' do. ReversibleSelections =: ,: x else. ReversibleSelections =: ReversibleSelections , x end.
)

scheduleBackgroundRender =: 3 : 0
NB. Something major happened.  Render everything.
BackgroundRenderRequired =: 1
CachedRectsAndLinks =: ''
)

backgroundRenderComplete =: 3 : 0
BackgroundRenderRequired =: 0
)

NB. ============================== Hits Drawing ===============================
drawHitEntryChild =: 4 : 0
NB. x xx yy maxWidth sectionFlag
NB. y Path/Docname ; Link/''
'xx yy maxWidth sectionFlag' =. x
'name link' =. y
if. sectionFlag do. 
	if. 1 = # components =. <;._2 name , '/' do. newComponents =. components else. newComponents =. }. components end.
	adjustedName =. }: ; newComponents ,. <'/'
	glrgb SectionColor
	gltextcolor ''
	glfont TocFont
	(xx , yy) drawStringAt adjustedName
	glrgb 0 0 0
	gltextcolor ''
	glfont TocFont
else.
	(xx , yy) drawStringAt name
	(xx , yy , maxWidth , TocLineHeight) registerRectLink link
end.
0
)

drawHitEntryChildrenColumn =: 4 : 0
NB. x xx yy width height
NB. y Table of Path/Docname ; Link/''
NB. Render the column in black, with paths in SectionColor
'xx yy width height' =. x
glclip xx , yy , (width - 10) , height
glrgb 0 0 0
gltextcolor ''
glfont TocFont
margin =. 5
sectionFlags =. -. * > # &. > 1 {"1 y
left =. (margin + xx) ,. (margin + yy + TocLineHeight * i. # y) ,"0 1 width ,. sectionFlags
left drawHitEntryChild"1 1 y
glclip 0 0 10000 10000
)

drawHits =: 3 : 0
if. -. DisplayMode -: 'H' do. return. end.
'xx yy width height' =. DetailRect
margin =. 5
glrgb 0 0 0
glpen 1
glrgb 255 255 255
glbrush ''
glrect xx , yy , width , height
if. 0 = # HighlightUrls do. return. end.
toc =. getToc ''
hitToc =. toc #~ (2 {"1 toc) e. {:"1 HighlightUrls
childGroups =. ({."1 hitToc) </. 1 2 {"1 hitToc NB. DocName ; Link
pathNub =. a: ,.~ ~. {."1 hitToc NB. Path ; ''	
entryList =. ; (<"1 pathNub) , &. > childGroups NB. Path/Docname ; Link/''
rowCount =. <. height % TocLineHeight
columnGroups =. (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - xx) % width) * # columnGroups
colWidth =. 200
compressedColWidth =. <. (width - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =. <"1 (xx + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
if. 3 < # columnRects do.
	glrgb ScrollColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
columnRects drawHitEntryChildrenColumn &. > columnGroups
)

CachedTocChildrenImage =: ''

NB. ======================= Draw the TOC =========================
drawTocEntryChild =: 4 : 0
NB. x xx yy maxWidth height
NB. y HighlightFlag ; Name ; Command ; HeadingFlag
'xx yy maxWidth height' =. x
'highlightFlag name command headingFlag' =. y
if. headingFlag do. 
	glrgb SectionColor
	gltextcolor ''
	glfont TocFont
	(xx , yy) drawStringAt name
	glrgb 0 0 0
	gltextcolor ''
	glfont TocFont
else.
	(xx , yy) drawStringAt name
end.
adjRect =. xx , yy , (maxWidth - 16) , height
if. highlightFlag do. adjRect drawHighlight SelectionColor end.
adjRect registerRectLink command
0
)

drawTocEntryChildrenColumn =: 4 : 0
NB. x xx yy width height
NB. y Table of HighlightFlag ; Name ; Link/Command ; HeadingFlag
NB. Render the column in black, with headings in SectionColor
'xx yy width height' =. x
glclip xx , yy , (width - 10) , height
glrgb 0 0 0
gltextcolor ''
glfont TocFont
margin =. 5
rect =. (margin + xx) ,. (margin + yy + TocLineHeight * i. # y) ,"0 1 width , TocLineHeight
rect drawTocEntryChild"1 1 y
glclip 0 0 10000 10000
rect
)

TocEntryForumMonth =: 11

setTocEntryForumMonthIndex =: 3 : 0
NB. y The month whose posts we'll display
TocEntryForumMonthIndex =: y
setTocEntryForumSubjectIndex 0
)

TocEntryForumYear =: 2023

setTocEntryForumYear =: 3 : 0
NB. y The year whose posts we'll display
TocEntryForumYear =: y
setTocEntryForumSubjectIndex 0
)

TocEntryForumSubjectIndex =: 0

setTocEntryForumSubjectIndex =: 3 : 0
NB. The index of the subject that's currently highlighted
TocEntryForumSubjectIndex =: y
setTocEntryForumAuthorIndex 0
)

TocEntryForumAuthorIndex =: 0

setTocEntryForumAuthorIndex =: 3 : 0
NB. The index of the author who's currently highlighted.
TocEntryForumAuthorIndex =: y
)

ForumCacheTable =: '' NB. Year ; Month ; Subject ; Author ; Link
ForumCurrentName =: ''

drawTocEntryForum =: 4 : 0
NB. x The name of the forum
NB. y xx yy width height
NB. Display the contents of the forum
'xx yy width height' =. y
if. -. ForumCurrentName -: x do. 
	ForumCacheTable =: > {: sqlreadm__db 'select year, month, subject, author, link from forums where forumname = "' , x , '" order by year, month, subject'
	ForumCurrentName =: x
	TocEntryForumYear =: 2019
	TocEntryForumSubjectIndex =: 0
	TocEntryForumMonthIndex =: 0
end.
glrgb 0 0 0
glpen 1
glrgb 255 255 255
glbrush ''
margin =. 5
glrect xx , yy , width , height
years =. ~. > {."1 ForumCacheTable
if. 0 = # years do. return. end.
months =. > ~. 1 {"1 ForumCacheTable #~ TocEntryForumYear = yyyy =. > {."1 ForumCacheTable
TocEntryForumMonthIndex =: TocEntryForumMonthIndex <. <: # months
month =. TocEntryForumMonthIndex { months
yearOrigins =. (xx + margin) ,. 50 + yy + TocLineHeight * i. # years
glrgb SectionColor
gltextcolor ''
glfont SectionFont
yearOrigins drawStringAt"1 1 > ": &. > <"0 years
monthStrings =. months { ;: 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'
monthOrigins =. (# months) {. <"1 (xx + 60 + 40 * i. 12) ,. yy + margin
monthOrigins drawStringAt &. > monthStrings
(<"1 yearRects =. yearOrigins ,"(1 1) 40 , TocLineHeight) registerRectLink &. > '*setTocEntryForumYear '&, &. > ": &. > <"0 years
(<"1 monthRects =. (> monthOrigins) ,"(1 1) 40 , TocLineHeight) registerRectLink &. > '*setTocEntryForumMonthIndex '&, &. > ": &. > <"0 i. # months
((years i. TocEntryForumYear) { yearRects) drawHighlight SelectionColor
TocEntryForumMonthIndex =. TocEntryForumMonthIndex <. <: # months
(TocEntryForumMonthIndex { monthRects) drawHighlight SelectionColor
entries =. 2 3 4 {"1 ForumCacheTable #~ (TocEntryForumYear = > {."1 ForumCacheTable) *. month = > 1 {"1 ForumCacheTable
if. 0 = # entries do. return. end.
subjects =. ~. {."1 entries
rowCount =. <. (height - 60) % # subjects
leftSubjects =. (rowCount <. # subjects) {. subjects
glrgb 0 0 0
gltextcolor''
glfont TocFont
(<"1 leftOrigins =. (xx + 80 + 180) ,. (1 { 0 { yearRects) + TocLineHeight * i. # leftSubjects) drawStringAt &. > leftSubjects
leftRects =. leftOrigins ,"1 1 > ,&TocLineHeight &. > {.@glqextent &. > leftSubjects
(<"1 leftRects) registerRectLink &. > '*setTocEntryForumSubjectIndex '&, &. > ": &. > (<"0 i. # leftRects)
(TocEntryForumSubjectIndex { leftRects) drawHighlight SelectionColor
subject =. 2 { TocEntryForumSubjectIndex { ForumCacheTable
authorEntries =. entries #~ ({."1 entries) = TocEntryForumSubjectIndex { subjects
authors =. 1 {"1 authorEntries
authorHeight =. TocLineHeight * # authors
authorY =. <. (height - authorHeight) <. (1 { 0 { leftRects) >. (-: authorHeight) -~ 1 { TocEntryForumSubjectIndex { leftRects 
authorOrigins =. (xx + margin + 60) ,. authorY + TocLineHeight * i. # authors
glclip 0 0 , (_5 + 0 { 0 { leftRects) , height
(<"1 authorOrigins) drawStringAt &. > authors
authorRects =. authorOrigins ,"1 1 (> {.@glqextent &. > authors) ,. TocLineHeight
(<"1 authorRects) registerRectLink &. > '*setTocEntryForumAuthorIndex '&, &. > ": &. > <"0 i. # authorRects
(TocEntryForumAuthorIndex { authorRects) drawHighlight SelectionColor
glclip 0 0 10000 100000
selectedAuthorEntry =. TocEntryForumAuthorIndex { authorEntries
queueLoadPage 'https://www.jsoftware.com/pipermail/' , (}. x) , '/' , (": TocEntryForumYear) , '-' , (> month { Months) , '/' , > 2 { selectedAuthorEntry
)

setTocEntryChildCategory =: 4 : 0
NB. x The link for the subtree node
NB. y Choose the subtree node whose children should be displayed.
TocEntryChildCategory =: y
queueLoadPage x
)

TocEntryChildCategory =: ''

drawTocEntryChildrenWithTree =: 4 : 0
NB. x maxDepth
NB. y xx yy width height entryY
NB. Render the descendants of the TocSelectedTopCategory in xx yy width height.
NB. This is used when the child count is too high.  It renders a tree in the first column
NB. and the children of each node in the subsequent columns.
maxDepth =. x
'xx yy width height' =. y
'level category fullPath count link sortkey' =. TocOutlineRailSelectedIndex { getTocOutlineRailEntries maxDepth NB. level ; category ; full path ; count ; link
margin =. 5
glrgb 0 0 0
glpen 1
glrgb 255 255 255
glbrush ''
glrect xx , yy , width , height
childTable =. (< 0) ,. 1 2 4 {"1 getTocChildren fullPath  NB. Title ; Category ; Link ; HeadlingFlag
if. 0 = # childTable do. '' return. end.
childCategories =: getTocOutlineSubcategories fullPath  NB. Level ; Category
indents =. (2 * > 0 {"1 childCategories) <@#"0 ' '
indentedCategoryColumn =. indents , &. > 1 {"1 childCategories
if. (# childCategories) <: index =. (1 {"1 childCategories) i. < TocEntryChildCategory do. 
	TocEntryChildCategory =: > {. 1 {"1 childCategories 
else.
	TocEntryChildCategory =: > index { 1 {"1 childCategories 
end.
catHighlightFlags =. (< TocEntryChildCategory) = 1 {"1 childCategories
cleanCategories =. ('''';'''''')&rxrplc &. > 1 {"1 childCategories
commandLinks =. ''''&, &. > ,&'''' &. > getLinkForCategory &. > cleanCategories
commandCategories =. ,&'''' &. > ''''&, &. > cleanCategories
commands =. '*'&, &. > commandLinks , &. > ' setTocEntryChildCategory '&, &. > commandCategories 
categoryEntryList =. (<"0 catHighlightFlags) ,. (< 1) ,.~ indentedCategoryColumn ,. commands  NB. Depth ; Title ; Link ; Heading Flag
displayChildTable =. childTable #~ (2 {"1 childTable) = < TocEntryChildCategory  NB. Title ; Category ; Full Path ; Link
entryList =. (< 0) ,.~ 0 1 3 {"1 displayChildTable  NB. HighlightFlag ; Title ; Link ; Heading Flag
rowCount =. <. height % TocLineHeight
columnGroups =. (< categoryEntryList) , (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - xx) % width) * # columnGroups
fullSizeColCount =. <. width % MinColWidth
colWidth =. <. width % fullSizeColCount
compressedColWidth =. <. (width - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =: <"1 <. (xx + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
if. fullSizeColCount < # columnRects do.
	glrgb ScrollColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
columnRects drawTocEntryChildrenColumn &. > columnGroups
''
)

drawTocEntryChildren =: 4 : 0
NB. x maxDepth
NB. y xx yy width height
NB. Render the descendants of the TocOutlineRailSelectedIndex category in xx yy width height.
NB. Use multiple columns if necessary.  If there are too many columns, invoke drawTocEntryChildrenWithTree.
maxDepth =. x
'xx yy width height' =. y
'level category fullPath count link sortkey' =. TocOutlineRailSelectedIndex { getTocOutlineRailEntries maxDepth NB. level ; category ; full path ; count ; link
margin =. 5
glrgb 0 0 0
glpen 1
glrgb 255 255 255
glbrush ''
glrect xx , yy , width , height
childTable =. (< 0) ,. 1 2 3 4 {"1 getTocChildren fullPath  NB. HighlightFlag ; Title ; Category ; Full Path ; Link
if. 0 = # childTable do. '' return. end.
childCategories =. ~. 2 {"1 childTable
links =. getLinkForCategory &. > childCategories
childGroups =. (2 {"1 childTable) </. (< 0) ,.~ 0 1 4 {"1 childTable NB. Level ; Title ; Link ; Heading Flag
categoryLinks =. (< 1) ,.~ (< 0) ,. childCategories ,. links
entryList =. ; (<"1 categoryLinks) , &. > childGroups         NB. Category/Title ; Link
rowCount =. <. height % TocLineHeight
columnGroups =. (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - xx) % width) * # columnGroups
fullSizeColCount =. <. width % MinColWidth
colWidth =. <. width % fullSizeColCount
compressedColWidth =. <. (width - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =. <"1 <. (xx + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
if. (# columnRects) > 2 * fullSizeColCount do. 
	maxDepth drawTocEntryChildrenWithTree xx , yy , width , height
	''
	return.
end.
if. fullSizeColCount < # columnRects do.
	glrgb ScrollColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
columnRects drawTocEntryChildrenColumn &. > columnGroups
''
)

NB. TocLargestCategoryTotal =: >./ > # &. > getTocChildren &. > (getTocTopPathComponents '') 
TocLargestCategoryTotal =: 1000

drawTocEntry =: 4 : 0
NB. x entryX entryY entryHeight railX railY railWidth railHeight
NB. y max depth , TocOutline rail index
NB. Draw the category name in the rail and then call drawTocEntryChildren to render the kids.
'entryX entryY entryHeight railX railY railWidth railHeight' =. x
'maxDepth railIndex' =. y
'level category fullPath count link sortkey' =. railIndex { getTocOutlineRailEntries maxDepth NB. level ; category ; full path ; count ; link
margin =. 5
isShrunken =. entryHeight < TocLineHeight
isSelected =. VocMouseXY pointInRect (entryX + 70) , entryY , (railWidth - 70) , TocLineHeight
indentedCategory =. category ,~ level # '  '
glclip railX , (entryY - 2) , railWidth , TocLineHeight + 4
if. isShrunken do. entryRect =. railX, entryY, ({. glqextent indentedCategory) , 1 else. entryRect =. railX , entryY , railWidth , entryHeight end.
if. isSelected do. 
	if. railIndex ~: TocOutlineRailSelectedIndex do. scheduleBackgroundRender '' end.
	TocOutlineRailSelectedIndex =: railIndex 
end.
if. 0 < countPercent =. 1 <. count % 1000 do. 
	glrgb HighlightTocColor
	glbrush ''
	glpen 0
	glrect railX , entryY , (margin + <. countPercent * railWidth - margin) , entryHeight - 4 
end.
glfont TocFont
if. count < 0 do. glrgba 0 0 0 64 else. glrgb 0 0 0 end.
if. ('/*Search' -: 8 {. fullPath) *. level = 1 do. 
	glrgb 0 0 255 
	glfont TocBoldFont
end.
gltextcolor ''
if. railIndex = TocOutlineRailSelectedIndex do. 
	if. isShrunken do.
		entryRect drawHighlight SelectionColor
		entryRect registerRectLink link
	else.
		(entryX , entryY) drawStringAt indentedCategory
		entryRect drawHighlight SelectionColor
		entryRect registerRectLink link
	end.
else.
	if. isShrunken do.
		glrgba 127 127 127 50
		glbrush ''
		glpen 0
		glrect entryRect
	else.
		(entryX , entryY) drawStringAt indentedCategory
	end.
end.
if. level < <: maxDepth do. count =. 0 end.
glclip 0 0 10000 10000
if.  '*NuVoc' -: > 1 { TocOutlineRailSelectedIndex { getTocOutlineRailEntries 3 do.
	DisplayMode =: 'V'
	return.
end.
if. (DisplayMode = 'T') *. railIndex = TocOutlineRailSelectedIndex do.
	if. '/*Forums/' -: 9 {. > 2 { railIndex { getTocOutlineRailEntries 3 do.
		(> 1 { railIndex { getTocOutlineRailEntries 3) drawTocEntryForum DisplayDetailRect
NB.	elseif. '*Search' -: 7 {. > 1 { railIndex { TocOutlineRailEntries do.
NB.		maxDepth drawTocEntryChildrenWithTree DisplayDetailRect
	else.
		maxDepth drawTocEntryChildren DisplayDetailRect
	end.
end.
''
)

TocOutlineRailSelectedIndex =: 0

drawTocRail =: 4 : 0
NB. x xx yy w h
NB. y A level of the Toc hierarchy to which to display
'xx yy width height' =. x
if. VocMouseXY pointInRect xx , yy , width , height do. setDisplayMode 'T' end.
margin =. 5
stripeWidth =. 70
window =. 20
entries =. getTocOutlineRailEntries y NB. level ; category ; full path ; count ; link
NB. entries =. e #~ ~: 1 {"1 e =. TocOutline #~ > <&y &. > {."1 TocOutline
NB. if. 0 < # SearchString do. s =. '*Search in progress...' else. s =. '*Search (' , (": # SearchResultsTable) , ')' end.
NB. TocOutlineRailEntries =: (0 ; s ; '/') , (0 ; '*NuVoc' ; '/') , entries NB. level ; path component ; full path
if. ({. VocMouseXY) < xx + stripeWidth do.
	TocScrollIndex =: 0 >. (<: # entries) <. <. ((({: VocMouseXY) - yy) % height) * # entries
end.
windowStartIndex =. <. 0 >. (window -~ # entries) <. 0 >. TocScrollIndex - -: window
squishedLineHeight =. (window -~ # entries) %~ height - window * TocLineHeight
heights =. (# entries) {. (windowStartIndex # squishedLineHeight) , (window # TocLineHeight) , 1000 # squishedLineHeight
ys =. <. }: +/\ 0 , heights
heights =. <. heights
origins =. <. (margin + xx) ,. margin + yy + ys
glrgb 0 0 0
gltextcolor ''
glpen 1
glrgb 255 255 255
glbrush ''
glrect xx , yy , width , height
glcursor IDC_ARROW
if. VocMouseXY pointInRect xx , yy , 70 , height do. glcursor IDC_SIZEVER end.
if. VocMouseXY pointInRect (xx + 70) , yy , (width - 70) , height do. glcursor IDC_POINTINGHAND end.
if. VocMouseXY pointInRect xx , yy , 70 , height do. glrgb 220 220 255 else. glrgb ScrollColor end.
glbrush ''
glpen 0
glrect xx , yy , stripeWidth , height
(origins ,"1 1 heights ,"0 1 xx , yy , width , height) drawTocEntry"1 1 y ,. i. # entries
)

drawToc =: 3 : 0
NB. height =. 1010
DisplayListRect drawTocRail 3
NB. (10 30 150 , height) drawTocRail topCategories
)

TocOutlineRailEntries =: ''

NB. ======================= Database Caching =====================
resetTocOutlineRailEntries =: 3 : 0
TocOutlineRailEntries =: ''
)

getTocOutlineRailEntries =: 3 : 0
NB. y Depth to which to go in the TOC hierarchy
NB. Return level ; category ; full path ; count ; link ; sortkey
if. TocOutlineRailEntries -: '' do.
	TocOutlineRailEntries =: > 1 { sqlreadm__db 'select level, child, fullpath, count, link, sortkey from categories order by sortkey asc, fullpath asc'
end.
TocOutlineRailEntries #~ y > > 0 {"1 TocOutlineRailEntries
)

getTocOutlineSubcategories =: 3 : 0
NB. y A partial path
NB. Return all of the categories beneath that path, with levels (and including the partial path y)
NB. To put it another way, return a table of level ; category
entries =. getTocOutlineRailEntries 100  NB. level ; category ; full path ; count ; link
0 1 {"1 entries #~ sieve =. {."1 > (< y) E. &. > 2 {"1 entries
)

WikiCachedPartialPath =: ''
WikiCachedTable =: ''

getWikiTable =: 3 : 0
NB. y Partial path
if. y -: WikiCachedPartialPath do. WikiCachedTable return. end.
WikiCachedPartialPath =: y
WikiCachedTable =: > 1 { sqlreadm__db 'select level, title, category, fullpath, link from wiki where fullpath like "' , y , '%" order by fullpath asc'
)
NB. ==================== End Database Caching ====================

NB. ====================== NuVoc ========================
loadVoc =: 3 : 0
VocTable =: > 1 { sqlreadm__db 'select * from vocabulary'
)

calcCellDimensions =: 3 : 0
NB. y A space-separated list of tokens inside a cell.
NB. Return the width and height of the cell.  Create extra lines if necessary.
glfont VocCellFont
tokens =. < ;._2 (> y) , ' '
tokenWidths =: (2 * CellMargin) + > {.@:glqextent &. > tokens
lineWidths =. ''
while. 0 < # tokenWidths do.
	sieve =. MaxCellWidth >: +/\tokenWidths
	lineWidths =. lineWidths , +/ sieve # tokenWidths
	tokenWidths =. tokenWidths #~ -. sieve
end.
(>./ lineWidths) , CellLineHeight * # lineWidths
)

calcRowDimensions =: 3 : 0
NB. y A row of boxed tokens
NB. Return the height and column widths of the row.
dimensions =. > calcCellDimensions &. > y
(>./ {:"1 dimensions) , {."1 dimensions
)

getVocGeometryForMouseXY =: 3 : 0
, CurrentVocGeometry #~ VocMouseXY pointInRect"1 1 > 1 2 3 4 {"1 CurrentVocGeometry
)

getVocEntryGeometryForMouseXY =: 3 : 0
, VocSelectionGeometry #~ VocMouseXY pointInRect"1 1 > 4 {."1 VocSelectionGeometry
)

drawVocEntry =: 4 : 0
NB. x An entry from VocTable: Group POS Row Glyph MonadicRank Label DyadicRank Link
NB. y centerOrigin (x and y)
'xx yy' =. y
'monadic label dyadic link' =. 4 5 6 7 { x
s =. monadic , ' ' , label , ' ' , dyadic
width =. {. glqextent s
leftX =. <. xx - -: width
glfont 'arial 16'
glrgb 0 0 255
gltextcolor ''
(leftX , yy) drawStringAt s
if. categoryTest link do.
	((leftX - 4) , (yy - 2) , (width + 8) , 20) drawHighlight HighlightColor
end.
if. VocMouseXY pointInRect leftX , yy , width , 20 do.
NB.	glrgb 255 0 0
NB.	glpen 4
NB.	glrgba 0 0 0 0
NB.	glbrush''
NB.	glrect (leftX - 4) , (yy - 5) , (width + 8) , 20
	((leftX - 4) , (yy - 1) , (width + 8) , 20) drawHighlight SelectionColor
	queueLoadPage > {: x
end.
0
)

drawVocCell =: 4 : 0
NB. x POS ; Glyph ; Selected
NB. y xStart ; yStart ; width ; height
NB. Return the height
'pos glyph selected' =. x
'xStart yStart width height' =. y
glfont VocCellFont
glrgb 0 0 0
gltextcolor ''
tokens =. < ;.2 glyph , ' ' 
tokens =. (}: tokens) , }: &. > {: tokens
tokenWidths =. > {.@:glqextent &. > tokens
lineWidths =. ''
lineTokens =. ''
yStarts =. ''
while. 0 < # tokenWidths do.
	sieve =. MaxCellWidth >: +/\tokenWidths
	lineWidths =. lineWidths , +/ sieve # tokenWidths
	tokenWidths =. tokenWidths #~ -. sieve
	lineTokens =. lineTokens , < sieve # tokens
	tokens =. tokens #~ -. sieve
	yStarts =. yStarts , (yStart + CellLineHeight * # lineWidths) - CellLineHeight
end.
xOffsets =. xStart + <. 0.5 * width - lineWidths
coords =. <"1 xOffsets ,. 2 + yStarts
glrgb getPosColor < pos
glbrush ''
glrgb 162 169 177
glpen 1
glrect xStart , yStart , width , height
if. selected do.
	(xStart, yStart, width, height) drawHighlight SelectionColor
end.
coords drawStringAt &. > ; &. > lineTokens
if. categoryGlyphTest glyph do.
	m =. 2
	((xStart + m) , (yStart + m) , (width - 2 * m) , (height - 2 * m)) drawHighlight HighlightColor
end.
NewVocGeometry =: NewVocGeometry , glyph ; xStart ; yStart ; width ; height
''
)

drawVocLine =: 4 : 0
NB. x Table of POS Glyph
NB. y Origin ; height ; column widths
NB. Return new y start.
'origin height colWidths' =. y
'xx yStart' =. origin
selected =. VocSelectedGlyph&-: &. > 1 {"1 x
adjustedColWidths =. (# x) {. colWidths NB. We may not need all of the column widths.
xStarts =. <"0 xx + +/\ 0 , }: adjustedColWidths
(x ,. selected) drawVocCell"1 1 xStarts ,. (< yStart) ,. (<"0 adjustedColWidths) ,. < height
selectionPadding =. 0
availableWidth =. +/ colWidths
entryLineHeight =. 20
if. 0 < +/ > selected do. 
	entries =. VocTable #~ > VocSelectedGlyph&-: &. > 3 {"1 VocTable  NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
	coords =. (xx + <. -: availableWidth) ,. yStart + height + 10 + entryLineHeight * i. # entries
	entries drawVocEntry"1 1 coords
	VocSelectionGeometry =: (<"0 coords) ,. (< availableWidth) ,. (<entryLineHeight) ,. 7 {"1 entries
	selectionPadding =. entryLineHeight * >: # entries
end.
yStart + selectionPadding + height
)

drawVocSections =: 4 : 0
NB. x Origin
NB. y Section numbers
'xx runningY' =. x
rows =. VocTable #~ (, > {."1 VocTable) e. y
cells =. ~. 1 2 3 {"1 rows NB. POS Line Glyph
dimensions =. > calcCellDimensions &. > (2 {"1 cells)
lineNumbers =. 1 {"1 cells
cellWidths =. {."1 dimensions
columnWidths =. >./ > lineNumbers < /. cellWidths
lineHeights =. > >./ &. > lineNumbers < /. {:"1 dimensions
lines =. ({. , {:)"1 &. > lineNumbers < /. cells NB. POS Glyph
spacings =. 20 * ~: lineNumbers
glfont 'consolas bold 12'
glrgb 0 0 0
gltextcolor ''
for_line. lines do.
	rowHeight =. line_index { lineHeights
	runningY =. (> line) drawVocLine (xx , runningY) ; rowHeight ; columnWidths
	runningY =. runningY + line_index { spacings
end.
runningY
)

drawVoc =: 3 : 0
if. -. DisplayMode -: 'V' do. return. end.
glrgb 255 255 255
glbrush ''
glrect 0 0 2000 2000
CurrentVocGeometry =: NewVocGeometry
NewVocGeometry =: ,: '' ; _1 ; 0 ; 0 ; 0
g =. getVocGeometryForMouseXY ''
if. (0 < # g) do.
	VocSelectedGlyph =: > 0 { g
end.
225 30 drawVocSections 0 1 2 3 4 5
510 30 drawVocSections 6 7 8 9 10 11
)

drawButton =: 4 : 0
NB. x rect
NB. y Label ; Link/Command
'label link' =. y
rect =. x
glrgb 255 255 255
glbrush ''
glrgb 0 0 0
glpen 1
glrect rect
glfont 'arial bold 18'
glrgb HighlightColor
gltextcolor ''
xx =. (0 { rect) + <. -: (2 { rect) - {. glqextent label
(xx , 1 { rect) drawStringAt label
rect registerRectLink link
)

FrameTimeStamps =: ''

drawFrameRate =: 3 : 0
FrameTimeStamps =: (t =. (6!:1) '' ) , FrameTimeStamps
fps =. # FrameTimeStamps =: FrameTimeStamps #~ (t - 1) < FrameTimeStamps
glfont 'arial bold 24'
glrgb HighlightColor
gltextcolor ''
10 0 drawStringAt (": fps) , ' fps'
)

go =: 3 : 0
dbOpenDb ''
loadVoc ''
buildForm ''
layoutForm ''
wd 'pshow'
)