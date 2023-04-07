load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'gl2'
coinsert 'jgl2'
NB. A Items
NB. Scroll behavior for long subject- and author lists in forum detail area.
NB. Fix use of curl for search
NB. Spider the Vocabulary--don't use the spreadsheet.
NB. Standalone application.
NB. NuVoc Ancillary Pages?
NB. Focus Lost on Isigraph?  What are the wheel events from the browser?
NB. Hover on a glyph selects the first valence link.
NB. Tag cloud

NB. B Items
NB. Can I add a "Back" button that drives the webview?  What else can I tell the webview?
NB. Support parallel download of forum posts.
NB. Animate scroll rather than jumping when the travel is too high.
NB. Saved pages mechanism.  "Save" button next to the url field?
NB. Add a "Search" label.
NB. Fix the extra "quotes in NuVoc

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
sqlinsert__db 'log' ; (;: 'datetime msg') ; < ((6!:0) 'YYYY MM DD hh mm ss') ; y
if. 0 = ? 100 do.
	max =. , > > {: sqlreadm__db 'select max(rowid) from log'
	sqlcmd__db 'delete from log where rowid < ' , ": 0 >. max - 1000
end.
)
NB. =======================================

NB. ==================== Form =====================
NB. FormMouseXY =: 0 0
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
wd     'bin h;'
wd       'cc history combolist;'
wd       'cc launch button; cn Launch Browser;'
wd     'bin z;'
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
wd 'set history maxwh ' , (": <. (winW * 0.4) , controlHeight) , ';'
wd 'set launch maxwh ' , (": <. (winW * 0.08) , controlHeight) , ';'
wd 'set vocContext maxwh ' , (": (<. winW * 0.5) , winH - controlHeight) , ';'
wd 'set browser maxwh ' , (": (<. winW * 0.5) , winH - controlHeight) , ';'
DisplayListRect =: <. 10 , controlHeight , 175 , winH - 80
DisplayDetailRect =: <. h , controlHeight , ((winW * 0.5) - h =. 190) , winH - 80
wd 'timer 200'
)

vizform_default =: 3 : 0
eventType =. > {: 5 { wdq
if. eventType -: 'close' do. wd 'pclose ;' end.
(> {: 5 { wdq) (1!:2) 2
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
NB. Give the user the chance to get the mouse over to the webview without activating another link.
NB. if. 1 > ((6!:1) '') - SuppressMouseHandlingStart do. return. end.
VocMouseXY =: 0 1 { ". > 1 { 13 { wdq
invalidateDisplay ''
)

vizform_vocContext_paint =: 3 : 0
trigger_paint ''
)

vizform_searchBox_button =: 3 : 0
try.
	search searchBox
	wd 'set searchBox text ""'
catch.
	log (13!:12) ''
	log dbError ''
end.
)

vizform_history_select =: 3 : 0
queueLoadPage s =. (". history_select) { HistoryMenu
LastUrlLoaded =: '' NB. Make sure selecting the top item in the History menu will still load that page.
)

vizform_launch_button =: 3 : 0
log 'vizform_launch_button ' , ": > 0 { 0 { HistoryMenu
if. IFUNIX do. (2!:1) 'open -a Safari "' , (> 0 { 0 { HistoryMenu) , '"' end.
)

vizform_wctrl_fkey =: 3 : 0
wd 'timer 0'
wd 'pclose'
)

sys_timer_z_ =: 3 : 0
try.
	checkHistoryMenu_base_ ''
catch.
	log (13!:12) ''
	log dbError ''
end.
NB. invalidateDisplay_base_ ''
)

wd 'timer 0'

trigger_paint =: 3 : 0
try.
'w h' =. ". wd 'get vocContext wh'
if. (w > 300) *. h > 300 do.
	scheduleBackgroundRender ''
 	glfill 255 255 255 255
	drawVoc ''
 	drawToc ''
	drawFrameRate ''
	backgroundRenderComplete ''
NB.	manageMouseMove VocMouseXY
end.
glclip 0 0 10000 10000
NB. wd 'msgs' NB. Message pump.  This really screws things up when it's uncommented.
catch.
log (13!:12) ''
log dbError ''
end.
)

invalidateDisplay =: 3 : 0
wd 'set vocContext invalid'
)
NB. ======================================================

NB. =================== Search ===========================
clearSearches =: 3 : 0
log 'clearSearches'
terms =. > {: sqlreadm__db 'select child from categories where parentid = ' , ": 1 getCategoryId SearchCatString
clearSearch &. > terms
clearCache ''
invalidateDisplay ''
)

clearSearch =: 3 : 0
NB. y A search string
NB. Remove the search records from the TOC.
log 'clearSearch ' , y
searchId =. 1 getCategoryId SearchCatString
termId =. searchId getCategoryId y
if. termId >: 0 do. 
	wikiId =. termId getCategoryId 'Wiki'
	if. wikiId >: 0 do. sqlcmd__db 'delete from wiki where categoryid = ' , ": wikiId end.
	forumsId =. termId getCategoryId 'Forums'
	if. forumsId >: 0 do.
		forumIds =. > {: sqlreadm__db 'select rowid from categories where parentid = ' , ": forumsId
		sqlcmd__db &. > 'delete from wiki where categoryid = '&, &. > ": &. > forumIds
		sqlcmd__db 'delete from categories where parentid = ' , ": forumsId
	end.
	sqlcmd__db 'delete from categories where parentid = ' , ": termId 
end.
sqlcmd__db 'delete from categories where parentid = ' , (": searchId) , ' and child = "' , y , '"'
)

addSearchToToc =: 3 : 0
NB. y A search string
NB. Save parent ; child.  
term =.  y
clearSearch term
searchId =. 1 getCategoryId SearchCatString
cols =. ;: 'level parentid child count parentseq link'
sqlinsert__db 'categories' ; cols ; < 2 ; searchId ; (< term) ; 0 ; 0 ; 'https://www.jsoftware.com'
sqlinsert__db 'categories' ; cols ; < 3 ; (searchId getCategoryId term) ; (< 'Wiki') ; 0 ; 0 ; 'https://code.jsoftware.com/wiki/Special:JwikiSearch'
sqlinsert__db 'categories' ; cols ; < 3 ; (searchId getCategoryId term) ; (< 'Forums') ; 0 ; 1 ; 'https://www.jsoftware.com/forumsearch.htm'
clearCache ''
invalidateDisplay ''
)

searchWiki =: 3 : 0
NB. y Search term
NB. Perform the search, parse the results, and update the "categories" and "wiki" table.
html =. (2!:0) 'curl "https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=70&offset=0&profile=default&search=' , (urlencode y) , '"'
pat =. rxcomp 'mw-search-result-heading''><a href="([^"]+)" title="([^"]+)"'
offsetLengths =.  pat rxmatches html
wikiId =. ((1 getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Wiki'
if. 0 = # offsetLengths do.
	sqlupdate__db 'categories' ; ('rowid = ' , ": wikiId) ; ('count' ; 'level') ; < 0 ; 3
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
	sqlupdate__db 'categories' ; ('rowid = ' , ": wikiId) ; ('count' ; 'level') ; < (# titles) ; 3
end.
clearCache ''
invalidateDisplay ''
)

searchForums =: 3 : 0
NB. y Search term
NB. Perform the search, parse the results, and update the "categories" and "wiki" table.
wikiCols =. ;: 'title categoryid link'
html =. (2!:0) 'curl "https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2030"'
pat =. rxcomp '(http://www.jsoftware.com/pipermail[^"]+)">\[([^\]]+)\] ([^<]+)</a>'
offsetLengths =.  pat rxmatches html
forumsId =. ((1 getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Forums'
if. 0 = # offsetLengths do.
	sqlupdate__db 'categories' ; ('rowid = ' , ": forumsId) ; ('count' ; 'level') ; < 0 ; 3
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
	sqlupdate__db 'categories' ; ('rowid = ' , ": forumsId) ; ('count' ; 'level') ; < (# titles) ; 3
	for_index. i. # titleGroups do.
		fname =. > index { ~. forums
		forumLinks =. > index { linkGroups
		forumTitles =. > index { titleGroups
		cols =. (;: 'level parentid child parentseq count link')
		data =. 4 ; forumsId ; fname ; index ; (# forumLinks) ; 'http://www.jsoftware.com/mailman/listinfo/' , }. fname
		sqlinsert__db 'categories' ; cols ; < data
		forumId =. forumsId getCategoryId fname
		data =. forumTitles ; (forumId #~ # forumLinks) ; < forumLinks
		sqlinsert__db 'wiki';wikiCols;<data
	end.
end.
clearCache ''
invalidateDisplay ''
)

search =: 3 : 0
NB. y A search string.
try.
	log 'Searching for ' , y
	addSearchToToc y
	searchWiki y
	searchForums y
catch.
	log (13!:12) ''
end.
)

NB. ================== Drawing ====================
BarColor =: 255 127 127
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
NB. Toc =: '' NB. path ; doc name ; document link
NB. TocOutline =: '' NB. level ; path component ; full path
TocFont =: 'arial 16'
TocBoldFont =: 'arial bold 16'
TocItalicFont =: 'arial italic 16'
TocBoldItalicFont =: 'arial bold italic 16'
TocLineHeight =: 21
TocSelectedTopCategory =: '*NuVoc'
TocScrollIndex =: 0
MaxTocDepth =: 4
ScrollColor =: 230 230 230
DisplayMode =: 'V' NB. Values are (V)oc, (T)ree
DisplayListRect =: 10 10 100 100
DisplayDetailRect =: 100 10 100 100
UseHtmlCache =: 0
SearchString =: ''
SearchResultsTable =: '' NB. Path ; doc name ; document link
Months =: ;:'January February March April May June July August September October November December'
ForumsCatString =: '*Forums'
SearchCatString =: '*Search'

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
(rx < px) *. (px < rx + rw) *. (py > ry) *. (py < ry + rh)
)

getDocumentSectionGeometryForMouseXY =: 3 : 0
, DocumentSectionGeometry #~ VocMouseXY pointInRect"1 1 (1 2 3 4) {"1 DocumentSectionGeometry
)

checkDefaultUrl =: 3 : 0
if. LastUrlLoaded -: '' do. loadPage DefaultUrl end. 
)

queueLoadPage =: 3 : 0
NB. y Url ; Optional title
if. 6 < # y do. entry =. (< y) , a: else. entry =. y end.
loadPage entry
)

addToHistoryMenu =: 3 : 0
if. CurrentHistoryEntry -: '' do. return. end.
if. HistoryMenu -: '' do. HistoryMenu =: ,: CurrentHistoryEntry else. HistoryMenu =: ~. CurrentHistoryEntry , HistoryMenu end.
s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
wd 'set history items *' , s
wd 'set history select 0'
CurrentHistoryEntry =: ''
HistoryMenu =: (60 <. # HistoryMenu) {. HistoryMenu
sqlcmd__db 'delete from history'
sqlinsert__db 'history' ; (;: 'label link') ; < ({:"1 HistoryMenu) ; < {."1 HistoryMenu
)

loadHistoryMenu =: 3 : 0
HistoryMenu =: > {: sqlreadm__db 'select link, label from history'
s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
wd 'set history items *' , s
wd 'set history select 0'
)
 
checkHistoryMenu =: 3 : 0
NB. Possibly prepend the current page to the history menu.
NB. Called from the timer.
if. (1.5 < ((6!:1) '') - CurrentHistoryLoadTime) *. -. '' -: CurrentHistoryEntry do.
	addToHistoryMenu ''
end.
)

HistoryMenu =: '' NB. Table of Title ; Link
CurrentHistoryEntry =: '' NB. Title ; Link
CurrentHistoryLoadTime =: 0 NB. The time at which this entry was first loaded.

loadPage =: 3 : 0
NB. y A url, possibly unqualified ; A title
if. 0 = # y do. return. end.
url =. > {. y
if. url -: '' do. return. end.
url =. ('User_' ; 'User:') rxrplc url
if. 'Category:' -: 9 {. url do.
	url =. 'https://code.jsoftware.com/wiki/' , url
elseif. -. 'http' -: 4 {. url do.
	url =. ('.html' ; '') rxrplc 'https://code.jsoftware.com/' , url
end.
if. LastUrlLoaded -: url do. return. end.
log 'Loading url ' , url
wd 'set browser url *' , url 
CurrentHistoryEntry =: url ; 1 { y
CurrentHistoryLoadTime =: (6!:1) ''
LastUrlLoaded =: url
)

NB. ======================== Cached Drawing ===========================
BackgroundRenderRequired =: 1
CachedRectsAndLinks =: ''  NB. Table of rect ; url
ReversibleSelections =: '' NB. Table of rect

registerRectLink =: 4 : 0
NB. x xx yy width height
NB. y A url or * to be evaluated ; an optional title
NB. Record this for mouse processing: highlighting and loading urls.
NB. Note that since we're frame-based, we re-register rect/links on every frame.  So we 
NB. just check immediately to see whether the mouse is inside the rect and activate accordingly.
if. -. VocMouseXY pointInRect x do. return. end.
if. 2 = # y do. 'urlCommand name' =. y else. 'urlCommand name' =. (; y) ; '----' end.
if. '*' = {. urlCommand do.
	". }. urlCommand
else. 
	queueLoadPage urlCommand ; name
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

NB. ============================== Scroller Field ===============================
drawScrollerField =: 3 : 0
NB. y Structure: x y width height ; strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
NB. Draw the strings and registerRectLink to highlight them and load pages.
NB. Use VocMouseXY to update scrollOffset and selectedIndex.
NB. Return the scrollIndex, which may have changed.
'rect strings links ratios headingFlags selectedIndex scrollIndex' =. y
'xx yy w h' =. rect
glclip xx , yy ,  w , h
window =. <. TocLineHeight %~ -: h
margin =. 5
stripeWidth =. 70
glfont TocFont
if. VocMouseXY pointInRect xx , yy , (-: w) , h do.
	scrollIndex =. 0 >. (<: # strings) <. <. ((({: VocMouseXY) - yy) % h) * # strings
end.
windowStartIndex =. <. 0 >. (window -~ # strings) <. 0 >. scrollIndex - -: window
squishedLineHeight =. (window -~ # strings) %~ h - window * TocLineHeight
heights =. (# strings) {. (windowStartIndex # squishedLineHeight) , (window # TocLineHeight) , 1000 # squishedLineHeight
ys =. <. }: +/\ 0 , heights
heights =. <. heights
origins =. <. (margin + xx) ,. margin + yy + ys
glrgb 0 0 0
gltextcolor ''
glpen 1
glrgb 255 255 255
glbrush ''
glrect rect
if. VocMouseXY pointInRect rect do.
	glcursor IDC_ARROW
	if. VocMouseXY pointInRect xx , yy , stripeWidth , h do. glcursor IDC_SIZEVER end.
	if. VocMouseXY pointInRect (xx + stripeWidth) , yy , (w - stripeWidth) , h do. glcursor IDC_POINTINGHAND end.
end.
if. VocMouseXY pointInRect xx , yy , stripeWidth , h do. glrgb 180 180 255 else. glrgb ScrollColor end.
glbrush ''
glpen 0
glrect xx , yy , stripeWidth , h
for_i. i. # strings do.
	lineHeight =. i { heights
	origin =. > i { origins
	glrgb BarColor
	glbrush ''
	glpen 0
	if. 0 < i { ratios do. glrect origin , (<. (w - margin) * i { ratios) , lineHeight end.
	if. i { headingFlags do. 
		glrgb SectionColor
		glfont TocBoldFont
	else.
		glrgb 0 0 0
		glfont TocFont
	end.
	glbrush ''
	gltextcolor''
	if. lineHeight > squishedLineHeight do.
		(> i { origins) drawStringAt > i { strings
	else.
		glrect origin , ({. glqextent > i { strings) , 2
	end.
	if. i = selectedIndex do. (origin , w , lineHeight) drawHighlight SelectionColor end.
	(origin, w, lineHeight) registerRectLink > i { links
	glclip xx , yy ,  w , h
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
adjRect registerRectLink command ; name
)

drawTocEntryChildrenColumn =: 4 : 0
NB. x xx yy width height
NB. y Table of Name ; Link/Command ; HeadingFlag
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
log 'drawTocEntryForum ' , x
'xx yy width height' =. y
if. -. ForumCurrentName -: x do. 
	result =. > {: sqlreadm__db 'select year, month, subject, author, link, rowid from forums where forumname = "' , x , '" order by year desc, month asc, rowid asc'
	ForumCacheTable =: 0 1 2 3 4 {"1 result
	ForumCurrentName =: x
	TocEntryForumYear =: 2023
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
subject =. TocEntryForumSubjectIndex { subjects
authorEntries =. entries #~ ({."1 entries) = TocEntryForumSubjectIndex { subjects
authors =. 1 {"1 authorEntries
authorHeight =. TocLineHeight * # authors
authorY =. <. (height - authorHeight) <. (1 { 0 { leftRects) >. (-: authorHeight) -~ 1 { TocEntryForumSubjectIndex { leftRects 
authorOrigins =. (xx + margin + 60) ,. authorY + TocLineHeight * i. # authors
glclip 0 0 , (_5 + 0 { 0 { leftRects) , height
(<"1 authorOrigins) drawStringAt &. > authors
authorRects =. authorOrigins ,"1 1 (> {.@glqextent &. > authors) ,. TocLineHeight
(<"1 authorRects) registerRectLink &. > '*setTocEntryForumAuthorIndex '&, &. > ": &. > <"0 i. # authorRects
TocEntryForumAuthorIndex =: TocEntryForumAuthorIndex <. <: # authors
(TocEntryForumAuthorIndex { authorRects) drawHighlight SelectionColor
glclip 0 0 10000 100000
title =. LF -.~ (> TocEntryForumAuthorIndex { authors) , ' * ' , (> subject)
selectedAuthorEntry =. TocEntryForumAuthorIndex { authorEntries
queueLoadPage ('https://www.jsoftware.com/pipermail/' , (}. x) , '/' , (": TocEntryForumYear) , '-' , (> month { Months) , '/' , > 2 { selectedAuthorEntry) ; title
)

setTocEntryChildCategoryIndex =: 3 : 0
NB. y Index of the category whose children should be displayed.
TocEntryChildCategoryIndex =: y
queueLoadPage (> TocEntryChildCategoryIndex { 1 {"1 TocEntryChildCategoryEntries) ; > TocEntryChildCategoryIndex { 0 {"1 TocEntryChildCategoryEntries
)

TocEntryChildCategoryIndex =: '' NB. The index of the currenty-selected child category in the tree.
TocEntryChildCategoryEntries =: '' NB. Table of Title ; Link

drawTocEntryChildrenWithTree =: 4 : 0
NB. x maxDepth
NB. y xx yy width height entryY
NB. Render the descendants of the TocSelectedTopCategory in xx yy width height.
NB. This is used when the child count is too high.  It renders a tree in the first column
NB. and the children of each node in the subsequent columns.
NB. getTocOutlineRailEntries returns table of level ; parent ; category ; parentseq ; count ; link
maxDepth =. x
'xx yy width height' =. y
'level parentId category parentSeq count link' =. TocOutlineRailSelectedIndex { 0 getTocOutlineRailEntries maxDepth
log 'drawTocEntryChildrenWithTree ' , (": parentId) , ' ' , category
categoryId =. parentId getCategoryId category
tocWikiDocs =. getTocWikiDocs categoryId NB. Table of level parent category parentSeq count link ; (table of title ; link)
if. 0 = # tocWikiDocs do. '' return. end.
margin =. 5
categoryEntries =. > {."1 tocWikiDocs  NB. categoryEntries: table of level parent category parentSeq count link
indents =. #&'  ' &. > 0 {"1 categoryEntries
catTitles =. indents , &. > 2 {"1 categoryEntries
catLinks =. 5 {"1 categoryEntries
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
glrgb 255 255 255
glbrush ''
glrect xx , yy , width , height
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
NB. getTocOutlineRailEntries returns table of level ; parentid ; category ; parentseq ; count ; link
maxDepth =. x
'xx yy width height' =. y
'level parentId category parentSeq count link' =. TocOutlineRailSelectedIndex { 0 getTocOutlineRailEntries maxDepth
log 'drawTocEntryChildren ' , (": parentId) , ' ' , category
margin =. 5
glrgb 0 0 0
glpen 1
glrgb 255 255 255
glbrush ''
glrect xx , yy , width , height
tocWikiDocs =. getTocWikiDocs parentId getCategoryId category NB. Table of tocOutlineEntry ; (table of title ; link)
if. 0 = # tocWikiDocs do. '' return. end.
categoryEntries =. > {."1 tocWikiDocs
catLinkFlag =. (2 5 {"1 categoryEntries) ,. <1 NB. Category ; Link ; Heading Flag
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
'level parentId category parentSeq count link' =. railIndex { 0 getTocOutlineRailEntries maxDepth NB. level ; parent ; category ; parentseq ; count ; link
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
if. parentId = 1 getCategoryId SearchCatString do. 
	glrgb 0 0 255 
	glfont TocBoldFont
end.
gltextcolor ''
if. railIndex = TocOutlineRailSelectedIndex do. 
	if. isShrunken do.
		entryRect drawHighlight SelectionColor
		entryRect registerRectLink link ; indentedCategory
	else.
		(entryX , entryY) drawStringAt indentedCategory
		entryRect drawHighlight SelectionColor
		entryRect registerRectLink link ; indentedCategory
	end.
else.
	if. isShrunken do.
		glrgba 0 0 0 200
		glbrush ''
		glpen 0
		glrect entryRect
	else.
		(entryX , entryY) drawStringAt indentedCategory
	end.
end.
if. level < <: maxDepth do. count =. 0 end.
glclip 0 0 10000 10000
if.  +./ '*NuVoc' E. > 2 { TocOutlineRailSelectedIndex { 0 getTocOutlineRailEntries maxDepth do.
	DisplayMode =: 'V'
	''
	return.
end.
if. (DisplayMode = 'T') *. railIndex = TocOutlineRailSelectedIndex do.
	if. (1 getCategoryId ForumsCatString) = > 1 { railIndex { 0 getTocOutlineRailEntries maxDepth do. NB. level ; parent ; category ; parentseq ; count ; link
		(> 2 { railIndex { 0 getTocOutlineRailEntries maxDepth) drawTocEntryForum DisplayDetailRect
	else.
		maxDepth drawTocEntryChildren DisplayDetailRect
	end.
end.
''
)

TocOutlineRailSelectedIndex =: 0
TocOutlineRailScrollIndex =: 0

setTocOutlineRailSelectedIndex =: 3 : 0
NB. y The new value of the index
TocOutlineRailSelectedIndex =: y
entry =. y { 0 getTocOutlineRailEntries MaxTocDepth  NB. level ; parent ; category ; parentseq ; count ; link
if.  +./ '*NuVoc' E. > 2 { entry do.
	DisplayMode =: 'V'
elseif. (1 getCategoryId ForumsCatString) = > 1 { entry do. NB. level ; parent ; category ; parentseq ; count ; link
	(> 2 { entry) drawTocEntryForum DisplayDetailRect
end.
queueLoadPage (> 5 { entry) ; > 2 { entry
)

drawTocRail =: 4 : 0
NB. x xx yy w h
NB. y A level of the Toc hierarchy to which to display
NB. drawScrollerField: x y width height ; strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
'xx yy width height' =. x
if. VocMouseXY pointInRect xx , yy , width , height do. setDisplayMode 'T' end.
entries =. 0 getTocOutlineRailEntries y NB. Table of level ; parentId ; category ; parentseq ; count ; link
maxCount =. >./ > 4 {"1 entries
indentStrings =. (#&'  ' &. > <: &. > 0 {"1 entries) , &. > 2 {"1 entries
linkCommands =. '*setTocOutlineRailSelectedIndex '&, &. > ": &. > <"0 i. # entries
parms =. x ; indentStrings ; linkCommands ; (maxCount %~ > 4 {"1 entries) ; (0 #~ # entries) ; TocOutlineRailSelectedIndex ; TocOutlineRailScrollIndex
TocOutlineRailScrollIndex =: drawScrollerField parms
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
entries =. > {: sqlreadm__db 'select level, parentid, child, parentseq, count, link from categories where parentid = ' , (": parentId) , ' order by parentseq'
childIds =. parentId&getCategoryId &. > 2 {"1 entries
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
	result =. > x recurseGetTocOutlineRailEntries y
	if. x = 0 do. result =. }. result end.
	TocOutlineRailEntriesCache =: TocOutlineRailEntriesCache , key , < result
end.
result
)

getTocWikiDocs =: 3 : 0
NB. y A category id
NB. Return the subtree TOC from the categories table with a set of wiki documents for each entry.
NB. Return table of (level parent category parentSeq count link) ; table of title ; link
key =. < y
if. (# WikiDocsCache) > index =. (0 {"1 WikiDocsCache) i. key do.
	result =. > index {1 {"1 WikiDocsCache
else.
	entries =. y getTocOutlineRailEntries 100
	if. 0 = # entries do.
		NB. The category is not a parent.
		entry =. > {: sqlreadm__db 'select level, parentid, child, parentseq, count, link from categories where rowid = ' , (": y)
		wikiDocs =. > {: sqlreadm__db 'select title, link from wiki where categoryid = ' , ": y
		result =. (< entry) , < wikiDocs
	else.
		categories =. 2 {"1 entries
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

getCategory =: 3 : 0
NB. y Category Id
NB. Return the category string, empty string if none.
result =. > {: sqlreadm__db 'select child from categories where rowid = ' , ": y
if. 0 = # result do. '' else. > , > result end.
)

getCategoryIdNoParent =: 3 : 0
NB. y Category string
NB. Return the id or _1.
result =. > {: sqlreadm__db 'select rowid from categories where child = "' , y , '"'
if. 0 = # result do. _1 else. > , > result end.
)

getCategoryId =: 4 : 0
NB. x Parent id
NB. y Category name (category names are guaranteed to be unique)
NB. Return the rowid of the category
result =. > {: sqlreadm__db 'select rowid from categories where child = "' , y , '" and parentid = ' , ": x
if. 0 = # result do. _1 else. , > result end.
)

getParentId =: 3 : 0
NB. y Category id
NB. Return the rowid of the category's parent.
, > , > {: sqlreadm__db 'select parentid from categories where rowid = ' , ": y
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
glfont 'arial 16'
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

selectVocGlyph =: 3 : 0
NB. y A glyph
VocSelectedGlyph =: , y
invalidateDisplay ''
)

drawVoc =: 3 : 0
if. -. DisplayMode -: 'V' do. return. end.
glrgb 255 255 255
glbrush ''
glrect 0 0 2000 2000
225 30 drawVocSections 0 1 2 3 4 5
510 30 drawVocSections 6 7 8 9 10 11
)
NB. ============================= End Voc ===============================

FrameTimeStamps =: ''

drawFrameRate =: 3 : 0
FrameTimeStamps =: (t =. (6!:1) '' ) , FrameTimeStamps
fps =. # FrameTimeStamps =: FrameTimeStamps #~ (t - 1) < FrameTimeStamps
glfont 'arial bold 24'
glrgb HighlightColor
gltextcolor ''
10 0 drawStringAt (": fps) , ' fps'
log 'drawFrameRate ' , ": fps
)

go =: 3 : 0
dbOpenDb ''
loadVoc ''
buildForm ''
layoutForm ''
loadHistoryMenu ''
wd 'pshow'
)