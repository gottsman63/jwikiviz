cocurrent 'jwikiviz'

clear ''

load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'gl2'
coinsert 'jgl2'
NB. A Items
NB. Can I force update of gethttp?  Raul's email...
NB. Bob's approach to Forums.
NB. Forum browsing really doesn't work on a small screen.
NB. Packaging an add-on
NB. Use browse_j_
NB. Must I delete the targetDB?
NB. Static for search or a default string
NB. Create a shortcut option
NB. What happens when gethttp fails during the --head check?
NB. Win default (not frozen) dimensions...how?

NB. B Items
NB. Fix use of sqlreadm__db
NB. Animated webview transition...?
NB. Support parallel download of forum and wiki documents.
NB. Add a "Search" label.
NB. Fix the extra "quotes in NuVoc
NB. Spider the Vocabulary--don't use the spreadsheet.

NB. ============= Database ===============
db =: ''
stageDbFile =: 'jwikiviz.stage.db'
stageDbPath =: jpath '~temp/' , stageDbFile
targetDbPath =: jpath '~temp/jwikiviz.db'
curlTracePath =: jpath '~temp/jwikiviz.trace'

clearTrace =: 3 : 0
'' (1!:2) < tracePath
)

trace =: 3 : 0
LF (1!:3) < tracePath
y (1!:3) < tracePath
)

dbError =: 3 : 0
sqlerror__db ''
)

dbOpenDb =: 3 : 0
try.
	db =: sqlopen_psqlite_ targetDbPath
catcht.
	smoutput 'Error opening database'
end.
)

log =: 3 : 0
if. -. LogFlag do. return. end.
sqlinsert__db 'log' ; (;: 'datetime msg') ; < ((6!:0) 'YYYY MM DD hh mm sssss') ; y
if. 0 = ? 200 do.
	max =. , > > {: sqlreadm__db 'select max(rowid) from log'
	sqlcmd__db 'delete from log where rowid < ' , ": 0 >. max - 1000
end.
)

clearLog =: 3 : 0
sqlcmd__db 'delete from log'
)

initAdmin =: 3 : 0
sqlupsert__db 'admin' ; 'key' ; (;: 'key value') ; < 'qscreen' ; wd 'qscreen'
sqlupsert__db 'admin' ; 'key' ; (;: 'key value') ; < 'JVERSION' ; JVERSION
)
NB. =======================================

NB. ==================== Form =====================
VocMouseXY =: 0 0
VocMouseClickXY =: 0 0

buildForm =: 3 : 0
log 'buildForm'
wd 'pc vizform;'
wd 'bin h;'
wd   'bin v;'
wd     'bin h;'
wd       'cc clearSearches button;cn Clear *Searches;'
wd       'cc searchBox edit;'
wd       'cc logcheck checkbox;cn Debug (Log);'
wd     'bin z'
wd     'cc vocContext isigraph;'
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

layoutForm =: 3 : 0
log 'layoutForm'
'w h' =. ". wd 'getp wh'
winW =. w - 40
winH =. h - 45
controlHeight =. 30
vocContextHeight =. winH >. 760
if. EmphasizeBrowserFlag do.
	vocContextWidth =. 175
	browserWidth =. winW - vocContextWidth
	wd 'set clearSearches maxwh ' , (": (vocContextWidth * 0.15) , controlHeight) , ';'
	wd 'set searchBox maxwh ' , (": (vocContextWidth * 0.65) , controlHeight) , ';'
	wd 'set logcheck maxwh ' , (": (vocContextWidth * 0.15) , controlHeight) , ';'
	wd 'set vocContext maxwh ' , (": <. vocContextWidth , vocContextHeight) , ';'
	wd 'set bookmark maxwh ' , (": <. (browserWidth * 0.15), controlHeight) , ';'
	wd 'set history maxwh ' , (": <. (browserWidth * 0.6) , controlHeight) , ';'
	wd 'set launch maxwh ' , (": <. (browserWidth * 0.15) , controlHeight) , ';'
	wd 'set browser maxwh ' , (": (<. browserWidth) , winH - controlHeight) , ';'
else.
	vocContextWidth =. <. 825 >. winW % 2
	browserWidth =. winW - vocContextWidth
	wd 'set clearSearches maxwh ' , (": <. (vocContextWidth * 0.15) , controlHeight) , ';'
	wd 'set searchBox maxwh ' , (": (vocContextWidth * 0.65) , controlHeight) , ';'
NB. 	wd 'set scrollConfig maxwh ' , (": (vocContextWidth * 0.35) , controlHeight) , ';'
	wd 'set logcheck maxwh ' , (": (vocContextWidth * 0.15) , controlHeight) , ';'
	wd 'set vocContext maxwh ' , (": <. vocContextWidth , vocContextHeight) , ';'
	wd 'set bookmark maxwh ' , (": <. (browserWidth * 0.15), controlHeight) , ';'
	wd 'set history maxwh ' , (": <. (browserWidth * 0.6) , controlHeight) , ';'
	wd 'set launch maxwh ' , (": <. (browserWidth * 0.15) , controlHeight) , ';'
	wd 'set browser maxwh ' , (": (<. browserWidth) , winH - controlHeight) , ';'
	wd 'set browser minwh 100 50;'
end.
wd 'timer 100'
)

emphasizeBrowser =: 3 : 0
'w h' =. ". wd 'getp wh'
if. w > 1500 do. return. end. 
EmphasizeBrowserFlag =: 1
layoutForm ''
)

deemphasizeBrowser =: 3 : 0
EmphasizeBrowserFlag =: 0
layoutForm ''
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
log 'vizform_close'
wd 'timer 0'
wd 'pclose'
)

vizform_bookmark_button =: 3 : 0
log 'vizform_bookmark_button'
bookmark ''
invalidateDisplay ''
)

vizform_clearSearches_button =: 3 : 0
log 'vizform_clearSearches_button'
clearSearches ''
invalidateDisplay ''
)

vizform_logcheck_button =: 3 : 0
LogFlag =: ". logcheck
smoutput LogFlag
)

vizform_vocContext_mmove =: 3 : 0
NB. Give the user the chance to get the mouse over to the webview without activating another link.
if. 1 > ((6!:1) '') - SuppressMouseHandlingStart do. return. end.
log 'vizform_vocContext_mmove'
if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do. return. end.
VocMouseXY =: 0 1 { ". > 1 { 13 { wdq
deemphasizeBrowser ''
invalidateDisplay ''
)

vizform_vocContext_mblup =: 3 : 0
log 'vizform_vocContext_mblup'
VocMouseClickXY =: 0 1 { ". > 1 { 13 { wdq
invalidateDisplay ''
)

vizform_vocContext_paint =: 3 : 0
trigger_paint ''
)

vizform_browser_curl =: 3 : 0
log 'vizform_browser_curl'
url =. > (1 {"1 wdq) {~ ({."1 wdq) i. < 'browser_curl'
topHistoryUrl =. > 0 { 0 { getHistoryMenu ''
if. -. +./ topHistoryUrl E. url do. addToHistoryMenu url ; url end.
resetBookmarkButton ''
)

vizform_mmove =: 3 : 0
deemphasizeBrowser ''
)

vizform_searchBox_button =: 3 : 0
log 'vizform_searchBox_button'
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
log 'vizform_history_select'
loadPage (". history_select) { getHistoryMenu ''
)

vizform_launch_button =: 3 : 0
log 'vizform_launch_button ' , ": > 0 { 0 { getHistoryMenu ''
browse_j_ > 0 { 0 { getHistoryMenu ''
)

PerpetuateAnimationStartTime =: 0

sys_timer_z_ =: 3 : 0
log_jwikiviz_ 'sys_timer_z_'
try.
NB. 	checkQueuedUrlTime_base_ ''
	if. 4 > ((6!:1) '') - PerpetuateAnimationStartTime_jwikiviz_ do. invalidateDisplay_jwikiviz_ '' end.
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
DisplayListRect =: 0 0 175 , h
DisplayDetailRect =: 175 0 , (w - 175) , h
)

trigger_paint =: 3 : 0
log 'trigger_paint ' , (wd 'getp wh') , '   ' , (": getFrameRate '') , ' fps'
try.
glfill BackgroundColor , 255
'w h' =. ". wd 'getp wh'
if. (w < 200) +. h < 200 do.
	log 'trigger_paint--dimensions too small.  Aborting.'
	return.
end.
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
log 'deleteCategoryIdAndDescendants ' , ": y
if. y < 0 do. return. end.
childIds =. > {: sqlreadm__db 'select categoryid from categories where parentid = ' , ": y
deleteCategoryIdAndDescendants &. > childIds
sqlcmd__db 'delete from categories where categoryid = ' , ": y
sqlcmd__db 'delete from wiki where categoryid = ' , ": y
)

deleteCategoryIdDescendantsOnly =: 3 : 0
log 'deleteCategoryIdDescendantsOnly ' , ": y
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
log 'clearSearch ' , y
termId =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '" AND parentid = ' , ": SearchHiddenCatId getCategoryId SearchCatString
deleteCategoryIdAndDescendants (SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y
deleteCategoryIdAndDescendants (getTopCategoryId SearchCatString) getCategoryId y
clearCache ''
)

addSearchToToc =: 3 : 0
NB. y A search string
NB. Save parent ; child.  
log 'addSearchToToc ' , ": y
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
url =. 'https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=5000&offset=0&profile=default&search=' , urlencode y
html =. gethttp url
pat =. rxcomp 'mw-search-result-heading''><a href="([^"]+)" title="([^"]+)"'
offsetLengths =.  pat rxmatches html
wikiId =. ((SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Wiki'
log '...received ' , (": # html) , ' bytes with ' , (": # offsetLengths) , ' hits.'
if. 0 = # offsetLengths do.
	sqlupdate__db 'categories' ; ('categoryid = ' , ": wikiId) ; ('count' ; 'level') ; < 0 ; 2
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
	sqlupdate__db 'categories' ; ('categoryid = ' , ": wikiId) ; ('count' ; 'level') ; < (# titles) ; 3
end.
# offsetLengths
)

searchForums =: 3 : 0
NB. y Search term		
NB. Perform the search, parse the results, and update the "categories" and "wiki" tables.
try.
log 'Searching forums for ' , y , '...'
wikiCols =. ;: 'title categoryid link'
NB. html =. (2!:0) 'curl "https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2030"'
url =.'https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2100&blk=5000'
html =. gethttp url
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
	for_index. i. # titleGroups do.
		fname =. > index { ~. forums
		forumLinks =. > index { linkGroups
		forumTitles =. > index { titleGroups
		cols =. (;: 'level parentid categoryid category parentseq count link')
		data =. 3 ; termId ; (nextUserCatId 1) ; fname ; (>: index) ; (# forumLinks) ; 'https://www.jsoftware.com/mailman/listinfo/' , }. fname
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
log 'search ' , y
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
log 'selectSearch'
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
SectionFont =: 'arial bold 16'

BackgroundColor =: 255 255 255
SectionColor =: 0 0 0
LabelColor =: 0 102 204
ColumnGuideColor =: 245 253 198
SelectionColor =: 0 0 0
HoverColor =: 255 0 0 
BarColor =: 245 195 150

NB. BackgroundColor =: 148 210 189
NB. SectionColor =: 155 34 38
NB. LabelColor =: 0 18 25
NB. ColumnGuideColor =: 10 147 150
NB. SelectionColor =: 0 95 115
NB. BarColor =: 233 216 166

NB. BackgroundColor =: 255 255 255
NB. SectionColor =: 238 170 170
NB. LabelColor =: 0 0 0
NB. ColumnGuideColor =: 204 238 255
NB. SelectionColor =: 0 0 0
NB. BarColor =: 238 170 170

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
QueuedUrl =: ''
QueuedUrlTime =: 0
SuppressMouseHandlingStart =: 0
PageLoadFreezeTime =: 0
PageLoadFreezeRect =: ''
PageLoadFreezeDuration =: 3
MWheelOffset =: 0
EmphasizeBrowserFlag =: 0
LogFlag =: 0
ScrollConfig =: 2
UploadAcct =: '12a1yBS'

getTocFontForLevel =: 3 : 0
NB. y An integer level in an outline hierarchy.  _1 indicates a page; 0..n indicates a level.
NB. Return the string specification of the font to use.
if. y < 0 do. 'arial 13' return. end.
fonts =. 'arial bold 15' ; 'arial bold 13' ; 'arial 13'
> (y <. <: # fonts) { fonts
)

getTocColorForLevel =: 3 : 0
NB. y An integer level in an outline hierarchy.  _1 indicates a page; 9..n indicates a level.
NB. Return a color for the text.
if. 0 > y do. LabelColor else. SectionColor end.
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
log 'resetBookmarkButton'
'url title' =. {. getHistoryMenu ''
links =. , > {: sqlreadm__db 'select link from wiki where categoryId = ' , ": getTopCategoryId BookmarkCatString
if. isBookmarked url do. wd 'set bookmark text "Un-bookmark";' else. wd 'set bookmark text "Bookmark";' end.
)

bookmark =: 3 : 0
log 'bookmark'
'url title' =. {. getHistoryMenu ''
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

queueUrl =: 3 : 0
NB. y A url to queue for delayed loading ; A title
log 'queueUrl ' , (0 {:: y) , ' ' , 1 {:: y
NB. if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do. return. end.
QueuedUrl =: y
QueuedUrlTime =: (6!:1) ''
loadPage QueuedUrl
)

addToHistoryMenu =: 3 : 0
NB. y Label ; Link
log 'addToHistoryMenu ' , (0 {:: y) , ' ' , 1 {:: y
if. y -: '' do. return. end.
loadHistoryMenu ''
if. HistoryMenu -: '' do. HistoryMenu =: ,: y else. HistoryMenu =: ~. y , HistoryMenu end.
s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
wd 'set history items *' , s
wd 'set history select 0'
HistoryMenu =: (30 <. # HistoryMenu) {. HistoryMenu
sqlcmd__db 'delete from history'
sqlinsert__db 'history' ; (;: 'label link') ; < ({:"1 HistoryMenu) ; < {."1 HistoryMenu
)

loadHistoryMenu =: 3 : 0
log 'loadHistoryMenu'
HistoryMenu =: > {: sqlreadm__db 'select link, label from history'
s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
wd 'set history items *' , s
wd 'set history select 0'
)

getHistoryMenu =: 3 : 0
if. HistoryMenu -: '' do. loadHistoryMenu '' end.
HistoryMenu
)

HistoryMenu =: '' NB. Table of Title ; Link
LastUrlLoaded =: ''

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
if. url -: LastUrlLoaded do. return. end.
LastUrlLoaded =: url
log 'Loading url ' , url
wd 'set browser url *' , url
addToHistoryMenu (< url) , {: y
catch.
	smoutput (13!:12) ''
end.
)

NB. ======================== Mouse-Sensitive Areas ===========================
isFrozen =: 3 : 0
PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime
)

registerRectLink =: 4 : 0
NB. x xx yy width height
NB. y A url or * to be evaluated ; a title ; loadMode (0 indicates hover, 1 indicates click)
NB. Record this for mouse processing: highlighting and loading urls.
NB. Note that since we're frame-based, we re-register rect/links on every frame.  So we 
NB. just check immediately to see whether the mouse is inside the rect and activate accordingly.
'urlCommand name loadMode' =. y
if. isFrozen '' do. 0 return. end.
if. -. VocMouseXY pointInRect x do. 0 return. end.
x drawReversibleSelection HoverColor
if. loadMode = 0 do.
	if. '*' = {. urlCommand do.
		". }. urlCommand
NB.		invalidateDisplay ''
	else. 
		queueUrl urlCommand ; name
	end.
elseif. VocMouseClickXY pointInRect x do.
	emphasizeBrowser ''
	if. '*' = {. urlCommand do.
		". }. urlCommand
NB.		invalidateDisplay ''
	else. 
		queueUrl urlCommand ; name
	end.
end.
if. VocMouseClickXY pointInRect x do.
	PageLoadFreezeTime =: (6!:1) ''
	SuppressMouseHandlingStart =: PageLoadFreezeTime
	PageLoadFreezeRect =: x
	emphasizeBrowser ''
end.
0
)

drawReversibleSelection =: 4 : 0
NB. x xx yy width height
NB. y color
NB. Draw an outline around xx yy width height.  Remember it so it can be erased later.
x drawHighlight y
NB. if. ReversibleSelections -: '' do. ReversibleSelections =: ,: x else. ReversibleSelections =: ReversibleSelections , x end.
)

drawPageLoadFreezeRect =: 3 : 0
if. isFrozen '' do.
	glrgb PageFreezeColor
	glpen 5
	glrgba 0 0 0 0
	glbrush ''
	glrect PageLoadFreezeRect
end.
)
NB. ============================== Scroller Field ===============================
drawScrollerField =: 4 : 0
NB. x xx yy width height
NB. y strings ; links ; ratios ; levels ; selectedIndex ; scrollIndex ; loadMode
NB. The "levels" indicate indention (0...n).  A level of _1 indicates that it's a page link, not a heading.
NB. Draw the strings and registerRectLink to highlight them and load pages.
NB. Use VocMouseXY to update scrollOffset and selectedIndex.
NB. Return the scrollIndex, which may have changed.
NB. Scroll/Select Configurations
NB.    (1) Simultaneous scroll/select, full width.
NB.    (2) Left mouse scroll, right select.
NB.    (3) Left mouse scroll, right numb.
NB.    (4) Two-finger scroll, mouse select, full width.
log 'drawScrollerField ' , (": x)
rect =. x
'strings links ratios levels selectedIndex scrollIndex loadMode' =. y
'xx yy w h' =. rect
window =. <. TocLineHeight %~ -: h
maxLineCount =. <. h % TocLineHeight
margin =. 5
NB. glfont TocFont
if. VocMouseXY pointInRect xx , yy , (-: w) , h do.
	scrollIndex =. 0 >. (window -~ # strings) <. <. (-: window) -~ (# strings) * (yy -~ {: VocMouseXY) % h
end.	
windowStartIndex =. scrollIndex NB. <. 0 >. (# strings) <. 0 >. scrollIndex - -: window
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
if. (ScrollConfig = 1) +. ScrollConfig = 2 do.
	glrgb ColumnGuideColor
	glbrush ''
	glpen 0
	glrect xx , yy , (<. -: w) , h
end.
scrollBarHeight =. <. h * window % # strings
scrollBarOffset =. <. h * scrollIndex % # strings
if. maxLineCount < # strings do.
	glrgb 3 # 200
	glbrush ''
	glpen 0
	glrect (xx + w - thickness) , scrollBarOffset , (thickness =. 10) , scrollBarHeight
end.
for_i. i. # strings do.
	lineHeight =. i { heights
	origin =. > i { origins
	glrgb BarColor
	glbrush ''
	glpen 0
	if. 0 < i { ratios do. glrect (origin - margin , 0) , (<. (w - margin) * i { ratios) , lineHeight - 4 end.
	glfont getTocFontForLevel i { levels
	glrgb getTocColorForLevel i { levels
	glbrush ''
	gltextcolor''
	glclip xx , yy ,  w , h
	if. lineHeight >: TocLineHeight do. (> i { origins) drawStringAt > i { strings end.
	if. i = selectedIndex do. ((origin - margin , 0) , w , lineHeight) drawHighlight SelectionColor end.
	if. VocMouseXY pointInRect xx , yy , (-: w) , h do. ((origin - margin , 0), w, lineHeight) registerRectLink (> i { links) ; (> i { strings) ; loadMode end.		
end.
glclip 0 0 10000 100000
scrollIndex
)
NB. ======================= Draw the TOC =========================
drawTocEntryChild =: 4 : 0
NB. x xx yy maxWidth height
NB. y Highlight Flag ; Name ; Link/Command ; Level
'xx yy maxWidth height' =. x
'highlightFlag name command level' =. y
glrgb getTocColorForLevel level
gltextcolor ''
glfont getTocFontForLevel level
(xx , yy) drawStringAt name
adjRect =. xx , yy , (maxWidth - 16) , height
if. highlightFlag do. adjRect drawHighlight SelectionColor end.
adjRect registerRectLink command ; name ; 0
)

drawTocEntryChildrenColumn =: 4 : 0
NB. x xx yy width height
NB. y Table of Name ; Link/Command ; Level
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
NB. y The index of the subject that's currently highlighted
TocEntryForumSubjectIndex =: y
ForumAuthorScrollIndex =: 0
setTocEntryForumAuthorIndex 0
)

TocEntryForumAuthorIndex =: 0

setTocEntryForumAuthorIndex =: 3 : 0
NB. Ty he index of the author who's currently highlighted.
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
NB. x y width height drawScrollerField strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
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
yearStrings =: '`',. _2 {."1 ": ,.years
glrgb SectionColor
gltextcolor ''
glfont SectionFont
yearOrigins drawStringAt"1 1 > ": &. > <"0 yearStrings
monthStrings =. months { ShortMonths
monthOrigins =. (# months) {. <"1 (xx + margin + 45) ,. (12 {. monthBumpArray) + yy + margin + timeLineHeight * i. 12
monthOrigins drawStringAt &. > monthStrings
rects1 =. (<"1 yearRects =. (yearOrigins -"(1 1) _2 2) ,"(1 1) 30 , TocLineHeight) 
yearCommands =: '*setTocEntryForumYear '&, &. > ": &. > <"0 years
rects1 registerRectLink &. > <"1 yearCommands ,"0 1 ' ' ; 0
rects2 =. (<"1 monthRects =. (_2 + > monthOrigins) ,"(1 1) 40 , TocLineHeight) 
monthCommands =. '*setTocEntryForumMonthIndex '&, &. > ": &. > <"0 i. # months
rects2 registerRectLink &. > <"1 monthCommands ,"0 1 ' ' ; 0
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
NB. links =.   4 {"1 ForumAuthorEntries
subjectCommands =. '*setTocEntryForumSubjectIndex '&, &. > ": &. > <"0 i. # subjects
NB. authorUrls =. ('https://www.jsoftware.com/pipermail/' , (}. x) , '/' , (": TocEntryForumYear) , '-' , (> month { Months) , '/')&, &. > links
authorCommands =. '*setTocEntryForumAuthorIndex '&, &. > ": &. > <"0 i. # authors
ForumSubjectScrollIndex =: subjRect drawScrollerField subjects ; subjectCommands ; ratios ; (2 #~ # subjects) ; TocEntryForumSubjectIndex ; ForumSubjectScrollIndex ; 0
ForumAuthorScrollIndex =: authRect drawScrollerField  authors ; authorCommands ; (0 #~ # authors) ; (_1 #~ # authors) ; TocEntryForumAuthorIndex ; ForumAuthorScrollIndex ; 0
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
NB. x y width height drawScrollerField strings ; links ; ratios ; levels ; selectedIndex ; scrollIndex
log 'drawTocEntryChildrenWithTree ' , (": x) , ' ' , ": y
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
categoryId =. x
tocWikiDocs =. getTocWikiDocs categoryId NB. Table of (level parent category parentSeq count link) ; (table of title ; link)
if. 1 = # $ tocWikiDocs do. '' return. end.
ratios =. counts % maxCount =. >./ counts =. > # &. > 1 {"1 tocWikiDocs
margin =. 5
categoryEntries =. > {."1 tocWikiDocs  NB. categoryEntries: table of level parent categoryid category parentSeq count link
indents =. #&'  ' &. > <: &. > 0 {"1 categoryEntries
levels =. (] - <./) > {."1 categoryEntries
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
entryList =. (< 0) ,. displayChildTable ,. <_1
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
parms =. (1 {"1 headerColumn) ; (2 {"1 headerColumn) ; ratios ; levels ; TocEntryChildCategoryIndex ; TocEntryChildScrollIndex ; 0
TocEntryChildScrollIndex =: (> {. columnRects) drawScrollerField parms
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
NB. x y width height drawScrollerField strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
log 'drawTocEntryTags ' , ": y
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
margin =. 5
subcatEntries =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link, categoryid from categories where parentid = ' , ": TagHiddenCatId getCategoryId TagCatString
subcats =. 3 {"1 subcatEntries
subcatColWidth =. <. width % 3
detailX =. xx + subcatColWidth + margin
detailWidth =. width - subcatColWidth + margin
commandLinks =. '*setTocEntryTagSubcatIndex '&, &. > ": &. > <"0 i. # subcats
scrollEntries =. subcats ; commandLinks ; (0 #~ # subcats) ; (2 #~ # subcats) ; TocEntryTagSubcatIndex ; TocEntryTagScrollIndex ; 0
TocEntryTagScrollIndex =: ((xx + margin) , (yy + margin) , subcatColWidth , height - +: margin) drawScrollerField scrollEntries
parentId =. > 7 { TocEntryTagSubcatIndex { subcatEntries
tocWikiDocs =. getTocWikiDocs parentId  NB. (level parentid categoryid category parentSeq count link) ; table of title ; link
if. 0 = # tocWikiDocs do. '' return. end.
categoryEntries =. > {."1 tocWikiDocs
catLinkFlag =. (3 6 {"1 categoryEntries) ,. <1 NB. Category ; Link ; Heading Flag
documentTables =. {:"1 tocWikiDocs
titleLinkLevel =. ,.&(<_1) &. > documentTables NB. Title ; Link ; Level
entryList =. (<0) ,. ; (<"1 catLinkFlag) , &. > titleLinkLevel
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
log 'drawTocEntryChildren ' , (": x) , ' ' , ": y
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
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
titleLinkLevel =. ,.&(<_1) &. > documentTables NB. Title ; Link ; Level
entryList =. (<0) ,. ; (<"1 catLinkFlag) , &. > titleLinkLevel
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
NB. (x y width height) drawScrollerField strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
log 'drawTocRail ' , (": x) , ', ' , ": y
'xx yy width height' =. x
entries =. 1 getTocOutlineRailEntries y NB. Table of level ; parentId ; categoryid ; category ; parentseq ; count ; link
levels =. (] - <./) > 0 {"1 entries
maxCount =. >./ > 4 {"1 entries
indentStrings =. (#&'  ' &. > <: &. > 0 {"1 entries) , &. > 3 {"1 entries
linkCommands =. '*setTocOutlineRailSelectedIndex '&, &. > ": &. > <"0 i. # entries
parms =. indentStrings ; linkCommands ; (maxCount %~ > 5 {"1 entries) ; levels ; TocOutlineRailSelectedIndex ; TocOutlineRailScrollIndex ; 0
TocOutlineRailScrollIndex =: x drawScrollerField parms
if. EmphasizeBrowserFlag do. return. end.
entry =. TocOutlineRailSelectedIndex { entries
if.  +./ '*NuVoc' E. > 3 { entry do.
	drawVoc ''
elseif. (getTopCategoryId ForumsCatString) = > 1 { entry do. NB. level ; parent ; categoryid ; category ; parentseq ; count ; link
	(> 3 { entry) drawTocEntryForum DisplayDetailRect
elseif. TagCatString -: > 3 { entry do.
	drawTocEntryTags DisplayDetailRect
elseif. (< SearchCatString) = 3 { entry do.
	(SearchHiddenCatId getCategoryId SearchCatString) drawTocEntryChildrenWithTree DisplayDetailRect
else.
	categoryId =. (> 1 { entry) getCategoryId > 3 { entry
	categoryId drawTocEntryChildren DisplayDetailRect
end.
)

drawToc =: 3 : 0
log 'drawToc'
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
NB. y A depth
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
log 'getTocOutlineRailEntries ' , (": x) , ', ' , ": y
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
log 'getTocWikiDocs ' , ": y
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
log 'clearCache'
TocOutlineRailEntriesCache =: ,: a: , a:
WikiDocsCache =: ,: a: , a:
)

NextUserCatId =: 0

nextUserCatId =: 3 : 0
NB. y Number of ids needed
log 'nextUserCatId ' , ": y
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
log 'getCategory ' , ": y
result =. > {: sqlreadm__db 'select category from categories where categoryid = ' , ": y
if. 0 = # result do. '' else. > , > result end.
)

getCategoryIdNoParent =: 3 : 0
NB. y Category string
NB. Return the id or _1.
log 'getCategoryIdNoParent ' , y
result =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '"'
if. 0 = # result do. _1 else. > , > result end.
)

getCategoryId =: 4 : 0
NB. x Parent id
NB. y Category name (category names are guaranteed to be unique)
NB. Return the categoryid of the category
log 'getCategoryId ' , (": x) , ', ' , y
if. x < 0 do. _1 return. end.
result =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '" and parentid = ' , ": x
if. 0 = # result do. 
NB. 	smoutput 'getCategoryId _1 for' ; x ; y
	_1
else. 
	{. , > result 
end.  NB. {. to force it to a scalar shape.
)

getTopCategoryId =: 3 : 0
NB. y Category name
log 'getTopCategoryId ' , y
1 getCategoryId y
)

getParentId =: 3 : 0
NB. y Category id
NB. Return the categoryid of the category's parent.
log 'getParentId ' , ": y
, > , > {: sqlreadm__db 'select parentid from categories where categoryid = ' , ": y
)
NB. ==================== End Table of Contents ====================

NB. ====================== NuVoc ========================
loadVoc =: 3 : 0
log 'loadVoc'
try. VocTable =: > 1 { sqlreadm__db 'select * from vocabulary' catch. end.
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
	if. 0 = +/ sieve do. NB. Throw up our hands--not enough horizontal area for the next token.
		lineWidths =. lineWidths , {. tokenWidths
		tokenWidths =. }. tokenWidths
	else.
		lineWidths =. lineWidths , +/ sieve # tokenWidths
		tokenWidths =. tokenWidths #~ -. sieve
	end.
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
((leftX - 4) , (yy - 1) , (width + 8) , 20) registerRectLink link ; label ; 0
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
	if. 0 = +./ sieve do. sieve =. 1 , (<: # tokenWidths) # 0 end. NB. Take a token even if it doesn't fit.
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
(xStart , yStart , width , height) registerRectLink ('*selectVocGlyph ''' , glyph , '''') ; glyph ; 0
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
log 'selectVocGlyph ' , y
VocSelectedGlyph =: , y
entry =. VocTable {~ (3 {"1 VocTable) i. < VocSelectedGlyph
queueUrl n =: (> 7 { entry) ; > 5 { entry
)

drawVoc =: 3 : 0
log 'drawVoc'
glrgb 255 255 255
glbrush ''
glrect DisplayDetailRect
((20 + {. DisplayDetailRect) , 5) drawVocSections 0 1 2 3 4 5 6
((300 + {. DisplayDetailRect) , 5) drawVocSections 7 8 9 10 11
)
NB. ============================= End Voc ===============================

NB. ============================ Database Management ====================
uploadAcct =: '12a1yBS'

checkForNewerDatabase =: 3 : 0
NB. Return 1 if a newer database is available.  
NB. Return 2 is a newer database is required.
NB. Return 0 if the local database is up to date.
if. -. fexist targetDbPath do. 
	2 
	return. 
end.
try. 
	dbOpenDb ''
	localHash =. , > > {: sqlreadm__db 'select value from admin where key = "Hash"' 
	if. 0 = # localHash do. 
		2
	return. 
	end.
catcht.
	2
	return.
end.
head =. ('--head') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
remoteHash =. n {.~ LF i.~ n =. (13 + I. 'x-file-hash: ' E. head) }. head
-. localHash -: remoteHash
)

downloadLatestStageDatabase =: 3 : 0
('-o "' , stageDbPath , '"') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
)

downloadAndTransferDatabase =: 3 : 0
NB. Open the target db (tdb) and read all of the user records.  
NB. Write them to the staging db (db).
NB. Delete the target db, then rename the staging db
downloadLatestStageDatabase ''
if. fexist stageDbPath do.
	if. fexist targetDbPath do.
		sdb =. sqlopen_psqlite_ stageDbPath
		tdb =. sqlopen_psqlite_ targetDbPath
		cats =. > {: sqlreadm__tdb 'select level, parentid, categoryid, category, parentseq, count, link from categories where categoryid > 1000000'
		historyMenu =. > {: sqlreadm__tdb 'select label, link from history'
		wiki =. > {: sqlreadm__tdb 'select title, categoryid, link from wiki where categoryid >= 1000000'
		catCols =. ;: 'level parentid categoryid category parentseq count link'
		wikiCols =. ;: 'title categoryid link'
		sqlinsert__sdb 'categories' ; catCols ; < (> 0 {"1 cats) ; (> 1 {"1 cats) ; (> 2 {"1 cats) ; (3 {"1 cats) ; (> 4 {"1 cats) ; (> 5 {"1 cats) ; < (6 {"1 cats)
		sqlinsert__sdb 'wiki' ; wikiCols ; < (0 {"1 wiki) ; (> 1 {"1 wiki) ; < (2 {"1 wiki)
		sqlinsert__sdb 'history' ; ('label' ; 'link') ; < (0 {"1 historyMenu) ; < (1 {"1 historyMenu)
		sqlclose__sdb ''
		sqlclose__tdb ''
		(1!:55) < targetDbPath 
	end.
	targetDbPath frename stageDbPath
NB.	'rw-rw-rw-' (1!:7) < targetDbPath
	try. (1!:22) < targetDbPath catch. end.
end.
head =. ('--head') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
hash =: n {.~ LF i.~ n =. (13 + I. 'x-file-hash: ' E. head) }. head
try. (1!:22) < targetDbPath catch. end.
dbOpenDb ''
sqlclose__db ''
dbOpenDb ''
sqlinsert__db 'admin' ; (;: 'key value') ; < 'Hash' ;  hash
)

downloadDialog =: 3 : 0
status =. {. , checkForNewerDatabase ''
select. status
case. 0 do.
	wdinfo 'Local Database Status' ; 'Your local database is up to date.'
	1
case. 1 do.
	result =. wd 'mb query mb_yes =mb_no "Local Database Status" "A new database is available.  Download (to ~temp)?"'
	if. result -: 'yes' do. downloadAndTransferDatabase'' end.
	1
case. 2 do.
	result =. wd 'mb query mb_yes =mb_no "Local Database Status" "A new database is required.  Yes to download (to ~temp); No to quit."'
	if. result -: 'yes' do. 
		downloadAndTransferDatabase ''
		1
	else.
		0
	end.
end.
)
NB. ====================================================================

FrameTimeStamps =: ''

getFrameRate =: 3 : 0
FrameTimeStamps =: (t =. (6!:1) '' ) , FrameTimeStamps
fps =. # FrameTimeStamps =: FrameTimeStamps #~ (t - 1) < FrameTimeStamps
)

manageLoad =: 3 : 0
try. wd 'pclose' catch. end.
)

manageLoad ''

go =: 3 : 0
if. -. downloadDialog '' do. return. end.
initAdmin ''
loadVoc ''
clearLog ''
buildForm ''
layoutForm ''
loadHistoryMenu ''
wd 'pshow'
)

go_z_ =: 3 : 0
go_jwikiviz_ ''
)