clear ''

load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'gl2'
coinsert 'jgl2'
NB. A Items
NB. Fix use of curl for search (post a question that contrasts spawning a curl with gethttp).
NB. Implement migration of ancillary information (history, searches, bookmarks) when a new cache.db file arrives.
NB. Fix the *Search results display.  It's hard to read.
NB. Look into splitting the detail pane from the TOC in order to facilitate Search child element management.
NB. Adjustable font size?
NB. Fix Raul's bug.

NB. B Items
NB. Can I add a "Back" button that drives the webview?  What else can I tell the webview?
NB. Support parallel download of forum and wiki documents.
NB. Animate scroll rather than jumping when the travel is too high.
NB. Add a "Search" label.
NB. Fix the extra "quotes in NuVoc
NB. Spider the Vocabulary--don't use the spreadsheet.
NB. Standalone application.

NB. ============= Database ===============
dbFile =: jpath '~temp/cache.db'
db =: ''

dbError =: 3 : 0
sqlerror__db ''
)

dbOpenDb =: 3 : 0
db =: sqlopen_psqlite_ dbFile
)

log =: 3 : 0
sqlinsert__db 'log' ; (;: 'datetime msg') ; < ((6!:0) 'YYYY MM DD hh mm sssss') ; y
if. 0 = ? 200 do.
	max =. , > > {: sqlreadm__db 'select max(rowid) from log'
	sqlcmd__db 'delete from log where rowid < ' , ": 0 >. max - 1000
	sqlinsert__db 'log' ; (;: 'datetime msg') ; < ((6!:0) 'YYYY MM DD hh mm sssss') ; JVERSION
end.
)
NB. =======================================

NB. ==================== Form =====================
NB. FormMouseXY =: 0 0
VocMouseXY =: 0 0
VocMouseClickXY =: 0 0

buildForm =: 3 : 0 
wd 'pc vizform;'
wd 'bin h;'
wd   'bin v;'
wd     'cc vocContext isigraph;'
wd     'bin h;'
wd       'cc clearSearches button;cn Clear *Searches;'
wd       'cc searchBox edit;'
wd      'bin z'
wd   'bin z;'
wd   'bin v;'
wd     'bin h;'
wd       'cc bookmark button; cn *Bookmark'
wd       'cc history combolist;'
wd       'cc launch button; cn Browser;'
wd     'bin z;'
wd     'cc browser webview;'
wd   'bin z;'
wd 'bin z;'
)

LayoutTemplate =: 'D'

setLayoutTemplate =: 3 : 0
NB. y A one-character layout template code
if. y -: LayoutTemplate do. return. end.
LayoutTemplate =: y
layoutForm ''
)

layoutForm =: 3 : 0
if. LayoutTemplate = 'D' do. layoutDefaultForm ''
elseif. LayoutTemplate = 'S' do. layoutSearchForm ''
elseif. LayoutTemplate = 'N' do. layoutNuVocForm ''
end.
wd 'timer 100'
)

layoutDefaultForm =: 3 : 0
'w h' =. ". wd 'getp wh'
winW =. w - 40
winH =. h - 45
controlHeight =. 30
wd 'set vocContext minwh 650 765;'
wd 'set searchBox visible 0;'
wd 'set clearSearches visible 0;'
wd 'set bookmark maxwh ' , (": <. (winW * 0.10), controlHeight) , ';'
wd 'set history maxwh ' , (": <. (winW * 0.30) , controlHeight) , ';'
wd 'set launch maxwh ' , (": <. (winW * 0.10) , controlHeight) , ';'
wd 'set browser minwh ' , (": (<. winW * 0.5) , winH - controlHeight) , ';'
)

layoutNuVocForm =: 3 : 0
'w h' =. ". wd 'getp wh'
winW =. w - 40
winH =. h - 45
leftWidth =. (winW * 0.5) >. 650 + 175  NB. Minimum width necessary to show NuVoc in the detail area.
controlHeight =. 30
rightWidth =. 0 >. winW - leftWidth
leftHeight =. winH
wd 'set vocContext minwh ' , (": leftWidth , 765) , ';'
wd 'set searchBox visible 0;'
wd 'set clearSearches visible 0;'
wd 'set bookmark maxwh ' , (": <. (rightWidth * 0.20), controlHeight) , ';'
wd 'set history maxwh ' , (": <. (rightWidth * 0.60) , controlHeight) , ';'
wd 'set launch maxwh ' , (": <. (rightWidth * 0.20) , controlHeight) , ';'
wd 'set browser minwh ' , (": <. rightWidth , winH - controlHeight) , ';'
)

layoutSearchForm =: 3 : 0
'w h' =. ". wd 'getp wh'
winW =. w - 40
winH =. h - 45
controlHeight =. 30
wd 'set vocContext minwh ' , (": 650 , 765 - controlHeight) , ';'
wd 'set searchBox visible 1;'
wd 'set searchBox focus;'
wd 'set searchBox maxwh ' , (": <. (winW * 0.3) , controlHeight) , ';'
wd 'set clearSearches visible 1;'
wd 'set clearSearches maxwh ' , (": <. (winW * 0.09) , controlHeight) , ';'
wd 'set bookmark maxwh ' , (": <. (winW * 0.10), controlHeight) , ';'
wd 'set history maxwh ' , (": <. (winW * 0.30) , controlHeight) , ';'
wd 'set launch maxwh ' , (": <. (winW * 0.10) , controlHeight) , ';'
wd 'set browser minwh ' , (": (<. winW * 0.5) , winH - controlHeight) , ';'
)

vizform_default =: 3 : 0
eventType =. > {: 5 { wdq
if. eventType -: 'close' do. wd 'pclose ;' end.
NB. (> {: 5 { wdq) (1!:2) 2
)

vizform_resize =: 3 : 0
layoutForm ''
)

vizform_close =: 3 : 0
wd 'timer 0'
wd 'pclose'
)

vizform_numb_button =: 3 : 0
Numb =: ". numb
invalidateDisplay ''
)

vizform_bookmark_button =: 3 : 0
bookmark ''
invalidateDisplay ''
)

vizform_clearSearches_button =: 3 : 0
clearSearches ''
invalidateDisplay ''
)

vizform_vocContext_mmove =: 3 : 0
NB. Give the user the chance to get the mouse over to the webview without activating another link.
NB. if. 1 > ((6!:1) '') - SuppressMouseHandlingStart do. return. end.
VocMouseXY =: 0 1 { ". > 1 { 13 { wdq
invalidateDisplay ''
)

vizform_vocContext_mblup =: 3 : 0
VocMouseClickXY =: 0 1 { ". > 1 { 13 { wdq
PageLoadFreezeTime =: (6!:1) ''
perpetuateAnimation ''
)

vizform_vocContext_mwheel =: 3 : 0
MWheelOffset =: MWheelOffset + 11 { ". > (1 {"1 wdq) {~ ({."1 wdq) i. < 'sysdata'
invalidateDisplay ''
)

vizform_vocContext_paint =: 3 : 0
trigger_paint ''
)

vizform_browser_curl =: 3 : 0
url =. > (1 {"1 wdq) {~ ({."1 wdq) i. < 'browser_curl'
topHistoryUrl =. > 0 { 0 { HistoryMenu
if. -. +./ topHistoryUrl E. url do. addToHistoryMenu url ; url end.
resetBookmarkButton ''
)

vizform_searchBox_button =: 3 : 0
try.
	search searchBox
	wd 'set searchBox text ""'
	invalidateDisplay ''
catch.
	log (13!:12) ''
	log dbError ''
end.
)

vizform_history_select =: 3 : 0
loadPage (". history_select) { HistoryMenu
)

vizform_launch_button =: 3 : 0
log 'vizform_launch_button ' , ": > 0 { 0 { HistoryMenu
if. IFUNIX do. (2!:1) 'open -a Safari "' , (> 0 { 0 { HistoryMenu) , '"' end.
)

vizform_wctrl_fkey =: 3 : 0
wd 'timer 0'
wd 'pclose'
)

PerpetuateAnimationStartTime =: 0

sys_timer_z_ =: 3 : 0
try.
NB. 	checkQueuedUrlTime_base_ ''
	if. 4 > ((6!:1) '') - PerpetuateAnimationStartTime_base_ do. invalidateDisplay_base_ '' end.
catch.
	smoutput (13!:12) ''
	smoutput dbError ''
end.
)

perpetuateAnimation =: 3 : 0
PerpetuateAnimationStartTime =: (6!:1) ''
)

wd 'timer 0'

DisplayListRectTargetWidth =: 175
DisplayListRectSourceWidth =: 20
DisplayListRectAnimationStartTime =: 0

setDisplayRects =: 3 : 0
'w h' =. ". wd 'get vocContext wh'
if. ({. VocMouseXY) < DisplayListRectTargetWidth do.
	if. DisplayListRectTargetWidth ~: 175 do. 
		DisplayListRectAnimationStartTime =: (6!:1) '' 
		perpetuateAnimation ''
	end.
	DisplayListRectTargetWidth =: 175
	DisplayListRectSourceWidth =: 20
else.
	if. DisplayListRectTargetWidth ~: 20 do. 
		DisplayListRectAnimationStartTime =: (6!:1) '' 
		perpetuateAnimation ''
	end.
	DisplayListRectTargetWidth =: 20
	DisplayListRectSourceWidth =: 175
end.
length =. <. DisplayListRectSourceWidth + (DisplayListRectTargetWidth - DisplayListRectSourceWidth) * 1 <. 2 * ((6!:1) '') - DisplayListRectAnimationStartTime
DisplayListRect =: 0 0 , length , h
DisplayDetailRect =: length , 0 , (w - length) , h
)

trigger_paint =: 3 : 0
log 'trigger_paint ' , (wd 'getp wh') , '   ' , (": getFrameRate '') , ' fps'
try.
glfill BackgroundColor , 255
setDisplayRects ''
drawToc ''
drawPageLoadFreezeRect ''
VocMouseClickXY =: 0 0
glclip 0 0 10000 10000
catcht. catch. 
log (13!:12) ''
log dbError ''
smoutput (13!:12) ''
smoutput dbError ''
end.
)

invalidateDisplay =: 3 : 0
wd 'set vocContext invalid'
)
NB. ======================================================

NB. =================== Search ===========================
deleteCategoryIdAndDescendants =: 3 : 0
NB. y A category id whose descendants are to be deleted.
if. y < 0 do. return. end.
childIds =. > {: sqlreadm__db 'select categoryid from categories where parentid = ' , ": y
deleteCategoryIdAndDescendants &. > childIds
sqlcmd__db 'delete from categories where categoryid = ' , ": y
sqlcmd__db 'delete from wiki where categoryid = ' , ": y
)

deleteCategoryIdDescendantsOnly =: 3 : 0
if. y < 0 do. return. end.
childIds =. , > > {: sqlreadm__db 'select categoryid from categories where parentid = ' , ": y
deleteCategoryIdAndDescendants &. > childIds
)

clearSearches =: 3 : 0
NB. y A search string
NB. Remove the search records from the TOC.
log 'clearSearches'
terms1 =. > {: sqlreadm__db 'select category from categories where parentid = ' , ": getTopCategoryId SearchCatString
if. 0 < # terms1 do. clearSearch &. > terms1 end.
terms2 =. > {: sqlreadm__db 'select category from categories where parentid = ' , ": SearchHiddenCatId getCategoryId SearchCatString
if. 0 < # terms2 do. clearSearch &. > terms2 end.
clearCache ''
)

clearSearch =: 3 : 0
NB. y A search term
termId =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '" AND parentid = ' , ": SearchHiddenCatId getCategoryId SearchCatString
deleteCategoryIdAndDescendants (SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y
deleteCategoryIdAndDescendants (getTopCategoryId SearchCatString) getCategoryId y
clearCache ''
)

addSearchToToc =: 3 : 0
NB. y A search string
NB. Save parent ; child.  
term =.  y
clearSearch term
cols =. ;: 'level parentid categoryid category count parentseq link'
NB. sqlinsert__db 'categories' ; cols ; < 2 ; (getTopCategoryId SearchCatString) ; (nextUserCatId 1) ; (< term) ; _1 ; 0 ; 'https://www.jsoftware.com'
sqlinsert__db 'categories' ; cols ; < 1 ; (termParentId =. SearchHiddenCatId getCategoryId SearchCatString) ; (nextUserCatId 1) ; (< term) ; 0 ; 0 ; 'https://www.jsoftware.com'
sqlinsert__db 'categories' ; cols ; < 2 ; (termParentId getCategoryId term) ; (nextUserCatId 1) ; (< 'Wiki') ; _1 ; 0 ; 'https://code.jsoftware.com/wiki/Special:JwikiSearch'
NB. sqlinsert__db 'categories' ; cols ; < 2 ; (termParentId getCategoryId term) ; (< 'Forums') ; 0 ; 1 ; 'https://www.jsoftware.com/forumsearch.htm'
)

searchWiki =: 3 : 0
NB. y Search term
NB. Perform the search, parse the results, and update the "categories" and "wiki" tables.
NB. Return the number of hits.
NB. fname =. (jpath '~temp/S' , ": ? 100000) , '.txt'
NB.  ('-o ' , fname) gethttp 'https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=70&offset=0&profile=default&search=' , (urlencode y)
NB. smoutput (1!:1) < fname
log 'Searching wiki for ' , y , '...'
html =. (2!:0) 'curl "https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=70&offset=0&profile=default&search=' , (urlencode y) , '"'
pat =. rxcomp 'mw-search-result-heading''><a href="([^"]+)" title="([^"]+)"'
offsetLengths =.  pat rxmatches html
wikiId =. ((SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Wiki'
log '...received ' , (": # html) , ' bytes with ' , (": # offsetLengths) , ' hits.'
if. 0 = # offsetLengths do.
	sqlupdate__db 'categories' ; ('categoryid = ' , ": wikiId) ; ('count' ; 'level') ; < 0 ; 3
else.
	ol =. 1 2 {"2 offsetLengths
	linkOffsets =. 0 {"(1) 0 {"2 ol
	titleOffsets =. 0 {"(1) 1 {"2 ol
	linkLengths =. 1 {"(1) 0 {"2 ol
	titleLengths =. 1 {"(1) 1 {"2 ol
	links =. 'https://code.jsoftware.com'&, &. > linkLengths <@{."0 1 linkOffsets }."0 1 html
	titles =. titleLengths <@{."0 1 titleOffsets }."0 1 html
	wikiCols =. ;: 'title categoryid link'
	data =. titles ; (wikiId #~ # titles) ; < links
	sqlinsert__db 'wiki';wikiCols;<data
	sqlupdate__db 'categories' ; ('categoryid = ' , ": wikiId) ; ('count' ; 'level') ; < (# titles) ; 2
end.
# offsetLengths
)

searchForums =: 3 : 0
NB. y Search term		
NB. Perform the search, parse the results, and update the "categories" and "wiki" tables.
try.
log 'Searching forums for ' , y , '...'
wikiCols =. ;: 'title categoryid link'
html =. (2!:0) 'curl "https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2030"'
pat =. rxcomp '(http://www.jsoftware.com/pipermail[^"]+)">\[([^\]]+)\] ([^<]+)</a>'
offsetLengths =. pat rxmatches html
termId =. (SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y
NB. forumsId =. ((SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Forums'
log '...received ' , (": # html) , ' bytes with ' , (": # offsetLengths) , ' hits.'
if. 0 < # offsetLengths do.
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
NB.	sqlupdate__db 'categories' ; ('rowid = ' , ": forumsId) ; ('count' ; 'level') ; < (# titles) ; 3
	for_index. i. # titleGroups do.
		fname =. > index { ~. forums
		forumLinks =. > index { linkGroups
		forumTitles =. > index { titleGroups
		cols =. (;: 'level parentid categoryid category parentseq count link')
		data =. 2 ; termId ; (nextUserCatId 1) ; fname ; (>: index) ; (# forumLinks) ; 'https://www.jsoftware.com/mailman/listinfo/' , }. fname
		sqlinsert__db 'categories' ; cols ; < data
		forumId =. termId getCategoryId fname
		data =. forumTitles ; (forumId #~ # forumLinks) ; < forumLinks
		sqlinsert__db 'wiki';wikiCols;<data
	end.
end.
count =. {. , > > {: sqlreadm__db 'select sum(count) from categories where parentid = ' , ": termId
otherTermId =. (getTopCategoryId SearchCatString) getCategoryId y
parms =. 'categories' ; ('categoryid = ' , ": otherTermId) ; (;: 'count level') ; < count ; 2
sqlupdate__db parms
catcht.
	log (13!:12) ''
	log 'Db Error (if any): ' , dbError ''
end.
)

search =: 3 : 0
NB. y A search term.
try.
	log 'Searching for ' , y
	addSearchToToc y
	clearCache ''
	selectSearch ''
	invalidateDisplay ''
	wd 'msgs'
	searchWiki y
	searchForums y
	clearCache ''
	invalidateDisplay ''
catcht.
	log (13!:12) ''
	log 'Db Error (if any): ' , dbError ''
end.
)

selectSearch=: 3 : 0
NB. Select '*Search' in the Table of Contents (TOC).
index =. (< SearchCatString) i.~ 3 {"(1) 1 getTocOutlineRailEntries MaxTocDepth NB. Table of level ; parentid ; categoryid ; category ; parentseq ; count ; link
setTocOutlineRailSelectedIndex index
)

NB. ================== Drawing ====================
VocMinWidth =: 800
VocMinHeight =: 900
MaxCellWidth =: 100
MinColWidth =: 200
CellMargin =: 5
CellLineHeight =: 25
DocumentLineHeight =: 26
DocumentFont =: 'arial bold 18'
DocumentColumnFont =: 'arial 18'
SectionFont =: 'arial bold 16'
NB. BackgroundColor =: 233 216 166
NB. SectionColor =: 155 34 38
NB. LabelColor =: 0 18 25
NB. ColumnGuideColor =: 148 210 189
NB. SelectionColor =: 0 95 115
NB. BarColor =: 148 210 189

BackgroundColor =: 255 255 255
SectionColor =: 0 0 0
LabelColor =: 0 0 0
ColumnGuideColor =: 204 238 255
SelectionColor =: 0 0 0
BarColor =: 238 170 170

PageFreezeColor =: 0 18 25
VocSelectedGlyph =: ''
DocumentSelectedIsletIndex =: _1
DocumentSectionGeometry =: '' NB. index x y width height label sectionName columnId url
DocumentSectionSelectedIndex =: _1
VocTable =: '' NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
POSColors =: 221 204 255 , 204 238 255 , 238 255 204 , 255 204 238 , 221 221 221 ,: 238 170 170
POSNames =: ;: 'Verb Adverb Conjunction Noun Copula Control'
VocCellFont =: 'consolas 16 bold'
VocValenceFont =: 'arial 14'
CategoryIndex =: 0
CategoryTable =: ''
HighlightUrls =: '' NB. Holds the labels ; URLs to be used for highlighting the map. 
TocFont =: 'arial 13'
NB. TocBoldFont =: 'arial bold 14'
TocLineHeight =: 21
TocScrollIndex =: 0
MaxTocDepth =: 3
DisplayListRect =: 10 10 100 100
DisplayDetailRect =: 100 10 100 100
Months =: ;:'January February March April May June July August September October November December'
ShortMonths =: ;: 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'
ForumsCatString =: '*Forums'
BookmarkCatString =: '*Bookmarks'
SearchCatString =: '*Search'
SearchHiddenCatId =: 200000
TagCatString =: '*Tags'
TagHiddenCatId =: 500000
Numb =: 0
QueuedUrl =: ''
QueuedUrlTime =: 0
PageLoadFreezeTime =: 0
PageLoadFreezeRect =: ''
PageLoadFreezeDuration =: 3
MWheelOffset =: 0
LayoutTemplate =: 'D' NB. (D)efault, (S)earch, (N)uVoc

getTocFontForLevel =: 3 : 0
NB. y An integer level in an outline hierarchy
NB. Return the string specification of the font to use.
> y { 'arial bold italic 13' ; 'arial bold 13' ; 'arial 13' ; 'arial 13' ; 'arial 13' ; 'arial 13' ; 'arial 13' ; 'arial 13'
)

getPosColor =: 3 : 0
NB. y The boxed name of a pos
NB. Return the corresponding color.
POSColors {~ POSNames i. y
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
(rx < px) *. (px < rx + rw) *. (py > ry) *. (py < ry + rh)
)

isBookmarked =: 3 : 0
NB. y A url
NB. Return 1 if y is bookmarked
links =. , > {: sqlreadm__db 'select link from wiki where categoryId = ' , ": getTopCategoryId BookmarkCatString
(# links) > links i. < y
)

resetBookmarkButton =: 3 : 0
'url title' =. {. HistoryMenu
links =. , > {: sqlreadm__db 'select link from wiki where categoryId = ' , ": getTopCategoryId BookmarkCatString
if. isBookmarked url do. wd 'set bookmark text "Un-bookmark";' else. wd 'set bookmark text "Bookmark";' end.
)

bookmark =: 3 : 0
'url title' =. {. HistoryMenu
id =. (getTopCategoryId BookmarkCatString)
if. isBookmarked url do.
	sqlcmd__db 'delete from wiki where categoryid = ' , (": id) , ' and link = "' , url , '"'
else.
	sqlinsert__db 'wiki' ; (;: 'title categoryid link') ; < title ; id ; url
end.
clearCache ''
invalidateDisplay ''
resetBookmarkButton ''
)

checkQueuedUrlTime =: 3 : 0
if. (0.25 < ((6!:1) '') - QueuedUrlTime_base_) *. -. QueuedUrl_base_ -: '' do. 
	loadPage_base_ QueuedUrl_base_
	QueuedUrl_base_ =: ''
end.
)

queueUrl =: 3 : 0
NB. y A url to queue for delayed loading ; A title
if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do. return. end.
QueuedUrl =: y
QueuedUrlTime =: (6!:1) ''
loadPage QueuedUrl
)

addToHistoryMenu =: 3 : 0
NB. y Label ; Link
if. y -: '' do. return. end.
if. HistoryMenu -: '' do. HistoryMenu =: ,: y else. HistoryMenu =: ~. y , HistoryMenu end.
s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
wd 'set history items *' , s
wd 'set history select 0'
HistoryMenu =: (30 <. # HistoryMenu) {. HistoryMenu
sqlcmd__db 'delete from history'
sqlinsert__db 'history' ; (;: 'label link') ; < ({:"1 HistoryMenu) ; < {."1 HistoryMenu
)

loadHistoryMenu =: 3 : 0
HistoryMenu =: > {: sqlreadm__db 'select link, label from history'
s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
wd 'set history items *' , s
wd 'set history select 0'
)

HistoryMenu =: '' NB. Table of Title ; Link

loadPage =: 3 : 0
NB. y A url, possibly unqualified ; A title
try.
if. 0 = # y do. return. end.
url =. > {. y
if. url -: '' do. return. end.
url =. ('User_' ; 'User:') rxrplc url
if. 'Category:' -: 9 {. url do.
	url =. 'https://code.jsoftware.com/wiki/' , url
elseif. -. 'http' -: 4 {. url do.
	url =. ('.html' ; '') rxrplc 'https://code.jsoftware.com/' , url
end.
log 'Loading url ' , url
wd 'set browser url *' , url
addToHistoryMenu (< url) , {: y
catch.
	smoutput (13!:12) ''
end.
)

NB. ======================== Cached Drawing ===========================
BackgroundRenderRequired =: 1
CachedRectsAndLinks =: ''  NB. Table of rect ; url
NB. ReversibleSelections =: '' NB. Table of rect

registerRectLink =: 4 : 0
NB. x xx yy width height
NB. y A url or * to be evaluated ; an optional title
NB. Record this for mouse processing: highlighting and loading urls.
NB. Note that since we're frame-based, we re-register rect/links on every frame.  So we 
NB. just check immediately to see whether the mouse is inside the rect and activate accordingly.
if. VocMouseClickXY pointInRect x do.
	PageLoadFreezeTime =: (6!:1) ''
	PageLoadFreezeRect =: x
end.
if. -. VocMouseXY pointInRect x do. return. end.
if. 2 = # y do. 'urlCommand name' =. y else. 'urlCommand name' =. (; y) ; '----' end.
if. '*' = {. urlCommand do.
	". }. urlCommand
else. 
	queueUrl urlCommand ; name
end.
x drawReversibleSelection SelectionColor
)

drawReversibleSelection =: 4 : 0
NB. x xx yy width height
NB. y color
NB. Draw an outline around xx yy width height.  Remember it so it can be erased later.
x drawHighlight y
NB. if. ReversibleSelections -: '' do. ReversibleSelections =: ,: x else. ReversibleSelections =: ReversibleSelections , x end.
)

drawPageLoadFreezeRect =: 3 : 0
if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do.
	glrgb PageFreezeColor
	glpen 5
	glrgba 0 0 0 0
	glbrush ''
	glrect PageLoadFreezeRect
end.
)
NB. ============================== Scroller Field ===============================
drawScrollerField =: 3 : 0
NB. y Structure: x y width height ; strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
NB. Draw the strings and registerRectLink to highlight them and load pages.
NB. Use VocMouseXY to update scrollOffset and selectedIndex.
NB. Return the scrollIndex, which may have changed.
'rect strings links ratios headingFlags selectedIndex scrollIndex' =. y
'xx yy w h' =. rect
window =. <. TocLineHeight %~ -: h
maxLineCount =. <. h % TocLineHeight
margin =. 5
stripeWidth =.<. 0.5 * w
glfont TocFont
if. VocMouseXY pointInRect rect do.
	scrollIndex =. 0 >. (# strings) <. scrollIndex + MWheelOffset
	MWheelOffset =: 0
end.
windowStartIndex =. <. 0 >. (window -~ # strings) <. 0 >. scrollIndex - -: window
squishedLineHeight =. TocLineHeight <. (window -~ # strings) %~ h - window * TocLineHeight
heights =. (# strings) {. (windowStartIndex # squishedLineHeight) , (window # TocLineHeight) , 1000 # squishedLineHeight
ys =. <. }: +/\ 0 , heights
heights =. <. heights
origins =. <. (margin + xx) ,. margin + yy + ys
glrgb LabelColor
gltextcolor ''
glpen 1
glrgb BackgroundColor
glbrush ''
glrect rect
for_i. i. # strings do.
	lineHeight =. i { heights
	origin =. > i { origins
	glrgb BarColor
	glbrush ''
	glpen 0
	if. 0 < i { ratios do. glrect (origin - margin , 0) , (<. (w - margin) * i { ratios) , lineHeight - 4 end.
	if. i { headingFlags do. 
		if. 0 > i { ratios do. glrgb 127 127 127 else.  glrgb SectionColor end.
		glfont TocBoldFont
	else.
		glrgb LabelColor
		glfont TocFont
	end.
	glbrush ''
	gltextcolor''
	glclip xx , yy ,  w , h
	if. lineHeight >: TocLineHeight do.
		(> i { origins) drawStringAt > i { strings
	else.
NB.		glrect origin , ({. glqextent > i { strings) , 2
	end.
	if. i = selectedIndex do. ((origin - margin , 0) , w , lineHeight) drawHighlight SelectionColor end.
	if. VocMouseXY pointInRect xx , yy , stripeWidth , h do.
		((origin - margin , 0), w, lineHeight) registerRectLink (> i { links) ; > i { strings
	elseif. -. Numb do.
		((origin - margin , 0), w, lineHeight) registerRectLink (> i { links) ; > i { strings
	end.
NB.	glclip xx , yy ,  w , h
end.
glclip 0 0 10000 100000
scrollIndex
)
NB. ======================= Draw the TOC =========================
drawTocEntryChild =: 4 : 0
NB. x xx yy maxWidth height
NB. y Highlight Flag ; Name ; Link/Command ; HeadingFlag
'xx yy maxWidth height' =. x
'highlightFlag name command headingFlag' =. y
if. headingFlag do. 
	glrgb SectionColor
	gltextcolor ''
	glfont TocBoldFont
else.
	glrgb 0 0 0
	gltextcolor ''
	glfont TocFont
end.
(xx , yy) drawStringAt name
adjRect =. xx , yy , (maxWidth - 16) , height
if. highlightFlag do. adjRect drawHighlight SelectionColor end.
adjRect registerRectLink command ; name
)

drawTocEntryChildrenColumn =: 4 : 0
NB. x xx yy width height
NB. y Table of Name ; Link/Command ; HeadingFlag
NB. Render the column in black, with headings in SectionColor
'xx yy width height' =. x
glclip xx , yy , (width - 10) , height
margin =. 5
rect =. (margin + xx) ,. (margin + yy + TocLineHeight * i. # y) ,"0 1 width , TocLineHeight
rect drawTocEntryChild"1 1 y
glclip 0 0 10000 10000
rect
)

setTocEntryForumMonthIndex =: 3 : 0
NB. y The month whose posts we'll display
TocEntryForumMonthIndex =: y
setTocEntryForumSubjectIndex 0
ForumSubjectScrollIndex =: 0
)

TocEntryForumYear =: 2023

setTocEntryForumYear =: 3 : 0
NB. y The year whose posts we'll display
TocEntryForumYear =: y
setTocEntryForumSubjectIndex 0
ForumSubjectScrollIndex =: 0
TocEntryForumMonthIndex =: 0
)

TocEntryForumSubjectIndex =: 0

setTocEntryForumSubjectIndex =: 3 : 0
NB. The index of the subject that's currently highlighted
TocEntryForumSubjectIndex =: y
ForumAuthorScrollIndex =: 0
setTocEntryForumAuthorIndex 0
)

TocEntryForumAuthorIndex =: 0

setTocEntryForumAuthorIndex =: 3 : 0
NB. The index of the author who's currently highlighted.
TocEntryForumAuthorIndex =: y
'year month subject author link' =. TocEntryForumAuthorIndex { ForumAuthorEntries
queueUrl ('https://www.jsoftware.com/pipermail/' , (}. ForumName) , '/' , (": year) , '-' , (> month { Months) , '/' , link , '.html') ; subject -. LF
)

ForumCacheTable =: '' NB. Year ; Month ; Subject ; Author ; Link
ForumCurrentName =: ''
ForumSubjectScrollIndex =: 0
ForumAuthorScrollIndex =: 0
ForumAuthorEntries =: ''  NB. Year ; Month ; Subject ; Author ; Link
ForumName =: ''
ForumYearBumpCount =: 0
ForumMonthBumpCount =: 0

drawTocEntryForum =: 4 : 0
NB. x The name of the forum
NB. y xx yy width height
NB. Display the contents of the forum
NB. drawScrollerField: x y width height ; strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
log 'drawTocEntryForum ' , x
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
ForumName =: x
'xx yy width height' =. y
if. -. ForumCurrentName -: x do. 
	result =. > {: sqlreadm__db 'select year, month, subject, author, link from forums where forumname = "' , x , '" order by year desc, month desc'
	ForumCacheTable =: 0 1 2 3 4 {"1 result
	ForumCurrentName =: x
	TocEntryForumYear =: 2023
	TocEntryForumSubjectIndex =: 0
	TocEntryForumMonthIndex =: 0
	ForumAuthorEntries =: ''
end.
margin =. 5
glclip 0 0 10000 100000
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
colWidth =. <. -: width - +: margin
colHeight =. height
subjRect =. (xx + margin + 100) , yy , colWidth, colHeight
authRect =. subjRect + (colWidth + margin) , 0 0 0
years =. \:~ ~. > {."1 ForumCacheTable
if. 0 = # years do. return. end.
months =. > ~. 1 {"1 ForumCacheTable #~ TocEntryForumYear = yyyy =. > {."1 ForumCacheTable
TocEntryForumMonthIndex =: TocEntryForumMonthIndex <. <: # months
timeLineHeight =. 20
month =. TocEntryForumMonthIndex { months
if. (xx > {. VocMouseXY) +. ({. VocMouseXY) > {. subjRect do. 
	ForumYearBumpCount =: 0 >. <: <. (({: VocMouseXY) - yy) % timeLineHeight
	ForumMonthBumpCount =: ForumYearBumpCount
end.
if. (xx < {. VocMouseXY) *. ({. VocMouseXY) < xx + 40 do. ForumMonthBumpCount =: 0 >. <: <. (({: VocMouseXY) - yy) % timeLineHeight end.
yearBumpArray =. (ForumYearBumpCount # 0) , 30 # 3 * timeLineHeight
monthBumpArray =. (ForumMonthBumpCount # 0) , 12 # 3 * timeLineHeight
yearOrigins =. (xx + margin) ,. ((# years) {. yearBumpArray) + yy + margin + timeLineHeight * i. # years
yearStrings =. '`'&, &. > _2&{. &. > ": &. > years
glrgb SectionColor
gltextcolor ''
glfont SectionFont
yearOrigins drawStringAt"1 1 > ": &. > <"0 yearStrings
monthStrings =. months { ShortMonths
monthOrigins =. (# months) {. <"1 (xx + margin + 45) ,. (12 {. monthBumpArray) + yy + margin + timeLineHeight * i. 12
monthOrigins drawStringAt &. > monthStrings
(<"1 yearRects =. (yearOrigins -"(1 1) _2 2) ,"(1 1) 30 , TocLineHeight) registerRectLink &. > '*setTocEntryForumYear '&, &. > ": &. > <"0 years
(<"1 monthRects =. (_2 + > monthOrigins) ,"(1 1) 40 , TocLineHeight) registerRectLink &. > '*setTocEntryForumMonthIndex '&, &. > ": &. > <"0 i. # months
((years i. TocEntryForumYear) { yearRects) drawHighlight SelectionColor
TocEntryForumMonthIndex =. TocEntryForumMonthIndex <. <: # months
(TocEntryForumMonthIndex { monthRects) drawHighlight SelectionColor
entries =. ForumCacheTable #~ (TocEntryForumYear = > {."1 ForumCacheTable) *. month = > 1 {"1 ForumCacheTable NB. entries: year ; month ; subject ; author ; link
if. 0 = # entries do. return. end.
subjects =: ~. 2 {"1 entries
ratios =. authorCounts % >./ authorCounts =. allSubjects #/. allSubjects =. 2 {"1 ForumCacheTable #~ (2 {"1 ForumCacheTable) e. subjects
NB. ratios =. authorCounts % >./ authorCounts =. > # &. > (2 {"1 entries) </. entries
subjects =. ~. allSubjects
subject =. TocEntryForumSubjectIndex { subjects 
ForumAuthorEntries =: e /: 4 {"1 e =. ForumCacheTable #~ (2 {"1 ForumCacheTable) = subject  NB. Check all posts since conversations may span months.
NB. smoutput '$ ForumAuthorEntries ; subject ; TocEntryForumAuthorIndex' ; ($ ForumAuthorEntries) ; subject ; TocEntryForumAuthorIndex
authors =. 3 {"1 ForumAuthorEntries
links =.   4 {"1 ForumAuthorEntries
subjectCommands =. '*setTocEntryForumSubjectIndex '&, &. > ": &. > <"0 i. # subjects
NB. authorUrls =. ('https://www.jsoftware.com/pipermail/' , (}. x) , '/' , (": TocEntryForumYear) , '-' , (> month { Months) , '/')&, &. > links
authorCommands =. '*setTocEntryForumAuthorIndex '&, &. > ": &. > <"0 i. # authors
ForumSubjectScrollIndex =: drawScrollerField subjRect ; subjects ; subjectCommands ; ratios ; (1 #~ # subjects) ; TocEntryForumSubjectIndex ; ForumSubjectScrollIndex
ForumAuthorScrollIndex =: drawScrollerField authRect ; authors ; authorCommands ; (0 #~ # authors) ; (0 #~ # authors) ; TocEntryForumAuthorIndex ; ForumAuthorScrollIndex
if. TocEntryForumAuthorIndex = 0 do. setTocEntryForumAuthorIndex 0 end.
glclip 0 0 10000 100000
)

setTocEntryChildCategoryIndex =: 3 : 0
NB. y Index of the category whose children should be displayed.
TocEntryChildCategoryIndex =: y
queueUrl (> TocEntryChildCategoryIndex { 1 {"1 TocEntryChildCategoryEntries) ; > TocEntryChildCategoryIndex { 0 {"1 TocEntryChildCategoryEntries
)

TocEntryChildScrollIndex =: 0
TocEntryChildCategoryIndex =: 0 NB. The index of the currenty-selected child category in the tree.
TocEntryChildCategoryEntries =: '' NB. Table of Title ; Link

drawTocEntryChildrenWithTree =: 4 : 0
NB. x Category id
NB. y xx yy width height entryY
NB. Render the descendants of x (category id) in xx yy width height.
NB. This is used when the child count is too high.  It renders a tree in the first column (drawaScrollerField)
NB. and the children of each node in the subsequent columns.
NB. getTocOutlineRailEntries returns table of level ; parentid ; categoryid ; category ; parentseq ; count ; link
NB. drawScrollerField: x y width height ; strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
categoryId =. x
NB. 'level parentId category parentSeq count link' =. TocOutlineRailSelectedIndex { 0 getTocOutlineRailEntries maxDepth
log 'drawTocEntryChildrenWithTree ' , (": parentId) , ' ' , category
NB. categoryId =. parentId getCategoryId category
tocWikiDocs =. getTocWikiDocs categoryId NB. Table of (level parent category parentSeq count link) ; (table of title ; link)
if. 1 = # $ tocWikiDocs do. '' return. end.
ratios =. counts % maxCount =. >./ counts =. > # &. > 1 {"1 tocWikiDocs
margin =. 5
categoryEntries =. > {."1 tocWikiDocs  NB. categoryEntries: table of level parent categoryid category parentSeq count link
NB. indents =. #&'  ' &. > &. <"0 levels - <./ levels =. > 0 {"1 categoryEntries
indents =. #&'  ' &. > <: &. > 0 {"1 categoryEntries
catTitles =. indents , &. > 3 {"1 categoryEntries
catLinks =. 6 {"1 categoryEntries
catHighlightFlags =. (-TocEntryChildCategoryIndex) |. 1 , 0 #~ <: # catTitles
cleanCategories =. ('''';'''''')&rxrplc &. > 1 {"1 catTitles
commandLinks =. ''''&, &. > ,&'''' &. > catLinks
commandCategories =. ,&'''' &. > ''''&, &. > cleanCategories
commands =. '*setTocEntryChildCategoryIndex '&, &. > <@":"0 i. # catLinks
categoryEntryList =. (<"0 catHighlightFlags) ,. catTitles ,. commands ,. <1 NB. Table of Highlight Flag ; Category ; Command ; Heading Flag
TocEntryChildCategoryIndex =: TocEntryChildCategoryIndex <. <: # catLinks
displayChildTable =. > TocEntryChildCategoryIndex { 1 {"1 tocWikiDocs  NB. Table of Title ; Link
TocEntryChildCategoryEntries =: catTitles ,. catLinks
entryList =. (< 0) ,. displayChildTable ,. <0
rowCount =. <. height % TocLineHeight
columnGroups =. (< categoryEntryList) , (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - xx) % width) * # columnGroups
fullSizeColCount =. <. width % MinColWidth
colWidth =. <. width % fullSizeColCount
compressedColWidth =. <. (width - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =: <"1 <. (xx + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
if. fullSizeColCount < # columnRects do.
	glrgb ColumnGuideColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
headerColumn =. > {. columnGroups
parms =. (> {. columnRects) ; (1 {"1 headerColumn) ; (2 {"1 headerColumn) ; ratios ; ((# headerColumn) # 1) ; TocEntryChildCategoryIndex ; TocEntryChildScrollIndex
TocEntryChildScrollIndex =: drawScrollerField parms
(}. columnRects) drawTocEntryChildrenColumn &. > }. columnGroups
''
)

TocEntryTagScrollIndex =: 0
TocEntryTagSubcatIndex =: 0

setTocEntryTagSubcatIndex =: 3 : 0
TocEntryTagSubcatIndex =: y
)

drawTocEntryTags =: 3 : 0
NB. y xx yy width height
NB. Render the immediate subcategories of *Tags in a scrollerField.  
NB. Render the sub-subcategories of the selected subcategory to the right with their pages.
NB. drawScrollerField: x y width height ; strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
margin =. 5
subcatEntries =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link, categoryid from categories where parentid = ' , ": TagHiddenCatId getCategoryId TagCatString
subcats =. 3 {"1 subcatEntries
subcatColWidth =. <. width % 3
detailX =. xx + subcatColWidth + margin
detailWidth =. width - subcatColWidth + margin
commandLinks =. '*setTocEntryTagSubcatIndex '&, &. > ": &. > <"0 i. # subcats
scrollEntries =. ((xx + margin) , (yy + margin) , subcatColWidth , height - +: margin) ; subcats ; commandLinks ; (0 #~ # subcats) ; (1 #~ # subcats) ; TocEntryTagSubcatIndex ; TocEntryTagScrollIndex
TocEntryTagScrollIndex =: drawScrollerField scrollEntries
parentId =. > 7 { TocEntryTagSubcatIndex { subcatEntries
tocWikiDocs =. getTocWikiDocs parentId  NB. (level parentid categoryid category parentSeq count link) ; table of title ; link
if. 0 = # tocWikiDocs do. '' return. end.
categoryEntries =. > {."1 tocWikiDocs
catLinkFlag =. (3 6 {"1 categoryEntries) ,. <1 NB. Category ; Link ; Heading Flag
documentTables =. {:"1 tocWikiDocs
titleLinkFlag =. ,.&(<0) &. > documentTables NB. Title ; Link ; Heading Flag
entryList =. (<0) ,. ; (<"1 catLinkFlag) , &. > titleLinkFlag
rowCount =. <. height % TocLineHeight
columnGroups =. (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - detailX) % detailWidth) * # columnGroups
fullSizeColCount =. <. (width - subcatColWidth) % MinColWidth
colWidth =. <. detailWidth % fullSizeColCount
compressedColWidth =. <. (detailWidth - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =. <"1 <. (detailX + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
if. fullSizeColCount < # columnRects do.
	glrgb ColumnGuideColor
	glbrush ''
	glpen 0
	w =. <. detailWidth % # columnRects
	glrect <. (detailX + selectedColumnIndex * w) , yy , w , height
end.
columnRects drawTocEntryChildrenColumn &. > columnGroups
)

drawTocEntryChildren =: 4 : 0
NB. x Category id
NB. y xx yy width height
NB. Render the descendants of the TocOutlineRailSelectedIndex category in xx yy width height.
NB. Use multiple columns if necessary.  If there are too many columns, invoke drawTocEntryChildrenWithTree.
NB. getTocOutlineRailEntries returns table of level ; parentid ; categoryid ; category ; parentseq ; count ; link
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
NB. 'level parentId category parentSeq count link' =. TocOutlineRailSelectedIndex { 0 getTocOutlineRailEntries maxDepth
NB. log 'drawTocEntryChildren ' , (": parentId) , ' ' , category
margin =. 5
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
tocWikiDocs =. getTocWikiDocs x NB. Table of (level parentid categoryid category parentSeq count link) ; table of title ; link
if. 0 = # tocWikiDocs do. '' return. end.
categoryEntries =. > {."1 tocWikiDocs
catLinkFlag =. (3 6 {"1 categoryEntries) ,. <1 NB. Category ; Link ; Heading Flag
documentTables =. {:"1 tocWikiDocs
titleLinkFlag =. ,.&(<0) &. > documentTables NB. Title ; Link ; Heading Flag
entryList =. (<0) ,. ; (<"1 catLinkFlag) , &. > titleLinkFlag
rowCount =. <. height % TocLineHeight
columnGroups =. (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - xx) % width) * # columnGroups
fullSizeColCount =. <. width % MinColWidth
colWidth =. <. width % fullSizeColCount
compressedColWidth =. <. (width - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =. <"1 <. (xx + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
if. (1 < # categoryEntries) *. (# columnRects) > 2 * fullSizeColCount do. 
	x drawTocEntryChildrenWithTree xx , yy , width , height
	''
	return.
end.
if. fullSizeColCount < # columnRects do.
	glrgb ColumnGuideColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
columnRects drawTocEntryChildrenColumn &. > columnGroups
''
)

TocOutlineRailSelectedIndex =: 0
TocOutlineRailScrollIndex =: 0

setTocOutlineRailSelectedIndex =: 3 : 0
NB. y The new value of the index
TocOutlineRailSelectedIndex =: y
entry =. y { 1 getTocOutlineRailEntries MaxTocDepth  NB. level ; parentid ; categoryid ; category ; parentseq ; count ; link
queueUrl (> 6 { entry) ; > 3 { entry
)

drawTocRail =: 4 : 0
NB. x xx yy w h
NB. y A level of the Toc hierarchy to which to display
NB. drawScrollerField: x y width height ; strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
'xx yy width height' =. x
entries =. 1 getTocOutlineRailEntries y NB. Table of level ; parentId ; categoryid ; category ; parentseq ; count ; link
maxCount =. >./ > 4 {"1 entries
indentStrings =. (#&'  ' &. > <: &. > 0 {"1 entries) , &. > 3 {"1 entries
linkCommands =. '*setTocOutlineRailSelectedIndex '&, &. > ": &. > <"0 i. # entries
parms =. x ; indentStrings ; linkCommands ; (maxCount %~ > 5 {"1 entries) ; (1 #~ # entries) ; TocOutlineRailSelectedIndex ; TocOutlineRailScrollIndex
TocOutlineRailScrollIndex =: drawScrollerField parms
entry =. TocOutlineRailSelectedIndex { entries
if.  +./ '*NuVoc' E. > 3 { entry do.
	setLayoutTemplate 'N'
	drawVoc ''
elseif. (getTopCategoryId ForumsCatString) = > 1 { entry do. NB. level ; parent ; categoryid ; category ; parentseq ; count ; link
	setLayoutTemplate 'D'
	(> 3 { entry) drawTocEntryForum DisplayDetailRect
elseif. TagCatString -: > 3 { entry do.
	setLayoutTemplate 'D'
	drawTocEntryTags DisplayDetailRect
elseif. (< SearchCatString) = 3 { entry do.
	setLayoutTemplate 'S'
	(SearchHiddenCatId getCategoryId SearchCatString) drawTocEntryChildrenWithTree DisplayDetailRect
NB. 	((SearchHiddenCatId getCategoryId SearchCatString) getCategoryId > 3 { entry) drawTocEntryChildren DisplayDetailRect
else.
	setLayoutTemplate 'D'
	categoryId =. (> 1 { entry) getCategoryId > 3 { entry
	categoryId drawTocEntryChildren DisplayDetailRect
end.
)

drawToc =: 3 : 0
DisplayListRect drawTocRail MaxTocDepth
)

NB. ======================= Table of Contents Data Management =====================
TocOutlineRailEntriesCache =: ,: a: , a:
WikiDocsCache =: ,: a: , a:

TocWikiDocsCategory =: ''
TocWikiDocsEntries =: ''

visitedRailEntries =: '' NB. Boxed IDs.

recurseGetTocOutlineRailEntries =: 4 : 0
NB. x A parent id
NB. y A depth.  
NB. Terminate cycles.
if. y = 0 do. '' return. end.
if. (# visitedRailEntries) > visitedRailEntries i. (< x) do. '' return. end.  NB. Terminate cycles.
visitedRailEntries =: visitedRailEntries , < x
parentId =. x
entries =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link from categories where parentid = ' , (": parentId) , ' order by parentseq'
NB. childIds =. parentId&getCategoryId &. > 2 {"1 entries
childIds =. 2 {"1 entries
NB. entries =. ({."1 entries) ,. parents ,. 2 3 4 5 {"1 entries
; (<"0<"1 entries) , &. > recurseGetTocOutlineRailEntries&(<: y) &. > childIds
)

getTocOutlineRailEntries =: 4 : 0
NB. x A parent category id
NB. y Depth to which to go in the TOC hierarchy
NB. Return level ; parentid ; category ; parentseq ; count ; link
NB. Take account of the parentseq number when ordering the entries.
NB. Terminate cycles.
key =. < (": x) , 'DDD' , ": y
if. (# TocOutlineRailEntriesCache) > index =. (0 {"1 TocOutlineRailEntriesCache) i. key do.
	result =. > index { 1 {"1 TocOutlineRailEntriesCache
else.
	visitedRailEntries =: ''
	result =: > x recurseGetTocOutlineRailEntries y
NB. 	if. x = 0 do. result =. }. result end.
	if. 0 = # result do.
		result =. ''
	else.
NB. 		result =. (> tagCatId&~: &. > 1 {"1 rawResult) # rawResult  NB. Drop the child categories of *Tags.
		TocOutlineRailEntriesCache =: TocOutlineRailEntriesCache , key , < result
	end.
end.
result
)

getTocWikiDocs =: 3 : 0
NB. y A category id
NB. Return the subtree TOC from the categories table with a set of wiki documents for each entry.
NB. Return table of (level parentid categoryid category parentSeq count link) ; table of title ; link
key =. < y
if. (# WikiDocsCache) > index =. (0 {"1 WikiDocsCache) i. key do.
	result =. > index { 1 {"1 WikiDocsCache
else.
	entries =. y getTocOutlineRailEntries 100
	if. 0 = # entries do.
		NB. The category is not a parent.
		entry =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link from categories where categoryid = ' , ": y
		wikiDocs =. > {: sqlreadm__db 'select title, link from wiki where categoryid = ' , ": y
		result =. (< entry) , < wikiDocs
	else.
		categories =. 3 {"1 entries
		parentIds =. 1 {"1 entries
		categoryIds =. parentIds getCategoryId &. > categories
		result =. (<"1 entries) ,. >@{: &. > sqlreadm__db &. > 'select title, link from wiki where categoryid = '&, &. > ": &. > categoryIds
	end.
	WikiDocsCache =: WikiDocsCache , key , < result
end.
result
)

clearCache =: 3 : 0
TocOutlineRailEntriesCache =: ,: a: , a:
WikiDocsCache =: ,: a: , a:
)

NextUserCatId =: 0

nextUserCatId =: 3 : 0
NB. y Number of ids needed
if. NextUserCatId = 0 do.
	result =. , > > {: sqlreadm__db 'select max(categoryid) from categories where categoryid >= 1000000' 
	if. 'NULL' -: result do. base =: 1000000 else. base =: >: {. result end.
else.
	base =: NextUserCatId
end.
ids =. base + i. y
NextUserCatId =: base + y
ids
)

getCategory =: 3 : 0
NB. y Category Id
NB. Return the category string, empty string if none.
result =. > {: sqlreadm__db 'select category from categories where categoryid = ' , ": y
if. 0 = # result do. '' else. > , > result end.
)

getCategoryIdNoParent =: 3 : 0
NB. y Category string
NB. Return the id or _1.
result =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '"'
if. 0 = # result do. _1 else. > , > result end.
)

getCategoryId =: 4 : 0
NB. x Parent id
NB. y Category name (category names are guaranteed to be unique)
NB. Return the categoryid of the category
if. x < 0 do. _1 return. end.
result =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '" and parentid = ' , ": x
if. 0 = # result do. 
	smoutput 'getCategoryId _1 for' ; x ; y
	_1
else. 
	{. , > result 
end.  NB. {. to force it to a scalar shape.
)

getTopCategoryId =: 3 : 0
NB. y Category name
1 getCategoryId y
)

getParentId =: 3 : 0
NB. y Category id
NB. Return the categoryid of the category's parent.
, > , > {: sqlreadm__db 'select parentid from categories where categoryid = ' , ": y
)
NB. ==================== End Table of Contents ====================

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
	if. 0 = +/ sieve do. break. end. NB. Abort--not enough horizontal area for any of the remaining tokens.
end.
(>./ lineWidths) , CellLineHeight * # lineWidths
)

calcRowDimensions =: 3 : 0
NB. y A row of boxed tokens
NB. Return the height and column widths of the row.
dimensions =. > calcCellDimensions &. > y
(>./ {:"1 dimensions) , {."1 dimensions
)

drawVocEntry =: 4 : 0
NB. x An entry from VocTable: Group POS Row Glyph MonadicRank Label DyadicRank Link
NB. y centerOrigin (x and y)
'xx yy' =. y
'monadic label dyadic link' =. 4 5 6 7 { x
s =. monadic , ' ' , label , ' ' , dyadic
width =. {. glqextent s
leftX =. <. xx - -: width
glfont VocValenceFont
glrgb 0 0 255
gltextcolor ''
(leftX , yy) drawStringAt s
((leftX - 4) , (yy - 1) , (width + 8) , 20) registerRectLink link ; label
NB. end.
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
(xStart , yStart , width , height) registerRectLink '*selectVocGlyph ''' , glyph , ''''
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
spacings =. 3 * ~: lineNumbers
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

selectVocGlyph =: 3 : 0
NB. y A glyph
VocSelectedGlyph =: , y
entry =. VocTable {~ (3 {"1 VocTable) i. < VocSelectedGlyph
queueUrl n =: (> 7 { entry) ; > 5 { entry
)

drawVoc =: 3 : 0
glrgb 255 255 255
glbrush ''
glrect DisplayDetailRect
((20 + {. DisplayDetailRect) , 5) drawVocSections 0 1 2 3 4 5 6
((300 + {. DisplayDetailRect) , 5) drawVocSections 7 8 9 10 11
)
NB. ============================= End Voc ===============================

FrameTimeStamps =: ''

getFrameRate =: 3 : 0
FrameTimeStamps =: (t =. (6!:1) '' ) , FrameTimeStamps
fps =. # FrameTimeStamps =: FrameTimeStamps #~ (t - 1) < FrameTimeStamps
NB. glfont 'arial bold 24'
NB. glrgb HighlightColor
NB. gltextcolor ''
NB. 10 0 drawStringAt (": fps) , ' fps'
)

go =: 3 : 0
dbOpenDb ''
loadVoc ''
buildForm ''
layoutForm ''
loadHistoryMenu ''
wd 'pshow'
)