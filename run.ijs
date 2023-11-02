coerase <'jwikiviz'

cocurrent 'jwikiviz'

load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'gl2'
load 'arc/lz4'
coinsert 'jgl2'

NB. Stephen's Notes
NB. Try 1280 for the minimum monitor width.
NB. Color code (make a key) for Wiki vs. Forum in the search results display
NB. Highlight the term that matches the search

NB. *** Wiki Meeting Discussion Items ***
NB. Expanded test user base (send them the draft announcement email)

NB. *** A Items ***
NB. Test initial installation.  
NB. Suppress <pre>
NB. Wiki documentation page.

NB. *** B Items ***
NB. Better reporting from the jwikiviz.db creation task.  How many retrieved, how many in the tables, etc.
NB. Support parallel download of forum and wiki documents.
NB. Fix the extra "quotes in NuVoc
NB. Spider the Vocabulary--don't use the spreadsheet.
NB. Tags as first-class/suggested search terms…?
NB. NuVoc R1 under Reference: blue 200 is wrong. (Multi-page category lists are a PITA.)

NB. ===================== Version Updates =====================
addonPath =: '~addons/gottsman63/jwikiviz/manifest.ijs'
githubUrl =: 'https://raw.githubusercontent.com/gottsman63/jwikiviz/main/manifest.ijs'
awsPrefix =: 'https://jwikiviz.s3.eu-north-1.amazonaws.com'
indexUrl =: awsPrefix , '/jwikiviz.fulltext.txt.lz4'
githubContentUrl =: awsPrefix , '/jwikiviz.gitHub.dat.lz4'
dateUrl =: awsPrefix , '/jwikiviz.dat'
stageDbUrl =: awsPrefix , '/jwikiviz.stage.db'

stageDbFile =: 'jwikiviz.stage.db'
stageFullTextDbFile =: 'jwikiviz.fulltext.stage.db'
stageDateFile =: 'jwikiviz.dat'
stageGitHubFile =: 'jwikiviz.github.stage.dat'
stageDatePath =: jpath '~temp/' , stageDateFile
stageDbPath =: jpath '~temp/' , stageDbFile
stageFullTextDbPath =: jpath '~temp/' , stageFullTextDbFile
stageGitHubPath =: jpath '~temp/' , stageGitHubFile
targetDbPath =: jpath '~temp/jwikiviz.db'
curlTracePath =: jpath '~temp/jwikiviz.trace'
liveSearchDbPath =: jpath '~temp/jwikiviz.fulltext.db'

AppUpToDate =: _1
DatabaseDownloadStatus =: _1
DatabaseDownloadMessage =: ''

manifest_version=: {{
  cocurrent temp=. cocreate''
  VERSION =: 'none'
  try.   0!:100 y
  catch. VERSION =: 'none'
  end.
  coerase temp
  VERSION
}}

asyncCheckAppUpToDate =: 3 : 0
NB. _1 if we're checking for a new version.
NB. 0 if the app is out of date.
NB. 1 if the app is up to date.
NB. 2 if we failed to get a remote version number.
AppUpToDate =: _1
try.
	v1 =. manifest_version (1!:1) < jpath addonPath
	if. IFWGET_wgethttp_ do.
		v2 =. manifest_version gethttp githubUrl
NB.		v2 =. manifest_version c =. '-O - --header "Cache-Control: no-cache, no-store, must-revalidate" ' gethttp githubUrl
	else.
NB.		v2 =. manifest_version '-s -H "Cache-Control: no-cache, no-store, must-revalidate"' gethttp githubUrl
		v2 =. manifest_version gethttp githubUrl
	end.
	if. v2 -: 'none' do. AppUpToDate =: 2
	elseif. v1 -: v2 do. AppUpToDate =: 1 
	else. AppUpToDate =: 0 end.
catch.
	AppUpToDate =: 0
end.
smoutput v1 ; v2 ; AppUpToDate
animate 5
)

updateAppVersion =: 3 : 0
log 'updateAppVersion'
sqlclose__db  ''
wd 'set appUpdate caption *Updating the add-on...'
wd 'msgs'
(9!:29) 1
(9!:27) 'load ''~addons/gottsman63/jwikiviz/run.ijs'' [ install ''github:gottsman63/jwikiviz'''
)
NB. ===========================================================

NB. ======================== Key/Value Store ===========================
setKeyValue =: 4 : 0
NB. x A string key
NB. y A string value
NB. Write the key/value pair to the database.
try. sqlupsert__db 'keyvalue' ; 'key' ; (;: 'key value') ; < x ; y catch. catcht. end.
)

getKeyValue =: 4 : 0
NB. x A default string value
NB. y A string key
NB. Return either the string value of the key from the database or the default value (x).
result =. ''
try. result =. , > > {: sqlreadm__db 'select value from keyvalue where key = "' , y , '"' catch. catcht. end.
if. 0 = # result do. x else. result end.
)
NB. ====================== End Key/Value Store =========================

NB. ============= Database ===============
db =: ''

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
NB. ================== Logging ===================
logHtmlPrefix =: 0 : 0
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Log</title>
  </head>
  <body>
  <pre>
)

logHtmlSuffix =: 0 : 0
  </pre>
  </body>
</html>
)

setSnapshotLogButtonState =: 3 : 0
count =. > > {: sqlreadm__db 'select count(*) from log'
if. count = 0 do.
	wd 'set snapshotLog visible 0'
else.
	wd 'set snapshotLog visible 1'	
	wd 'set snapshotLog caption Show: ' , , ": count
end.
)

snapshotLogToBrowser =: 3 : 0
entries =. |. > {: sqlreadm__db 'select datetime, msg from log'
datetimes =. ,&'    ' &. > 0 {"1 entries
msgs =. 1 {"1 entries
html =. logHtmlPrefix , (; datetimes ,. ,&'<br>' &. > msgs) , logHtmlSuffix
wd 'set browser html *' , html
)

isLogEmpty =: 3 : 0
NB. Return 1 if the log is empty
0 = > > {: sqlreadm__db 'select count(*) from log'
)

log =: 0&baseLog : baseLog

baseLog =: 4 : 0
if. (x = 0) *. -. LogFlag do. return. end.
try.
	sqlinsert__db 'log' ; (;: 'datetime msg') ; < ((6!:0) 'YYYY MM DD hh mm sssss') ; y
	setSnapshotLogButtonState ''
catch.
	smoutput 'Log error logging: ' , y
end.
)

clearLog =: 3 : 0
sqlcmd__db 'delete from log'
)
NB. =============== End Logging ===================

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
log 'setUpdateButtons'
select. AppUpToDate
case. _1 do. appCap =. 'Checking for new version...'
case. 0 do. appCap =. 'New add-on version available'
case. 1 do. appCap =. 'Add-on is up to date' 
case. 2 do. appCap =. 'Offline (apparently)'
end.
wd 'set appUpdate caption *' , appCap
select. DatabaseDownloadStatus
case. _3 do. dbCap =. 'Click to bring new data online'
case. _2 do. dbCap =. 'Downloading data (background)...'
case. _1 do. dbCap =. 'Checking for new database...'
case. 0 do. dbCap =. 'Local database is up to date'
case. 1 do. dbCap =. 'Click to download the latest data (background)...'
case. 2 do. dbCap =. 'Database download required...'
case. 3 do. dbCap =. 'Offline (apparently)'
end.
wd 'set dbUpdate caption *' , dbCap
wd 'msgs'
)

vizform_appUpdate_button =: 3 : 0
log 'vizform_appUpdate_button'
updateAppVersion ''
)
downloadPyx =: a:

vizform_dbUpdate_button =: {{
downloadFlag =. 0
log 'vizform_dbUpdate_Button'
select. DatabaseDownloadStatus 
case. _3 do. bringNewDataOnline ''
case. _2 do. wdinfo 'Currently downloading data in the background'
case. _1 do. wdinfo 'Checking for new data in the background'
case. 0 do. downloadFlag =. 'yes' -: wd 'mb query mb_yes =mb_no "Local Database Status" "Nota bene: Yes to download ~100 MB that (decompressed & indexed) will occupy ~1 GB in ~temp."'
case. 1 do. downloadFlag =. 'yes' -: wd 'mb query mb_yes =mb_no "Local Database Status" "Nota bene: Yes to download ~100 MB that (decompressed & indexed) will occupy ~1 GB in ~temp."'
NB. case. 2 do. dbCap =. 'Database download required...' (Should not happen.)
case. 3 do. setUpdateButtons ''  NB. We were offline; check whether we're connected again.
end.
if. downloadFlag do. 
	DatabaseDownloadStatus =: _2
	downloadPyx =: downloadLatestData t. 'worker' ''
	setUpdateButtons ''
end.
}}

buildForm =: 3 : 0
log 'buildForm'
wd 'pc vizform escclose;'
wd 'pn *J Viewer'
wd 'bin h;'
wd   'bin v;'
wd     'bin h;'
wd       'cc closeButton button; cn *X'
wd       'cc fontSlider slider 2 1 1 1 9 3'
wd       'cc searchStatic static; cn *Phrase:'
wd       'cc searchBox edit;'
wd       'cc searchWordsStatic static; cn *Words:'
wd       'cc searchBoxWords edit;'
wd     'bin z;'
wd     'bin h;'
wd       'cc logcheck checkbox; cn Debug (Log);'
wd       'cc snapshotLog button; cn 0;'
wd       'cc shortcut button;cn Shortcut...;'
wd       'cc dbUpdate button; cn Haha!;'
wd       'cc appUpdate button; cn Wocka!;'
wd     'bin z;'
wd     'bin h;'
wd       'cc liveForum checkbox; cn *Forum Posts'
wd       'cc liveGitHub checkbox; cn *GitHub'
wd       'cc liveWiki checkbox; cn *Wiki'
wd       'cc wikiSearchMenu combolist;'
wd       'cc liveAgeLabel static'
wd       'cc liveAge slider 2 1 1 1 10 3'
wd     'bin z;'
wd     'cc vocContext isidraw'
wd   'bin z;'
wd   'bin v;'
wd     'bin h;'
wd       'cc bookmark button; cn *Bookmark'
wd       'cc history combolist;'
wd       'cc launch button; cn Browser;'
wd       'cc feedback button; cn Feedback;'
wd     'bin z;'
wd     'bin h;'
wd       'cc shrinkBrowser button ; cn *> Shrink Browser <'
wd       'cc expandBrowser button ; cn *< Expand Browser >'
wd     'bin z;'
wd     'cc loadPost button; cn *Show Post in Thread'
wd     'cc browser webview;'
wd   'bin z;'
wd 'bin z;'
wd 'set snapshotLog visible 0'
wd 'set loadPost font arial 14 bold'
)

LayoutForumPostLoadButtonEnable =: 0

LayoutRatio =: 0.5
LayoutRatioTarget =: 0.5

layoutForm =: 3 : 0
log 'layoutForm'
'w h' =. ". wd 'getp wh'
log 'layoutForm getp wh: ' , ": w , h 
winW =. w NB. - 40
winH =. h - 45
controlHeight =. 30
vocContextHeight =. winH >. 760
if. 0.1 < | LayoutRatioTarget - LayoutRatio do.
	sgn =. * LayoutRatioTarget - LayoutRatio
	LayoutRatio =: LayoutRatio + sgn * 0.1 <. | LayoutRatioTarget - LayoutRatio
else.
	LayoutRatio =: LayoutRatioTarget
end.
vocContextWidth =. <. winW * LayoutRatio
browserWidth =. winW - vocContextWidth
wd 'set closeButton maxwh ' , (": 20 , controlHeight) , ';'
wd 'set fontSlider maxwh ' , (": (<. vocContextWidth * 0.15) , controlHeight) , ';'
wd 'set searchStatic maxwh ' , (": (<. vocContextWidth * 0.06) , controlHeight) , ';'
wd 'set searchBox maxwh ' , (": (<. vocContextWidth * 0.35) , controlHeight) , ';'
wd 'set searchWordsStatic maxwh ' , (": (<. vocContextWidth * 0.05) , controlHeight) , ';'
wd 'set searchBoxWords maxwh ' , (": (<. vocContextWidth * 0.35) , controlHeight) , ';'

wd 'set shortcut maxwh ' ,  , (": (<. vocContextWidth * 0.12) , controlHeight) , ';'
wd 'set logcheck maxwh ' , (": (<. vocContextWidth * 0.12) , controlHeight) , ';'
wd 'set snapshotLog maxwh ' ,  (": (<. vocContextWidth * 0.1) , controlHeight) , ';'
wd 'set dbUpdate maxwh ' , (": (<. vocContextWidth * 0.4) , controlHeight) , ';'
wd 'set appUpdate maxwh ' , (": (<. vocContextWidth * 0.30) , controlHeight) , ';'

wd 'set liveForum maxwh ' , (": 110 , controlHeight) , ';'
wd 'set liveGitHub maxwh ' , (": 90 , controlHeight) , ';'
wd 'set liveWiki maxwh ' , (": 60 , controlHeight) , ';'
wd 'set wikiSearchMenu maxwh ' , (": (-: vocContextWidth - 340) , controlHeight) , ';'
wd 'set liveAgeLabel maxwh ' , (": 70 , controlHeight) , ';'
wd 'set liveAge maxwh ' , (": (-: vocContextWidth - 340) , controlHeight) , ';'

wd 'set vocContext maxwh ' , (": vocContextWidth , vocContextHeight) , ';'

wd 'set bookmark maxwh ' , (": 100, controlHeight) , ';'
wd 'set history maxwh ' , (": (browserWidth * 0.5) , controlHeight) , ';'
wd 'set launch maxwh ' , (": (browserWidth * 0.15) , controlHeight) , ';'
wd 'set feedback maxwh ' , (": 100, controlHeight) , ';'
wd 'set browser maxwh ' , (": browserWidth , winH - controlHeight) , ';'
wd 'set loadPost visible ' , ": LayoutForumPostLoadButtonEnable
if. LayoutRatio ~: LayoutRatioTarget do. animate 2 end.
setLiveAgeLabel ''
setUpdateButtons ''
)

MinScreenWidth =: 1500

setLayoutRatioBrowser =: 3 : 0
if. LayoutRatioTarget < 0.4 do. return. end.
'w h' =. ". wd 'getp wh'
centerW =. w * LayoutRatio
if. w < MinScreenWidth do. NB. Small screen
	LayoutRatioTarget =: 0.3
else.
	LayoutRatioTarget =: 0.5
end.
animate 2
)

setLayoutRatioToc =: 3 : 0
if. LayoutRatioTarget > 0.6 do. return. end.
'w h' =. ". wd 'getp wh'
centerW =. w * LayoutRatio
if. w < MinScreenWidth do. NB. Small screen
	LayoutRatioTarget =: 0.7
else.
	LayoutRatioTarget =: 0.5
end.
animate 2
)

setFontSize =: 3 : 0
NB. y A font slider value (1..9)
NB. use y to set various font-oriented metrics.
log 'setFontSize'
glfont 'arial 15'
factor =. 15 %~ {: glqextent 'M'
FontAdjustment =: <. factor * y - 5
log '...FontAdjustment: ' , ": FontAdjustment
TocFont =: 'arial ' , ": 13 + FontAdjustment
TocLineHeight =: 2 * 13 + FontAdjustment
VocCellFont =: 'arial ' , (": 14 + FontAdjustment) , ' bold'
VocValenceFont =: 'arial ' , ": 14 + FontAdjustment
CountFont =: 'arial ' , ": 15 + FontAdjustment
LiveSearchFont =: 'arial ' , ": 16 + FontAdjustment
SectionFont =: 'arial bold ' , ": 16 + FontAdjustment
'FontSlider' setKeyValue ": y
invalidateDisplay ''
)

vizform_resize =: 3 : 0
layoutForm ''
)

vizform_close =: 3 : 0
log 'vizform_close'
try. sqlclose__db catch. end.
try. sqlclose__liveSearchDb catch. end.
wd 'timer 0'
wd 'pclose'
)

vizform_closeButton_button =: {{
vizform_close ''
}}

vizform_escape =: 3 : 0
vizform_close ''
)

vizform_browser_escape =: 3 : 0
vizform_close ''
)

vizform_vocContext_escape =: 3 : 0
vizform_close ''
)

vizform_fontSlider_changed =: 3 : 0
setFontSize ". fontSlider
)

vizform_snapshotLog_button =: 3 : 0
snapshotLogToBrowser ''
)

vizform_liveForum_button =: 3 : 0
markLiveSearchDirty ''
invalidateDisplay ''
setTocOutlineRailTopLevelEntry LiveSearchCatString
)

vizform_liveWiki_button =: 3 : 0
markLiveSearchDirty ''
invalidateDisplay ''
setTocOutlineRailTopLevelEntry LiveSearchCatString
)

vizform_liveGitHub_button =: 3 : 0
markLiveSearchDirty ''
invalidateDisplay ''
setTocOutlineRailTopLevelEntry LiveSearchCatString
)

vizform_liveAge_changed =: 3 : 0
markLiveSearchDirty ''
invalidateDisplay ''
setTocOutlineRailTopLevelEntry LiveSearchCatString
)

vizform_wikiSearchMenu_select =: 3 : 0
log 'vizform_wikiSearchMenu_select ' , wikiSearchMenu
LiveSearchWikiCategory =: ('\s\([^)]+\)' ; '') rxrplc wikiSearchMenu
markLiveSearchDirty ''
invalidateDisplay ''
setTocOutlineRailTopLevelEntry LiveSearchCatString
)

vizform_expandBrowser_button =: 3 : 0
log 'vizform_expandBrowser_button'
LayoutRatioTarget =: 0.2
animate 2
)

vizform_shrinkBrowser_button =: 3 : 0
log 'vizform_shrinkBrowser_button'
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
NB. if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do. return. end.
VocMouseXY =: 0 1 { ". > 1 { 13 { wdq
setLayoutRatioToc ''
invalidateDisplay ''
sys_timer_z_ ''
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
VocMouseXY =: _1 _1
)

vizform_browser_curl =: 3 : 0
log 'vizform_browser_curl'
url =. > (1 {"1 wdq) {~ ({."1 wdq) i. < 'browser_curl'
LastUrlLoaded =: url
topHistoryUrl =. > 0 { 0 { getHistoryMenu ''
if. -. +./ topHistoryUrl -: url do. addToHistoryMenu url ; url end.
resetBookmarkButton ''
resetForumPostLoadButton ''
loadHistoryMenu ''
)

vizform_searchBox_char =: 3 : 0
log 'vizform_searchBox_char ' , searchBox NB. This won't actually reflect the current contents of the search box.
markLiveSearchDirty ''
entry =. TocOutlineRailSelectedIndex { 1 getTocOutlineRailEntries MaxTocDepth  NB. level ; parentid ; categoryid ; category ; parentseq ; count ; link
category =. > 3 { entry
if. -. category -: GitHubCatString do. 
	setTocOutlineRailTopLevelEntry LiveSearchCatString
end.
LiveSearchCountdown =: 30
animate 3
)

vizform_searchBoxWords_char =: 3 : 0
log 'vizform_searchBoxWords_char ' , searchBoxWords
markLiveSearchDirty ''
setTocOutlineRailTopLevelEntry LiveSearchCatString
animate 3
)

vizform_searchBox_button =: {{
log 'vizform_searchBox_button ' , searchBox
setTocOutlineRailTopLevelEntry LiveSearchCatString
animate 3
}}

vizform_searchBoxWords_button =: {{
log 'vizform_searchBoxWords_button ' , searchBoxWords
setTocOutlineRailTopLevelEntry LiveSearchCatString
animate 3
}}

vizform_history_select =: 3 : 0
log 'vizform_history_select'
loadPage (". history_select) { getHistoryMenu ''
)

vizform_launch_button =: 3 : 0
log 'vizform_launch_button ' , ": > 0 { 0 { getHistoryMenu ''
launch_jbrowser_ > 0 { 0 { getHistoryMenu ''
)

vizform_feedback_button =: 3 : 0
log 'feedback'
launch_jbrowser_ 'mailto:edward.j.gottsman@gmail.com'
)

vizform_loadPost_button =: 3 : 0
log 'vizform_loadPost_button'
loadForumPost ''
)

animate =: 3 : 0
NB. y Number of frames to animate
NB. log 'animate ' , ": y
TimerCount =: TimerCount + y
)

FrameCounter =: 0

sys_timer_z_ =: {{
NB. if. 0 = 100 | FrameCounter_jwikiviz_ do. smoutput '4 T. downloadPyx' ; 4 T. downloadPyx_jwikiviz_ end.
FrameCounter_jwikiviz_ =: >: FrameCounter_jwikiviz_
if. (0 = 100 | FrameCounter_jwikiviz_) *. (DatabaseDownloadStatus_jwikiviz_ = _2) +. DatabaseDownloadStatus_jwikiviz_ = _3 do. 
	checkWhetherStageDatabasesHaveArrived_jwikiviz_ ''
	setUpdateButtons_jwikiviz_ ''
	if. -. DatabaseDownloadMessage_jwikiviz_ -: '' do.
		smoutput DatabaseDownloadMessage_jwikiviz_
		DatabaseDownloadMessage_jwikiviz_ =: ''
	end.
end.
if. 0 = TimerCount_jwikiviz_ do. return. end.
log_jwikiviz_ 'sys_timer_z_: ' , ": TimerCount_jwikiviz_
try.
	TimerCount_jwikiviz_ =: TimerCount_jwikiviz_ - 1
	layoutForm_jwikiviz_ ''
	trigger_paint_jwikiviz_ ''
catch.
	smoutput (13!:12) ''
	smoutput dbError_jwikiviz_ ''
	1 log (13!:12) ''
	1 log dbError_jwikiviz_ ''
end.
}}

TimerCount =: 0

wd 'timer 0'

DisplayListRectTargetWidth =: 175
DisplayListRectSourceWidth =: 20
DisplayListRectAnimationStartTime =: 0

setDisplayRects =: 3 : 0
'w h' =. ". wd 'get vocContext wh'
log 'setDisplayRects vocContext wh: ' , ": w , h
DisplayListRect =: 0 0 175 , h
DisplayDetailRect =: 175 0 , (w - 175) , h
)

trigger_paint =: 3 : 0
log 'trigger_paint ' , (wd 'getp wh') , '   ' , (": getFrameRate '') , ' fps'
try.
glfill BackgroundColor , 255
'w h' =. ". wd 'getp wh'
if. (w < 200) +. h < 200 do.
	1 log 'trigger_paint--dimensions too small.  Aborting.'
	return.
end.
setDisplayRects ''
drawToc ''
'vocW vocH' =. ". wd 'get vocContext wh'
drawFloatingString vocW , vocH
VocMouseClickXY =: 0 0
glclip 0 0 10000 10000
glpaint ''
DisplayDirtyFlag =: 0
catcht. catch. 
1 log (13!:12) ''
1 log dbError ''
smoutput (13!:12) ''
smoutput dbError ''
end.
)

invalidateDisplay =: 3 : 0
NB. wd 'set vocContext invalid'
TimerCount =: TimerCount + 1
)
NB. ======================================================

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
HoverColor =: 138 51 36 
BarColor =: 245 195 150
CountColor =: 127 127 127
CountFont =: 'arial 15'

WikiColor =: 0 127 127
ForumColor =: 110 38 14
GitHubColor =: 136 6 206

TimerCount =: 0

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
FontAdjustment =: 0
TocFont =: 'arial 13'
LiveSearchFont =: 'courier 16'
TocLineHeight =: 25
TocScrollIndex =: 0
MaxTocDepth =: 3
DisplayListRect =: 10 10 100 100
DisplayDetailRect =: 100 10 100 100
DisplayDirtyFlag =: 1
Months =: ;:'January February March April May June July August September October November December'
ShortMonths =: ;: 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'
ForumsCatString =: '*Forums'
BookmarkCatString =: '*Bookmarks'
SearchCatString =: '*Search'
SearchHiddenCatId =: 200000
LiveSearchCatString =: '*Live Search'
GitHubCatString =: '*GitHub'
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
NB. XFileHashLabel =: > IFWGET_wgethttp_ { 'x-file-hash: ' ; 'X-File-Hash: '

getTocFontForLevel =: 3 : 0
NB. y An integer level in an outline hierarchy.  _1 indicates a page; 0..n indicates a level.
NB. Return the string specification of the font to use.
if. y < 0 do. 'arial ' , ": FontAdjustment + 16 return. end.
fonts =. ('arial bold ' , ": FontAdjustment + 17) ; ('arial bold ' , ": FontAdjustment + 14) ; ('arial ' , ": FontAdjustment + 14)
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
	1 log 'Error in drawStringAt: ' , (13!:12) ''
	1 log 'Error drawing: ' , (": x) , ' ' , 'drawStringAt ' , ' ' , ": y
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
'url title' =. {. getHistoryMenu ''
LayoutForumPostLoadButtonEnable =: shouldShowPostLoadButton url
layoutForm ''
)

loadForumPost =: 3 : 0
NB. Load the currently-displayed Forum post in the Forums section of the table of contents.
NB. ForumCacheTable year ; month ; subject ; author ; link
'url title' =. {. getHistoryMenu ''
'forumName link month year' =. reverseEngineerForumUrl url
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
	1 log (13!:12) ''
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
try.
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
catch. catcht.
	1 log 'Problem in drawFloatingString: ' , (13!:12) ''
end.
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
if. ('*' ~: {. urlCommand) *. urlCommand -: LastUrlCommandSelected do. 
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
	elseif. '#' = {. urlCommand do.
		wd 'set browser html *' , }. urlCommand
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
squishedLineHeight =. TocLineHeight <. (window -~ # strings) %~ h - window * TocLineHeight
NB. if. VocMouseXY pointInRect xx , yy , w , h do.
NB.          'scrollX scrollY'=. (VocMouseXY - xx,yy) % w,h
NB.          targetIndex=. scrollY * window + # strings  NB. retain fractional part, for now
NB.          limit=. (#strings) - window
NB.          'lo hi'=. <.0.5+ 0 >. (+<./@,&0) limit <. window -~ targetIndex (-,+) scrollX * window%2
NB.          bump=. (scrollIndex < lo) - scrollIndex > hi
NB.          scrollIndex=. 0 >. scrollIndex + bump
NB.          if. bump do. animate 2 end.
NB. end.
if. VocMouseXY pointInRect xx , yy , w , h do.
	mouseY =. ({: VocMouseXY) - yy
	upperWindowY =. squishedLineHeight * scrollIndex
	lowerWindowY =. upperWindowY + window * TocLineHeight
	maxScrollIndex =. window -~ # strings
	if. mouseY < upperWindowY do.
		scrollIndex =. <: scrollIndex
		animate 2
	elseif. (mouseY > lowerWindowY) *. scrollIndex < maxScrollIndex do.
		scrollIndex =. >: scrollIndex
		animate 2
	end.
end.
windowStartIndex =. scrollIndex NB. <. 0 >. (# strings) <. 0 >. scrollIndex - -: window
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
	level =. i { levels
	glrgb BarColor
	glbrush ''
	glpen 0
	if. (lineHeight >: TocLineHeight) *. _1 < i { counts do.
		glfont CountFont
		glrgb CountColor
		gltextcolor ''
		countWidth =. {. glqextent c =. ": i { counts
		indentLevel =. 6 * level - (<. / levels)
		(origin - (countWidth + 2 - indentLevel) , 0) drawStringAt c
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
	hoverRect =. (origin - margin , 0) , w , lineHeight
	if. i = selectedIndex do. hoverRect drawHighlight SelectionColor end.
	if. VocMouseXY pointInRect xx , yy , w , h do. hoverRect registerRectLink (> i { links) ; (> i { strings) ; loadMode end.
	if. VocMouseXY pointInRect hoverRect do. ". hoverCallback , ' ' , ": i end.		
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

TocEntryForumYear =: {. (6!:0) ''

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
'year month subject author link day' =. TocEntryForumAuthorIndex { ForumAuthorEntries
queueUrl ('https://www.jsoftware.com/pipermail/' , (}. ForumCurrentName) , '/' , (": year) , '-' , (> month { Months) , '/' , link , '.html') ; subject -. LF
)

NB. ---------------------- Live Search ---------------------------
NB. indexDbFile =: '~temp/jsearch.db'
liveSearchDb =: ''
liveSearchPageIndex =: 0
LiveSearchPyx =: a:
LiveSearchIsDirty =: 0
LiveSearchResults =: '' NB. Title ; Snippet ; URL
LiveSearchWikiTitlesByCategory =: '' NB. Category ; Title
LiveSearchCategorizedWikiResults =: '' NB. Category ; < Titles ; Snippets ; Urls
LiveSearchWikiCategory =: '' NB. Currently-selected wiki category name
LastLiveSearchQuery =: ''
LiveSearchCountdown =: 0

jEnglishDict =: _2 ]\ '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':' ; 'co' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'F:.' ; 'fcapcodot' ; 'F::' ; 'fcapcoco' ; 'F:' ; 'fcapco' ; 'F..' ; 'fcapdotdot' ; 'F.:' ; 'fcapdotco' ; 'F.' ; 'fcapdot' ; 'H.' ; 'hcapdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco' ; 'j.' ; 'jdot' ; 'L.' ; 'lcapdot' ; 'L:' ; 'lcapco' ; 'm.' ; 'mdot' ; 'M.' ; 'mcapdot' ; 'NB.' ; 'ncapbcapdot' ; 'o.' ; 'odot' ; 'p.' ; 'pdot' ; 'p:' ; 'pco' ; 'q:' ; 'qco' ; 'r.' ; 'rdot' ; 's:' ; 'sco' ; 't.' ; 'tdot' ; 'T.' ; 'tcapdot' ; 'u:' ; 'uco' ; 'x:' ; 'xco' ; 'Z:' ; 'zcapco' ; 'assert.' ; 'assertdot' ; 'break.' ; 'breakdot' ; 'continue.' ; 'continuedot' ; 'else.' ; 'elsedot' ; 'elseif.' ; ' elseifdot' ; 'for.' ; 'fordot' ; 'if.' ; 'ifdot' ; 'return.' ; 'returndot' ; 'select.' ; 'selectdot' ; 'case.' ; 'casedot' ; 'fcase.' ; 'fcasedot' ; 'try.' ; 'trydot' ; 'catch.' ; 'catchdot' ; 'catchd.' ; 'catchddot' ; 'catcht.' ; 'catchtdot' ; 'while.' ; 'whiledot' ; 'whilst.' ; 'whilstdot'         
jMnemonics =: , &. > 0 {"1 jEnglishDict
jEnglishWords =: 'J'&, &. > 1 {"1 jEnglishDict
jPrintedIndices =: 'J'&, &. > <@":"0 i. # jMnemonics

checkLiveSearchCountdown =: {{
if. LiveSearchCountdown > 0 do.
	LiveSearchCountdown =: 0 >. <: LiveSearchCountdown
	if. 0 = LiveSearchCountdown do. markLiveSearchDirty '' end.
end.
}}

buildLiveSearchWikiTitlesByCategory =: {{
LiveSearchWikiTitlesByCategory =: > {: sqlreadm__db 'select category, title from categories, wiki where categories.categoryid = wiki.categoryid'
}}

categorizeLiveSearchWikiTitles =: {{
NB. y A list of boxed titles, snippets, urls, years, sources from the wiki search results
NB. Return a table of Category Name .: (titles ; urls)
NB. The first category should be a synthetic "all" containing all titles/urls.
NB. LiveSearchWikiTitlesByCategory: Category ; Title
titleSnippetUrlYearSource =. y #~ (0 {"1 y) e. 1 {"1 LiveSearchWikiTitlesByCategory
titles1 =. 0 {"1 titleSnippetUrlYearSource
titles2 =. 1 {"1 LiveSearchWikiTitlesByCategory
categories =. (titles2 i. titles1) { 0 {"1 LiveSearchWikiTitlesByCategory
categoryKeys =. ~. categories
groups =. (categories < /. titleSnippetUrlYearSource) /: categoryKeys
(/:~ categoryKeys) ,: groups
}}

categorizeLiveSearchForumPosts =: {{
NB. y A list of boxed titles, snippets, urls, years, sources from the forum search results
NB. Return a table of Category (Forum) Name .: (subjects ; urls)
lengths =. >:@{.@i.&' ' &. > }. &. > 0 {"1 y
categories =. lengths {. &. > 0 {"1 y
categoryKeys =. ~. categories
groups =. (categories < /. y) /: categoryKeys
(/:~ categoryKeys) ,: groups
}}

categorizeLiveSearchGitHubFiles =: {{
NB. y A list of boxed titles, snippets, urls, years, sources from the forum search results
NB. Return a table of Category (Repository) Name .: (subjects ; urls)
lengths =. {.@i.&':' &. > 0 {"1 y
categories =. lengths {. &. > 0 {"1 y
categoryKeys =. ~. categories
groups =. (categories < /. y) /: categoryKeys
(/:~ categoryKeys) ,: groups
}}

setLiveAgeLabel =: 3 : 0
try.
if. (". liveAge) = 10 do.
	wd 'set liveAgeLabel text *' , 'All Docs'
else.
	cutoffYear =. 1 + ({. (6!:0) '') - ". liveAge
	wd 'set liveAgeLabel text * >= ' , ": cutoffYear
end.
catch.
end.
)

setLiveSearchPageIndex =: 3 : 0
liveSearchPageIndex =: y
invalidateDisplay ''
)

openLiveSearchDb =: 3 : 0
if. liveSearchDb -: '' do. liveSearchDb =: sqlopen_psqlite_ liveSearchDbPath end.
)

createQuery =: 3 : 0
NB. Use searchBox and searchBoxWords to create a query.
phrase =. ; }: , (<'+') ,.~ a: -.~ < ;. _2 (translateToJEnglish searchBox) , ' '
words =. ; }: , (<' AND ') ,.~ a: -.~ < ;. _2 (translateToJEnglish searchBoxWords) , ' '
if. 0 = # words do. and =. '' else. and =. ' AND ' end.
'"' , phrase , and , words , '"'
)

dropSpacesSnippetTokens =: (jMnemonics -. , &. > ':' ; '.') , , &. > '(' ; ')'

translateToJ =: 3 : 0
NB. y A string possibly containing JEnglish tokens
NB. Convert the JEnglish to J tokens.
NB. Drop most of the spaces between the J tokens.
log 'translateToJ ' , y
try.
	tokens =. ;: y -. ''''
	hits =. jEnglishWords i."1 0 tokens
	jTokens =. (hits {"0 1 jMnemonics ,"1 0 tokens)
	spaces =. (-. jTokens e. dropSpacesSnippetTokens) { '' ; ' '
	squished =. ('  ' ; ' ') rxrplc ('   ' ; ' ') rxrplc ; spaces ,. jTokens ,. spaces
	(' \)' ; ')') rxrplc ('\( ' ; '(') rxrplc squished
catch. catcht. 
1 log 'translateToJ problem: ' , y
1 log (13!:12) '' 
end.
)

performLiveSearch =: 3 : 0
NB. y A SQL statement
try.
	> {: sqlreadm__liveSearchDb y
catch.
1 log 'Live Search problem: ' , (13!:12) ''
1 log 'DB Error (if any): ' , sqlerror__liveSearchDb ''
end.
)

submitLiveSearch =: 3 : 0
NB. y Empty
NB. Set and return a table of title ; Snippet ; Url
log 'submitLiveSearch: ' , searchBox
LiveSearchResults =: ''
LastLiveSearchQuery =: searchBox
setLiveSearchPageIndex 0
try. openLiveSearchDb '' catch. return. end.
forumFlag =. liveForum = '1'
wikiFlag =. liveWiki = '1'
gitHubFlag =. liveGitHub = '1'
if. 0 = +./ forumFlag , wikiFlag , gitHubFlag do. forumFlag =. wikiFlag =. gitHubFlag =. 1 end.
whereClause =. ' source IN (' , (}: ; ,&',' &. > ((forumFlag , wikiFlag , gitHubFlag) # '"F"' ; '"W"' ; '"G"')) , ') '
currentYear =. {. (6!:0) ''
if. 10 = ". liveAge do.
	cutoffYear =. 0
else.
	cutoffYear =. 1 + currentYear - ". liveAge
end.
query =. createQuery searchBox
fullSearch =. 'select title, url, year, source, snippet(jindex, 0, '''', '''', '''', 20) from auxiliary, jindex where jindex MATCH ' , query , ' AND (auxiliary.rowid = jindex.rowid) AND (year >= ' , (": cutoffYear) , ') AND ' , whereClause , ' order by rank limit 500'
log 'About to make a pyx for search: ' , fullSearch
LiveSearchPyx =: performLiveSearch t. 'worker' fullSearch
LiveSearchIsDirty =: 0
)

markLiveSearchDirty =: 3 : 0
LiveSearchIsDirty =: 1
)

processLiveSearchResults =: 3 : 0
log 'processLiveSearchResults ' , ": rattleResult =. 4 T. LiveSearchPyx
if. rattleResult = _1001 do. NB. Not a pyx.
	if. LiveSearchIsDirty do. 
		NB. The goal below is to delay executing one-character searches (which are slow) to give the user a chance to enter another character.
		if. LiveSearchCountdown > 0 do. animate 1 end.
		LiveSearchCountdown =: 0 >. <: LiveSearchCountdown
		if. (0 = LiveSearchCountdown) +. 1 < # searchBox do.
			submitLiveSearch ''
			animate 1
		end.
	end.
	rattleResult
	return.
end.
if. 0 <: rattleResult do. 
	log '...(processLiveSearchResults) no results yet.' 
	animate 1
	rattleResult
	return. 
end.
result =. ''
try.
	result =. > LiveSearchPyx
catch. catcht. catchd.
	1 log 'Error opening pyx: ' , (13!:12) ''
	1 log 'DB error (if any): ' , sqlerror__liveSearchDb ''
	rattleResult
	return.
end.
if. 0 = # result do. 
	LiveSearchResults =: ''
	categoryMenuList =. ''
	wd 'set wikiSearchMenu items *'
	log '...(processLiveSearchResults) zero results'
else.
	snippets =. translateToJ &. > 4 {"1 result
	sources =. {. &. > 3 {"1 result
	results =. (titles =. 0 {"1 result) ,. snippets ,. (links =. 1 {"1 result) ,. (years =. 2 {"1 result) ,. sources
	log '...(processLiveSearchResults) found ' , (": # result) , ' results.'
	LiveSearchResults =: results
	categorizedWikiResults =. categorizeLiveSearchWikiTitles results #~ sources = < 'W'
	categorizedForumResults =. categorizeLiveSearchForumPosts results #~ sources = < 'F'
	categorizedGitHubResults =. categorizeLiveSearchGitHubFiles results #~ sources = < 'G'
	categorizedResults =. ((<'*All') ,: < LiveSearchResults) ,. categorizedForumResults ,. categorizedWikiResults ,. categorizedGitHubResults
	categories =. {. categorizedResults
	categoryCounts =. ' ('&, &. > ,&')' &. > ":@# &. > 1 { categorizedResults
	categoryMenuList =. categories , &. > categoryCounts
	wd 'set wikiSearchMenu items ' , ; ' "'&, &. > ,&'"' &. > categoryMenuList
	setLiveSearchPageIndex 0
	if. 0 = # LiveSearchWikiCategory do. LiveSearchWikiCategory =: '*All' end.
	index =. categories i. < LiveSearchWikiCategory
	if. index = # categories do. index =. 0 end.
	wd 'set wikiSearchMenu select ' , ": index
	if. index > 0 do.
		LiveSearchResults =: > index { (1 { categorizedResults)
	else.
		LiveSearchResults =: results
	end.
end.
LiveSearchPyx =: a:
if. LiveSearchIsDirty do. 
	submitLiveSearch '' 
	animate 1
end.
rattleResult
)

translateToJEnglish =: 3 : 0
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
raw =. ('''' ; '''''') rxrplc y
rawTokens =. ;: raw
hits =. jMnemonics i."1 0 rawTokens
string =. ; (hits {"0 1 jEnglishWords ,"1 0 rawTokens) ,. < ' '
string
)

drawTocEntryLiveSearch =: 3 : 0
NB. y xx yy width height
NB. Display the results of the current search against the local database.
'xx yy width height' =. y
setLiveAgeLabel ''
glclip 0 0 10000 100000
glrgb 0 0 0
gltextcolor ''
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
glfont LiveSearchFont
colSep =: 20
NB. if. -. searchBox -: LastLiveSearchQuery do. submitLiveSearch '' end.
rattleResult =. processLiveSearchResults ''
if. (0 = # LiveSearchResults) do.
	glfont 'arial 30'
	startY =. <. yy + -: height
	if. (rattleResult > 0) *. 0 < # searchBox do.
		n =.  192 * | 1 o. 2 * (6!:1) ''
		glrgb n , n , n
		gltextcolor ''
		startX =. <. (xx + -: width) - -: {. glqextent searchBox
		(startX , startY) drawStringAt searchBox
	elseif. rattleResult < 0 do.
		noResults =. 'No Results'
		startX =. <. (xx + -: width) - -: {. glqextent noResults
		(startX , startY) drawStringAt noResults
	end.
	return. 
end.
pageLabelHeight =. 30
pageLabelWidth =. 30
contentHeight =. height - pageLabelHeight
contentLineCount =. <. contentHeight % TocLineHeight
pageLabelCount =. >. (# LiveSearchResults) % contentLineCount
pageLabels =. <@":"0 >: i. pageLabelCount
pageLabelOrigins =. (xx + 60 + pageLabelWidth * i. pageLabelCount) ,. 5
pageLabelRects =. pageLabelOrigins ,"1 1 pageLabelWidth , pageLabelHeight
(pageLabelRects -"(1 1) 4 4 0 0) registerRectLink"1 1 ('*setLiveSearchPageIndex '&, &. > <@":"0 i. pageLabelCount) ,"0 1 (< ' ') , <1
((liveSearchPageIndex { pageLabelRects) - 4 4 0 0) drawHighlight SelectionColor

results =. > liveSearchPageIndex { (- contentLineCount) <\ LiveSearchResults
(<"1 pageLabelOrigins) drawStringAt &. > pageLabels
((5 + xx) , 5) drawStringAt 'Page:'
titles =. 0 {"1 results
snippets =. 1 {"1 results
links =. 2 {"1 results
sources =. 4 {"1 results
colWidth =. <. -: width - colSep
snippetOrigins =. (xx + 5) ,. pageLabelHeight + TocLineHeight * i. # results
titleOrigins =. (xx + colSep + colWidth) ,. pageLabelHeight + TocLineHeight * i. # results

NB. glrgb WikiColor
gltextcolor ''
sieve =. sources = <'W'
glclip xx , yy , colWidth , height
NB. (<"1 sieve # snippetOrigins) drawStringAt &. > sieve # snippets
(<"1 (sieve # snippetOrigins) ,"(1 1) 10 , TocLineHeight) drawCodeWithHighlights"0 1 (< searchBox) ,. (sieve # snippets) ,. < WikiColor
glclip (xx + 5 + colWidth) , yy , colWidth , height
(<"1 sieve # titleOrigins) drawStringAt &. > sieve # titles

NB. glrgb ForumColor
gltextcolor ''
sieve =. sources = <'F'
glclip xx , yy , colWidth , height
NB. (<"1 sieve # snippetOrigins) drawStringAt &. > sieve # snippets
(<"1 (sieve # snippetOrigins) ,"(1 1) 10 , TocLineHeight) drawCodeWithHighlights"0 1 (< searchBox) ,. (sieve # snippets) ,. < ForumColor
glclip (xx + 5 + colWidth) , yy , colWidth , height
(<"1 sieve # titleOrigins) drawStringAt &. > sieve # titles

NB. glrgb GitHubColor
gltextcolor ''
sieve =. sources = <'G'
glclip xx , yy , colWidth , height
NB. (<"1 sieve # snippetOrigins) drawStringAt &. > sieve # snippets
(<"1 (sieve # snippetOrigins) ,"(1 1) 10 , TocLineHeight) drawCodeWithHighlights"0 1 (< searchBox) ,. (sieve # snippets) ,. < GitHubColor
glclip (xx + 5 + colWidth) , yy , colWidth , height
(<"1 sieve # titleOrigins) drawStringAt &. > sieve # titles

glclip 0 0 10000 100000
(snippetRects =. <"1 snippetOrigins ,"1 1 colWidth , TocLineHeight) registerRectLink &. > <"1 links ,. titles ,. (# snippets) # < 1
(titleRects =. <"1 titleOrigins ,"1 1 colWidth , TocLineHeight) registerRectLink &. > <"1 links ,. titles ,. (# titles) # < 1

textColors =. WikiColor , ForumColor ,: GitHubColor
if. _1 < titleIndex =. {. _1 ,~ I. > VocMouseXY&pointInRect &. > titleRects do.
	title =. > titleIndex { titles
	colorIndex =. ('W' ; 'F' ; 'G') i. titleIndex { sources
	textColor =. colorIndex { textColors
	floatRect =. (2 {. > titleIndex { titleRects) , (colWidth >. {. glqextent title) , TocLineHeight
	floatRect registerFloatingString title ; LiveSearchFont ; textColor
end.
if. _1 < snippetIndex =. {. _1 ,~ I. > VocMouseXY&pointInRect &. > snippetRects do.
	snippet =. > snippetIndex { snippets
	colorIndex =. ('W' ; 'F' ; 'G') i. snippetIndex { sources
	textColor =. colorIndex { textColors
	floatRect =. (2 {. > snippetIndex { snippetRects) , (colWidth >. {. glqextent snippet) , TocLineHeight
	floatRect registerFloatingString snippet ; LiveSearchFont ; textColor
end.
)
NB. ---------------------- End Live Search ------------------------

NB. ---------------------- GitHub Search --------------------------
GitHubTable =: ''
GitHubWords =: ''
GitHubLines =: ''
GitHubLineCounts =: ''
GitHubCumulativeLineCounts =: ''
GitHubOriginalLinesByFile =: ''
SearchCode =: ''
GitHubResults =: ''
GitHubResultsNextCharacters =: ''
GitHubResultsNextTokens =: ''
GitHubPageIndex =: 0
GitHubPageCount =: 1
GitHubLastSearch =: ''
GitHubLastLiveSearchFont =: LiveSearchFont

setupGitHubTable =: {{
if. '' -: GitHubTable do.
	openLiveSearchDb ''
	gitHubContent =. , > {. > {: sqlreadm__liveSearchDb 'select content from github'
	GitHubTable =: _3 ]\ < ;._2 gitHubContent
	gitHubWordsInFiles =. ;: :: a: &. > lines =. ,&LF &. > 2 {"1 GitHubTable
	GitHubWords =: ; ,&(<0 { a.) &. > gitHubWordsInFiles
	GitHubLines =: < ;. _2 GitHubWords , (< , LF)
	GitHubOriginalLinesByFile =: < ;. _2 &. > lines
	SearchCode =: E. & GitHubWords
	GitHubLineCounts =. (SearchCode < 0 { a.) +/ ;. 2 SearchCode < , LF
	GitHubCumulativeLineCounts =: }: 0 , +/\ GitHubLineCounts
end.
}}

setGitHubPageIndex =: {{
NB. y A new page index for the GitHub search.
NB. Set it and perform a new search.
GitHubPageIndex =: y
searchGitHub searchBox
animate 1
}}

addSpacesToCodeWords =: {{
NB. y Code in boxed word form.
NB. Add a space to either side of a . or a :
t =. y
for_w. ;: '. : if. do. else. end. while. whilst. break. return. try. catch. catcht. catchd.' do.
t =. (< ' ' , (> w) , ' ') (I. w E. t) } t
end.
t
}}

searchGitHub =: {{
s =. ;: :: '' y
GitHubLastSearch =: y
if. 0 = # s do. GitHubResults =: '' return. end.
setupGitHubTable ''
maxLineCount =. _2 + <. (3 { DisplayDetailRect) % TocLineHeight
rawIndices =. I.@SearchCode s
GitHubPageCount =: >. (# rawIndices) % maxLineCount
if. 0 = # rawIndices do. GitHubResults =: '' return. end.
hitIndices =. > GitHubPageIndex { (- maxLineCount) <\ rawIndices
dotCount =. +/ SearchCode ;: y , '.'
colonCount =. +/ SearchCode ;: y , ':'
nextTokens =. (< LF) -.~ (rawIndices + # s) { GitHubWords
uniqueNextTokens =. ~. nextTokens
prefixes =. ('' ; '<space>') {~ (uniqueNextTokens = (< , '.')) +. uniqueNextTokens = (< , ':')
uniqueNextTokens =. prefixes , &. > uniqueNextTokens
nextTokenCounts =. #/.~ nextTokens
GitHubResultsNextTokens =: (uniqueNextTokens \: nextTokenCounts) ,: <"(0) \:~ nextTokenCounts
lineIndices =. +/"(1) 0 < hitIndices -/ I.@SearchCode < , LF
lineIndicesInFiles =. lineIndices - GitHubCumulativeLineCounts {~ <: +/"1 lineIndices >/ GitHubCumulativeLineCounts
lineNumbers =. >: lineIndicesInFiles
fileIndices =. +/"(1) 0 < hitIndices -/ I.@SearchCode < 0 { a.
hitLines =. > (<"0 lineIndicesInFiles) { &. > fileIndices { GitHubOriginalLinesByFile
urls =. fileIndices { 1 {"1 GitHubTable
GitHubResults =: ((fileIndices { 0 {"1 GitHubTable) ,. urls ,. (<"0 lineNumbers) ,. hitLines)
}}

drawCodeWithHighlights =: {{
NB. x xx yy width height
NB. y term ; code ; code color
NB. "Term" is the search term, which may have spaces.  The code may have spaces
NB. Matched tokens should be rendered in reverse video
if. y -: a: do. '' return. end.
'xx yy width height' =. > x
'term code color' =. y
if. 0 = # code -. ' ' do. '' return. end.
term =. term -. ' '
codeWithSpaces =. (code ~: ' ') < ;.1 code
highlightIndices =. , (i. # term) +"1 0 I. term E. code -. ' '
highlightFlags =. (1) highlightIndices } (# codeWithSpaces) # 0
lengths =. > {.@glqextent &. > codeWithSpaces
offsets =. xx + }: 0 , +/\ lengths
for_i. i. # codeWithSpaces do.
	fragment =. > i { codeWithSpaces
	offset =. i { offsets
	if. i { highlightFlags do.
		glrgb 0 0 0
		glbrush ''
		glpen ''
		glrect offset, (yy + height - <. TocLineHeight * 0.3), (i { lengths) , 4
	else.
		glrgb color
		gltextcolor ''
	end.
	(offset, yy) drawStringAt fragment
end.
''
}}

drawTocEntryGitHubSearch =: {{
NB. y xx yy width height
NB. Render the GitHub search display.
log 'drawTocEntryGitHubSearch ' , ": y
'xx yy width height' =. y
glclip 0 0 10000 100000
glrgb 0 0 0
gltextcolor ''
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
glfont LiveSearchFont
if. -. GitHubLastSearch -: searchBox do.
	GitHubPageIndex =: 0
	searchGitHub searchBox
end.
if. -. GitHubLastLiveSearchFont -: LiveSearchFont do.
	GitHubPageIndex =: 0
	searchGitHub searchBox
end.
GitHubLastLiveSearchFont =: LiveSearchFont
if. GitHubResults -: '' do.
	glfont SectionFont
	text =. 'GitHub Code Exploration' ; '(JSoftware Account Only)' ; 'Enter code in the "Phrase:" input text box.' ; 'Common following tokens are shown.' ; '0 Results'
	startY =. yy + <. (-: height) - TocLineHeight * # text
	xs =. xx + (-: width) - -: > {.@glqextent &. > text
	ys =. startY + TocLineHeight * i. # text
	(<"1 xs ,. ys) drawStringAt &. > text
	return.
end.
pageLabelHeight =. TocLineHeight
pageLabelWidth =. 30
pageLabels =. <@":"0 >: i. GitHubPageCount
pageLabelOrigins =. (xx + 60 + pageLabelWidth * i. GitHubPageCount) ,. 5
pageLabelRects =. pageLabelOrigins ,"1 1 pageLabelWidth , pageLabelHeight
(pageLabelRects -"(1 1) 4 4 0 0) registerRectLink"1 1 ('*setGitHubPageIndex '&, &. > <@":"0 i. GitHubPageCount) ,"0 1 (< ' ') , <1
(<"1 pageLabelOrigins) drawStringAt &. > pageLabels
((GitHubPageIndex { pageLabelRects) - 4 4 0 0) drawHighlight SelectionColor
((5 + xx) , 5) drawStringAt 'Page:'
pageLabelMargin =. 5
glrgb 180 180 180
gltextcolor ''
nextTokensLabel =. 'Next Tokens: '
((xx + 5) , yy + pageLabelMargin + pageLabelHeight) drawStringAt nextTokensLabel
nextTokensLabelWidth =. {. glqextent nextTokensLabel
nextTokens =. 0 { GitHubResultsNextTokens
tokenWidths =. 5 + > {.@glqextent &. > nextTokens
tokenCounts =. 1 { GitHubResultsNextTokens
tokenCountsWidths =. 15 + > {.@glqextent &. > tokenCountStrings =. ": &. > tokenCounts
tokenOffsets =. xx + 5 + nextTokensLabelWidth + +/\ }: 0 , tokenWidths + tokenCountsWidths
tokenCountsOffsets =. xx + 5 + nextTokensLabelWidth + +/\ tokenWidths + }: , 0 , tokenCountsWidths
glfont SectionFont
glrgb 180 180 180
gltextcolor ''
(<"1 tokenCountsOffsets ,. yy + pageLabelHeight + pageLabelMargin) drawStringAt &. > tokenCountStrings
glrgb GitHubColor 
gltextcolor ''
(<"1 tokenOffsets ,. yy + pageLabelHeight + pageLabelMargin) drawStringAt &. > nextTokens
glfont LiveSearchFont
columnGap =. 10
glrgb 0 0 0
gltextcolor ''
projects =. 0 {"1 GitHubResults
maxProjectWidth =. columnGap + >./ > {.@glqextent &. > projects
filenames =. >@{: &. > < ;. _2 &. > ,&'/' &. > 1 {"1 GitHubResults
maxFilenameWidth =. columnGap + >./ > {.@glqextent &. > filenames 
lineNumbers =. 2 {"1 GitHubResults
stringLineNumbers =. _4&{. &. > '000'&, &. > ": &. > lineNumbers
maxLineNumberWidth =. columnGap + >./ > {.@glqextent &. > stringLineNumbers
urls =. 1 {"1 GitHubResults
codes =. 3 {"1 GitHubResults
leftMargin =. 6
topMargin =. TocLineHeight * 2
ys =. topMargin + yy + TocLineHeight * i. # codes
glrgb 127 0 0
gltextcolor ''
(<"(1) projectOrigins =. (leftMargin + xx) ,. ys) drawStringAt &. > projects
projectRects =. _2 _2 4 4 +"1 1 projectOrigins ,. > glqextent &. > projects
projectUrls =. 'https://github.com/jsoftware/'&, &. > projects
(<"1 projectRects) registerRectLink &. ><"1 projectUrls ,. projects ,. < 1
glrgb 0 0 127
gltextcolor ''
filenameOffsets =. _5 + maxFilenameWidth - > {.@glqextent &. > filenames 
(<"(1) (filenameOffsets +"0 0 leftMargin + xx + maxProjectWidth) ,. ys) drawStringAt &. > filenames
glrgb 164 164 164
gltextcolor ''
(<"(1) (leftMargin + xx + maxProjectWidth + maxFilenameWidth) ,. ys) drawStringAt &. > stringLineNumbers
glrgb GitHubColor
gltextcolor ''
(<"(1) codeOrigins =. (leftMargin + xx + maxProjectWidth + maxFilenameWidth + maxLineNumberWidth) ,. ys) NB. drawStringAt &. > codes
names =. projects , &. > ':'&, &. > filenames 
codeRects =. _2 _2 4 4 +"1 1 codeOrigins ,. > glqextent &. > codes
(<"1 codeRects) registerRectLink &. > <"1 urls ,. names ,. < 1
(<"1 codeOrigins ,"(1 1) 10 , TocLineHeight) drawCodeWithHighlights &. > <"1 (< searchBox) ,. codes ,. < GitHubColor
}}
NB. -------------------- End GitHub Search ------------------------

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
result =. > {: sqlreadm__db 'select year, month, subject, author, link, day from forums where forumname = "' , y , '" order by year desc, month asc, day asc'
ForumCacheTable =: 0 1 2 3 4 5 {"1 result
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
entries =. ForumCacheTable #~ (TocEntryForumYear = > {."1 ForumCacheTable) *. calendarMonthIndex = > 1 {"1 ForumCacheTable NB. entries: year ; month ; subject ; author ; link ; day
if. 0 = # entries do. return. end.
subjects =. ~. 2 {"1 entries
ratios =. authorCounts % >./ authorCounts =. allSubjects #/. allSubjects =. 2 {"1 ForumCacheTable #~ (2 {"1 ForumCacheTable) e. subjects
subjects =. ~. allSubjects
subject =. TocEntryForumSubjectIndex { subjects 
resetForumAuthorEntries subject
authors =. 3 {"1 ForumAuthorEntries
authorYears =. 2&}. &. > ": &. > 0 {"1 ForumAuthorEntries
authorMonths =. ": &. > >: &. > 1 {"1 ForumAuthorEntries
authorDays =. ": &. > 5 {"1 ForumAuthorEntries
authorDates =. ; &. > <"1 authorMonths ,. (<'/') ,. authorDays
authorsWithDates =. ; &. > <"1 authors ,. (<'  ') ,. authorDates
subjectCommands =. '*setTocEntryForumSubjectIndex '&, &. > ": &. > <"0 i. # subjects
authorCommands =. '*setTocEntryForumAuthorIndex '&, &. > ": &. > <"0 i. # authors
ForumSubjectScrollIndex =: subjRect drawScrollerField subjects ; subjectCommands ; authorCounts ; (2 #~ # subjects) ; TocEntryForumSubjectIndex ; ForumSubjectScrollIndex ; 1 ; '<'
ForumAuthorScrollIndex =: authRect drawScrollerField  authorsWithDates ; authorCommands ; (_1 #~ # authors) ; (_1 #~ # authors) ; TocEntryForumAuthorIndex ; ForumAuthorScrollIndex ; 1 ; '<'
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

setTocOutlineRailTopLevelEntry =: 3 : 0
NB. The string name of a top-level category
NB. Select the current top-level category by string (entry)
NB. Table of level ; parentId ; categoryid ; category ; parentseq ; count ; link
index =. (3 {"(1) 1 getTocOutlineRailEntries MaxTocDepth) i. < y
setTocOutlineRailSelectedIndex index
)

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
elseif. GitHubCatString -: > 3 { entry do.
	drawTocEntryGitHubSearch y
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
	result =. > x recurseGetTocOutlineRailEntries y
NB. 	if. x = 0 do. result =. }. result end.
	if. 0 = # result do.
		result =. ''
	else.
NB. 		result =. (> tagCatId&~: &. > 1 {"1 rawResult) # rawResult  NB. Drop the child categories of *Tags.
		TocOutlineRailEntriesCache =: TocOutlineRailEntriesCache , key , < result
	end.
end.
log '...(getTocOutlineRailEntries) returning ' , (": # result) , ' results.'
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
0 < # gethttp dateUrl
NB. 0 < # gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/upload.test?cache=false'
)

checkForNewerDatabase =: 3 : 0
NB. Return 1 if a newer database is available.  
NB. Return 2 if a newer database is required.
NB. Return 3 if we're not on the network.
NB. Return 0 if the local database is up to date.
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

checkWhetherStageDatabasesHaveArrived =: {{
if. (fexist stageDbPath) *. (fexist stageFullTextDbPath) do.
	DatabaseDownloadStatus =: _3
	1
else.
	0
end.
}}

downloadLatestData =: {{
try.
	buildFullTextIndexDb ''
	(gethttp stageDbUrl) (1!:2) < stageDbPath
catch.
	DatabaseDownloadMessage =: (13!:12) ''
end.
}}

getRemoteDatabaseHash =: 3 : 0
gethttp dateUrl
)

transferDatabase =: 3 : 0
NB. Open the target db (tdb) and read all of the user records.  
NB. Write them to the staging db (db).
NB. Delete the target db, then rename the staging db
try.
	if. fexist stageDbPath do.
		if. fexist targetDbPath do.
			sdb =. sqlopen_psqlite_ stageDbPath
			tdb =. sqlopen_psqlite_ targetDbPath
			cats =. > {: sqlreadm__tdb 'select level, parentid, categoryid, category, parentseq, count, link from categories where categoryid > 1000000'
			historyMenu =. > {: sqlreadm__tdb 'select label, link from history'
			wiki =. > {: sqlreadm__tdb 'select title, categoryid, link from wiki where categoryid >= 1000000'
			try. keyValues =. > {: sqlread__tdb 'select key, value from keyvalue' catch. catcht. keyValues =. '' end.
			catCols =. ;: 'level parentid categoryid category parentseq count link'
			wikiCols =. ;: 'title categoryid link'
			keyValueCols =. ;: 'key value'
			sqlinsert__sdb 'categories' ; catCols ; < (> 0 {"1 cats) ; (> 1 {"1 cats) ; (> 2 {"1 cats) ; (3 {"1 cats) ; (> 4 {"1 cats) ; (> 5 {"1 cats) ; < (6 {"1 cats)
			sqlinsert__sdb 'wiki' ; wikiCols ; < (0 {"1 wiki) ; (> 1 {"1 wiki) ; < (2 {"1 wiki)
			sqlinsert__sdb 'history' ; ('label' ; 'link') ; < (0 {"1 historyMenu) ; < (1 {"1 historyMenu)
			if. 0 < # keyValues do.
				sdb_parms =. 'keyvalue' ; keyValueCols ; < (> 0 {"1 keyValues) ; (1 {"1 keyValues)
				sqlinsert__sdb sdb_parms
			end.
			sqlclose__sdb ''
			sqlclose__tdb ''
 			(1!:55) < targetDbPath
		end.
		targetDbPath frename stageDbPath
		try. (1!:22) < targetDbPath catch. end.  NB. Close the file.
	end.
	hash =. getRemoteDatabaseHash ''
	try. (1!:22) < targetDbPath catch. end.
	dbOpenDb ''
	sqlclose__db ''
	dbOpenDb ''
	sqlinsert__db 'admin' ; (;: 'key value') ; < 'Hash' ;  hash
	clearCache ''
catch. catcht.
	smoutput 'db error (if any): ' , sqlerror__db ''
	smoutput 'Problem: ' , (13!:12) ''
	smoutput 'sdb error (if any): ' , sqlerror__sdb ''
	smoutput 'tdb error (if any): ' , sqlerror__tdb ''
end.
)

asyncCheckForNewerDatabase =: {{
NB. Set DatabaseDownloadStatus
NB. Note that this routine is meant to be called as a task.
DatabaseDownloadStatus =: checkForNewerDatabase ''
animate 5
}}

initialDbDownloadDialog =: 3 : 0
if. isOnTheNetwork'' do.
	result =. wd 'mb query mb_yes =mb_no "Local Database Status" "A new database is required.  Yes to download ~100 MB (which will decompress and index to ~1 GB in ~temp); THIS MAY TAKE OVER A MINUTE."'
	if. result -: 'yes' do. 
		downloadLatestData ''
		transferDatabase ''
		buildFullTextIndexDb ''
		1
	else.
		0
	end.
else.
	wdinfo '' ; 'Cannot connect to the CDN and a new database is required.  Please be sure you have an internet connection.  OK to exit.'
	0
end.
)

buildFullTextIndexDb =: 3 : 0
try. (1!:55) < stageFullTextDbPath catch. end.
localDb =. sqlcreate_psqlite_ stageFullTextDbPath
sqlcmd__localDb 'CREATE VIRTUAL TABLE jindex USING FTS5 (body, tokenize="porter")'
sqlcmd__localDb 'CREATE TABLE auxiliary (title TEXT, year INTEGER, source TEXT, url TEXT)'
sqlcmd__localDb 'CREATE INDEX year_index ON auxiliary (year)'
sqlcmd__localDb 'CREATE INDEX source_index ON auxiliary (source)'
sqlcmd__localDb 'CREATE TABLE github (content BLOB)'
NB. lz4String =. gethttp indexUrl
dataString =. lz4_uncompressframe gethttp indexUrl
NB. lz4String =. (1!:1) < jpath '~temp/jwikiviz.fulltext.txt.lz4'
sep =. 2 3 4 { a.
table =. _6 ]\ (<: # sep)&}. &. > (sep E. s) <;._2 s =. dataString
bodies =. <@;"1 ,&' ' &. > 3 4 5 {"1 table
titles =. 3 {"1 table
years =. > ". &. > 2 {"1 table
sources =. 1 {"1 table
urls =. 0 {"1 table
try.
	sqlinsert__localDb 'auxiliary' ; (;: 'title year source url') ; < titles ; years ; sources ; < urls
	sqlinsert__localDb 'jindex' ; (;: 'body') ;  << bodies
catch. catcht.
	smoutput (13!:12) ''
	smoutput sqlerror__localDb ''
end.
gitHubStringCompressed =. gethttp githubContentUrl
gitHubString =. lz4_uncompressframe gitHubStringCompressed
try.
	sqlinsert__localDb 'github' ; (;: 'content') ; < gitHubString
	sqlclose__localDb ''
	(1!:22) < stageFullTextDbPath
	GitHubTable =: ''
catch. catcht.
	s =. 'Problem in buidFullTextIndedDb ' , (13!:12) ''
	s =. s , ' / ' , sqlerror__localDb ''
	return.
end.
''
)

bringNewDataOnline =: {{
if. -. checkWhetherStageDatabasesHaveArrived '' do.
	'Cannot bring new data online; not all data has arrived.'
	return.
end.
try.
	transferDatabase ''
	try. sqlclose__liveSearchDb '' catch. end.
	liveSearchDb =: ''
	try. (1!:22) < liveSearchDbPath catch. end.  NB. Close the file.
	try. (1!:55) < liveSearchDbPath catch. end. NB. Delete the file.
	liveSearchDbPath frename stageFullTextDbPath 
	asyncCheckForNewerDatabase '' NB. It's okay to call it synchronously.
	setUpdateButtons ''
catch. catcht.
	'Problem in bringNewDataOnline: ' , (13!:12) ''
end.
}}
NB. ==================== End Database Management ======================

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
try.
	if. -. checkGethttpVersion '' do. return. end.
	if. -. dbExists '' do. 
		if. -. initialDbDownloadDialog '' do. return. end.
	end.
	if. 0 < count =. 0 >. 5 - 1 T. '' do. 0&T."(0) count # 0 end.
	dbPyx =: asyncCheckForNewerDatabase t. 'worker' ''
	appPyx =: asyncCheckAppUpToDate t. 'worker' ''
	dbOpenDb ''
	initAdmin ''
	buildLiveSearchWikiTitlesByCategory ''
	loadVoc ''
	clearLog ''
	buildForm ''
	layoutForm ''
	loadHistoryMenu ''
	version =. ". '.' -.~ 9 10 11 12 13 { JVERSION
	wd 'pshow maximized'
	wd 'msgs'
	animate 10
	fs =. '5' getKeyValue 'FontSlider'
	wd 'set fontSlider ' , fs
	setFontSize ". fs
	wd 'timer 20'
catch. catcht.
	smoutput 'Problem: ' , (13!:12) ''
	smoutput 'Database error (if any): ' , sqlerror__db ''
end.
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
