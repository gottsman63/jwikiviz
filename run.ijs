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

NB. *** A Items ***
NB. Test initial installation.  
NB. Suppress <pre>

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
awsPrefix =: 'https://jviewer.s3.us-east-2.amazonaws.com'
dbUrl =: awsPrefix , '/jviewer.lz4'

dbPath =: jpath '~temp/jviewer.db'
logPath =: jpath '~temp/jviewer.log'
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
1 log 'asyncCheckAppUpToDate'
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
1 log '...AppUpToDate = ' , ": AppUpToDate
animate 5
)

updateAppVersion =: 3 : 0
log 'updateAppVersion'
dbCloseDb ''
wd 'set appUpdate caption *Updating the J Viewer...'
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

dbError =: 3 : 0
if. '' ~: db do. sqlerror__db '' else. 'Error?  Database is closed!' end.
)

dbOpenDb =: 3 : 0
try.
NB.	if. -. db -: '' do. dbCloseDb '' end.
	if. db -: '' do. 
		db =: sqlopen_psqlite_ dbPath
NB.		initializeWithDatabase ''
	end.
catch. catcht.
	1 log 'dbOpenDb: Error opening database: ' , dbPath
	1 log (13!:12) ''
end.
)

dbCloseDb =: {{
try.
	if. db ~: '' do. sqlclose__db '' end.
catch. catcht.
	1 log 'dbCloseDb: Error closing database'
end.
db =: ''
}}
NB. ================== Logging ===================
logHtmlPrefix =: 0 : 0
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Log</title>
  </head>
  <body style="font-family: 'Avenir', Verdana, sans-serif; font-size: 16px">
<p style="font-family: 'Avenir', Verdana, sans-serif; font-size: 18px; font-weight: bold">
Log (most recent first)
</p>
  <pre>
)

logHtmlSuffix =: 0 : 0
  </pre>
  </body>
</html>
)

LogBackgroundEvents =: ''
LogMutex =: ''
LogLoadBrowserFlag =: 0
LogNewEventsWrittenFlag =: 0
LogBrowserUpdateRequired =: 0

setSnapshotLogButtonState =: 3 : 0
count =. +/ LF = (1!:1) < logPath
wd 'set snapshotLog caption *Log (' , , (": count) , ')'
)

snapshotLogToBrowser =: 3 : 0
NB. y Number of records to snapshot (0 for all)
try.
	LogLoadBrowserFlag =: 1
	allEntries =. |. < ;. _2 (1!:1) < logPath
	if. (y = 0) +. y >: # allEntries do.
		entries =. allEntries
	else.
		if. (50 + y) > # allEntries do. ellipsis =. a: else. ellipsis =. < '...' end.
		entries =. a: -.~ ~. (y {. allEntries) , ellipsis , (_50 {. allEntries)
	end.
	html =. logHtmlPrefix , (; ,&'<br>' &. > entries) , logHtmlSuffix
	wd 'set browser html *' , html
	LogBrowserUpdateRequired =: 0
catch.
wd 'set browser html *Problem in snapshotLogToBrowser: ' , (13!:12) ''
end.
)

writeBackgroundEvents =: {{
if. 0 = # LogBackgroundEvents_jwikiviz_ do. return. end.
try.
	try. 13 T. LogMutex_jwikiviz_ catch. end. NB. Release, just in case...
	11 T. LogMutex_jwikiviz_ NB. Take a lock.
	boxedPath =. < logPath_jwikiviz_
	((1!:3)&boxedPath) &. > LogBackgroundEvents_jwikiviz_
	LogBackgroundEvents_jwikiviz_ =: ''
	try. 13 T. LogMutex_jwikiviz_ catch. end. NB. Release the lock.
catch.
	smoutput 'Problem in writeBackgroundEvents: ' , (13!:12) ''
end.
}}

log =: 0&baseLog : baseLog

baseLog =: 4 : 0
if. (x = 0) *. -. LogFlag do. return. end.
LogNewEventsWrittenFlag =: 1
LogBrowserUpdateRequired =: 1
event =. ((6!:0) 'YYYY MM DD hh mm sssss') , '      ' , y , LF
if. 0 ~: 3 T. '' do. NB. If we're not on the main thread...
	try. 13 T. LogMutex catch. end. NB. Release, just in case...
	11 T. LogMutex NB. Take a lock.
	LogBackgroundEvents =: LogBackgroundEvents , < event
	13 T. LogMutex NB. Release the lock.
else. 
	writeBackgroundEvents ''
	event (1!:3) < logPath
end.
)

clearLog =: 3 : 0
'' (1!:2) < logPath
LogBackgroundEvents =: ''
if. LogMutex -: '' do. LogMutex =: 10 T. 0 end.
2 log 'Path: ' , logPath
2 log 'email to edward.j.gottsman@gmail.com'
2&log &. > < ;. _2 JVERSION , LF
2 log 'qscreen: ' , wd 'qscreen'
)

logVersionInfo =: {{
version =. manifest_version (1!:1) < jpath addonPath
2 log 'J Viewer Version ' , version
if. isDatabaseOpen '' do.
	datetime =. , > > {: sqlreadm__db 'select value from admin where key = "CrawlStart"'
	2 log 'Crawl: ' , datetime
else.
	2 log '(No database open.)'
end.
}}
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

NB. =============== Shortcut ==================
ShortcutFlag =: 0

setShortcutFlag =: {{
userkeys =. (1!:1) < jpath '~config/userkeys.cfg'
ShortcutFlag =: +./ 'jwikiviz' E. userkeys
}}

shortcutInfo =: 3 : 0
smoutput ' '
smoutput 'NB. Create a shortcut for J Viewer:'
smoutput 'open ''~config/userkeys.cfg'''
smoutput 'NB. Append the line: Ctrl+Shift+H;0;J Viewer;load ''~addons/gottsman63/jwikiviz/run.ijs'''
smoutput ' '
smoutput 'browse_j_ ''https://code.jsoftware.com/wiki/Guides/Qt_IDE/Configure/User_Keys'' NB. More information.'
NB.    load '~addons/gottsman63/jwikiviz/run.ijs'
)

NB. ==================== Form =====================
VocMouseXY =: 0 0
VocMouseClickXY =: 0 0

setUpdateButtons =: 3 : 0
log 'setUpdateButtons'
select. AppUpToDate
case. _1 do. appCap =. 'Checking for new version...'
case. 0 do. appCap =. 'New J Viewer version available'
case. 1 do. appCap =. 'J Viewer is up to date' 
case. 2 do. appCap =. 'Offline (apparently)'
end.
wd 'set appUpdate caption *' , appCap
select. DatabaseDownloadStatus
case. _3 do. dbCap =. 'Click to move new data online'
case. _2 do. dbCap =. 'Downloading data (background)...'
case. _1 do. dbCap =. 'Checking for new database...'
case. 0 do. dbCap =. 'Local database is up to date'
case. 1 do. dbCap =. 'Click to download the latest data (background)...'
case. 2 do. dbCap =. 'Database download required...'
case. 3 do. dbCap =. 'Offline (apparently)'
end.
wd 'set dbUpdate caption *' , dbCap
if. DatabaseDownloadStatus >: 0 do. wd 'set appUpdate enable 1' else. wd 'set appUpdate enable 0' end.
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
case. _2 do. wdinfo 'Downloading data in the background'
case. _1 do. wdinfo 'Checking for new data in the background'
case. 0 do. downloadFlag =. 'yes' -: wd 'mb query mb_yes =mb_no "Local Database Status" "Nota bene: Yes to download ~350 MB that (decompressed & indexed) will occupy ~1 GB in ~temp."'
case. 1 do. downloadFlag =. 'yes' -: wd 'mb query mb_yes =mb_no "Local Database Status" "Nota bene: Yes to download ~350 MB that (decompressed & indexed) will occupy ~1 GB in ~temp."'
case. 2 do. downloadFlag =. 'yes' -: wd 'mb query mb_yes =mb_no "Local Database Status" "Nota bene: Yes to download ~350 MB that (decompressed & indexed) will occupy ~1 GB in ~temp."'
case. 3 do. setUpdateButtons ''  NB. We were offline; check whether we're connected again.
end.
if. downloadFlag do. 
	DatabaseDownloadStatus =: _2
	downloadPyx =: downloadLatestData t. 'worker' ''
	setUpdateButtons ''
	if. -. isDatabaseOpen '' do. snapshotLogToBrowser 0 end.
end.
}}

buildForm =: 3 : 0
log 'buildForm'
NB.	datetime =. , > > {: sqlreadm__db 'select value from admin where key = "CrawlStart"'
version =. manifest_version (1!:1) < jpath addonPath
NB.	caption =. 'J Viewer ' , version , ' (Crawl: ' , datetime , ')'
caption =. 'J Viewer ' , version

wd 'pc vizform escclose;'
wd 'pn *' , caption
wd 'bin h;'
wd   'bin v;'
wd     'bin h;'
NB. wd       'cc closeButton button; cn *X'
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
wd       'cc liveForum checkbox; cn *Forum'
wd       'cc liveGitHub checkbox; cn *GitHub'
wd       'cc liveWiki checkbox; cn *Wiki'
wd       'cc liveRosetta checkbox; cn *Rosetta'
wd       'cc wikiSearchMenu combolist;'
wd       'cc liveAgeLabel static'
wd       'cc liveAge slider 2 1 1 1 10 3'
wd     'bin z;'
wd     'bin h;'
wd       'bin v;'
wd         'cc showBookmarks checkbox; cn *Show Bookmarks'
wd         'cc tocList listbox;'
wd       'bin z'
wd       'cc vocContext isidraw'
wd     'bin z'
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
wd 'set snapshotLog visible 1'
wd 'set loadPost font arial 14 bold'
wd 'set tocList font Arial 14'
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
tocListWidth =. 200
if. 0.1 < | LayoutRatioTarget - LayoutRatio do.
	sgn =. * LayoutRatioTarget - LayoutRatio
	LayoutRatio =: LayoutRatio + sgn * 0.1 <. | LayoutRatioTarget - LayoutRatio
else.
	LayoutRatio =: LayoutRatioTarget
end.
leftWidth =. winW * LayoutRatio
vocContextWidth =. <. leftWidth - tocListWidth
browserWidth =. winW - leftWidth
NB. wd 'set closeButton maxwh ' , (": 20 , controlHeight) , ';'
wd 'set fontSlider maxwh ' , (": (<. leftWidth * 0.18) , controlHeight) , ';'
wd 'set searchStatic maxwh ' , (": (<. leftWidth * 0.06) , controlHeight) , ';'
wd 'set searchBox maxwh ' , (": (<. leftWidth * 0.35) , controlHeight) , ';'
wd 'set searchWordsStatic maxwh ' , (": (<. leftWidth * 0.05) , controlHeight) , ';'
wd 'set searchBoxWords maxwh ' , (": (<. leftWidth * 0.35) , controlHeight) , ';'
if. ShortcutFlag = 0 do.
wd 'set shortcut visible 1'
wd 'set shortcut maxwh ' ,  , (": (<. leftWidth * 0.12) , controlHeight) , ';'
wd 'set logcheck maxwh ' , (": (<. leftWidth * 0.12) , controlHeight) , ';'
wd 'set snapshotLog maxwh ' ,  (": (<. leftWidth * 0.1) , controlHeight) , ';'
wd 'set dbUpdate maxwh ' , (": (<. leftWidth * 0.38) , controlHeight) , ';'
wd 'set appUpdate maxwh ' , (": (<. leftWidth * 0.28) , controlHeight) , ';'
else.
wd 'set shortcut visible 0'
wd 'set logcheck maxwh ' , (": (<. leftWidth * 0.12) , controlHeight) , ';'
wd 'set snapshotLog maxwh ' ,  (": (<. leftWidth * 0.16) , controlHeight) , ';'
wd 'set dbUpdate maxwh ' , (": (<. leftWidth * 0.4) , controlHeight) , ';'
wd 'set appUpdate maxwh ' , (": (<. leftWidth * 0.3) , controlHeight) , ';'
end.
wd 'set liveForum maxwh ' , (": 60 , controlHeight) , ';'
wd 'set liveGitHub maxwh ' , (": 70 , controlHeight) , ';'
wd 'set liveWiki maxwh ' , (": 50 , controlHeight) , ';'
wd 'set liveRosetta maxwh ' , (": 80 , controlHeight) , ';'
wd 'set wikiSearchMenu maxwh ' , (": (-: vocContextWidth - 350) , controlHeight) , ';'
wd 'set liveAgeLabel maxwh ' , (": 70 , controlHeight) , ';'
wd 'set liveAge maxwh ' , (": (-: leftWidth - 340) , controlHeight) , ';'

wd 'set vocContext maxwh ' , (": vocContextWidth , vocContextHeight) , ';'
wd 'set tocList maxwh ' , (": tocListWidth , vocContextHeight) , ';'

wd 'set bookmark maxwh ' , (": 100, controlHeight) , ';'
wd 'set history maxwh ' , (": (browserWidth * 0.5) , controlHeight) , ';'
wd 'set launch maxwh ' , (": (browserWidth * 0.15) , controlHeight) , ';'
wd 'set feedback maxwh ' , (": 100, controlHeight) , ';'
wd 'set browser maxwh ' , (": browserWidth , winH - controlHeight) , ';'
wd 'set loadPost visible ' , ": LayoutForumPostLoadButtonEnable
if. LayoutRatio ~: LayoutRatioTarget do. animate 2 end.
setLiveAgeLabel ''
NB. setUpdateButtons ''  NB. This turns out to be a significant drag on frame rate.  Do not do it.
setControlVisibility isDatabaseOpen ''
)

setControlVisibility =: {{
NB. y Visibility flag for controls that are hidden when database is unavailable.
log 'setControlVisibility'
try.
	flag =. ": y
	wd 'set fontSlider enable ' , flag
	wd 'set searchStatic enable ' , flag
	wd 'set searchBox enable ' , flag
	wd 'set searchWordsStatic enable ' , flag
	wd 'set searchBoxWords enable ' , flag
	wd 'set liveForum enable ' , flag
	wd 'set liveGitHub enable ' , flag
	wd 'set liveWiki enable ' , flag
	wd 'set liveRosetta enable ' , flag
	wd 'set wikiSearchMenu enable ' , flag
	wd 'set liveAgeLabel enable ' , flag
	wd 'set liveAge enable ' , flag
	wd 'set tocList enable ' , flag
NB.	wd 'set vocContext enable ' , flag
	wd 'set bookmark enable ' , flag
	wd 'set history enable ' , flag
	wd 'set launch enable ' , flag
	wd 'set loadPost enable ' , flag
catch.
	1 log 'Problem in setControlVisibility: ' , (13!:12) ''
end.
}}

setLiveSearchSourceFlagButtons =: {{
wd 'set liveForum value 1'
wd 'set liveGitHub value 1'
wd 'set liveWiki value 1'
wd 'set liveRosetta value 1'
}}

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
TocLineHeight =: <. 2.2 * 13 + FontAdjustment
VocCellFont =: 'arial ' , (": 14 + FontAdjustment) , ' bold'
VocValenceFont =: 'arial ' , ": 12 + FontAdjustment
CountFont =: 'arial ' , ": 15 + FontAdjustment
LiveSearchFont =: 'arial ' , ": 16 + FontAdjustment
SectionFont =: 'arial bold ' , ": 16 + FontAdjustment
wd 'set tocList font Arial ' , ": 14 + FontAdjustment
CellLineHeight =: <. TocLineHeight * 0.8
'FontSlider' setKeyValue ": y
invalidateDisplay ''
)

vizform_resize =: 3 : 0
layoutForm ''
)

vizform_close =: 3 : 0
log 'vizform_close'
dbCloseDb ''
wd 'timer 0'
wd 'pclose'
)

vizform_showBookmarks_button =: {{
ShowBookmarksFlag =: showBookmarks = '1'
clearCache ''
initializeTocList MaxTocDepth
}}

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
snapshotLogToBrowser 0
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

vizform_liveRosetta_button =: {{
markLiveSearchDirty ''
invalidateDisplay ''
setTocOutlineRailTopLevelEntry LiveSearchCatString
}}

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

vizform_tocList_select =: {{
items =. < ;. _2 (wd 'get tocList allitems') , LF
index =. items i. < tocList
setTocOutlineRailSelectedIndex index
}}

vizform_browser_mmove =: 3 : 0
clearQueuedUrl ''
setLayoutRatioBrowser ''
VocMouseXY =: _1 _1
)

vizform_browser_curl =: 3 : 0
log 'vizform_browser_curl'
if. -. isDatabaseOpen '' do. return. end.
url =. > (1 {"1 wdq) {~ ({."1 wdq) i. < 'browser_curl'
if. -. 'http' -: 4 {. url do. return. end.  NB. Probably loading html, not a url.
LogLoadBrowserFlag =: 0
LastUrlLoaded =: url
historyMenu =. getHistoryMenu ''
if. 0 = # historyMenu do.
	addToHistoryMenu url ; url
else.
	topHistoryUrl =. > 0 { 0 { getHistoryMenu ''
	if. -. +./ topHistoryUrl -: url do. addToHistoryMenu url ; url end.
end.
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
LogLoadBrowserFlag =: 0
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

FrameTimeQueue =: (6!:1) ''

frame =: {{
now =. (6!:1) ''
if. 0 < +/ 1 < now - FrameTimeQueue do.
	1 log 'fps ' , ": # FrameTimeQueue
	FrameTimeQueue =: now
else.
	FrameTimeQueue =: FrameTimeQueue , now
end.
}}

sys_timer_z_ =: {{
NB. frame_jwikiviz_ ''
wd 'psel vizform'
FrameCounter_jwikiviz_ =: >: FrameCounter_jwikiviz_
fps =. <. 1000 % TimerFractionMsec_jwikiviz_
if. LogNewEventsWrittenFlag_jwikiviz_ do. 
	setSnapshotLogButtonState_jwikiviz_ ''
	writeBackgroundEvents_jwikiviz_ ''
	LogNewEventsWrittenFlag_jwikiviz_ =: 0
end.
if. LogLoadBrowserFlag_jwikiviz_ *. LogBrowserUpdateRequired_jwikiviz_ do. snapshotLogToBrowser_jwikiviz_ 300 end.
try.
if. 0 = (10 * fps) | FrameCounter_jwikiviz_ do. NB. Check things.
	checkWhetherNewDatabaseHasArrived_jwikiviz_ ''
	setUpdateButtons_jwikiviz_ ''
end.
if. 0 = (60 * 60 * fps) | FrameCounter_jwikiviz_ do.
	asyncCheckAppUpToDate_jwikiviz_ t. 'worker' ''
	asyncCheckForNewerDatabase_jwikiviz_ t. 'worker' ''
end.
catch.
end.
if. 0 = TimerCount_jwikiviz_ do. return. end.
NB. log_jwikiviz_ 'sys_timer_z_: ' , ": TimerCount_jwikiviz_
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

setDisplayRects =: 3 : 0
'w h' =. ". wd 'get vocContext wh'
log 'setDisplayRects vocContext wh: ' , ": w , h
DisplayListRect =: 0 0 175 , h
NB. DisplayDetailRect =: 175 0 , (w - 175) , h
DisplayDetailRect =: 0 0 , w , h
)

trigger_paint =: 3 : 0
log 'trigger_paint ' , (wd 'getp wh') , '   ' , (": getFrameRate '') , ' fps'
try.
	glfill BackgroundColor , 255
	if. -. isDatabaseOpen '' do. return. end.
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
RosettaColor =: 11 0 128

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
MaxTocDepth =: 8
DisplayListRect =: 10 10 100 100
DisplayDetailRect =: 100 10 100 100
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
ShowBookmarksFlag =: 0
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
initializeTocList MaxTocDepth
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
try.
	if. y -: '' do. return. end.
	if. -. 'http' -: 4 {. > 1 { y do. return. end. NB. Probably loading html, not a url.
	loadHistoryMenu ''
	if. HistoryMenu -: '' do. HistoryMenu =: ,: y else. HistoryMenu =: ~. y , HistoryMenu end.
	s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
	wd 'set history items *' , s
	wd 'set history select 0'
	HistoryMenu =: (30 <. # HistoryMenu) {. HistoryMenu
	sqlcmd__db 'delete from history'
	sqlinsert__db 'history' ; (;: 'label link') ; < ({:"1 HistoryMenu) ; < {."1 HistoryMenu
catch.
	1 log 'Problem in addToHistoryMenu: ' , (13!:12) ''
	1 log 'db error (if any): ' , sqlerror__db ''
end.
)

loadHistoryMenu =: 3 : 0
log 'loadHistoryMenu'
dbOpenDb ''
HistoryMenu =: > {: sqlreadm__db 'select link, label from history'
if. 0 = # HistoryMenu do. return. end.
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
	string =. ('_\d+_' ; '') rxrplc string  NB. Remove any stray embedded line numbers (used in GitHub Live Search).
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
NB. glrgb LabelColor
glrgb BackgroundColor
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
LiveSearchRawResult =: ''

NB. jEnglishDict =: _2 ]\ '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':' ; 'co' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'F:.' ; 'fcapcodot' ; 'F::' ; 'fcapcoco' ; 'F:' ; 'fcapco' ; 'F..' ; 'fcapdotdot' ; 'F.:' ; 'fcapdotco' ; 'F.' ; 'fcapdot' ; 'H.' ; 'hcapdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco' ; 'j.' ; 'jdot' ; 'L.' ; 'lcapdot' ; 'L:' ; 'lcapco' ; 'm.' ; 'mdot' ; 'M.' ; 'mcapdot' ; 'NB.' ; 'ncapbcapdot' ; 'o.' ; 'odot' ; 'p.' ; 'pdot' ; 'p:' ; 'pco' ; 'q:' ; 'qco' ; 'r.' ; 'rdot' ; 's:' ; 'sco' ; 't.' ; 'tdot' ; 'T.' ; 'tcapdot' ; 'u:' ; 'uco' ; 'x:' ; 'xco' ; 'Z:' ; 'zcapco' ; 'assert.' ; 'assertdot' ; 'break.' ; 'breakdot' ; 'continue.' ; 'continuedot' ; 'else.' ; 'elsedot' ; 'elseif.' ; ' elseifdot' ; 'for.' ; 'fordot' ; 'if.' ; 'ifdot' ; 'return.' ; 'returndot' ; 'select.' ; 'selectdot' ; 'case.' ; 'casedot' ; 'fcase.' ; 'fcasedot' ; 'try.' ; 'trydot' ; 'catch.' ; 'catchdot' ; 'catchd.' ; 'catchddot' ; 'catcht.' ; 'catchtdot' ; 'while.' ; 'whiledot' ; 'whilst.' ; 'whilstdot'         
NB. jMnemonics =: , &. > 0 {"1 jEnglishDict
NB. jEnglishWords =: 'J'&, &. > 1 {"1 jEnglishDict
NB. jPrintedIndices =: 'J'&, &. > <@":"0 i. # jMnemonics
jEnglishEquivalents =: _2 ]\ '(' ; 'leftpar' ; ')' ; 'rightpar' ; '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':' ; 'co' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'F:.' ; 'fcapcodot' ; 'F::' ; 'fcapcoco' ; 'F:' ; 'fcapco' ; 'F..' ; 'fcapdotdot' ; 'F.:' ; 'fcapdotco' ; 'F.' ; 'fcapdot' ; 'H.' ; 'hcapdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco' ; 'j.' ; 'jdot' ; 'L.' ; 'lcapdot' ; 'L:' ; 'lcapco' ; 'm.' ; 'mdot' ; 'M.' ; 'mcapdot' ; 'NB.' ; 'ncapbcapdot' ; 'o.' ; 'odot' ; 'p.' ; 'pdot' ; 'p:' ; 'pco' ; 'q:' ; 'qco' ; 'r.' ; 'rdot' ; 's:' ; 'sco' ; 't.' ; 'tdot' ; 'T.' ; 'tcapdot' ; 'u:' ; 'uco' ; 'x:' ; 'xco' ; 'Z:' ; 'zcapco' ; 'assert.' ; 'assertdot' ; 'break.' ; 'breakdot' ; 'continue.' ; 'continuedot' ; 'else.' ; 'elsedot' ; 'elseif.' ; ' elseifdot' ; 'for.' ; 'fordot' ; 'if.' ; 'ifdot' ; 'return.' ; 'returndot' ; 'select.' ; 'selectdot' ; 'case.' ; 'casedot' ; 'fcase.' ; 'fcasedot' ; 'try.' ; 'trydot' ; 'catch.' ; 'catchdot' ; 'catchd.' ; 'catchddot' ; 'catcht.' ; 'catchtdot' ; 'while.' ; 'whiledot' ; 'whilst.' ; 'whilstdot'         
jEnglishDict =: (0 {"1 jEnglishEquivalents) ,. 'J'&, &. > <@":"0 i. # jEnglishEquivalents
jMnemonics =: , &. > 0 {"1 jEnglishDict
jEnglishWords =: 1 {"1 jEnglishDict
htmlEncodings =: _2 ]\ '&gt;' ; '>' ; '&lt;' ; '<' ; '&quot;' ; '"' ; '&amp;' ; '&' ; '<tt>' ; ' ' ; '</tt>' ; ' ' ; '<pre>' ; ' '
searchJMnemonics =: jMnemonics&i.
searchJEnglishWords =: jEnglishWords&i.
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

categorizeLiveSearchRosettaFiles =: {{
NB. y A list of boxed titles, snippets, urls, years, sources from the forum search results
NB. Just categorize everything under RosettaCode.
(< 'RosettaCode') ,: < y
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

NB. openLiveSearchDb =: 3 : 0
NB. if. liveSearchDb -: '' do. liveSearchDb =: sqlopen_psqlite_ liveSearchDbPath end.
NB. )

createQuery =: 3 : 0
NB. Use searchBox and searchBoxWords to create a query.
phrase =. ; }: , (<'+') ,.~ a: -.~ < ;. _2 (translateToJEnglish searchBox) , ' '
words =. ; }: , (<' AND ') ,.~ a: -.~ < ;. _2 (translateToJEnglish searchBoxWords) , ' '
if. (0 = # words) +. 0 = # phrase do. and =. '' else. and =. ' AND ' end.
'"' , phrase , and , words , '"'
)

dropSpacesSnippetTokens =: (jMnemonics -. , &. > ':' ; '.') , , &. > '(' ; ')'

translateToJ =: 3 : 0
NB. y A string possibly containing JEnglish tokens
NB. Convert the JEnglish to J tokens.
NB. Drop most of the spaces between the J tokens.
NB. log 'translateToJ ' NB. , y
try.
	tokens =. ;: y -. ''''
	hits =. searchJEnglishWords"1 0 tokens
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
	1 log 'performLiveSearch: ' , y
	LiveSearchRawResult =: ''
	dbOpenDb ''
	time =. (6!:2) 'LiveSearchRawResult =. > {: sqlreadm__db y'
	1 log '...' , (": # LiveSearchRawResult) , ' result(s) in ' , (": time) , ' sec.'
catch.
1 log 'Live Search problem: ' , (13!:12) ''
1 log 'DB Error (if any): ' , dbError ''
end.
LiveSearchRawResult
)

submitLiveSearch =: 3 : 0
NB. y Empty
NB. Create a table of title ; Snippet ; Url
log 'submitLiveSearch: ' , searchBox
try.
	LiveSearchRawResult =: ''
	if. 1 >: (# searchBox) + # searchBoxWords do. return. end.
NB.	rattleResult =. 4 T. LiveSearchPNB.yx
NB.	if.  rattleResult > 0 do. NB. Make sure we don't step on a running search. 
NB.		1 log 'submitLiveSearch: search in progress already.  Returning.'
NB.		return.
NB.	end.
	LastLiveSearchQuery =: searchBox , ' ' , searchBoxWords
	setLiveSearchPageIndex 0
	forumFlag =. liveForum = '1'
	wikiFlag =. liveWiki = '1'
	gitHubFlag =. liveGitHub = '1'
	rosettaFlag =. liveRosetta = '1'
	if. 0 = +./ forumFlag , wikiFlag , gitHubFlag , rosettaFlag do. forumFlag =. wikiFlag =. gitHubFlag =. rosettaFlag =. 1 end.
	whereClause =. ' source IN (' , (}: ; ,&',' &. > ((forumFlag , wikiFlag , gitHubFlag , rosettaFlag) # '"F"' ; '"W"' ; '"G"' ; '"R"')) , ') '
	currentYear =. {. (6!:0) ''
	if. 10 = ". liveAge do.
		cutoffYear =. 0
	else.
		cutoffYear =. 1 + currentYear - ". liveAge
	end.
	query =. createQuery ''
	fullSearch =. 'select title, url, year, source, snippet(jindex, 0, '''', '''', '''', 50) from auxiliary, jindex where jindex MATCH ' , query , ' AND (auxiliary.rowid = jindex.rowid) AND (year >= ' , (": cutoffYear) , ') AND ' , whereClause , ' order by rank limit 200'
NB.	log 'About to make a pyx for search: ' , fullSearch
NB.	LiveSearchPyx =: performLiveSearch t. 'worker' fullSearch
	LiveSearchRawResult =: performLiveSearch fullSearch
	LiveSearchIsDirty =: 0
catch.
	1 log 'Problem in submitLiveSearch: ' , (13!:12) ''
	1 log '...db error (if any): ' , dbError ''
end.
)

markLiveSearchDirty =: 3 : 0
LiveSearchIsDirty =: 1
)

processLiveSearchResults =: {{
log 'processLiveSearchResults'
try.
	if. -. LiveSearchIsDirty do. 1 return. end.
	submitLiveSearch ''
	result =. LiveSearchRawResult
	if. 0 = # result do. 
		LiveSearchResults =: ''
 		wd 'set wikiSearchMenu items *'
		log 'processLiveSearchResults: no results found'
		1 NB. Fake rattleResult indicating that we're done with the query.
		return.
	end.
	result =. result /: 'test'&E. &. > (1 {"1 result) NB. Sort 'test' files last
	snippets =. 4 {"1 result
	sources =. {. &. > 3 {"1 result
	if. 0 < # searchBox do. highlightString =. searchBox else. highlightString =. > {. < ;. _2 searchBoxWords , ' ' end.

	lineLabels =. highlightString&extractLineLabel &. > translateToJ &. > snippets
	links =. (1 {"1 result) , &. > lineLabels
	results =. (titles =. 0 {"1 result) ,. snippets ,. links ,. (years =. 2 {"1 result) ,. sources
	log '...(processLiveSearchResults) found ' , (": # result) , ' results.'
	LiveSearchResults =: results
	categorizedWikiResults =. categorizeLiveSearchWikiTitles results #~ sources = < 'W'
	categorizedForumResults =. categorizeLiveSearchForumPosts results #~ sources = < 'F'
	categorizedGitHubResults =. categorizeLiveSearchGitHubFiles results #~ sources = < 'G'
	categorizedRosettaResults =. categorizeLiveSearchRosettaFiles results #~ sources = < 'R'
	categorizedResults =. ((<'*All') ,: < LiveSearchResults) ,. categorizedForumResults ,. categorizedWikiResults ,. categorizedGitHubResults ,. categorizedRosettaResults
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
catch.
	1 log 'Problem in processLiveSearchResults: ' , (13!:12) ''
	1 log 'DB error (if any): ' , dbError ''
end.
1 NB. Fake rattleResult indicating that we're done with the query.
}}

translateToJEnglish =: 3 : 0
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
raw =. ('''' ; '''''') rxrplc y
rawTokens =. ;: raw
hits =. jMnemonics i."1 0 rawTokens
string =. ; (hits {"0 1 jEnglishWords ,"1 0 rawTokens) ,. < ' '
string
)

extractLineLabel =: {{
NB. x A search term from Live Search.
NB. y A code fragment from Live Search possibly including embedded line numbers.
NB. Return the line number # label on which the code fragment appears or '' if there is no line number.
term =. x -. ' '
code =. y -. ' '
if. 0 = # code do. '' return. end.
if. 0 = +/ map =. term E. code do. '' return. end.
termIndex =. {. term I.@E. code
pageOLs =. ,/ (rxcomp '_\d+_') rxmatches code
if. 0 = # pageOLs do. '' return. end.
pageOffsets =. {."1 pageOLs
pageIndex =. {. /: | pageOffsets - termIndex
ol =. , pageIndex { pageOLs
pageNumber =. ". }. }: ({: ol) {. ({. ol) }. code
if. termIndex < {. ol do. pageNumber =. <: pageNumber end.
'#L' , ": pageNumber
}}

drawTocEntryLiveSearch =: 3 : 0
NB. y xx yy width height
NB. Display the results of the current search against the local database.
try.
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
		noResults =. 'No Results'
		startX =. <. (xx + -: width) - -: {. glqextent noResults
		(startX , startY) drawStringAt noResults
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
	snippets =. translateToJ &. > 1 {"1 results
	links =. 2 {"1 results
	sources =. 4 {"1 results
	colWidth =. <. -: width - colSep
	snippetOrigins =. (xx + 5) ,. pageLabelHeight + TocLineHeight * i. # results
	titleOrigins =. (xx + colSep + colWidth) ,. pageLabelHeight + TocLineHeight * i. # results

	if. 0 < # searchBox do. highlightString =. searchBox else. highlightString =. > {. < ;. _2 searchBoxWords , ' ' end.

	sieve =. sources = <'W'
	glclip xx , yy , colWidth , height
	(<"1 (sieve # snippetOrigins) ,"(1 1) colWidth , TocLineHeight) drawCodeWithHighlights"0 1 (< highlightString) ,. (sieve # snippets) ,. < WikiColor
	glclip (xx + 5 + colWidth) , yy , colWidth , height
	(<"1 sieve # titleOrigins) drawStringAt &. > sieve # titles

	sieve =. sources = <'F'
	glclip xx , yy , colWidth , height
	(<"1 (sieve # snippetOrigins) ,"(1 1) colWidth , TocLineHeight) drawCodeWithHighlights"0 1 (< highlightString) ,. (sieve # snippets) ,. < ForumColor
	glclip (xx + 5 + colWidth) , yy , colWidth , height
	(<"1 sieve # titleOrigins) drawStringAt &. > sieve # titles

	sieve =. sources = <'G'
	glclip xx , yy , colWidth , height
	(<"1 (sieve # snippetOrigins) ,"(1 1) colWidth , TocLineHeight) drawCodeWithHighlights"0 1 (< highlightString) ,. (sieve # snippets) ,. < GitHubColor
	glclip (xx + 5 + colWidth) , yy , colWidth , height
	(<"1 sieve # titleOrigins) drawStringAt &. > sieve # titles

	sieve =. sources = <'R'
	glclip xx , yy , colWidth , height
	(<"1 (sieve # snippetOrigins) ,"(1 1) colWidth , TocLineHeight) drawCodeWithHighlights"0 1 (< highlightString) ,. (sieve # snippets) ,. < RosettaColor
	glclip (xx + 5 + colWidth) , yy , colWidth , height
	(<"1 sieve # titleOrigins) drawStringAt &. > sieve # titles

	glclip 0 0 10000 100000
	(snippetRects =. <"1 snippetOrigins ,"1 1 colWidth , TocLineHeight) registerRectLink &. > <"1 links ,. titles ,. (# snippets) # < 1
	(titleRects =. <"1 titleOrigins ,"1 1 colWidth , TocLineHeight) registerRectLink &. > <"1 links ,. titles ,. (# titles) # < 1
	return.
	textColors =. WikiColor , ForumColor  , RosettaColor ,: GitHubColor
	if. _1 < titleIndex =. {. _1 ,~ I. > VocMouseXY&pointInRect &. > titleRects do.
		title =. > titleIndex { titles
		colorIndex =. ('W' ; 'F' ; 'R' ; 'G') i. titleIndex { sources
		textColor =. colorIndex { textColors
		floatRect =. (2 {. > titleIndex { titleRects) , (colWidth >. {. glqextent title) , TocLineHeight
		floatRect registerFloatingString title ; LiveSearchFont ; textColor
	end.
	if. _1 < snippetIndex =. {. _1 ,~ I. > VocMouseXY&pointInRect &. > snippetRects do.
		snippet =. > snippetIndex { snippets
		colorIndex =. ('W' ; 'F' ; 'R' ; 'G') i. snippetIndex { sources
		textColor =. colorIndex { textColors
		floatRect =. (2 {. > snippetIndex { snippetRects) , (colWidth >. {. glqextent snippet) , TocLineHeight
		floatRect registerFloatingString snippet ; LiveSearchFont ; textColor
	end.
catch.
	1 log 'Problem in drawTocEntryLiveSearch: ' , (13!:12) ''
	1 log '...db error (if any): ' , dbError ''
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
	dbOpenDb ''
	gitHubContent =. , > {. > {: sqlreadm__db 'select content from github'
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
NB. Matched tokens should be rendered with an underscore
NB. Remove any embedded line numbers, e.g., _987_
NB. Insofar as possible, center the matched term.
if. y -: a: do. '' return. end.
'xx yy width height' =. > x
'term code color' =. y
if. 0 = # code -. ' ' do. '' return. end.
code =. ('_\d+_' ; '') rxrplc code
term =. term -. ' '
codeWithSpaces =. (code ~: ' ') < ;.1 code
highlightIndices =. , (i. # term) +"1 0 I. term E. code -. ' '
highlightFlags =. (1) highlightIndices } (# codeWithSpaces) # 0
lengths =. > {.@glqextent &. > codeWithSpaces
rawOffsets =. }: 0 , +/\ lengths
NB. maxLeftSlide =. 0 >. (+/ lengths) - width
if. 0 < # highlightIndices do. leftSlide =. (({. highlightIndices) { rawOffsets) - -: width else. leftSlide =. 0 end.
offsets =. <. (xx - leftSlide) + rawOffsets
glrgb color
gltextcolor ''
((0 { offsets) , yy) drawStringAt ; codeWithSpaces
highlightOffsets =. highlightFlags # offsets
highlightLengths =. highlightFlags # lengths
highlightRects =. highlightOffsets ,"0 1 (yy + height - <. TocLineHeight * 0.3) ,"0 1 highlightLengths ,. 4
glrgb 0 0 0
glbrush ''
glpen ''
glrect"1 highlightRects
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

NB. ------------------------- Forums ------------------------------
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
glfont SectionFont
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
colWidth =. <. -: width - +: margin
dateHeight =. 2 * TocLineHeight
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
timeLineSeparation =. TocLineHeight
timeLineHeight =. <. TocLineHeight * 0.8
yearWidth =. 5 + {. glqextent '"23'
monthWidth =. 5 + {. glqextent 'MMM'
yearOrigins =. (xx + margin + yearWidth * i. # years) ,. yy + margin
monthOrigins =. (# ForumMonthStrings) {. <"1 (xx + margin + monthWidth * i.12) ,. yy + margin + timeLineSeparation
yearStrings =: '`',. _2 {."1 ": ,.years
glrgb SectionColor
gltextcolor ''
yearOrigins drawStringAt"1 1 > ": &. > <"0 yearStrings
monthOrigins drawStringAt &. > ForumMonthStrings
rects1 =. (<"1 yearRects =. (yearOrigins -"(1 1) _2 2) ,"(1 1) yearWidth , timeLineHeight) 
yearCommands =: '*setTocEntryForumYear '&, &. > ": &. > <"0 years
rects1 registerRectLink &. > <"1 yearCommands ,"0 1 ' ' ; 1
rects2 =. (<"1 monthRects =. (_2 + > monthOrigins) ,"(1 1) 40 , timeLineHeight) 
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
if. compressedColWidth <: 5 do. return. end.
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
NB. if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
margin =. 5
glrgb 0 32 0
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
wd 'set tocList select ' , ": y
entry =. y { 1 getTocOutlineRailEntries MaxTocDepth  NB. level ; parentid ; categoryid ; category ; parentseq ; count ; link
queueUrl (> 6 { entry) ; > 3 { entry NB. url ; title
animate 1
)

setTocRailHoverIndex =: 3 : 0
NB. y The index of the currently-hovered entry in the TOC rail.
TocOutlineRailHoverIndex =: y
)

drawTocRailChildren =: 4 : 0
NB. x Toc outline rail entry whose children need to be drawn.
NB. x: level ; parent ; categoryid ; category ; parentseq ; count ; link
NB. y The rectangle in which to draw.
log 'drawTocRailChildren'
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
NB. levels =. (] - <./) > 0 {"1 entries
NB. maxCount =. >./ > 4 {"1 entries
NB. indentStrings =. (#&'  ' &. > <: &. > 0 {"1 entries) , &. > 3 {"1 entries
NB. linkCommands =. '*setTocOutlineRailSelectedIndex '&, &. > ": &. > <"0 i. # entries
NB. parms =. indentStrings ; linkCommands ; (> 5 {"1 entries) ; levels ; TocOutlineRailSelectedIndex ; TocOutlineRailScrollIndex ; 1 ; 'setTocRailHoverIndex'
NB. TocOutlineRailScrollIndex =: x drawScrollerField parms
if. 200 > 2 { DisplayDetailRect do. return. end.
(TocOutlineRailSelectedIndex { entries) drawTocRailChildren DisplayDetailRect
)

drawToc =: 3 : 0
log 'drawToc'
DisplayListRect drawTocRail MaxTocDepth
)

NB. ======================= Table of Contents (TOC) Data Management =====================
TocOutlineRailEntriesCache =: ,: a: , a:
WikiDocsCache =: ,: a: , a:

TocWikiDocsCategory =: ''
TocWikiDocsEntries =: ''

visitedRailEntries =: '' NB. Boxed IDs.

initializeTocList =: {{
NB. y A level of the Toc hierarchy to which to display
entries =. 1 getTocOutlineRailEntries y NB. Table of level ; parentId ; categoryid ; category ; parentseq ; count ; link
indentStrings =. (#&'  ' &. > 0 {"1 entries) , &. > 3 {"1 entries NB. Indents for level
tocCounts =. _3&{. &. > '___'&, &. > ":`(''"_) @. (=&0) &. > 0&>. &. > 5 {"1 entries
tocListItems =. ,&'"' &. > '"'&, &. > tocCounts , &. > indentStrings
wd 'set tocList items ' , ; tocListItems
}}

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
NB. Return level ; parentid ; categoryId ; category ; parentseq ; count ; link
NB. Take account of the parentseq number when ordering the entries.
NB. Terminate cycles.
log 'getTocOutlineRailEntries ' , (": x) , ', ' , ": y
dbOpenDb ''
key =. < (": x) , 'D' , (": ShowBookmarksFlag) , 'D' , ": y
if. (# TocOutlineRailEntriesCache) > index =. (0 {"1 TocOutlineRailEntriesCache) i. key do.
	combinedResult =. > index { 1 {"1 TocOutlineRailEntriesCache
else.
	visitedRailEntries =: ''
	result =. > x recurseGetTocOutlineRailEntries y
	bookmarkResult =. ''
	if. ShowBookmarksFlag *. x = 1 do.
		bookmarks =. > {: sqlreadm__db 'select title, link from wiki where categoryid = ' , ": getTopCategoryId BookmarkCatString
		titles =. > {: &. > < ;. _2 &. > ,&'/' &. > 0 {"1 bookmarks
		if. 0 < # bookmarks do. bookmarkResult =. (< 0) ,. (< 1) ,. (< 10000 + i. # bookmarks) ,. titles ,. (<"0 - i. # bookmarks) ,. (< 0) ,. 1 {"1 bookmarks end.
	end.
	if. 0 < # bookmarkResult do. 
		combinedResult =. bookmarkResult , result
	else.
		combinedResult =. result
	end.
	TocOutlineRailEntriesCache =: TocOutlineRailEntriesCache , key , < combinedResult
end.
log '...(getTocOutlineRailEntries) returning ' , (": # combinedResult) , ' results.'
combinedResult
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
dbOpenDb ''
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

getVoc =: {{
if. 0 = # VocTable do. loadVoc '' end.
VocTable
}}

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
(xStart , yStart , width , height) registerRectLink ('*selectVocGlyph ''' , glyph , '''') ; glyph ; 1
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
	entries =. (getVoc '') #~ > VocSelectedGlyph&-: &. > 3 {"1 (getVoc '')  NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
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
rows =. (getVoc '') #~ (, > {."1 (getVoc '')) e. y
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
entry =. (getVoc '') {~ (3 {"1 (getVoc '')) i. < VocSelectedGlyph
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
NewDatabaseContents =: ''

dbPathExists =: 3 : 0
NB. Return 1 if the target or stage db exists.
fexist dbPath
)

isOnTheNetwork =: 3 : 0
NB. Return 1 if we can connect to the CDN.
0 < # getRemoteDatabaseHash ''
)

checkForNewerDatabase =: 3 : 0
NB. Return _3 if a databases are staged and ready to be brought online.
NB. Return 1 if a newer database is available.  
NB. Return 2 if a newer database is required.
NB. Return 3 if we're not on the network.
NB. Return 4 if there was a problem opening/reading the database.
NB. Return 0 if the local database is up to date.
if. -. isOnTheNetwork '' do. 3 return. end.
try. 
	dbOpenDb ''
	localHash =. getLocalDatabaseHash ''
	if. 0 = # localHash do. 
		1
		return. 
	end.
catcht.
	4
	return.
end.
remoteHash =. getRemoteDatabaseHash ''
-. localHash -: remoteHash
)

checkWhetherNewDatabaseHasArrived =: {{
if. NewDatabaseContents -: '' do.
	0
else.
	DatabaseDownloadStatus =: _3  NB. The data is here; we're ready to bring it online.
	1
end.
}}

downloadLatestData =: {{
try.
	LogLoadBrowserFlag =: 1
	1 log 'Downloading latest data...'
	1 log '...which may take quite a while...'
	compressedDbContents =. gethttp dbUrl
	1 log '...got it.  Decompressing ' , (": # compressedDbContents) , ' bytes...'
	NewDatabaseContents =: lz4_uncompressframe compressedDbContents
	1 log '...decompressed to ' , (": # NewDatabaseContents) , ' bytes.'
	1 log '*** Ready to move new data online ***'
catch.
	1 log 'Problem in downloadLatestData: ', (13!:12) ''
end.
downloadPyx =: a:
}}

getRemoteDatabaseHash =: 3 : 0
if. IFWGET_wgethttp_ do.
	header =. '--server-response --spider ' gethttp dbUrl_jwikiviz_
else.
	header =. '-sI ' gethttp dbUrl_jwikiviz_
end.
> 4 { < ;. _2 header , LF
)
 
getLocalDatabaseHash =: {{
if. isDatabaseOpen '' do.
	, > > {: sqlreadm__db 'select value from admin where key = "Hash"' 
else.
	''
end.
}}

transferDatabase =: 3 : 0
NB. Read the user records from the database.
NB. Write the new database.
NB. Insert the user records.
1 log 'transferDatabase'
try.
	if. dbPathExists'' do. dbOpenDb '' end.
	writeUserData =. 0
	if. isDatabaseOpen '' do.
		cats =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link from categories where categoryid > 1000000'
		historyMenu =. > {: sqlreadm__db 'select label, link from history'
		wiki =. > {: sqlreadm__db 'select title, categoryid, link from wiki where categoryid >= 1000000'
		try. keyValues =. > {: sqlreadm__db 'select key, value from keyvalue' catch. catcht. keyValues =. '' end.
		writeUserData =. 1
	end.
	dbCloseDb ''
	NewDatabaseContents (1!:2) < dbPath
	NewDatabaseContents =: ''
	dbOpenDb ''
	if. writeUserData do.
		catCols =. ;: 'level parentid categoryid category parentseq count link'
		wikiCols =. ;: 'title categoryid link'
		keyValueCols =. ;: 'key value'
		sqlinsert__db 'categories' ; catCols ; cat_parms =. < (> 0 {"1 cats) ; (> 1 {"1 cats) ; (> 2 {"1 cats) ; (3 {"1 cats) ; (> 4 {"1 cats) ; (> 5 {"1 cats) ; < (6 {"1 cats)
		sqlinsert__db 'wiki' ; wikiCols ; < (0 {"1 wiki) ; (> 1 {"1 wiki) ; < (2 {"1 wiki)
		sqlinsert__db 'history' ; ('label' ; 'link') ; < (0 {"1 historyMenu) ; < (1 {"1 historyMenu)
		if. 0 < # keyValues do.
			db_parms =. 'keyvalue' ; keyValueCols ; < (0 {"1 keyValues) ; < (1 {"1 keyValues)
			sqlinsert__db db_parms
		end.
	end.
	sqlinsert__db 'admin' ; (;: 'key value') ; < 'Hash' ; getRemoteDatabaseHash''
catch.
	1 log 'Problem in transferDatabase: ' , (13!:12) ''
	1 log 'DB error (if any): ' , dbError ''
end.
)

isDatabaseOpen =: {{
-. db -: ''
}}

asyncCheckForNewerDatabase =: {{
NB. Set DatabaseDownloadStatus
NB. Note that this routine is meant to be called as a task.
1 log 'asyncCheckForNewerDatabase'
NB. if. checkWhetherStageDatabasesHaveArrived '' do. return. end.
status =. checkForNewerDatabase ''
if. status = 4 do.
	1 log 'asyncCheckForNewDatabase: Could not open/read the db.' 
	end.  NB. Couldn't open/read the database.
DatabaseDownloadStatus =: status
1 log 'asyncCheckForNewerDatabase: DatabaseDownloadStatus = ' , ": DatabaseDownloadStatus
NB. animate 5
}}

bringNewDataOnline =: {{
1 log 'bringNewDataOnline'
if. -. checkWhetherNewDatabaseHasArrived '' do.
	1 log 'Cannot bring the new data online; not all data has arrived.'
	return.
end.
try.
	transferDatabase ''
	initializeWithDatabase ''
	DatabaseDownloadStatus =: 0
	setUpdateButtons ''
catch. catcht.
	1 log 'Problem in bringNewDataOnline ' 
	1 log (13!:12) ''
	return.
end.
1 log '*** Moved the new data online ***'
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

TimerFractionMsec =: 50 NB. Milliseconds per frame

initializeWithDatabase =: {{
2 log 'initializeWithDatabase'
try.
	logVersionInfo ''
	clearCache ''
NB.	initAdmin ''
	buildLiveSearchWikiTitlesByCategory ''
	loadHistoryMenu ''
	fs =. '4' getKeyValue 'FontSlider'
	try. wd 'set fontSlider ' , fs catch. end.
	setFontSize ". fs
	dbPyx =: asyncCheckForNewerDatabase t. 'worker' ''
	datetime =. , > > {: sqlreadm__db 'select value from admin where key = "CrawlStart"'
	version =. manifest_version (1!:1) < jpath addonPath
	caption =. 'J Viewer ' , version , ' (Crawl Datetime: ' , datetime , ')'
	wd 'pn *' , caption
	initializeTocList MaxTocDepth
catch.
	1 log 'initializeWithDatabase Problem: ' , (13!:12) ''
	1 log 'initializeWithDatabase Database error (if any): ' , dbError ''
end.
}}

go =: 3 : 0
try.
	clearLog ''
	logVersionInfo ''
	if. -. checkGethttpVersion '' do. return. end.
	if. 0 < count =. 0 >. 5 - 1 T. '' do. 0&T."(0) count # 0 end.
	appPyx =: asyncCheckAppUpToDate t. 'worker' ''
	if. dbPathExists '' do. 
		dbOpenDb ''
	else.
		1 log '*** Database download required. ***'
		DatabaseDownloadStatus =: 2 
	end.
	setShortcutFlag ''
	buildForm ''
	layoutForm ''
	setUpdateButtons ''
	'w h' =. 2 3 { ". wd 'qscreen'
NB.	wd 'pshow fullscreen'
	wd 'pshow'
	wd 'msgs'
	setLiveSearchSourceFlagButtons ''
	wd 'pmove 10 60 ' , ": (w - 20) , h - 80
	if. isDatabaseOpen '' do. initializeWithDatabase '' end.
NB.	initializeTocList MaxTocDepth
	animate 10
	wd 'timer ' , ": TimerFractionMsec
catch. catcht.
	1 log 'go: Problem: ' , (13!:12) ''
	1 log 'go: Database error (if any): ' , sqlerror__db ''
end.
)

go_z_ =: 3 : 0
go_jwikiviz_ ''
)

cocurrent 'base'

LogFlag =: 1

go ''
