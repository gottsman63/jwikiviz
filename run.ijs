coerase <'jwikiviz'

cocurrent 'jwikiviz'

load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'gl2'
coinsert 'jgl2'

NB. *** Wiki Meeting Discussion Items ***
NB. How should we handle bug reports?  General feedback? "Bugs/Feedback" button that would do what?
NB. Fix WGET.
NB. Expanded test user base (send them the draft announcement email)

NB. *** A Items ***
NB. Check the behavior of the cursor icon in the Forums section (especially).  
NB. Test initial installation.  
NB. Forum search result "jump to thread" feature.  
NB. Look for more trace opportunities.  
NB. Should we check for new versions at other times?
NB. Fix "TocEntryForumYear  =: 2023"

NB. *** B Items ***
NB. Better reporting from the jwikiviz.db creation task.  How many retrieved, how many in the tables, etc.
NB. Compress the file?  It would save CDN bandwidth...goes from 8.2 to 1.7.  Or compress semantically (0 - Jsoftware, 1 - Jchat, ...)
NB. Fix use of sqlreadm__db
NB. Support parallel download of forum and wiki documents.
NB. Add a "Search" label.
NB. Fix the extra "quotes in NuVoc
NB. Spider the Vocabulary--don't use the spreadsheet.

NB. ===================== Version Updates =====================
addonPath =: '~addons/gottsman63/jwikiviz/manifest.ijs'
githubUrl =: 'https://raw.githubusercontent.com/gottsman63/jwikiviz/main/manifest.ijs'

manifest_version=: {{
  cocurrent temp=. cocreate''
  VERSION =: 'none'
  try.   0!:100 y
  catch. VERSION =: 'none'
  end.
  coerase temp
  VERSION
}}

checkAppUpToDate =: 3 : 0
NB. Return 0 if the app is out of date.
NB. Return 1 if the app is up to date.
NB. Return 2 if we failed to get a remote version number.
log 'checkAppUpToDate'
try.
	v1 =. manifest_version (1!:1) < jpath addonPath
	if. IFWGET_wgethttp_ do.
		v2 =. manifest_version c =. '-O - --header "Cache-Control: no-cache, no-store, must-revalidate" ' gethttp githubUrl
NB.		v2 =. manifest_version (2!:0) 'wget --header="Cache-Control: no-cache, no-store, must-revalidate"'
	else.
		v2 =. manifest_version '-s -H "Cache-Control: no-cache, no-store, must-revalidate"' gethttp githubUrl
	end.
NB.	smoutput 'JWikiViz Versions' ; v1 ; v2
	if. v2 -: 'none' do. 2 return. end.
	if. v1 -: v2 do. 1 return. end.
catch.
	smoutput 'Problem: ' , (13!:12) ''
	log 'Problem: ' , (13!:12) ''
	0 return.
end.
0
)

updateAppVersion =: 3 : 0
log 'updateAppVersion'
sqlclose__db  ''
(9!:29) 1
(9!:27) 'load ''~addons/gottsman63/jwikiviz/run.ijs'' [ install ''github:gottsman63/jwikiviz'''
)
NB. ===========================================================

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
NB. smoutput y
sqlinsert__db 'log' ; (;: 'datetime msg') ; < ((6!:0) 'YYYY MM DD hh mm sssss') ; y
NB. if. 0 = ? 200 do.
NB.	max =. , > > {: sqlreadm__db 'select max(rowid) from log'
NB.	sqlcmd__db 'delete from log where rowid < ' , ": 0 >. max - 10000
NB. end.
)

clearLog =: 3 : 0
sqlcmd__db 'delete from log'
)

initAdmin =: 3 : 0
log 'initAdmin'
sqlupsert__db 'admin' ; 'key' ; (;: 'key value') ; < 'qscreen' ; wd 'qscreen'
sqlupsert__db 'admin' ; 'key' ; (;: 'key value') ; < 'JVERSION' ; JVERSION
)
NB. ================ gethttp version check ==========================
checkGethttpVersion =: 3 : 0
log 'checkGethttpVersion'
NB. Return 0 if the version of gethttp is too old.
f =. jpath '~addons/web/gethttp/manifest.ijs'
ol =. {: (rxcomp 'VERSION[ ]*=:[ ]*''(\d+\.\d+\.\d+)''') rxmatch mtext =. (1!:1) < f
version =. +/ 100 10 1 * ". ;._2 (({: ol) {. ({. ol) }. mtext) , '.'
if. version < 111 do.
	wdinfo 'The web/gethttp addon is out of date.  Pleae update it using the text in the terminal.'
	smoutput 'install ''web/gethttp'''
	0
else.
	1
end.
)
NB. =================================================================

shortcutInfo =: 3 : 0
smoutput ' '
smoutput 'NB. Create a shortcut for JWikiViz:'
smoutput 'open ''~config/userkeys.cfg'''
smoutput 'NB. Append the line: Ctrl+Shift+H;0;JWikiViz;load ''~addons/gottsman63/jwikiviz/run.ijs'''
smoutput ' '
smoutput 'browse_j_ ''https://code.jsoftware.com/wiki/Guides/Qt_IDE/Configure/User_Keys'' NB. More information.'
NB.    load '~addons/gottsman63/jwikiviz/run.ijs'
)

NB. ==================== Form =====================
VocMouseXY =: 0 0
VocMouseClickXY =: 0 0

lastUpdateButtonCheckTime =: _10000000

setUpdateButtons =: 3 : 0
NB. if. (((6!:1) '') - lastUpdateButtonCheckTime) < 60 * 60 do. return. end.
NB. lastUpdateButtonCheckTime =: (6!:1) ''
select. checkAppUpToDate ''
case. 0 do. appCap =. 'New add-on version available'
case. 1 do. appCap =. 'Add-on is up to date' 
case. 2 do. appCap =. 'Offline (apparently)'
end.
wd 'set appUpdate caption *' , appCap
dbStatus =. checkForNewerDatabase ''
select. dbStatus
case. 0 do. dbCap =. 'Local database is up to date'
case. 1 do. dbCap =. 'Click to load a new database'
case. 2 do. dbCap =. 'Database download required'
case. 3 do. dbCap =. 'Offline (apparently)'
end.
wd 'set dbUpdate caption *' , dbCap
)

vizform_appUpdate_button =: 3 : 0
log 'vizform_appUpdate_button'
updateAppVersion ''
)

vizform_dbUpdate_button =: 3 : 0
log 'vizform_dbUpdate_Button'
downloadAndTransferDatabase ''
setUpdateButtons ''
)

buildForm =: 3 : 0
log 'buildForm'
wd 'pc vizform escclose;'
wd 'pn *J Documentation Viewer Add-On'
wd 'bin h;'
wd   'bin v;'
wd     'bin h;'
wd       'cc shortcut button;cn Shortcut...;'
wd       'cc clearSearches button;cn Clear *Searches;'
wd       'cc searchBox edit;'
wd       'cc logcheck checkbox;cn Debug (Log);'
wd     'bin z;'
wd     'bin h;'
wd       'cc dbUpdate button; cn Haha!;'
wd       'cc appUpdate button; cn Wocka!;'
wd     'bin z;'
wd     'cc vocContext isigraph;'
wd   'bin z;'
wd   'bin v;'
wd     'bin h;'
wd       'cc loadPost button; cn *Show Post in Context'
wd       'cc bookmark button; cn *Bookmark'
wd       'cc history combolist;'
wd       'cc launch button; cn Browser;'
wd     'bin z;'
wd     'bin h;'
wd       'cc shrinkBrowser button ; cn *> Shrink Browser <'
wd       'cc expandBrowser button ; cn *< Expand Browser >'
wd     'bin z;'
wd     'cc browser webview;'
wd   'bin z;'
wd 'bin z;'
)

LayoutForumPostLoadButtonEnable =: 0

LayoutRatio =: 0.5
LayoutRatioTarget =: 0.5

layoutForm =: 3 : 0
log 'layoutForm'
'w h' =. ". wd 'getp wh'
winW =. w - 40
winH =. h - 45
controlHeight =. 30
vocContextHeight =. winH >. 760
NB. LayoutRatio =: 0.8 <. 0.2 >. LayoutRatio + 0.1 * LayoutDirection
NB. if. w > 1500 do. LayoutRatio =: 0.5 end.
if. 0.1 < | LayoutRatioTarget - LayoutRatio do.
	sgn =. LayoutRatioTarget - LayoutRatio
	LayoutRatio =: LayoutRatio + sgn * 0.1 <. | LayoutRatioTarget - LayoutRatio
else.
	LayoutRatio =: LayoutRatioTarget
end.
vocContextWidth =. <. winW * LayoutRatio
browserWidth =. winW - vocContextWidth
wd 'set shortcut maxwh ' ,  , (": (vocContextWidth * 0.10) , controlHeight) , ';'
wd 'set clearSearches maxwh ' , (": (vocContextWidth * 0.15) , controlHeight) , ';'
wd 'set searchBox maxwh ' , (": (vocContextWidth * 0.55) , controlHeight) , ';'
wd 'set logcheck maxwh ' , (": (vocContextWidth * 0.15) , controlHeight) , ';'
wd 'set vocContext maxwh ' , (": vocContextWidth , vocContextHeight) , ';'
NB. wd 'set vocContext minwh ' , (": 1 , 760) , ';'
wd 'set loadPost maxwh ' , (": (browserWidth * 0.18), controlHeight) , ';'
wd 'set bookmark maxwh ' , (": (browserWidth * 0.12), controlHeight) , ';'
wd 'set history maxwh ' , (": (browserWidth * 0.5) , controlHeight) , ';'
wd 'set launch maxwh ' , (": (browserWidth * 0.15) , controlHeight) , ';'
wd 'set browser maxwh ' , (": browserWidth , winH - controlHeight) , ';'
wd 'set loadPost visible ' , ": LayoutForumPostLoadButtonEnable
if. LayoutRatio ~: LayoutRatioTarget do. animate 2 end.
)

setLayoutRatioBrowser =: 3 : 0
if. LayoutRatioTarget < 0.4 do. return. end.
'w h' =. ". wd 'getp wh'
centerW =. w * LayoutRatio
if. w < 1500 do. NB. Small screen
	LayoutRatioTarget =: 0.2
else.
	LayoutRatioTarget =: 0.5
end.
animate 2
)

setLayoutRatioToc =: 3 : 0
if. LayoutRatioTarget > 0.6 do. return. end.
'w h' =. ". wd 'getp wh'
centerW =. w * LayoutRatio
if. w < 1500 do. NB. Small screen
	LayoutRatioTarget =: 0.8
else.
	LayoutRatioTarget =: 0.5
end.
animate 2
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

vizform_escape =: 3 : 0
vizform_close ''
)

vizform_browser_escape =: 3 : 0
vizform_close ''
)

vizform_vocContext_escape =: 3 : 0
vizform_close ''
)

vizform_expandBrowser_button =: 3 : 0
LayoutRatioTarget =: 0.2
animate 2
)

vizform_shrinkBrowser_button =: 3 : 0
LayoutRatioTarget =: 0.8
animate 2
)

vizform_bookmark_button =: 3 : 0
log 'vizform_bookmark_button'
bookmark ''
invalidateDisplay ''
)

vizform_shortcut_button =: 3 : 0
log 'shortcut'
shortcutInfo ''
wdinfo 'The terminal has instructions for adding a shortcut to the IDE''s userkeys.cfg file.'
)

vizform_clearSearches_button =: 3 : 0
log 'vizform_clearSearches_button'
clearSearches ''
invalidateDisplay ''
)

vizform_logcheck_button =: 3 : 0
LogFlag =: ". logcheck
)

vizform_vocContext_mmove =: 3 : 0
NB. Give the user the chance to get the mouse over to the webview without activating another link.
NB. if. 1 > ((6!:1) '') - SuppressMouseHandlingStart do. return. end.
log 'vizform_vocContext_mmove'
if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do. return. end.
VocMouseXY =: 0 1 { ". > 1 { 13 { wdq
setLayoutRatioToc ''
invalidateDisplay ''
)

vizform_vocContext_mblup =: 3 : 0
log 'vizform_vocContext_mblup'
VocMouseClickXY =: 0 1 { ". > 1 { 13 { wdq
NB. setUpdateButtons ''
invalidateDisplay ''
)

vizform_vocContext_paint =: 3 : 0
trigger_paint ''
)

vizform_browser_mmove =: 3 : 0
clearQueuedUrl ''
setLayoutRatioBrowser ''
)

vizform_browser_curl =: 3 : 0
log 'vizform_browser_curl'
url =. > (1 {"1 wdq) {~ ({."1 wdq) i. < 'browser_curl'
topHistoryUrl =. > 0 { 0 { getHistoryMenu ''
if. -. +./ topHistoryUrl E. url do. addToHistoryMenu url ; url end.
resetBookmarkButton ''
resetForumPostLoadButton ''
)

vizform_searchBox_button =: 3 : 0
log 'vizform_searchBox_button'
try.
	search searchBox
	wd 'set searchBox text ""'
	invalidateDisplay ''
catch. catcht.
	log (13!:12) ''
	log dbError ''
end.
)

vizform_searchBox_char =: 3 : 0
log 'vizform_searchBox_char ' , searchBox
animate 3
)

vizform_history_select =: 3 : 0
log 'vizform_history_select'
loadPage (". history_select) { getHistoryMenu ''
)

vizform_launch_button =: 3 : 0
log 'vizform_launch_button ' , ": > 0 { 0 { getHistoryMenu ''
launch_jbrowser_ > 0 { 0 { getHistoryMenu ''
)

vizform_loadPost_button =: 3 : 0
log 'vizform_loadPost_button'
loadForumPost ''
)

animate =: 3 : 0
NB. y Number of frames to animate
log 'animate ' , ": y
wd 'timer 20'
TimerCount =: y
)

TimerCount =: 0

sys_timer_z_ =: 3 : 0
log_jwikiviz_ 'sys_timer_z_'
try.
if. TimerCount_jwikiviz_ > 0 do.
	TimerCount_jwikiviz_ =: TimerCount_jwikiviz_ - 1
	invalidateDisplay_jwikiviz_ ''
	layoutForm_jwikiviz_ ''
	wd 'timer 20'
else.
	wd 'timer 0'
end.
catch.
	smoutput (13!:12) ''
	smoutput dbError_jwikiviz_ ''
	log (13!:12) ''
	log dbError_jwikiviz_ ''
end.
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
'vocW vocH' =. ". wd 'get vocContext wh'
drawFloatingString vocW , vocH
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
searchCatId =. , > > {: sqlreadm__db 'select categoryid from categories where parentid = ' , ": SearchHiddenCatId
searchCount =. , > > {: sqlreadm__db 'select count(parentseq) from categories where parentid = ' , ": searchCatId
parentSeq =. 10000 - searchCount
cols =. ;: 'level parentid categoryid category count parentseq link'
sqlinsert__db 'categories' ; cols ; < 1 ; (termParentId =. SearchHiddenCatId getCategoryId SearchCatString) ; (nextUserCatId 1) ; (< term) ; _1 ; parentSeq ; 'https://www.jsoftware.com'
NB. sqlinsert__db 'categories' ; cols ; < 3 ; (termParentId getCategoryId term) ; (nextUserCatId 1) ; (< 'Wiki') ; _1 ; 0 ; 'https://code.jsoftware.com/wiki/Special:JwikiSearch'
)

searchWiki =: 3 : 0
NB. y Search term
NB. Perform the search, parse the results, and update the "categories" and "wiki" tables.
NB. Return the links ; titles.
log 'Searching wiki for ' , y , '...'
NB. url =. 'https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=1000&offset=0&profile=default&search=' , urlencode y
NB. url =. 'https://code.jsoftware.com/mediawiki/index.php?title=Special%3AJwikiSearch&for=' , urlencode y
url =. 'https://code.jsoftware.com/mediawiki/index.php?title=Special%3AJwikiSearch&blk=300&offset=0&for=' , urlencode y
html =. gethttp url
pat =. rxcomp 'mw-search-result-heading"><a href="([^"]+)">([^<]+)<'
offsetLengths =.  pat rxmatches html
NB. wikiId =. ((SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Wiki'
log '...received ' , (": # html) , ' bytes with ' , (": # offsetLengths) , ' hits.'
if. 0 = # offsetLengths do.
NB.	sqlupdate__db 'categories' ; ('categoryid = ' , ": wikiId) ; ('count' ; 'level') ; < 0 ; 3
	links =. ''
	titles =. ''
else.
	ol =. 1 2 {"2 offsetLengths
	linkOffsets =. 0 {"(1) 0 {"2 ol
	titleOffsets =. 0 {"(1) 1 {"2 ol
	linkLengths =. 1 {"(1) 0 {"2 ol
	titleLengths =. 1 {"(1) 1 {"2 ol
	links =. 'https://code.jsoftware.com'&, &. > linkLengths <@{."0 1 linkOffsets }."0 1 html
	titles =. titleLengths <@{."0 1 titleOffsets }."0 1 html
	wikiCols =. ;: 'title categoryid link'
	termParentId =. SearchHiddenCatId getCategoryId SearchCatString
	cols =. ;: 'level parentid categoryid category count parentseq link'
	sqlinsert__db 'categories' ; cols ; < 3 ; (termParentId getCategoryId y) ; (nextUserCatId 1) ; (< 'Wiki') ; (# titles) ; 0 ; 'https://code.jsoftware.com/wiki/Special:JwikiSearch'
	wikiId =. ((SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Wiki'
	data =. titles ; (wikiId #~ # titles) ; < links
	sqlinsert__db 'wiki';wikiCols;<data	
end.
if. 0 < # links do.
	queueUrl ({. links) , ({. titles)
end.
# links
NB. links ,. titles
)

searchForums =: 3 : 0
NB. y Search term		
NB. Perform the search, parse the results, and update the "categories" and "wiki" tables.
try.
log 'Searching forums for ' , y , '...'
wikiCols =. ;: 'title categoryid link'
NB. html =. (2!:0) 'curl "https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2030"'
url =.'https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2100&blk=300'
html =. '-s' gethttp url
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
	forums =. 'J'&, &. > > _3&{ &. > < ;. _2 &. > ,&'/' &. > links
NB.	forums =. forumLengths <@{."0 1 forumOffsets }."0 1 html
	titles =. titleLengths <@{."0 1 titleOffsets }."0 1 html
	titleGroups =. forums </. titles
	linkGroups =. forums </. links
	for_index. i. # titleGroups do.
		fname =. > index { ~. forums
		forumLinks =. > index { linkGroups
		forumTitles =. > index { titleGroups
		cols =. ;: 'level parentid categoryid category parentseq count link'
		data =. 3 ; termId ; (nextUserCatId 1) ; fname ; (>: index) ; (# forumLinks) ; 'https://www.jsoftware.com/mailman/listinfo/' , }. fname
		sqlinsert__db 'categories' ; cols ; < data
		forumId =. termId getCategoryId fname
		data =. forumTitles ; (forumId #~ # forumLinks) ; < forumLinks
		sqlinsert__db 'wiki';wikiCols;<data
	end.
	count =. {. , > > {: sqlreadm__db 'select sum(count) from categories where parentid = ' , ": termId
else.
	count =. 0
end.
otherTermId =. (getTopCategoryId SearchCatString) getCategoryId y
parms =. 'categories' ; ('categoryid = ' , ": otherTermId) ; (;: 'count level') ; < count ; 2
sqlupdate__db parms
catcht.
	log (13!:12) ''
	log 'searchForums Db Error (if any): ' , dbError ''
end.
count
)

search =: 3 : 0
NB. y A search term.
try.
	log 'Searching for ' , y
	addSearchToToc y
	clearCache ''
	invalidateDisplay ''
	wd 'msgs'
NB.	wikiResults =. searchWiki y
	wikiCount =. searchWiki y
	forumCount =. searchForums y
	clearCache ''
	if. 0 = wikiCount + forumCount do.
		termCategoryId =. (SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y
		sqlupdate__db 'categories' ; ('categoryid = ' , ": termCategoryId) ; (;: 'count level') ; < (wikiCount + forumCount) ; 1
	end.
	selectFirstSearchResult ''
	invalidateDisplay ''
catcht.
	log (13!:12) ''
	log 'search Db Error (if any): ' , dbError ''
end.
)

selectFirstSearchResult=: 3 : 0
log 'selectFirstSearchResult'
NB. Select first search result in the Table of Contents (TOC).
index =. (< SearchCatString) i.~ 3 {"(1) 1 getTocOutlineRailEntries MaxTocDepth NB. Table of level ; parentid ; categoryid ; category ; parentseq ; count ; link
setTocOutlineRailSelectedIndex index
setTocEntryChildCategoryIndex 1
NB. queueUrl y
)

NB. ================== Drawing ====================
MaxCellWidth =: 100
MinColWidth =: 200
CellMargin =: 5
CellLineHeight =: 22
DocumentLineHeight =: 26
SectionFont =: 'arial bold 16'

BackgroundColor =: 255 255 255
SectionColor =: 0 0 0
LabelColor =: 0 102 204
ColumnGuideColor =: 220 220 220
ColumnBorderColor =: 220 220 220
SelectionColor =: 0 0 0
HoverColor =: 255 0 0 
BarColor =: 245 195 150
CountColor =: 0 0 255
CountFont =: 'arial 15'

VocSelectedGlyph =: ''
DocumentSelectedIsletIndex =: _1
DocumentSectionGeometry =: '' NB. index x y width height label sectionName columnId url
DocumentSectionSelectedIndex =: _1
VocTable =: '' NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
POSColors =: 221 204 255 , 204 238 255 , 238 255 204 , 255 204 238 , 221 221 221 ,: 238 170 170
POSNames =: ;: 'Verb Adverb Conjunction Noun Copula Control'
VocCellFont =: 'consolas 14 bold'
VocValenceFont =: 'arial 14'
CategoryIndex =: 0
CategoryTable =: ''
HighlightUrls =: '' NB. Holds the labels ; URLs to be used for highlighting the map. 
TocFont =: 'arial 13'
LiveSearchFont =: 'courier 16'
TocLineHeight =: 25
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
LiveSearchCatString =: '*Live Search'
TagCatString =: '*Tags'
TagHiddenCatId =: 500000
QueuedUrl =: ''
QueuedUrlTime =: 0
QueuedUrlTimeDelay =: 250
SuppressMouseHandlingStart =: 0
PageLoadFreezeTime =: 0
PageLoadFreezeRect =: ''
PageLoadFreezeDuration =: 3
MWheelOffset =: 0
LogFlag =: 0
XFileHashLabel =: > IFWGET_wgethttp_ { 'x-file-hash: ' ; 'X-File-Hash: '

getTocFontForLevel =: 3 : 0
NB. y An integer level in an outline hierarchy.  _1 indicates a page; 0..n indicates a level.
NB. Return the string specification of the font to use.
if. y < 0 do. 'arial 16' return. end.
fonts =. 'arial bold 17' ; 'arial bold 14' ; 'arial 14'
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
try.
NB.	log 'drawStringAt ' , (": x) , ' ' , y
	gltextxy x
	gltext y
catch.
	log 'drawStringAt ' , (": x) , ' ' , y
	log 'Error in drawStringAt: ' , (13!:12) ''
NB.	smoutput 'Could not drawStringAt' ; x ; y
NB.	log 'Could not drawStringAt' ; x ; y 
end.
)

drawHighlight =: 4 : 0 
NB. x xx yy w h
NB. y color (r g b) but no (a)
NB. glrgb y
color =. y , 255 NB. <. 255 * | 1 o. 2 * {: (6!:0) ''
glrgba color
glpen 3
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
log 'bookmark '
'url title' =. {. getHistoryMenu ''
log '...(bookmark) '  , url , ' ' , title
id =. (getTopCategoryId BookmarkCatString)
if. isBookmarked url do.
	log '...(bookmark) DELETING'
	sqlcmd__db 'delete from wiki where categoryid = ' , (": id) , ' and link = "' , url , '"'
else.
	log '...(bookmark) ADDING'
	sqlinsert__db 'wiki' ; (;: 'title categoryid link') ; < title ; id ; url
end.
clearCache ''
invalidateDisplay ''
resetBookmarkButton ''
)

NB. --------- Managing URLs from the Forum ---------
shouldShowPostLoadButton =: 3 : 0
NB. y A url, possibly from a Forum
NB. Return 1 if the url is for a Forum post AND we're currently showing search results.
1 *. -. '' -: reverseEngineerForumUrl y
)

reverseEngineerForumUrl =: 3 : 0
NB. y A url, possibly from a Forum
NB. If it's from a Forum, return the forum name, link, month (Jan/Feb/...), and year.
NB. If it's not from a Forum, return ''
NB. Sample Forum url: https://www.jsoftware.com/pipermail/programming/2023-July/062652.html
if. 0  = +/ '/pipermail/' E. y do. '' return. end.
'link forumName' =. _1 _3{ <;._2 y , '/'
link =. 6 {. link
forumName =. 'J' , forumName
result =. , > {: sqlreadm__db 'select year, month from forums where forumname = "' , forumName , '" AND link = "' , link , '"'
NB.  smoutput 'result' ; result
'year monthIndex' =. result
years =. , > {: sqlreadm__db 'select distinct year from forums where forumname = "' , forumName , '" order by year'
forumName ; link ; (> monthIndex { ShortMonths) ; year
)

resetForumPostLoadButton =: 3 : 0
NB. If the current page is a forum post, show the forum load button.
NB. Note that we only want to do this if we're looking at Search results.
LayoutForumPostLoadButtonEnable =: shouldShowPostLoadButton LastUrlLoaded
layoutForm ''
)

loadForumPost =: 3 : 0
NB. Load the currently-displayed Forum post in the Forums section of the table of contents.
NB. ForumCacheTable year ; month ; subject ; author ; link
'forumName link month year' =. reverseEngineerForumUrl LastUrlLoaded
entries =. 1 getTocOutlineRailEntries MaxTocDepth  NB. level ; parentid ; categoryid ; category ; parentseq ; count ; link
setTocOutlineRailSelectedIndex (, 3 {"1 entries) i. < forumName
resetForumCache forumName
subject =. > (2 {"1 ForumCacheTable) {~ (4 {"1 ForumCacheTable) i. < link
resetForumAuthorEntries < subject
setTocEntryForumYear year
setTocEntryForumMonth month
calendarMonthIndex =. ShortMonths i. < TocEntryForumMonth
entries =. ForumCacheTable #~ (TocEntryForumYear = > {."1 ForumCacheTable) *. calendarMonthIndex = > 1 {"1 ForumCacheTable NB. entries: year ; month ; subject ; author ; link
allSubjects =. 2 {"1 ForumCacheTable #~ (2 {"1 ForumCacheTable) e. ~. 2 {"1 entries
subjects =. ~. allSubjects
subjectIndex =. subjects i. < subject
setTocEntryForumSubjectIndex subjectIndex
authorIndex =. (< link) i.~ (4 {"1 ForumCacheTable) #~ (< subject) = 2 {"1 ForumCacheTable
setTocEntryForumAuthorIndex authorIndex
NB. smoutput smoutput  'subjectIndex authorIndex subjects subject'  ; subjectIndex ; authorIndex ; (,.  subjects) ; subject
invalidateDisplay ''
)
NB. ---------  End Managing URLs from the Forum --------

queueUrl =: 3 : 0
NB. y A url to queue for delayed loading ; A title
log 'queueUrl ' , (0 {:: y) , ' ' , 1 {:: y
NB. if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do. return. end.
QueuedUrl =: y
QueuedUrlTime =: (6!:1) ''
NB. wd 'timer ' , ": QueuedUrlTimeDelay
loadQueuedUrl ''
)

loadQueuedUrl =: 3 : 0
loadPage QueuedUrl
QueuedUrl =: ''
)

clearQueuedUrl =: 3 : 0
NB. Do not, after all, load the queued url.  Used when the user has entered the webview.
QueuedUrl =: ''
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
'url title' =. y
NB. url =. > {. y
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
addToHistoryMenu (< url) , < title
catch.
	smoutput (13!:12) ''
	log (13!:12) ''
end.
)

NB. ========================= Floating Strings ===============================
FloatingString =: ''
FloatingStringRect =: ''

registerFloatingString =: 4 : 0
NB. x xx yy width height
NB. y string ; font ; textColor
log 'registerFloatingString ' , (": x) 
FloatingStringRect =: x
FloatingString =: y
)

drawFloatingString =: 3 : 0
NB. y windowWidth windowHeight
log 'drawFloatingString ' , ": y
'windowWidth windowHeight' =. y
if. 0 = # FloatingString do. return. end.
'string font textColor' =. FloatingString
glfont font
glrgb BackgroundColor
glbrush ''
glpen 0
'xx yy width height' =. FloatingStringRect
width =. width + 5
newX =. width -~ (xx + width) <. windowWidth
rect =. newX , yy , width , height 
glrect rect
glrgb textColor
gltextcolor ''
(2 {. rect) drawStringAt string
NB. if. (2 { FloatingStringRect) < width do.
	rect drawHighlight HoverColor
NB. end.
FloatingStringRect =: ''
FloatingString =: ''
)

NB. ======================== Mouse-Sensitive Areas ===========================
isFrozen =: 3 : 0
PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime
)

LastUrlCommandSelected =: ''

registerRectLink =: 4 : 0
NB. x xx yy width height
NB. y A url or * to be evaluated ; a title ; loadMode (0 indicates hover, 1 indicates click)
NB. Record this for mouse processing: highlighting and loading urls.
NB. Note that since we're frame-based, we re-register rect/links on every frame.  So we 
NB. just check immediately to see whether the mouse is inside the rect and activate accordingly.
'urlCommand name loadMode' =. y
NB. if. isFrozen '' do. 0 return. end.
if. urlCommand -: LastUrlCommandSelected do. 
	x drawReversibleSelection SelectionColor 
end.
if. -. VocMouseXY pointInRect x do. 0 return. end.
if. loadMode = 1 do.
	x drawReversibleSelection HoverColor
end.
if. loadMode = 0 do.
	if. '*' = {. urlCommand do.
		". }. urlCommand
		LastUrlCommandSelected =: urlCommand
	else. 
		queueUrl urlCommand ; name
		LastUrlCommandSelected =: urlCommand
	end.
elseif. VocMouseClickXY pointInRect x do.
	if. '*' = {. urlCommand do.
		". }. urlCommand
		LastUrlCommandSelected =: urlCommand
	else. 
		loadPage urlCommand ; name
		LastUrlCommandSelected =: urlCommand
	end.
	invalidateDisplay ''
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

NB. ============================== Scroller Field ===============================
drawScrollerField =: 4 : 0
NB. x xx yy width height
NB. y strings ; links ; counts ; levels ; selectedIndex ; scrollIndex ; loadMode ; hoverCallback
NB. The "levels" indicate indention (0...n).  A level of _1 indicates that it's a page link, not a heading.
NB. Draw the strings and registerRectLink to highlight them and load pages.
NB. Use VocMouseXY to update scrollOffset and selectedIndex.
NB. Return the scrollIndex, which may have changed.
log 'drawScrollerField ' , (": x)
rect =. x
'strings links counts levels selectedIndex scrollIndex loadMode hoverCallback' =. y
'xx yy w h' =. rect
log '...(drawScrollerField) ' , ": (# strings) , (# links) , (# levels) , selectedIndex , scrollIndex , loadMode
window =. <. TocLineHeight %~ -: h
maxLineCount =. <. h % TocLineHeight
margin =. 30
if. VocMouseXY pointInRect xx , yy , (-: w) , h do. glcursor IDC_SIZEVER end.
if. VocMouseXY pointInRect (xx + -: w) , yy , (-: w) , h do. glcursor IDC_POINTINGHAND end.
if. VocMouseXY pointInRect xx , yy , (-: w) , h do.
	tentativeScrollIndex =. 0 >. (window -~ # strings) <. <. (-: window) -~ (# strings) * (yy -~ {: VocMouseXY) % h
	if. scrollIndex ~: tentativeScrollIndex do.
		if. scrollIndex > tentativeScrollIndex do. scrollIndex =. <: scrollIndex else. scrollIndex =. >: scrollIndex end.
		animate 2
	else.
		scrollIndex =. tentativeScrollIndex
	end.
end.	
windowStartIndex =. scrollIndex NB. <. 0 >. (# strings) <. 0 >. scrollIndex - -: window
squishedLineHeight =. TocLineHeight <. (window -~ # strings) %~ h - window * TocLineHeight
heights =. (# strings) {. (windowStartIndex # squishedLineHeight) , (window # TocLineHeight) , 1000 # squishedLineHeight
ys =. <. }: +/\ 0 , heights
heights =. <. heights
origins =. <. (margin + xx) ,. 5 + yy + ys
glrgb LabelColor
gltextcolor ''
glpen 1
glrgb BackgroundColor
glbrush ''
glrect rect
glrgb ColumnGuideColor
glbrush ''
glpen 0
glrect xx , yy , (<. -: w) , h
scrollBarHeight =. <. h * window % # strings
scrollBarOffset =. <. h * scrollIndex % # strings
if. maxLineCount < # strings do.
	glrgb 3 # 200
	glbrush ''
	glpen 0
	glrect (xx + w - thickness) , (yy + scrollBarOffset) , (thickness =. 10) , scrollBarHeight
end.
for_i. i. # strings do.
	lineHeight =. i { heights
	origin =. > i { origins
	glrgb BarColor
	glbrush ''
	glpen 0
	if. (lineHeight >: TocLineHeight) *. _1 < i { counts do.
		glfont CountFont
		glrgb CountColor
		gltextcolor ''
		countWidth =. {. glqextent c =. ": i { counts
		(origin - (countWidth + 2) , 0) drawStringAt c
	end.
	glfont getTocFontForLevel i { levels
	glrgb getTocColorForLevel i { levels
	glbrush ''
	gltextcolor''
	glclip xx , yy , w , h
	string =. > i { strings
	origin =. > i { origins
	if. lineHeight >: TocLineHeight do. 
		stringWidth =. {. glqextent string
		if. (VocMouseXY pointInRect origin , w , TocLineHeight) *. stringWidth >: (w - margin) do.
			((origin + 0 1) , stringWidth , TocLineHeight - 2) registerFloatingString string ; (getTocFontForLevel i { levels) ; (getTocColorForLevel i { levels)
		else.
			origin drawStringAt string 
		end.
	else.
		stringWidth =. {. glqextent > i { strings
		glpen 0
		glrect (> i { origins) , stringWidth , 1
	end.
	if. i = selectedIndex do. (origin , (w - margin) , lineHeight) drawHighlight SelectionColor end.
	if. VocMouseXY pointInRect xx , yy , w , h do. (origin, (w - margin) , lineHeight) registerRectLink (> i { links) ; (> i { strings) ; loadMode end.
	if. VocMouseXY pointInRect (origin , w , lineHeight) do. ". hoverCallback , ' ' , ": i end.		
end.
glclip 0 0 100000 100000
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
nameWidth =. {. glqextent name
adjRect =. xx , yy , (maxWidth - 16) , height
if. (VocMouseXY pointInRect x) *. nameWidth >: maxWidth - 16 do. 
	(xx , yy , nameWidth , TocLineHeight) registerFloatingString name ; (getTocFontForLevel level) ; getTocColorForLevel level 
end.
(xx , yy) drawStringAt name
if. highlightFlag do. adjRect drawHighlight SelectionColor end.
adjRect registerRectLink command ; name ; 1
)

drawTocEntryChildrenColumn =: 4 : 0
NB. x xx yy width height
NB. y Table of Name ; Link/Command ; Level
NB. Render the column
'xx yy width height' =. x
glclip xx , yy , (width - 10) , height
margin =. 5
rect =. (margin + xx) ,. (margin + yy + TocLineHeight * i. # y) ,"0 1 width , TocLineHeight
rect drawTocEntryChild"1 1 y
glclip 0 0 10000 10000
rect
)

TocEntryForumMonth =: ''

setTocEntryForumMonth =: 3 : 0
NB. y The month whose posts we'll display
TocEntryForumMonth =: y
setTocEntryForumSubjectIndex 0
ForumSubjectScrollIndex =: 0
)

TocEntryForumYear =: 2023

setTocEntryForumYear =: 3 : 0
NB. y The year whose posts we'll display
TocEntryForumYear =: y
setTocEntryForumSubjectIndex 0
ForumSubjectScrollIndex =: 0
setTocEntryForumMonth > {. ForumMonthStrings
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
NB. The index of the author who's currently highlighted.
TocEntryForumAuthorIndex =: y
'year month subject author link' =. TocEntryForumAuthorIndex { ForumAuthorEntries
queueUrl ('https://www.jsoftware.com/pipermail/' , (}. ForumCurrentName) , '/' , (": year) , '-' , (> month { Months) , '/' , link , '.html') ; subject -. LF
)

NB. ---------------------- Live Search ---------------------------
indexDbFile =: '~temp/jsearch.db'
liveSearchDb =: ''

openLiveSearchDb =: 3 : 0
if. liveSearchDb -: '' do. liveSearchDb =: sqlopen_psqlite_ indexDbFile end.
)

jEnglishDict =: _2 ]\ '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco'
jMnemonics =: , &. > 0 {"1 jEnglishDict
jEnglishWords =: 'J'&, &. > 1 {"1 jEnglishDict
  
LiveSearchResults =: '' NB. Title ; Snippet ; URL
LastLiveSearchQuery =: ''

createQuery =: 3 : 0
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
NB. Return a NEAR query of JEnglish tokens and English tokens
raw =. ('''' ; '''''') rxrplc y
rawTokens =. ;: raw
hits =. jMnemonics i."1 0 rawTokens
tokens =. hits {"0 1 jEnglishWords ,"1 0 rawTokens
englishPortion =. tokens -. jEnglishWords
jPortion =. tokens -. englishPortion	
'NEAR("' , (; jPortion ,. <' ') , '" ' , ( ; englishPortion ,. <' ') , ', 100)'
)

translateToJ =: 3 : 0
NB. y A string possibly containing JEnglish tokens
tokens =. ;: y
hits =. jEnglishWords i."1 0 tokens
; (hits {"0 1 jMnemonics ,"1 0 tokens) ,. <' '
)

liveSearch =: 3 : 0
NB. y Empty
NB. Treat the J code as a quoted phrase for query purposes.
NB. Treat the English (non-J) tokens separately in the query.
NB. Return a table of title ; Snippet ; Url
if. searchBox -: LastLiveSearchQuery do. return. end.
LastLiveSearchQuery =: searchBox
try. openLiveSearchDb '' catch. return. end.
query =. createQuery searchBox
result =. > {: sqlreadm__liveSearchDb 'select title, snippet(jindex, 2, '''', '''', '''', 15), url from jindex where body MATCH ''' , query , ''' order by rank limit 1000'
snippets =. translateToJ &. > 1 {"1 result
results =. (0 {"1 result) ,. snippets ,. 2 {"1 result
uniques =. (~: snippets) # results
LiveSearchResults =: uniques
NB. smoutput LiveSearchResults
)

translateToJEnglish =: 3 : 0
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
raw =. ('''' ; '''''') rxrplc y
rawTokens =. ;: raw
hits =. jMnemonics i."1 0 rawTokens
string =. ; (hits {"0 1 jEnglishWords ,"1 0 rawTokens) ,. < ' '
)

drawTocEntryLiveSearch =: 3 : 0
NB. y xx yy width height
NB. Display the results of the current search against the local database.
'xx yy width height' =. y
glclip 0 0 10000 100000
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
glfont LiveSearchFont
colSep =: 20
liveSearch ''
if. 0 = # LiveSearchResults do. return. end.
results =. ((# LiveSearchResults) <. <. height % TocLineHeight) {. LiveSearchResults
titles =. 0 {"1 results
snippets =. 1 {"1 results
links =. 2 {"1 results
colWidth =. <. -: width - colSep
glclip xx , yy , colWidth , height
snippetOrigins =. (xx + 5) ,. TocLineHeight * i. # results
(<"1 snippetOrigins) drawStringAt &. > snippets
titleOrigins =. (xx + colSep + colWidth) ,. TocLineHeight * i. # results
glclip (xx + 5 + colWidth) , yy , colWidth , height
(<"1 titleOrigins) drawStringAt &. > titles
glclip 0 0 10000 100000
(snippetRects =. <"1 snippetOrigins ,"1 1 colWidth , TocLineHeight) registerRectLink &. > <"1 links ,. titles ,. (# snippets) # < 1
(titleRects =. <"1 titleOrigins ,"1 1 colWidth , TocLineHeight) registerRectLink &. > <"1 links ,. titles ,. (# titles) # < 1
if. _1 < titleIndex =. {. _1 ,~ I. > VocMouseXY&pointInRect &. > titleRects do.
	title =. > titleIndex { titles
	floatRect =. (2 {. > titleIndex { titleRects) , (colWidth >. {. glqextent title) , TocLineHeight
	floatRect registerFloatingString title ; LiveSearchFont ; 0 0 0
end.
if. _1 < snippetIndex =. {. _1 ,~ I. > VocMouseXY&pointInRect &. > snippetRects do.
	snippet =. > snippetIndex { snippets
	floatRect =. (2 {. > snippetIndex { snippetRects) , (colWidth >. {. glqextent snippet) , TocLineHeight
	floatRect registerFloatingString snippet ; LiveSearchFont ; 0 0 0
end.
)
NB. ---------------------- End Live Search ------------------------

ForumCacheTable =: '' NB. Year ; Month ; Subject ; Author ; Link
ForumCurrentName =: ''
ForumSubjectScrollIndex =: 0
ForumAuthorScrollIndex =: 0
ForumAuthorEntries =: ''  NB. Year ; Month ; Subject ; Author ; Link
ForumMonthStrings =: ''
ForumYearBumpCount =: 0
ForumMonthBumpCount =: 0

resetForumCache =: 3 : 0
NB. y Forum name
NB. Fill the forum cache with y's posts.
NB. ForumCacheTable year ; month ; subject ; author ; link
result =. > {: sqlreadm__db 'select year, month, subject, author, link from forums where forumname = "' , y , '" order by year desc, month asc'
ForumCacheTable =: 0 1 2 3 4 {"1 result
ForumCurrentName =: y
TocEntryForumSubjectIndex =: 0
ForumAuthorEntries =: ''
)

resetForumAuthorEntries =: 3 : 0
NB. y Subject string  (boxed)
ForumAuthorEntries =: e /: 4 {"1 e =. ForumCacheTable #~ (2 {"1 ForumCacheTable) = y  NB. Check all posts since conversations may span months.
)

drawTocEntryForum =: 4 : 0
NB. x The name of the forum
NB. y xx yy width height
NB. Display the contents of the forum
NB. x y width height drawScrollerField strings ; links ; ratios ; levels ; selectedIndex ; scrollIndex
log 'drawTocEntryForum ' , x , ' ' , (": TocEntryForumYear) , ' ' , ": TocEntryForumMonth
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
'xx yy width height' =. y
if. -. ForumCurrentName -: x do. resetForumCache x end.
margin =. 5
glclip 0 0 10000 100000
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
colWidth =. <. -: width - +: margin
dateHeight =. 50
colHeight =. height - dateHeight
subjRect =. (xx + margin) , (yy + dateHeight) , colWidth, colHeight
authRect =. subjRect + (colWidth + margin) , 0 0 0
years =. \:~ ~. > {."1 ForumCacheTable
TocEntryForumYear =: (years i. TocEntryForumYear) { years , {. years
if. 0 = # years do. return. end.
monthIndexes =. > ~. 1 {"1 ForumCacheTable #~ TocEntryForumYear = yyyy =. > {."1 ForumCacheTable
ForumMonthStrings =: monthIndexes { ShortMonths
if. (# ForumMonthStrings) = ForumMonthStrings i. < TocEntryForumMonth do. TocEntryForumMonth =: > {: ForumMonthStrings end.
monthIndex =. ForumMonthStrings i. < TocEntryForumMonth
timeLineHeight =. 20
yearWidth =. 30
yearOrigins =. (xx + margin + yearWidth * i. # years) ,. yy + margin
monthOrigins =. (# ForumMonthStrings) {. <"1 (xx + margin + 45 * i.12) ,. yy + margin + timeLineHeight
yearStrings =: '`',. _2 {."1 ": ,.years
glrgb SectionColor
gltextcolor ''
glfont SectionFont
yearOrigins drawStringAt"1 1 > ": &. > <"0 yearStrings
monthOrigins drawStringAt &. > ForumMonthStrings
rects1 =. (<"1 yearRects =. (yearOrigins -"(1 1) _2 2) ,"(1 1) yearWidth , TocLineHeight) 
yearCommands =: '*setTocEntryForumYear '&, &. > ": &. > <"0 years
rects1 registerRectLink &. > <"1 yearCommands ,"0 1 ' ' ; 1
rects2 =. (<"1 monthRects =. (_2 + > monthOrigins) ,"(1 1) 40 , TocLineHeight) 
monthCommands =. '*setTocEntryForumMonth '''&, &. > ": &. > ,&'''' &. > ForumMonthStrings
rects2 registerRectLink &. > <"1 monthCommands ,"0 1 ' ' ; 1
((years i. TocEntryForumYear) { yearRects) drawHighlight SelectionColor
(monthIndex { monthRects) drawHighlight SelectionColor
calendarMonthIndex =. ShortMonths i. < TocEntryForumMonth
entries =. ForumCacheTable #~ (TocEntryForumYear = > {."1 ForumCacheTable) *. calendarMonthIndex = > 1 {"1 ForumCacheTable NB. entries: year ; month ; subject ; author ; link
if. 0 = # entries do. return. end.
subjects =. ~. 2 {"1 entries
ratios =. authorCounts % >./ authorCounts =. allSubjects #/. allSubjects =. 2 {"1 ForumCacheTable #~ (2 {"1 ForumCacheTable) e. subjects
subjects =. ~. allSubjects
subject =. TocEntryForumSubjectIndex { subjects 
resetForumAuthorEntries subject
authors =. 3 {"1 ForumAuthorEntries
subjectCommands =. '*setTocEntryForumSubjectIndex '&, &. > ": &. > <"0 i. # subjects
authorCommands =. '*setTocEntryForumAuthorIndex '&, &. > ": &. > <"0 i. # authors
ForumSubjectScrollIndex =: subjRect drawScrollerField subjects ; subjectCommands ; authorCounts ; (2 #~ # subjects) ; TocEntryForumSubjectIndex ; ForumSubjectScrollIndex ; 1 ; '<'
ForumAuthorScrollIndex =: authRect drawScrollerField  authors ; authorCommands ; (_1 #~ # authors) ; (_1 #~ # authors) ; TocEntryForumAuthorIndex ; ForumAuthorScrollIndex ; 1 ; '<'
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
tocWikiDocs =. getTocWikiDocs categoryId NB. Table of (level parentid categoryid category parentSeq count link) ; table of title ; link
if. 1 = # $ tocWikiDocs do. '' return. end.
NB. ratios =. counts % maxCount =. >./ counts =. > # &. > 1 {"1 tocWikiDocs
counts =. > 5 {"1 > {."1 tocWikiDocs
margin =. 5
categoryEntries =. > {."1 tocWikiDocs  NB. categoryEntries: table of level parent categoryid category parentSeq count link
indents =. #&'  ' &. > <: &. > 0 {"1 categoryEntries
levels =. (] - <./) > {."1 categoryEntries
catTitles =. indents , &. > 3 {"1 categoryEntries
catLinks =. 6 {"1 categoryEntries
catHighlightFlags =. (-TocEntryChildCategoryIndex) |. 1 , 0 #~ <: # catTitles
NB. cleanCategories =. ('''';'''''')&rxrplc &. > 1 {"1 catTitles
cleanCategories =. ('''';'''''')&rxrplc &. > catTitles
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
	glrgb ColumnBorderColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
headerColumn =. > {. columnGroups
parms =. (1 {"1 headerColumn) ; (2 {"1 headerColumn) ; counts ; levels ; TocEntryChildCategoryIndex ; TocEntryChildScrollIndex ; 1 ; '<'
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
glrgb BackgroundColor
glbrush ''
glrect y
margin =. 5
subcatEntries =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link, categoryid from categories where parentid = ' , ": TagHiddenCatId getCategoryId TagCatString
subcats =. 3 {"1 subcatEntries
subcatColWidth =. <. width % 3
detailX =. xx + subcatColWidth + margin
detailWidth =. width - subcatColWidth + margin
commandLinks =. '*setTocEntryTagSubcatIndex '&, &. > ": &. > <"0 i. # subcats
scrollEntries =. subcats ; commandLinks ; (0 #~ # subcats) ; (2 #~ # subcats) ; TocEntryTagSubcatIndex ; TocEntryTagScrollIndex ; 1 ; '<'
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
	glrgb ColumnBorderColor
	glbrush ''
	glpen 0
	w =. <. detailWidth % # columnRects
	glrect <. (detailX + selectedColumnIndex * w) , yy , w , height
end.
if. 1 = # columnRects do.
	(< 0 0 500 0 + , > columnRects) drawTocEntryChildrenColumn &. > columnGroups
else.
	columnRects drawTocEntryChildrenColumn &. > columnGroups
end.
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
topLevel =. > {. > {. {. tocWikiDocs
if. topLevel < MaxTocDepth do. tocWikiDocs =. ,: {. tocWikiDocs end. NB. Don't show a subtree that's already visible in the left TOC pane.
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
	glrgb ColumnBorderColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
if. 1 = # columnRects do.
	(< y) drawTocEntryChildrenColumn &. > columnGroups
else.
	columnRects drawTocEntryChildrenColumn &. > columnGroups
end.
''
)

TocOutlineRailSelectedIndex =: 0
TocOutlineRailScrollIndex =: 0
TocOutlineRailHoverIndex =: 0

setTocOutlineRailSelectedIndex =: 3 : 0
NB. y The new value of the index
TocOutlineRailSelectedIndex =: y
entry =. y { 1 getTocOutlineRailEntries MaxTocDepth  NB. level ; parentid ; categoryid ; category ; parentseq ; count ; link
queueUrl (> 6 { entry) ; > 3 { entry
)

setTocRailHoverIndex =: 3 : 0
NB. y The index of the currently-hovered entry in the TOC rail.
TocOutlineRailHoverIndex =: y
)

drawTocRailChildren =: 4 : 0
NB. x Toc outline rail entry whose children need to be drawn.
NB. y The rectangle in which to draw.
entry =. x
if.  +./ '*NuVoc' E. > 3 { entry do.
	drawVoc ''
elseif. (getTopCategoryId ForumsCatString) = > 1 { entry do. NB. level ; parent ; categoryid ; category ; parentseq ; count ; link
	(> 3 { entry) drawTocEntryForum y
elseif. TagCatString -: > 3 { entry do.
	drawTocEntryTags y
elseif. LiveSearchCatString -: > 3 { entry do.
	drawTocEntryLiveSearch y
elseif. (< SearchCatString) = 3 { entry do.
	(SearchHiddenCatId getCategoryId SearchCatString) drawTocEntryChildrenWithTree y
else.
	categoryId =. (> 1 { entry) getCategoryId > 3 { entry
	categoryId drawTocEntryChildren y
end.
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
NB. parms =. indentStrings ; linkCommands ; (maxCount %~ > 5 {"1 entries) ; levels ; TocOutlineRailSelectedIndex ; TocOutlineRailScrollIndex ; 0
parms =. indentStrings ; linkCommands ; (> 5 {"1 entries) ; levels ; TocOutlineRailSelectedIndex ; TocOutlineRailScrollIndex ; 1 ; 'setTocRailHoverIndex'
TocOutlineRailScrollIndex =: x drawScrollerField parms
if. 200 > 2 { DisplayDetailRect do. return. end.
(TocOutlineRailSelectedIndex { entries) drawTocRailChildren DisplayDetailRect
return.
if. (VocMouseXY pointInRect x) *. TocOutlineRailHoverIndex ~: TocOutlineRailSelectedIndex do.
	delta =. 0 0 0 0 NB. 30 30 _60 _60
	glrgba 0 0 0 64
	glbrush ''
	glpen 0
	glrect DisplayDetailRect + delta + 10 10 0 0
	(TocOutlineRailHoverIndex { entries) drawTocRailChildren DisplayDetailRect + delta
	if. 0 ~: TocOutlineRailHoverIndex do. (DisplayDetailRect + delta) drawHighlight HoverColor end.
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
	entry =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link from categories where categoryid = ' , ": y
	wikiDocs =. > {: sqlreadm__db 'select title, link from wiki where categoryid = ' , ": y
	result =. ,: (< , entry) , < wikiDocs
	entries =. y getTocOutlineRailEntries 100
	if. 0 < # entries do.
		categories =. 3 {"1 entries
		parentIds =. 1 {"1 entries
		categoryIds =. parentIds getCategoryId &. > categories
		result =. result , (<"1 entries) ,. >@{: &. > sqlreadm__db &. > 'select title, link from wiki where categoryid = '&, &. > ": &. > categoryIds
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
((leftX - 4) , (yy - 1) , (width + 8) , 20) registerRectLink link ; label ; 1
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
NB. queueUrl n =: (> 7 { entry) ; > 5 { entry
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

dbExists =: 3 : 0
NB. Return 1 if the target db exists.
fexist targetDbPath
)

isOnTheNetwork =: 3 : 0
NB. Return 1 if we can connect to the CDN.
0 < # gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/upload.test?cache=false'
)

checkForNewerDatabase =: 3 : 0
NB. Return 1 if a newer database is available.  
NB. Return 2 is a newer database is required.
NB. Return 3 if we're not on the network.
NB. Return 0 if the local database is up to date.
if. -. dbExists '' do. 2 return. end.
if. -. isOnTheNetwork '' do. 3 return. end.
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
remoteHash =. getRemoteDatabaseHash ''
-. localHash -: remoteHash
)

downloadLatestStageDatabase =: 3 : 0
if. IFWGET_wgethttp_ do.
	('-O "' , stageDbPath , '"') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
else.
	('-s -o "' , stageDbPath , '"') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
end.
)

getRemoteDatabaseHash =: 3 : 0
if. IFWGET_wgethttp_ do.
	head =. (2!:0) s =. 'wget -o - -S --spider ' , ' https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
else.
	head =. ('--head -s') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
end.
if. 0 = # head do.
	3 
	return. 
end.
n {.~ LF i.~ n =. (13 + I. XFileHashLabel E. head) }. head
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
	try. (1!:22) < targetDbPath catch. end.  NB. Close the file.
end.
hash =. getRemoteDatabaseHash ''
smoutput 'downloadLatestStageDatabase: ' ; hash
try. (1!:22) < targetDbPath catch. end.
dbOpenDb ''
sqlclose__db ''
dbOpenDb ''
smoutput 'About to insert hash into admin table...'
sqlinsert__db 'admin' ; (;: 'key value') ; < 'Hash' ;  hash
smoutput '...succeeded.'
clearCache ''
smoutput 'downloadLatestStageDatabase succeeded.'
)


initialDbDownloadDialog =: 3 : 0
status =. {. , checkForNewerDatabase ''
select. status
case. 0 do. 1
case. 1 do. 1
case. 2 do.
	if. isOnTheNetwork'' do.
		result =. wd 'mb query mb_yes =mb_no "Local Database Status" "A new database is required.  Yes to download (to ~temp); No to quit."'
		if. result -: 'yes' do. 
			downloadAndTransferDatabase ''
			1
		else.
			0
		end.
	else.
		wdinfo '' ; 'Cannot connect to the CDN and a new database is required.  Please be sure you have an internet connection.  OK to exit.'
		0
	end.
case. 3 do.
	wdinfo '' ; 'Cannot connect to the CDN.  Please be sure you have an internet connection.'
	1
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
if. -. checkGethttpVersion '' do. return. end.
if. -. initialDbDownloadDialog '' do. return. end.
dbOpenDb ''
initAdmin ''
loadVoc ''
clearLog ''
buildForm ''
layoutForm ''
setUpdateButtons ''
loadHistoryMenu ''
wd 'pshow maximized'
)

go_z_ =: 3 : 0
go_jwikiviz_ ''
)

test_z_ =: 3 : 0
NB. 	head =. (2!:0) 'wget -S --save-headers -O - https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
smoutput 'head' ; '-S --save-headers -O -' gethttp 'https://www.google.com?cache=false'
k =. (2!:0) 'wget -S --save-headers -O - "https://www.google.com"'
smoutput 'k' ; k
)

cocurrent 'base'

go ''
