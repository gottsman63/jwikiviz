NB. The wiki pages for jwikiviz.db have to be crawled so we can get the topic structure.
NB. The posts for jwikiviz.db need not be crawled.
NB. The posts for master.db need to be crawled, and may be crawled incrementally.
NB. The posts for jwikiviz.db could be taken from the post rows in master.db.

clear ''

load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'arc/lz4'
load 'convert/pjson'

db =: ''
Months =: ;:'January February March April May June July August September October November December'

wikiUrlPrefix =: 'https://code.jsoftware.com'

appDir =: jpath '~temp/loaddb'
stageDbPath =: appDir , '/jviewer.db'
wikiDir =: appDir , '/code.jsoftware.com/wiki'
codeSearchFile =: appDir , '/codesearch.html'
forumDir =: appDir , '/forums'
forumStderrDir =: forumDir , '/stderr'
forumHtmlDir =: forumDir , '/html'
masterDbFile =: appDir , '/master.db'
quoraDbPath =: appDir , '/quora.db'
youTubeDbPath =: appDir , '/youtube.db'
forumsDbPath =: appDir , '/forums.db'
tokenFile =: appDir , '/token.txt'
compressedDbPath =: appDir , '/jviewer.lz4'
logPath =: appDir , '/log.txt'

jEnglishEquivalents =: _2 ]\ '(' ; 'leftpar' ; ')' ; 'rightpar' ; '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':' ; 'co' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'F:.' ; 'fcapcodot' ; 'F::' ; 'fcapcoco' ; 'F:' ; 'fcapco' ; 'F..' ; 'fcapdotdot' ; 'F.:' ; 'fcapdotco' ; 'F.' ; 'fcapdot' ; 'H.' ; 'hcapdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco' ; 'j.' ; 'jdot' ; 'L.' ; 'lcapdot' ; 'L:' ; 'lcapco' ; 'm.' ; 'mdot' ; 'M.' ; 'mcapdot' ; 'NB.' ; 'ncapbcapdot' ; 'o.' ; 'odot' ; 'p.' ; 'pdot' ; 'p:' ; 'pco' ; 'q:' ; 'qco' ; 'r.' ; 'rdot' ; 's:' ; 'sco' ; 't.' ; 'tdot' ; 'T.' ; 'tcapdot' ; 'u:' ; 'uco' ; 'x:' ; 'xco' ; 'Z:' ; 'zcapco' ; 'assert.' ; 'assertdot' ; 'break.' ; 'breakdot' ; 'continue.' ; 'continuedot' ; 'else.' ; 'elsedot' ; 'elseif.' ; ' elseifdot' ; 'for.' ; 'fordot' ; 'if.' ; 'ifdot' ; 'return.' ; 'returndot' ; 'select.' ; 'selectdot' ; 'case.' ; 'casedot' ; 'fcase.' ; 'fcasedot' ; 'try.' ; 'trydot' ; 'catch.' ; 'catchdot' ; 'catchd.' ; 'catchddot' ; 'catcht.' ; 'catchtdot' ; 'while.' ; 'whiledot' ; 'whilst.' ; 'whilstdot'         
jEnglishDict =: (0 {"1 jEnglishEquivalents) ,. 'J'&, &. > <@":"0 i. # jEnglishEquivalents
jMnemonics =: , &. > 0 {"1 jEnglishDict
jEnglishWords =: 1 {"1 jEnglishDict
htmlEncodings =: _2 ]\ '&gt;' ; '>' ; '&lt;' ; '<' ; '&quot;' ; '"' ; '&amp;' ; '&' ; '<tt>' ; ' ' ; '</tt>' ; ' ' ; '<pre>' ; ' ' ; '&nbsp;' ; ' '
NB. searchJMnemonics =: jMnemonics&i.

translateToJEnglish =: 3 : 0
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
try.
	translatedHtml =. ('''' ; ' ') rxrplc translateHtmlEncodings , y
	rawTokens =. , ;: translatedHtml
	hits =. (jMnemonics , rawTokens) i. rawTokens
	result =. ; (<' ') ,. hits { jEnglishWords , rawTokens
	if. 0 = # result do. 'No Code' else. result end.
catch. catcht.
	echo 'JEnglish Failure ' , (13!:12) ''
	'JEnglish Failure'
end.
)

translateToJEnglishOld =: 3 : 0
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
NB. try. raw =. ('''' ; '''''') rxrplc y catch. ' ' return. end.
try.
NB.	singleLine =. (LF ; ' ') rxrplc y
NB.	if. 1 = 2 | +/ '''' = y do. quoted =. singleLine , '''' else. quoted =. singleLine end.
	translatedHtml =. ('''' ; ' ') rxrplc translateHtmlEncodings , y
	rawTokens =. , ;: translatedHtml
	hits =. searchJMnemonics"0 1 rawTokens
	result =. ; (hits {"0 1 jEnglishWords ,"1 0 rawTokens) ,. < ' '
	if. 0 = # result do. 'No Code' else. result end.
catch. catcht.
	echo 'JEnglish Failure ' , (13!:12) ''
	'JEnglish Failure'
end.
)

translateHtmlEncodings =: 3 : 0
NB. y HTML string
NB. Convert HTML encodings such as &amp; to their ascii characters.
r =. y
try.
	for_enc. htmlEncodings do.
		r =. enc rxrplc r
	end.
catch.
	'rx error for ' , r
end.
)

convertToWikiUrl =: 3 : 0
NB. Title of the form /wiki/...
'https://code.jsoftware.com/mediawiki/index.php?title=' , (urlencode 6 }. y) , '&action=edit'
)

getHtml =: 3 : 0
NB. y Boxed urls
NB. Return a list of boxed html, one for each url
echo 'getHtml...'
echo ,. y
blockSize =. 100 <. # y
urlBlocks =. (- blockSize) <\ y
result =. ''
for_i. i. # urlBlocks do.
	urlBatch =. > i { urlBlocks
	urlSpec =. ; ('"'&, &. > ,&'"' &. > urlBatch) ,. <' '
	files =. (jpath '~temp/html/')&, &. > ,&'.html' &. > <@":"0 i. blockSize <. # urlBatch
	outputSpec =. ; (<' -o ') ,. files
	command =. 'curl --parallel ' , outputSpec , ' ' , urlSpec
	try.
		(2!:0) command
	catch.
		echo (13!:12) ''
		echo urlSpec
	end.
	result =. result , <@(1!:1)"0 files
end.
result
)

extractTextFromWikiArticle =: 3 : 0
NB. y HTML
start =. '<textarea'
end =. '</textarea'
result =. 'extractTextFromWikiArticle Failure! '
try.
 	result =. translateHtmlEncodings p {.~ I. end E. p =. ((# start) + I. start E. y) }. y
catch.
result =. 'extractTextFromWikiArticle failure!'
end.
NB. echo 'extractTextFromWikiArticle Failure! ' , 200 {. result
result
)

NB. ===================== Magic 8 Ball ===========================
loadMagic8Docs =: 3 : 0
NB. y Number of docs to return
NB. Return a table id ; contents
result =. > {: sqlreadm__db 'select jindex.rowid, body, source from jindex, auxiliary where auxiliary.rownum = jindex.rowid limit ' , ": y
sources =. , > 2 {"1 result
docs =. (sources ~: 'G') # 0 1 {"1 result
bodies =. tolower &. > -.&'.,:"' &. > 1 {"1 docs
Docs =:  (0 {"1 docs) ,. bodies
echo '# Docs' ; (# Docs) ; '# result' ; (# result)
)

buildMagic8Ball =: 3 : 0
loadMagic8Docs 500000
rawDocs =. < ;._2 &. > -.&(LF , CR , '();,._0123456789') &. > tolower &. > ,&' ' &. > 1 {"1 Docs
wordsWithRepeats =. ; rawDocs
uniqueWords =. ~. wordsWithRepeats
echo '$ uniqueWords' ; $ uniqueWords
counts =. # /.~ wordsWithRepeats
countSieve =. (counts > 1) *. counts < 200
wordLengths =. > $ &. > uniqueWords
lengthSieve =. (wordLengths < 20) *. wordLengths > 2
sieve =. , countSieve *. lengthSieve
sievedWords =. sieve # uniqueWords
echo '$ sievedWords' ; $ sievedWords
sievedCounts =. sieve # counts
try.
  sqlcmd__db 'delete from similar'
  data =. sievedCounts ; < sievedWords
  sqlinsert__db 'similar' ; (;: 'count word') ; < data
catch. catcht.
  echo 'Problem in buildCounts: ' , (13!:12) ''
  echo 'DB Error (if any): ' , dbError ''
end.
NB. out =.; (": &. > 0 {"1 table) ,. (< TAB) ,. (1 {"1 table) ,. < LF
NB. out (1!:2) < jpath '~temp/counts.txt'
)
NB. =================== End Magic 8 Ball =========================

NB. ========================== Crawling Rosettacode ====================================
updateMasterDbWithRosettaCodeChallenge =: {{
NB. x The url of a challenge.
NB. y The name of a challenge.
NB. Get the challenge, extract the J portion, translate.
NB. Return url ; filename ; 'RosettaCode' ; 'R' ; 9999 ; 0 ; 0 ; title ; author ; content
url =. x
title =. '[Rosetta] ' , y
try.
	echo 'RosettaCode: ' , title
	wd 'msgs'
	html =. gethttp url , '?action=edit'
	problemPlus =. html {.~ {. I. '=={{header|' E. html
	problem =. problemPlus }.~ {. I. '<textarea' E. problemPlus
	jSolution =. > jList #~ (< '=={{header|J}}==') = 16&{. &. > jList =. ('=={{header|' E. html) <  ;. 1 html
	if. jSolution -: '' do. 
		echo 'No J code found for ' , title
		a:
		return.
	end.
	content =. y , ' ' , (translateHtmlEncodings problem) , ' ' , translateToJEnglish translateHtmlEncodings jSolution
	filename =. ' '
	(url , '#J') ; filename ; 'RosettaCode' ; 'R' ; 9999 ; 0 ; 0 ; title ; ' ' ; content
catch. catchd.
	echo (13!:12) ''
	a:
	return.
end.
}}

updateMasterDbWithRosettaCode =: {{
echo 'updateMasterDbWithRosettaCode'
createOrOpenMasterDb ''
sqlcmd__masterDb 'delete from content where sourcetype = "R"'
pat =. rxcomp '<li>[^<]*<a href="([^"]+)" title="([^"]+)"'
nextPagePat =. '<a href="(/wiki/Category:Programming_Tasks\?pagefrom[^"]+)"[^>]+>next page</a>'
html =. gethttp 'https://rosettacode.org/wiki/Category:Programming_Tasks'
while. 0 < # html do.
	try.
		c =. 1 2 {"2 pat rxmatches html
		urlTitles =. ({:"1 c) <@{."0 1 ({."1 c) }."0 1 html
		titles =. 1 {"1 urlTitles
		echo titles
		wd 'msgs'
		fullUrls =. 'https://rosettacode.org'&, &. > 0 {"1 urlTitles
		table =: _10 ]\ , > (<a:) -.~ fullUrls updateMasterDbWithRosettaCodeChallenge &. > titles
		data =: (0 {"1 table) ; (1 {"1 table) ; (2 {"1 table) ; (3 {"1 table) ; (> 4 {"1 table) ; (> 5 {"1 table) ; (> 6 {"1 table) ; (7 {"1 table) ; (8 {"1 table) ; (9 {"1 table) ; < ((# table) # 1)
		try.
		 	sqlinsert__masterDb 'content' ; masterCols ; < data
		catch. catcht. catchd.
			echo 'Problem ' , (13!:12) ''
			echo sqlerror__masterDb ''
		end.
		if. 0 < {. c =. {: nextPagePat rxmatch html do.
			nextUrl =. 'https://rosettacode.org' , ({: c) {. ({. c) }. html
			html =. gethttp nextUrl
		else.
			html =. ''
		end.
	catch.
		echo 'Problem ' , (13!:12) ''
		echo sqlerror__masterDb ''
		echo 400 {. html
		break.
	end.
end.
''
}}
NB. ======================= End Crawling Rosettacode ===================================

NB. ========================== Crawling Quora ==========================================
updateMasterDbWithQuora =: 3 : 0
echo 'updateMasterDbWithQuora'
createOrOpenMasterDb ''
quoraDb =. sqlopen_psqlite_ quoraDbPath
sqlcmd__masterDb 'delete from content where sourcetype = "Q"'
table =. > {: sqlreadm__quoraDb 'select link, title, body from posts'
links =. 0 {"1 table
titles =. '[Quora] '&, &. > 1 {"1 table
bodies =. 2 {"1 table
augmentedBodies =. translateToJEnglish@translateHtmlEncodings &. > titles , &. > ' '&, &. > bodies
data =. links ; links ; ((# links) # <'Quora') ; ((# links) # < 'Q') ; ((# links) # 9999) ; ((# links) # 0) ; ((# links) # 0) ; titles ; ((# links) # < 'Skip Cave') ; augmentedBodies ; < ((# links) # 1)
sqlinsert__masterDb 'content' ; masterCols ; < data
)
NB. ======================== End Crawling Quora ========================================

NB. ========================= Crawling YouTube =========================================
updateMasterDbWithYouTube =: 3 : 0
echo 'updateMasterDbWithYouTube'
try.
createOrOpenMasterDb ''
youTubeDb =. sqlopen_psqlite_ youTubeDbPath
sqlcmd__masterDb 'delete from content where sourcetype = "V"'
table =. > {: sqlreadm__youTubeDb 'select link, title, description, transcript from videos'
links =. 0 {"1 table
titles =. '[YouTube] '&, &. > 1 {"1 table
descriptions =. 2 {"1 table
transcripts =. 3 {"1 table
bodies =. titles , &. > ' '&, &. > descriptions , &. > ' '&, &. > transcripts
data =. links ; links ; ((# links) # <'YouTube') ; ((# links) # < 'V') ; ((# links) # 9999) ; ((# links) # 0) ; ((# links) # 0) ; titles ; ((# links) # <' ') ; bodies ; ((# bodies) # 1)
sqlinsert__masterDb 'content' ; masterCols ; < data
catch. catcht.
	echo (13!:12) ''
end.
)
NB. ======================= End Crawling YouTube =======================================

NB. ============================ Crawling GitHub ======================================
indexSuffixes =:  '.ijs' ; '.ijt'
sep =: 0 { a.
gitHubContent =: ''

log =: 3 : 0
LF (1!:3) < logPath
y (1!:3) < logPath
)

updateMasterDbWithGitHub =: 3 : 0
NB. Process GitHub J repositories.
owners =. ~. (getGitHubRepoOwners '') , (getGitHubRepoOwners '') , getGitHubRepoOwners ''
echo 'Found owner count: ' , ": # owners
updateMasterDbWithGitHubOwner &. > /:~ owners
)

getGitHubRepoOwners =: 3 : 0
NB. Return a list of repository owners.
echo 'getGitHubRepoOwners'
try.
  url =. 'https://github.com/search?q=language%3AJ&type=Repositories&ref=advsearch&l=J&sort:updated&p='
  page =. 0
  owners =. ''
  while. 1 do.
    json =. gethttp url , ": page =. >: page
echo 'page' ; page
echo json
    rec =. > {. {:"1 dec_pjson_ json
    keys =. {."1 rec
    vals =. {:"1 rec
    pageCount =. > (keys i. < 'page_count') { vals
    echo 'pageCount' ; pageCount
    tokens =. {."1 > (keys i. < 'csrf_tokens') { vals
    projects =. ~. ; &. > (<'/')&,. &. > 1 2&{ &. > < ;. _2 &. >  ,&'/' &. > tokens 
    newOwners =. > {. &. > < ;. _1 &. > projects
    owners =. ~.owners , newOwners
    echo $ owners
NB.    updateMasterDbWithGitHubDocs &. > projects
    if. page > pageCount do. break. end.
    (6!:3) 10
  end.
catch.
  echo (12!:13) ''
end.
echo 'end getGitHubRepoOwners'
~. owners
)

updateMasterDbWithGitHubDocs =: 3 : 0
NB. y Project name from GitHub
NB. Get the project, get contents of the relevant files, translate, insert into master.db.
project =. y
echo project
try.
	token =. LF -.~ (1!:1) < tokenFile
	cmd =. 'curl -H "Authorization: token ' , token , '" -L https://github.com' , project , '/zipball/master/'
	echo 'cmd' ; cmd
	zip =. (2!:0) cmd
	echo '$ zip' ; $ zip
	zipFilename =. appDir , '/github/' , (project -. '/') , '.zip'
	try. (2!:0) 'mkdir ' , appDir , '/github/' catch. end.
	exdir =. appDir , '/github/' , project -. '/'
	zip (1!:2) < zipFilename
	try. (2!:0) 'rm -r ' , exdir catch. end.
	(2!:0) 'unzip -o -d ' , exdir , ' ' , zipFilename
	commands =. ('find ' , exdir , ' -type f -name "*')&, &. > ,&'"' &. > indexSuffixes
	filenames =. a: -.~ , > < ;. _2 @(2!:0) &. > commands
	rawContents =. <@(1!:1)"0 filenames
	contents =. translateToJEnglish &. > rawContents
	echo '# filenames' ; # filenames
	for_i. i. # filenames do.
		lines =. < ;. 2 (> i { contents) , LF
		lineNumbers =. ,&'_ ' &. > '_'&, &. > <@":"0 >: i. # lines
		fullPath =. , > i { filenames
		partialPath_1 =. ((# project -. '/') + (project -. '/') I.@E. fullPath) }. fullPath
		partialPath =. (('^/[^/]+/') ; '') rxrplc partialPath_1
		url =. 'https://github.com' , project , '/blob/master/' , partialPath
		subject =. '[GitHub] ' , project , ': ' , partialPath
		content =. (kk =.translateToJEnglish partialPath) , ' ' , subject , ' ' , ; lineNumbers ,. lines
		echo '[' , partialPath , '] [' , kk , ']'
NB. masterCols: link id sourcename sourcetype year monthindex day subject author body
		priority =. 2
		if. +./ 'jsoftware' E. url do. priority =. 3 end.
		if. +./ 'test' E. url do. priority =. 1 end.
		data =. url ; url ; project ; 'G' ; 9999 ; 0 ; 0 ; subject ; ' ' ; content ; <priority
		try.
			sqlupsert__masterDb 'content' ; 'link' ; masterCols ; < data
		catch. catcht.
			echo 'Problem upserting: ' , sqlerror__masterDb
			echo (13!:12) ''
		end.
	end.
catch. catcht.
	echo (13!:12) ''
	echo sqlerror__masterDb ''
end.
try. (2!:0) 'rm -r ' , exdir catch. end.
try. (2!:0) 'rm ' , zipFilename catch. end.
(6!:3) 10
)

updateMasterDbWithGitHubOwner =: 3 : 0
NB. y The name of a repo owner.
NB. Process all of the projects for that owner.
echo 'updateMasterDbWithGitHubOwner ' , y
createOrOpenMasterDb ''
token =. LF -.~ (1!:1) < tokenFile
header =. '-L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ' , token , '" -H "X-GitHub-Api-Version: 2022-11-28"' 
page =. 0
owner =. y -. '/'
while. 1 do.
NB. https://api.github.com/search/repositories?q=user:jsoftware+language:J&per_page=100&page=1
  json =. header gethttp 'https://api.github.com/search/repositories?q=user:' , owner , '+language:J&per_page=100&page=' , ": page =. page + 1
NB.  json =. header gethttp 'https://api.github.com/users/' , owner , '/repos?per_page=100&page=' , ": page =. page + 1
  result =. ('"full_name": "(' , owner , '/[^"]+)"') rxmatches json
  if. 0 = # result do. break. end.
  ols =. 1 {"2 result
  updateMasterDbWithGitHubDocs &. > '/'&, &. > ({:"1 ols) <@{."0 1 ({."1 ols) }."0 1 json
end.
NB. updateMasterDbWithGitHubDocs &. > repositories
)

NB. updateMasterDbWithGitHubProjects =: 3 : 0
NB. NB. Update master.db with the jsoftware projects from GitHub.
NB. echo 'updateMasterDbWithGitHubProjects'
NB. gitHubContent =: ''
NB. createOrOpenMasterDb ''
NB. sqlcmd__masterDb 'delete from content where sourcetype = "G"'
NB. page =. 1
NB. whilst. 0 < # ol do.
NB. 	url =. 'https://github.com/orgs/jsoftware/repositories?page=' , (": page) , '&type=all'
NB. 	html =. gethttp url
NB. 	ol =. }. {:"2 (rxcomp 'd-inline-block">\s+([^<]+)<') rxmatches html
NB. 	projects =. -.&LF &. > (<"0 {:"1 ol) {. &. > ({."1 ol) <@}."0 1 html
NB. 	updateMasterDbWithGitHubDocs &. > projects NB. -. 'jsource' ; 'winget-pkgs'
NB. 	page =. >: page
NB. 	echo 'page' ; page
NB. end.
NB. )
NB. ========================== End Crawling GitHub ====================================

NB. =================================== Master DB =============================================
masterCols =: ;: 'link id sourcename sourcetype year monthindex day subject author body priority'

createOrOpenMasterDb =: 3 : 0
if. fexist < masterDbFile do.
	masterDb =: sqlopen_psqlite_ masterDbFile
else.
	masterDb =: sqlcreate_psqlite_ masterDbFile
	NB. The id can be used with other columns to reconstruct the link, which may not be sent down to the client (since it's fairly long).
	sqlcmd__masterDb 'CREATE TABLE content (link TEXT PRIMARY KEY, id TEXT, sourcename TEXT, sourcetype TEXT, year INTEGER, monthindex INTEGER, day INTEGER, subject TEXT, author TEXT, body TEXT, priority INTEGER)'
end.
)

moveForumRecordsFromMasterToStage =: 3 : 0
echo 'moveForumRecordsFromMasterToStage...'
createOrOpenMasterDb ''
dbOpenDb ''
sqlcmd__db 'delete from forums'
f =. > {: sqlreadm__masterDb 'select link, sourcename, year, monthIndex, day, subject, author from content where sourcetype = "F"'
cols =. ;: 'forumname year month day subject author link'
NB. data =. ('J'&, &. > 1 {"1 f) ; (> 2 {"1 f) ; (> 3 {"1 f) ; (> 4 {"1 f) ; (5 {"1 f) ; (6 {"1 f) ; < 0 {"1 f
data =. (1 {"1 f) ; (> 2 {"1 f) ; (> 3 {"1 f) ; (> 4 {"1 f) ; (5 {"1 f) ; (6 {"1 f) ; < (0 {"1 f)
sqlinsert__db 'forums' ; cols ; <data
echo '...moveForumRecordsFromMasterToStage: ' , ": # f
)

NB. ======================== Crawling Forums ==========================
updateMasterDbWithForumPosts =: 3 : 0
echo 'updateMasterDbWithForumPosts'
wd 'msgs'
try.
createOrOpenMasterDb ''
sqlcmd__masterDb 'delete from content where sourcetype = "F"'
forumsDb =: sqlopen_psqlite_ forumsDbPath
ftable =. > {: sqlreadm__forumsDb 'select link, id, sourcename, year, monthindex, day, subject, author, body from forum' 
echo '$ ftable' ; $ ftable
links =. 0 {" 1 ftable
ids =. 1 {"1 ftable
sourceNames =. 2 {"1 ftable
echo '10 {. sourceNames' ; 10 {. sourceNames
years =. > 3 {"1 ftable
k =: years
echo '10 {. years' ; 10 {. years
monthIndexes =. > 4 {"1 ftable
days =. > 5 {"1 ftable
subjects =. 6 {"1 ftable
authors =. 7 {"1 ftable
bodies =. 8 {"1 ftable
data =. links ; ids ; sourceNames ; ((# links) # < 'F') ; years ; monthIndexes ; days ; subjects ; authors ; bodies ; < ((# links) # 1)
sqlinsert__masterDb 'content' ; masterCols ; < data
echo 'end updateMasterDbWithForumPosts'
wd 'msgs'
catch. catcht.
  echo (13!:12) ''
  echo sqlerror__masterDb ''
end.
)

updateMasterDbWithPostsForDate =: 4 : 0
NB. x Forum name (programming, chat, etc.)
NB. y year, monthIndex
NB. Get posts from forum x for the date y and upsert them.
NB. No longer used.
return.
'year monthIndex' =. y
echo 'Processing' ; x ; year ; > monthIndex { Months
wd 'msgs'
tocHtml =. gethttp 'https://www.jsoftware.com/pipermail/' , x , '/' , (": year) , '-' , (> monthIndex { Months) , '/subject.html'
ol =. {:"2 (rxcomp '<LI><A HREF="([^"]+)">') rxmatches tocHtml
offsets =. {."1 ol
lengths =. {:"1 ol
htmlIds =. lengths <@{."0 1 offsets }."0 1 tocHtml
links =. ('https://www.jsoftware.com/pipermail/', x , '/' , (": year) , '-' , (> monthIndex { Months) , '/')&, &. > htmlIds
if. 0 = # links do. 0 return. end.
postsHtml =. getHtml links
dayPat =. rxcomp '<I>\w\w\w\s\w\w\w\s+(\d+)\s\d\d'
titlePat =. rxcomp '<TITLE>([^<]+)</TITLE>'
authorPat =. rxcomp '<B>([^<]+)</B>'
for_postHtml. postsHtml do.
	html =. > postHtml
	'dayOffset dayLength' =. {: dayPat rxmatch html
	day =. ". dayLength {. dayOffset }. html
	'titleOffset titleLength' =. {: titlePat rxmatch html
	title =. '[' , (": year) , ']' , ('^\s*';'') rxrplc }: }: }: }: titleLength {. titleOffset }. html
	jtitle =. translateToJEnglish title
	'authorOffset authorLength' =. {: authorPat rxmatch html
	author =. authorLength {. authorOffset }. html
	id =. 6 {. > postHtml_index { htmlIds
	link =. postHtml_index { links
	try.
		body =. _11 }. 6 }. b {.~ I. '<!--endarticle-->' E. b =. ((# f) + I. (f =. '<!--beginarticle-->') E. html) }. html
	catch.
		body =. 'Failed to find article fenceposts.'
	end.
	if. 0 = # body do. body =. ' ' end.
	body =. translateToJEnglish translateHtmlEncodings title , ' ' , author , ' ' , body
	data =. link ; id ; x ; 'F' ; year ; monthIndex ; day ; (translateHtmlEncodings title) ; author ; body
	try.
		sqlupsert__masterDb 'content' ; 'link' ; masterCols ; < data
	catcht. catch.
		echo 'Failed to insert:'
		echo ,. data
	end.
end.
# links
)

updateMasterDbWithPosts =: 3 : 0
NB. Determine the most recent year-month for which we have posts.  
NB. Grab all of those posts as well as all posts since and upsert them into masterDb.
NB. No longer used.
return.
echo 'updateMasterDbWithPosts'
createOrOpenMasterDb ''
dbOpenDb ''
'currentYear currentMonthIndex' =. 0 _1 + 2 {. (6!:0) ''
if. 0 = , > > {: sqlreadm__masterDb 'select count(*) from content where sourcetype = "F"' do.
	startYear =. 1998
	startMonth =. 0
else.
	startYear =. {. , > > {: sqlreadm__masterDb 'select max(year) from content where sourcetype = "F"'
	startMonth =. {. , > > {: sqlreadm__masterDb 'select max(monthIndex) from content where sourcetype = "F" and year = ' , ": startYear
end.
echo '$ startYear ' ; $ startYear
years =.  startMonth }. 12 # startYear + i. 1 + currentYear - startYear
months =. startMonth }. (12 * 1 + currentYear - startYear) $ i.12
dates =. years ,. months
forums =. ;: 'general chat programming database source beta'
(((# forums) * # dates) $ forums) updateMasterDbWithPostsForDate &. > <"(1) (# forums) # dates
)
NB. ==================== End Crawling Forums ======================

updateMasterDbWithAllWikiPages =: 3 : 0
echo 'updateMasterDbWithAllWikiPages'
dbOpenDb ''
createOrOpenMasterDb ''
rawRows =. > {: sqlreadm__db 'select title, link from wiki'
rawTitles =. 0 {"1 rawRows
rawLinks =. 1 {"1 rawRows
prefixes =. (k =: > 'https:'&-: &. > 6&{. &. > rawLinks) { h =. wikiUrlPrefix ; ''
rawUrls =. prefixes , &. > rawLinks
uniqueRows =. (~: rawUrls) # rawTitles ,. rawUrls
echo 'Processing row count' ; # uniqueRows
wd 'msgs'
for_rowBatch. _100 < \ uniqueRows do.
	rows =. > rowBatch
	echo 'processing row count' ; # rows
	wd 'msgs'
	links =. 1 {"1 rows
	urls =. convertToWikiUrl &. > ids =. (# wikiUrlPrefix)&}. &. > links
	titles =. '[Wiki] '&, &. > {."1 rows
	rawHtmls =. getHtml urls
	extractedHtmls =. extractTextFromWikiArticle &. > rawHtmls
	htmls =. translateToJEnglish &. > extractedHtmls
	data =. links ; ids ; ((<'wiki') #~ # urls) ; ((<'W') #~ # urls) ; (9999 #~ # urls) ; (11 #~ # urls) ; (0 #~ # urls) ; titles ; ((<' ') #~ # urls) ; htmls ; < ((# links) # 1)
	try.
		sqlupsert__masterDb 'content' ; 'link' ; masterCols ; <data
	catch. catcht.
		echo (13!:12) ''
		echo sqlerror__masterDb '' 
	end.
end.
)

updateMasterDbWithChangedWikiPages =: 3 : 0
NB. Use the Mediawiki "changed" page to grab the last three days' changes...
NB. ...unless there are no wiki pages, in which case load the whole wiki.
echo 'updateMasterDbWithChangedWikiPages...'
dbOpenDb ''
createOrOpenMasterDb ''
if. 0 = # > > {: sqlreadm__masterDb 'select count(*) from content where sourcetype = "W"' do.
	updateMasterDbWithAllWikiPages ''
	return.
end.
changedLinkHtml =. gethttp 'https://code.jsoftware.com/wiki/Special:RecentChanges?hidebots=1&namespace=0&limit=50&days=10&enhanced=1&urlversion=2'
ol =. {:"2 (rxcomp '<a href="([^"]+)" class="mw-changeslist-title"') rxmatches changedLinkHtml
wikiLinks =. ~. ({:"1 ol) <@{."0 1 ({."1 ol) }."0 1 changedLinkHtml
ol =. {:"2 (rxcomp 'class="mw-changeslist-title" title="([^"]+)">') rxmatches changedLinkHtml
titles =. ~. ({:"1 ol) <@{."0 1 ({."1 ol) }."0 1 changedLinkHtml
titles =. '[Wiki] '&, &. > titles
echo 'Found ', (": # titles) , ' changed wiki pages.'
if. 0 = # titles do. return. end.
links =. (wikiUrlPrefix , '/')&, &. > wikiLinks
urls =. convertToWikiUrl &. > ids =. (# wikiUrlPrefix)&}. &. > links
htmls =: translateToJEnglish &. > extractTextFromWikiArticle &. > getHtml urls
data =. links ; ids ; ((<'wiki') #~ # urls) ; ((<'W') #~ # urls) ; (9999 #~ # urls) ; (11 #~ # urls) ; (0 #~ # urls) ; titles ; ((<' ') #~ # urls) ; htmls ; < ((# urls) # 1)
try.
	sqlupsert__masterDb 'content' ; 'link' ; masterCols ; <data
catch. catcht.
	echo 'updateMasterDbWithChangedWikiPages'
	echo (13!:12) ''
	echo sqlerror__masterDb '' 
end.
)
NB. ================================= End Master DB ===========================================

NB. ===================== Full-Text Search ================================
NB. generateFullTextContentFile =: 3 : 0
NB. NB. Create a string of (id sourceType year subject author body) separated by 2 3 4 { a.
NB. createOrOpenMasterDb ''
NB. table =. > {: sqlreadm__masterDb 'select link, sourcetype, year, subject, author, body from content'
NB. formattedTable =. (0 1 {"1 table) ,. (": &. > 2 {"1 table) ,. 3 4 5 {"1 table
NB. s =. lz4_compressframe ; ,&(2 3 4 { a.) &. > , formattedTable 
NB. s (1!:2) < indexFile
NB. )

moveFullTextIndexIntoStage =: {{
echo 'moveFullTextIndexIntoStage'
createOrOpenMasterDb ''
dbOpenDb ''
table =. > {: sqlreadm__masterDb 'select link, sourcetype, year, subject, author, body, priority from content'
titles =. 3 {"1 table
years =: > 2 {"1 table
sources =. -.&' ' &. > 1 {"1 table
bodies =. 5 {"1 table
urls =. 0 {"1 table
priorities =. > 6 {"1 table
data =. titles ; years ; sources ; urls ; < priorities
sqlinsert__db 'auxiliary' ; (;: 'title year source url priority') ; < data
sqlinsert__db 'jindex' ; (;: 'body') ;  << bodies

}}
NB. ================== End Full-Text Search ================================

generateDatabaseReport =: 3 : 0
NB. Write a report on the newly-created database to the wiki.
dbOpenDb ''
forumCount =. , > > {: sqlreadm__db 'select count(*) from forums'
categoryCount =. , > > {: sqlreadm__db 'select count(*) from categories'
wikiCount =. , > > {: sqlreadm__db 'select count(*) from wiki'
vocCount =. , > > {: sqlreadm__db 'select count(*) from vocabulary'
logCount =. , > > {: sqlreadm__db 'select count(*) from log'
historyCount =. , > > {: sqlreadm__db 'select count(*) from history'
adminCount =. , > > {: sqlreadm__db 'select count(*) from admin'
out =. getCurlDate ''
out =. out , LF , ('Forums: ' , ": forumCount)
out =. out , LF , ('Categories: ' , ": categoryCount)
out =. out , LF , ('Wiki: ' , ": wikiCount)
out =. out , LF , ('Vocabulary: ' , ": vocCount)
out =. out , LF , ('Log: ' , ": logCount)
out =. out , LF , ('History: ' , ": historyCount)
out =. out , LF , ('Admin: ' , ": adminCount)
)

updateWikiBuildLog =: 3 : 0
message =. generateDatabaseReport ''
NB. $ curl -X PUT https://en.wikipedia.org/w/rest.php/v1/page/Wikipedia:Sandbox -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" --data '{"source": "Hello, world!", "comment": "Testing out the REST API", "latest": { "id": 555555555 }}'
('-H "Content-Type: application/json" --data {"source": "Hello, world!", "comment": "Testing"}') gethttp 'https://code.jsoftware.com/rest.php/page/JWikiViz%20Crawl%20Log'
)

loadVoc =: 3 : 0
NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
table =: > <;._2 &. > ,&TAB &. > < ;._2 LF ,~ vocab
col0 =. ". &. > {."1 table
table =: }: col0 ,. (}:"1 }."1 table) ,. -.&CR &. > {:"1 table  NB. Stray CRs in the links column.
glyphColumn =. 3 {"1 table
VocTable =: (0 1 2 {"1 table) ,. glyphColumn ,. 4 5 6 7 {"1 table
cols =. ;: 'groupnum pos row glyph monadicrank label dyadicrank link'
data =. (< > 0 {"1 table) , (< 1 {"1 table) , (< > ". &. > 2 {"1 table) , (< 3 {"1 table) , (< 4 {"1 table) , (< 5 {"1 table) , (< 6 {"1 table) , (< 7 {"1 table)
sqlinsert__db 'vocabulary';cols;<data
)

vocab =: 0 : 0
0	Noun	0	x y		Arguments of verbs left/right		https://code.jsoftware.com/wiki/Vocabulary/Verbs#Executing_an_Explicit_Definition:_Private_Namespaces
0	Verb	0	u v		Verb operands of modifiers left/right		https://code.jsoftware.com/wiki/Vocabulary/Modifiers
0	Noun	0	m n		Noun operands of modifiers left/right		https://code.jsoftware.com/wiki/Vocabulary/Modifiers
1	Verb	1	=	_	Self-Classify		https://code.jsoftware.com/wiki/Vocabulary/eq#monadic
1	Verb	1	=		Equal	0 0	https://code.jsoftware.com/wiki/Vocabulary/eq#dyadic
1	Copula	1	=.		Is (Local)		https://code.jsoftware.com/wiki/Vocabulary/eqdot
1	Copula	1	=:		Is (Global)		https://code.jsoftware.com/wiki/Vocabulary/eqco
1	Verb	2	<	_	Box		https://code.jsoftware.com/wiki/Vocabulary/lt
1	Verb	2	<		Lesser	0 0	https://code.jsoftware.com/wiki/Vocabulary/lt#dyadic
1	Verb	2	<.	0	Floor		https://code.jsoftware.com/wiki/Vocabulary/ltdot
1	Verb	2	<.		Lesser of / Min	0 0	https://code.jsoftware.com/wiki/Vocabulary/ltdot#dyadic
1	Verb	2	<:	0	Decrement		https://code.jsoftware.com/wiki/Vocabulary/ltco
1	Verb	2	<:		Lesser or Equal	0 0	https://code.jsoftware.com/wiki/Vocabulary/ltco#dyadic
1	Verb	3	>	0	Open		https://code.jsoftware.com/wiki/Vocabulary/gt
1	Verb	3	>		Greater	0 0	https://code.jsoftware.com/wiki/Vocabulary/gt#dyadic
1	Verb	3	>.	0	Ceiling		https://code.jsoftware.com/wiki/Vocabulary/gtdot
1	Verb	3	>.		Greater of / Max	0 0	https://code.jsoftware.com/wiki/Vocabulary/gtdot#dyadic
1	Verb	3	>:	0	Increment		https://code.jsoftware.com/wiki/Vocabulary/gtco
1	Verb	3	>:		Greater or Equal	0 0	https://code.jsoftware.com/wiki/Vocabulary/gtco#dyadic
1	Noun	4	_ __		Negative Sign / Infinities		https://code.jsoftware.com/wiki/Vocabulary/under
1	Noun	4	_.		Indeterminate		https://code.jsoftware.com/wiki/Vocabulary/underdot
1	Noun	4	_: __:	_	Infinities	_ _	https://code.jsoftware.com/wiki/Vocabulary/underco
2	Verb	5	+	0	Conjugate		https://code.jsoftware.com/wiki/Vocabulary/plus
2	Verb	5	+		Plus	0 0	https://code.jsoftware.com/wiki/Vocabulary/plus#dyadic
2	Verb	5	+.	0	Real / Imag		https://code.jsoftware.com/wiki/Vocabulary/plusdot
2	Verb	5	+.		GCD (Or)	0 0	https://code.jsoftware.com/wiki/Vocabulary/plusdot#dyadic
2	Verb	5	+:	0	Double		https://code.jsoftware.com/wiki/Vocabulary/plusco
2	Verb	5	+:		Not-Or	0 0	https://code.jsoftware.com/wiki/Vocabulary/plusco#dyadic
2	Verb	6	*	0	Signum		https://code.jsoftware.com/wiki/Vocabulary/star
2	Verb	6	*		Times	0 0	https://code.jsoftware.com/wiki/Vocabulary/star#dyadic
2	Verb	6	*.		Length / Angle		https://code.jsoftware.com/wiki/Vocabulary/stardot
2	Verb	6	*.		LCM (And)	0 0	https://code.jsoftware.com/wiki/Vocabulary/stardot#dyadic
2	Verb	6	*:	0	Square		https://code.jsoftware.com/wiki/Vocabulary/starco
2	Verb	6	*:		Not-And	0 0	https://code.jsoftware.com/wiki/Vocabulary/starco#dyadic
2	Verb	7	-	0	Negate		https://code.jsoftware.com/wiki/Vocabulary/minus
2	Verb	7	-		Minus	0 0	https://code.jsoftware.com/wiki/Vocabulary/minus#dyadic
2	Verb	7	-.	0	Not		https://code.jsoftware.com/wiki/Vocabulary/minusdot
2	Verb	7	-.		Less	_ _	https://code.jsoftware.com/wiki/Vocabulary/minusdot#dyadic
2	Verb	7	-:	0	Halve		https://code.jsoftware.com/wiki/Vocabulary/minusco
2	Verb	7	-:		Match	_ _	https://code.jsoftware.com/wiki/Vocabulary/minusco#dyadic
2	Verb	8	%	0	Reciprocal		https://code.jsoftware.com/wiki/Vocabulary/percent
2	Verb	8	%		Divide	0 0	https://code.jsoftware.com/wiki/Vocabulary/percent#dyadic
2	Verb	8	%.	2	Matrix Inverse		https://code.jsoftware.com/wiki/Vocabulary/percentdot
2	Verb	8	%.		Matrix Divide	_ 2	https://code.jsoftware.com/wiki/Vocabulary/percentdot#dyadic
2	Verb	8	%:	0	Square Root		https://code.jsoftware.com/wiki/Vocabulary/percentco
2	Verb	8	%:		Root	0 0	https://code.jsoftware.com/wiki/Vocabulary/percentco#dyadic
3	Verb	9	^ ^!.p	0	Exponential		https://code.jsoftware.com/wiki/Vocabulary/hat
3	Verb	9	^ ^!.p		Power	0 0	https://code.jsoftware.com/wiki/Vocabulary/hat#dyadic
3	Verb	9	^ ^!.p		Stope Function	0 0	https://code.jsoftware.com/wiki/Vocabulary/hat#stope
3	Verb	9	^.	0	Natural Log		https://code.jsoftware.com/wiki/Vocabulary/hatdot
3	Verb	9	^.		Logarithm	0 0	https://code.jsoftware.com/wiki/Vocabulary/hatdot#dyadic
3	Conjunction	9	^:	_	Power of Verb	_ _	https://code.jsoftware.com/wiki/Vocabulary/hatco
3	Conjunction	9	^:		If		https://code.jsoftware.com/wiki/Vocabulary/hatco#IfDyad
3	Conjunction	9	^:		Inverse		https://code.jsoftware.com/wiki/Vocabulary/hatco#Inverse
3	Conjunction	9	^:		DoWhile		https://code.jsoftware.com/wiki/Vocabulary/hatco#DoWhile
3	Verb	10	$	_	Shape Of		https://code.jsoftware.com/wiki/Vocabulary/dollar
3	Verb	10	$		Shape	1 _	https://code.jsoftware.com/wiki/Vocabulary/dollar#dyadic
3	Verb	10	$.	_	Sparse	_ _	https://code.jsoftware.com/wiki/Vocabulary/dollardot
3	Verb	10	$:	_	Self-Reference	_ _	https://code.jsoftware.com/wiki/Vocabulary/dollarco
3	Adverb	11	u~ m~	_	Reflex		https://code.jsoftware.com/wiki/Vocabulary/tilde
3	Adverb	11	u~ m~		Passive	lu ru	https://code.jsoftware.com/wiki/Vocabulary/tilde#dyadic
3	Adverb	11	u~ m~	0	Evoke	0 0	https://code.jsoftware.com/wiki/Vocabulary/tildem
3	Verb	11	~.	_	Nub		https://code.jsoftware.com/wiki/Vocabulary/tildedot
3	Verb	11	~:	_	Nub Sieve		https://code.jsoftware.com/wiki/Vocabulary/tildeco
3	Verb	11	~:		Not-Equal	0 0	https://code.jsoftware.com/wiki/Vocabulary/tildeco#dyadic
3	Verb	12	|	0	Magnitude		https://code.jsoftware.com/wiki/Vocabulary/bar
3	Verb	12	|		Residue	0 0	https://code.jsoftware.com/wiki/Vocabulary/bar#dyadic
3	Verb	12	|. |.!.f	_	Reverse		https://code.jsoftware.com/wiki/Vocabulary/bardot
3	Verb	12	|. |.!.f		Rotate	_ _	https://code.jsoftware.com/wiki/Vocabulary/bardot#dyadic
3	Verb	12	|. |.!.f	_	Shift Right 1		https://code.jsoftware.com/wiki/Vocabulary/bardot#monadicfit
3	Verb	12	|. |.!.f		Shift	_ _	https://code.jsoftware.com/wiki/Vocabulary/bardot#dyadicfit
3	Verb	12	|:	_	Transpose		https://code.jsoftware.com/wiki/Vocabulary/barco
3	Verb	12	|:		Reverse Axes	1 _	https://code.jsoftware.com/wiki/Vocabulary/barco#dyadic
4	Conjunction	13	.	2	Determinant		https://code.jsoftware.com/wiki/Vocabulary/dot
4	Conjunction	14	:	 	Definition		https://code.jsoftware.com/wiki/Vocabulary/cor
4	Conjunction	14	:		Explicit Def.		https://code.jsoftware.com/wiki/Vocabulary/com
4	Conjunction	14	:		Verb Anatomy		https://code.jsoftware.com/wiki/Vocabulary/coa
4	Conjunction	14	:		Monad / Dyad		https://code.jsoftware.com/wiki/Vocabulary/cou
4	Conjunction	14	:.	mu	Assign Obverse	lu ru	https://code.jsoftware.com/wiki/Vocabulary/codot
4	Conjunction	14	::	_	Assign Adverse	_ _	https://code.jsoftware.com/wiki/Vocabulary/coco
4	Verb	15	,	_	Ravel		https://code.jsoftware.com/wiki/Vocabulary/comma
4	Verb	15	,		Append	_ _	https://code.jsoftware.com/wiki/Vocabulary/comma#dyadic
4	Verb	15	,.	_	Ravel Items		https://code.jsoftware.com/wiki/Vocabulary/commadot
4	Verb	15	,.		Stitch	_ _	https://code.jsoftware.com/wiki/Vocabulary/commadot#dyadic
4	Verb	15	,:	_	Itemize		https://code.jsoftware.com/wiki/Vocabulary/commaco
4	Verb	15	,:		Laminate	_ _	https://code.jsoftware.com/wiki/Vocabulary/commaco#dyadic
4	Verb	16	;	_	Raze		https://code.jsoftware.com/wiki/Vocabulary/semi
4	Verb	16	;		Link	_ _	https://code.jsoftware.com/wiki/Vocabulary/semi#dyadic
4	Conjunction	16	;. ;.0 ;.+1 +2 ;.+3		Cut		https://code.jsoftware.com/wiki/Vocabulary/semidot
4	Conjunction	16	;. ;.0 ;.+1 +2 ;.+3	_	Reversed		https://code.jsoftware.com/wiki/Vocabulary/semidot0
4	Conjunction	16	;. ;.0 ;.+1 +2 ;.+3		Subarray	2 _	https://code.jsoftware.com/wiki/Vocabulary/semidot0#dyadic
4	Conjunction	16	;. ;.0 ;.+1 +2 ;.+3	_	SelfIntervals		https://code.jsoftware.com/wiki/Vocabulary/semidot1
4	Conjunction	16	;. ;.0 ;.+1 +2 ;.+3		Intervals	1 _	https://code.jsoftware.com/wiki/Vocabulary/semidot1#dyadic
4	Conjunction	16	;. ;.0 ;.+1 +2 ;.+3	_	MaxCubes		https://code.jsoftware.com/wiki/Vocabulary/semidot3
4	Conjunction	16	;. ;.0 ;.+1 +2 ;.+3		Subarrays	2 _	https://code.jsoftware.com/wiki/Vocabulary/semidot3#dyadic
4	Verb	16	;:	1	Words		https://code.jsoftware.com/wiki/Vocabulary/semico
4	Verb	16	;:		Seq Machine	_ _	https://code.jsoftware.com/wiki/Vocabulary/semico#dyadic
5	Verb	17	#	_	Tally		https://code.jsoftware.com/wiki/Vocabulary/number
5	Verb	17	#		Copy	1 _	https://code.jsoftware.com/wiki/Vocabulary/number#dyadic
5	Verb	17	#.	1	Base Two		https://code.jsoftware.com/wiki/Vocabulary/numberdot
5	Verb	17	#.		Base	1 1	https://code.jsoftware.com/wiki/Vocabulary/numberdot#dyadic
5	Verb	17	#:	_	Antibase Two		https://code.jsoftware.com/wiki/Vocabulary/numberco
5	Verb	17	#:		Antibase	1 0	https://code.jsoftware.com/wiki/Vocabulary/numberco#dyadic
5	Verb	18	!	0	Factorial		https://code.jsoftware.com/wiki/Vocabulary/bang
5	Verb	18	!		Out Of	0 0	https://code.jsoftware.com/wiki/Vocabulary/bang#dyadic
5	Conjunction	18	!.	mu	Fit (Customize)	lu ru	https://code.jsoftware.com/wiki/Vocabulary/bangdot
5	Conjunction	18	!:	0	Foreign (System Functions)	0 0	https://code.jsoftware.com/wiki/Vocabulary/bangco
5	Adverb	19	/	_	Insert		https://code.jsoftware.com/wiki/Vocabulary/slash
5	Adverb	19	/		Table	_ _	https://code.jsoftware.com/wiki/Vocabulary/slash#dyadic
5	Adverb	19	/. /..	_	Oblique		https://code.jsoftware.com/wiki/Vocabulary/slashdot
5	Adverb	19	/. /..		Key	_ _	https://code.jsoftware.com/wiki/Vocabulary/slashdot#dyadic
5	Adverb	19	/. /..		Key Dyad	_ _	https://code.jsoftware.com/wiki/Vocabulary/slashdot#dyadic
5	Verb	19	/:	_	Grade Up		https://code.jsoftware.com/wiki/Vocabulary/slashco
5	Verb	19	/:		Sort Up (Using)	_ _	https://code.jsoftware.com/wiki/Vocabulary/slashco#dyadic
5	Adverb	20	\	_	Prefix		https://code.jsoftware.com/wiki/Vocabulary/bslash
5	Adverb	20	\		Infix	_ _	https://code.jsoftware.com/wiki/Vocabulary/bslash#dyadic
5	Adverb	20	\.	_	Suffix		https://code.jsoftware.com/wiki/Vocabulary/bslashdot
5	Adverb	20	\.		Outfix	_ _	https://code.jsoftware.com/wiki/Vocabulary/bslashdot#dyadic
5	Verb	20	\:	_	Grade Down		https://code.jsoftware.com/wiki/Vocabulary/slashco
5	Verb	20	\:		Sort Down (Using)	_ _	https://code.jsoftware.com/wiki/Vocabulary/slashco#dyadic
6	Verb	21	[	_	Same		https://code.jsoftware.com/wiki/Vocabulary/squarelf
6	Verb	21	[		Left	_ _	https://code.jsoftware.com/wiki/Vocabulary/squarelf#dyadic
6	Conjunction	21	[.		Lev		https://code.jsoftware.com/wiki/Vocabulary/squarelfdot
6	Verb	21	[:		Cap		https://code.jsoftware.com/wiki/Vocabulary/squarelfco
6	Verb	22	]	_	Same		https://code.jsoftware.com/wiki/Vocabulary/squarert
6	Verb	22	]		Right	_ _	https://code.jsoftware.com/wiki/Vocabulary/squarert#dyadic
6	Conjunction	22	].		Dex		https://code.jsoftware.com/wiki/Vocabulary/squarertdot
6	Adverb	22	]:		Ident		https://code.jsoftware.com/wiki/Vocabulary/squarertco
6	Verb	23	{	1	Catalog		https://code.jsoftware.com/wiki/Vocabulary/curlylf
6	Verb	23	{		From	0 {	https://code.jsoftware.com/wiki/Vocabulary/curlylf#dyadic
6	Verb	23	{.	_	Head		https://code.jsoftware.com/wiki/Vocabulary/curlylfdot
6	Verb	23	{.		Take	1 _	https://code.jsoftware.com/wiki/Vocabulary/curlylfdot#dyadic
6	Verb	23	{:	_	Tail		https://code.jsoftware.com/wiki/Vocabulary/curlylfco
6	Verb	23	{::	_	Map		https://code.jsoftware.com/wiki/Vocabulary/curlylfcoco
6	Verb	23	{::		Fetch	1 _	https://code.jsoftware.com/wiki/Vocabulary/curlylfcoco#dyadic
6	Verb	24	}	_	Composite Item		https://code.jsoftware.com/wiki/Vocabulary/curlyrt
6	Verb	24	}		Amend	_ _	https://code.jsoftware.com/wiki/Vocabulary/curlyrt#dyadic
6	Verb	24	}.	_	Behead		https://code.jsoftware.com/wiki/Vocabulary/curlyrtdot
6	Verb	24	}.		Drop	1 _	https://code.jsoftware.com/wiki/Vocabulary/curlyrtdot#dyadic
6	Verb	24	}:	_	Curtail		https://code.jsoftware.com/wiki/Vocabulary/curlyrtco
6	Control	24	{{ }}		DirectDefinition		https://code.jsoftware.com/wiki/Vocabulary/DirectDefinition
7	Conjunction	25	"		Rank		https://code.jsoftware.com/wiki/Vocabulary/quote
7	Conjunction	25	"	u"n	Assign		https://code.jsoftware.com/wiki/Vocabulary/quote
7	Conjunction	25	"	m"n	Constant		https://code.jsoftware.com/wiki/Vocabulary/quotem
7	Conjunction	25	"	u"v m"v	Copy		https://code.jsoftware.com/wiki/Vocabulary/quotev
7	Verb	25	".	1	Do		https://code.jsoftware.com/wiki/Vocabulary/quotedot
7	Verb	25	".		Numbers	_ _	https://code.jsoftware.com/wiki/Vocabulary/quotedot#dyadic
7	Verb	25	":	_	Default Format		https://code.jsoftware.com/wiki/Vocabulary/quoteco
7	Verb	25	":		Format	1 _	https://code.jsoftware.com/wiki/Vocabulary/quoteco#dyadic
7	Conjunction	26	`		Tie		https://code.jsoftware.com/wiki/Vocabulary/grave
7	Conjunction	27	@	mv	Atop	lv rv	https://code.jsoftware.com/wiki/Vocabulary/at
7	Conjunction	27	@.	mv	Agenda	lv rv	https://code.jsoftware.com/wiki/Vocabulary/atdot
7	Conjunction	27	@:	_	At	_ _	https://code.jsoftware.com/wiki/Vocabulary/atco
7	Conjunction	28	&	_	Bond	0 _	https://code.jsoftware.com/wiki/Vocabulary/ampm
7	Conjunction	28	&	mv	Compose	mv mv	https://code.jsoftware.com/wiki/Vocabulary/ampv
7	Conjunction	28	&.	mv	Under (Dual)	mv mv	https://code.jsoftware.com/wiki/Vocabulary/ampdot
7	Conjunction	28	&:	_	Appose	_ _	https://code.jsoftware.com/wiki/Vocabulary/ampco
7	Verb	29	?	0	Roll		https://code.jsoftware.com/wiki/Vocabulary/query
7	Verb	29	?		Deal	0 0	https://code.jsoftware.com/wiki/Vocabulary/query#dyadic
7	Verb	29	?.	0	Roll (Fixed Seed)		https://code.jsoftware.com/wiki/Vocabulary/querydot
7	Verb	29	?.		Deal (Fixed Seed)	0 0	https://code.jsoftware.com/wiki/Vocabulary/querydot#dyadic
8	Noun	30	a.		Alphabet (all bytes)		https://code.jsoftware.com/wiki/Vocabulary/adot
8	Noun	30	a:		Ace (Boxed Empty)		https://code.jsoftware.com/wiki/Vocabulary/aco
8	Verb	30	A.	1	Anagram Index		https://code.jsoftware.com/wiki/Vocabulary/acapdot
8	Verb	30	A.		Anagram	0 _	https://code.jsoftware.com/wiki/Vocabulary/acapdot#dyadic
8	Adverb	31	m b. u b.	_	Boolean	0 0	https://code.jsoftware.com/wiki/Vocabulary/bdot
8	Adverb	31	m b. u b.	_	Bitwise	0 0	https://code.jsoftware.com/wiki/Vocabulary/bdot#bitwise
8	Adverb	31	m b. u b.	_	Bitwise Shift	0 0	https://code.jsoftware.com/wiki/Vocabulary/bdot#bitshift
8	Adverb	31	m b. u b.	_	"Verb Info (Obverse, Rank, Identity)"		https://code.jsoftware.com/wiki/Vocabulary/bdotu
8	Verb	31	C. C.!.2	1	Cycle-Direct		https://code.jsoftware.com/wiki/Vocabulary/ccapdot
8	Verb	31	C. C.!.2	1	Permutation Parity		https://code.jsoftware.com/wiki/Vocabulary/ccapdot#permparity
8	Verb	31	C. C.!.2		Permute	1 _	https://code.jsoftware.com/wiki/Vocabulary/ccapdot#dyadic
8	Conjunction	31	d.	0	Ordinary		https://code.jsoftware.com/wiki/Vocabulary/ddot
8	Conjunction	31	d.	0	Derivative		https://code.jsoftware.com/wiki/Vocabulary/ddot
8	Conjunction	32	u D. m D.	mu	Derivative		https://code.jsoftware.com/wiki/Vocabulary/dcapdot
8	Conjunction	32	u D. m D.	mu	Assign Derivative		https://code.jsoftware.com/wiki/Vocabulary/dcapdot#dcapdotm
8	Conjunction	32	D:		Secant Slope	mu mu	https://code.jsoftware.com/wiki/Vocabulary/dcapco
8	Verb	32	e.	_	Raze In		https://code.jsoftware.com/wiki/Vocabulary/edot
8	Verb	32	e.		Member (In)	_ _	https://code.jsoftware.com/wiki/Vocabulary/edot#dyadic
8	Verb	33	E.		Find Matches	_ _	https://code.jsoftware.com/wiki/Vocabulary/ecapdot
8	Adverb	33	f.		Fix		https://code.jsoftware.com/wiki/Vocabulary/fdot
8	Conjunction	33	F. F.. F: F: F:. F::	_	Fold	_ _	https://code.jsoftware.com/wiki/Vocabulary/fcap
9	Conjunction	34	H.	0	Hypergeometric	0 0	https://code.jsoftware.com/wiki/Vocabulary/hcapdot
9	Verb	34	i.	1	Integers		https://code.jsoftware.com/wiki/Vocabulary/idot
9	Verb	34	i.		Index Of	_ _	https://code.jsoftware.com/wiki/Vocabulary/idot#dyadic
9	Verb	34	i:	0	Steps		https://code.jsoftware.com/wiki/Vocabulary/ico
9	Verb	34	i:		Index of Last		https://code.jsoftware.com/wiki/Vocabulary/ico#dyadic
9	Verb	35	I.	1	Indices		https://code.jsoftware.com/wiki/Vocabulary/icapdot
9	Verb	35	I.		Interval Index	_ _	https://code.jsoftware.com/wiki/Vocabulary/icapdot#dyadic
9	Verb	35	j.	0	Imaginary		https://code.jsoftware.com/wiki/Vocabulary/jdot
9	Verb	35	j.		Complex	0 0	https://code.jsoftware.com/wiki/Vocabulary/jdot#dyadic
9	Verb	35	L.	_	Level Of		https://code.jsoftware.com/wiki/Vocabulary/lcapdot
9	Verb	36	L:	_	Level At	_ _	https://code.jsoftware.com/wiki/Vocabulary/lcapco
9	Verb	36	m.		Modular arithmetic		https://code.jsoftware.com/wiki/Vocabulary/mdot
9	Adverb	36	M.	mu	Memo	lu ru	https://code.jsoftware.com/wiki/Vocabulary/mcapdot
9	Control	37	NB.		Comment		https://code.jsoftware.com/wiki/Vocabulary/ncapbcapdot
9	Verb	37	o.	0	Pi Times		https://code.jsoftware.com/wiki/Vocabulary/odot
9	Verb	37	o.		Circle Function	0 0	https://code.jsoftware.com/wiki/Vocabulary/odot#dyadic
9	Verb	37	p.	1	Roots		https://code.jsoftware.com/wiki/Vocabulary/pdot
9	Verb	37	p.		Polynomials	1 0	https://code.jsoftware.com/wiki/Vocabulary/pdot#dyadic
9	Verb	38	p..	1	Polynomial Deriv		https://code.jsoftware.com/wiki/Vocabulary/pdotdot
9	Verb	38	p..		Polynomial Int	0 1	https://code.jsoftware.com/wiki/Vocabulary/pdotdot#dyadic
10	Verb	38	p:	0	Primes	_ _	https://code.jsoftware.com/wiki/Vocabulary/pco
10	Verb	38	q:	0	Prime Factors		https://code.jsoftware.com/wiki/Vocabulary/qco
10	Verb	38	q:		Prime Exponents	0 0	https://code.jsoftware.com/wiki/Vocabulary/qco#dyadic
10	Verb	39	r.	0	Angle		https://code.jsoftware.com/wiki/Vocabulary/rdot
10	Verb	39	r.		Polar	0 0	https://code.jsoftware.com/wiki/Vocabulary/rdot#dyadic
10	Verb	39	s:	_	Symbol	_ _	https://code.jsoftware.com/wiki/Vocabulary/sco
10	Conjunction	39	S:	_	Spread	_ _	https://code.jsoftware.com/wiki/Vocabulary/scapco
10	Conjunction	40	t.	_	Run as task	_ _	https://code.jsoftware.com/wiki/Vocabulary/tdot
10	Verb	40	T.	_	Set Debug Thread		https://code.jsoftware.com/wiki/Vocabulary/tcapdot
10	Verb	40	T.		Threads/tasks	_ _	https://code.jsoftware.com/wiki/Vocabulary/tcapdot#dyadic
10	Verb	40	u:	_	Unicode	_ _	https://code.jsoftware.com/wiki/Vocabulary/uco
10	Verb	41	x:	_	Extended Precision	_ _	https://code.jsoftware.com/wiki/Vocabulary/xco
10	Verb	41	Z:	_	Terminate Fold	_ _	https://code.jsoftware.com/wiki/Vocabulary/zcapco
10	Verb	41	_9: to 9:	_	Constant Functions	_ _	https://code.jsoftware.com/wiki/Vocabulary/zeroco
10	Conjunction	42	(u v)	_	Hook	_ _	https://code.jsoftware.com/wiki/Vocabulary/hook
10	Conjunction	42	(f g h)	_	Fork	_ _	https://code.jsoftware.com/wiki/Vocabulary/fork
10	Conjunction	42	(f g h)		Modifier Trains		https://code.jsoftware.com/wiki/Vocabulary/fork#invisiblemodifiers
10	Verb	42	u. v.	_	Enhanced Operand	_ _	https://code.jsoftware.com/wiki/Vocabulary/udot
11	Control	43	assert.		Assertion		https://code.jsoftware.com/wiki/Vocabulary/assertdot
11	Control	43	break.		Terminate Loop		https://code.jsoftware.com/wiki/Vocabulary/breakdot
11	Control	43	continue.		Terminate iteration		https://code.jsoftware.com/wiki/Vocabulary/continuedot
11	Control	44	else. elseif.		Execute alternative		https://code.jsoftware.com/wiki/Vocabulary/elsedot
11	Control	44	for. for_ijk.		Repeat for each item		https://code.jsoftware.com/wiki/Vocabulary/fordot
11	Control	44	goto_lbl.  label_lbl.		Go to label		https://code.jsoftware.com/wiki/Vocabulary/gotodot
11	Control	45	if.		Execute if		https://code.jsoftware.com/wiki/Vocabulary/ifdot
11	Control	45	return.		Exit with result		https://code.jsoftware.com/wiki/Vocabulary/returndot
11	Control	45	select. case. fcase.		Select among alternatives		https://code.jsoftware.com/wiki/Vocabulary/selectdot
11	Control	46	throw.		Throw to higher-level catcht.		https://code.jsoftware.com/wiki/Vocabulary/throwdot
11	Control	46	try. catch. catchd. catcht.		"Execute, catching errors"		https://code.jsoftware.com/wiki/Vocabulary/trydot
11	Control	46	while. whilst.		Loop while		https://code.jsoftware.com/wiki/Vocabulary/whiledot
)

urldecode =: 3 : 0
NB. y A string with % encodings.  Convert to plain text.
parts =. }. < ;. _2 '%20' , y , '%'
codes =. 2&{. &. > parts
}. ; (2&}. &. > parts) ,.~ ({&a.)@".@('16b'&,) &. > codes
)

setupTempDirectory =: 3 : 0
if. fexist appDir do. return. end.
(1!:5) < appDir
NB. (1!:5) < wikiDir
(1!:5) < forumDir
(1!:5) < forumStderrDir
(1!:5) < forumHtmlDir
)

dbError =: 3 : 0
sqlerror__db ''
)

loadAncillaryPages =: 3 : 0
try.
echo 'loadAncillaryPages'
html =. gethttp 'https://code.jsoftware.com/wiki/NuVoc'
html =. (I. 'printfooter' E. html) {. html =. (I. 'Ancillary_Pages' E. html) }. html
pat =. 'href="([^"]+)" title="([^"]+)"'
offsetLengths =. }."2 pat rxmatches html
linkOffsetLengths =. 0 {"2 offsetLengths
titleOffsetLengths =. 1 {"2 offsetLengths
links =. (<"0 {:"1 linkOffsetLengths) {. &. > ({."1 linkOffsetLengths) <@}."0 1 html
titles =. (<"0 {:"1 titleOffsetLengths) {. &. > ({."1 titleOffsetLengths) <@}."0 1 html
nuVocId =. 1 getCategoryId '*NuVoc'
data =. 2 ; nuVocId ; (nextCatId 1) ; 'Ancillary Pages' ; (# titles) ; _1 ; 'https://code.jsoftware.com/wiki/NuVoc'
echo data
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < data
ancillaryId =. nuVocId getCategoryId 'Ancillary Pages'
sqlinsert__db 'wiki' ; (;: 'categoryid title link') ; < (ancillaryId #~ # links) ; titles ; <links
catcht.
	echo (13!:12) ''
	echo dbError ''
end.
)

extractFields =: 4 : 0
NB. x Pattern string (assumes a single parenthesized subpattern match)
NB. y String
NB. Return boxed matches (all of them).
try.
  ols =. 1 {"2 (rxcomp x) rxmatches y
  relativeIndices =. <@i."(0) 1 {"1 ols
  indices =. (<"0 {."1 ols) + &. > relativeIndices
  indices { &. > < y
catch.
  a:
  return.
end.
)

extractField =: 4 : 0
NB. x Pattern string (assumes a parenthesized subpattern match)
NB. y String
NB. Return the first match of x in y
ol =. {: (rxcomp x) rxmatch y
({: ol) {. ({. ol) }. y
)

NB. ------------------- Forums ---------------------
copyForumRecordsToMaster =: 3 : 0
NB. New routine to use now that the old jsoftware Forum archive is unavailable.
NB. Move the Forum records from forunms.db to master.db.
echo 'copyForumRecordsToMaster'
createOrOpenMasterDb ''
sqlcmd__masterDb 'delete from content where sourcetype = "F"'
forumsDb =: sqlopen_psqlite_ forumsDbPath
table =. > {: sqlreadm__forumsDb 'select link, sourcename, year, monthindex, day, subject, body, author from forum'
links =. 0 {"1 table
sourceNames =. 1 {"1 table
years =. > 2 {"1 table
monthIndexes =. > 3 {"1 table
days =. > 4 {"1 table
subjects =. 5 {"1 table
bodies =. 6 {"1 table
authors =. 7 {"1 table
data =. links ; ((# links) # < ' ') ; sourceNames ; ((# links) # < 'F') ; years ; monthIndexes ; days ; subjects ; authors ; bodies ; ((# links) # 1)
echo ,. data
sqlinsert__masterDb 'content' ; masterCols ; < data
)

loadForum =: 3 : 0
NB. y Forum name (path component)
NB. Retrieve the forum archive files and add them to the forums table.
NB. No longer used now that the jsoftware Forum archive is unavailable.
return.
echo 'loadForum' ; y
wd 'msgs'
mainPageHtml =: gethttp 'https://www.jsoftware.com/pipermail/' , y , '/'
ol =. {:"2 (rxcomp 'href="([^\"]+subject.html)"') rxmatches mainPageHtml
offsets =. {."1 ol
lengths =. {:"1 ol
links =. ('https://www.jsoftware.com/pipermail/', y , '/')&, &. > lengths <@{."0 1 offsets }."0 1 mainPageHtml
yearMonthHtml =. gethttp &. > links
pat =. rxcomp '<LI><A HREF="([^"]+\.html)">[^ ]* ([^<]+)</A><A NAME="[^"]+">[^>]+</A>[^<]*<I>([^<]+)<'
sqlcmd__db 'begin transaction'
yearMonthPat =. rxcomp '<h1>([^ ]+) (\d\d\d\d)'
cols =. ;: 'forumname year month subject author link'
for_boxedHtml. yearMonthHtml do.
	html =. > boxedHtml
	'mo ml yo yl' =. , }. yearMonthPat rxmatch html
	month =. Months i. < ml {. mo }. html
	year =. ". yl {. yo }. html
	k =. pat rxmatches html
	matches =. }."1 (1 {"1 k) {. &. > ({."1 k) <@}."1"0 _ html
	if. 0 = # matches do. continue. end.
	links =. _5&}. &. > {."1 matches
	subjects =. 1 {"1 matches
	authors =. 2 {"1 matches
	c =. # links
  	data =: (c # < 'J' , y) ; (c # year) ; (c # month) ; (translateHtmlEncodings &. > subjects) ; authors ; < links
	sqlinsert__db 'forums' ; cols ; <data
end.
sqlcmd__db 'commit transaction'
)

loadTagCategories =: 3 : 0
NB. Load all of the categories and remove the existing tree categories from the list to produce the Tag categories.
NB. Create a category called *Tags in the categories table and put the Tag categories under it.
NB. Load all of the Tag categories' pages into the wiki table.
NB. html =. gethttp 'https://code.jsoftware.com/mediawiki/index.php?title=Special:Categories&offset=&limit=1000'
NB. No longer used now that the jsoftware Forum archive is unavailable.
echo 'loadTagCategories'
anchorId =. 500000
data1 =. 1 ; 1 ; (nextCatId 1) ; '*Tags' ; _1 ; 4 ; 'https://code.jsoftware.com/mediawiki/index.php?title=Special:Categories&offset=&limit=1000'
cols1 =. ;: 'level parentid categoryid category count parentseq link'
sqlinsert__db 'categories' ; cols1 ; < data1
data2 =. 1 ; anchorId ; (nextCatId 1) ; '*Tags' ; _1 ; 2 ; 'https://code.jsoftware.com/mediawiki/index.php?title=Special:Categories&offset=&limit=1000'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < data2
treeCategories =. , > {: sqlreadm__db 'select distinct category from categories'
html =. (2!:0) 'curl "https://code.jsoftware.com/mediawiki/index.php?title=Special:Categories&offset=&limit=1000"'
pat =. rxcomp '<li>[^h]+href="([^"]+)"[^>]+>([^<]+)\<'
offsetLengths =. }."2 pat rxmatches html
linkOffsets =. {."(1) 0 {"2 offsetLengths
linkLengths =. {:"(1) 0 {"2 offsetLengths
links =: 'https://code.jsoftware.com/'&, &. > linkLengths <@{."0 1 linkOffsets }."0 1 html
catOffsets =. {."(1) 1 {"2 offsetLengths
catLengths =. {:"(1) 1 {"2 offsetLengths
sieve =. -. (categories =: catLengths <@{."0 1 catOffsets }."0 1 html) e. treeCategories
categories =. sieve # categories
links =. sieve # links
headerCategories =. ,&'...' &. > > {. &. > _15 <\ categories
count =. # headerCategories
data3 =. (count # 1) ; (count # anchorId getCategoryId '*Tags') ; (nextCatId count) ; headerCategories ; (count # _1) ; (i. count) ; < count # < ''
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < data3
headerIds =. (anchorId getCategoryId '*Tags')&getCategoryId &. > headerCategories
for_entry. k =. ((# categories) {. 15 # headerIds) ,. categories ,. links do.
	'headerId category link' =. entry
	try. 
		catHtml =. (2!:0) 'curl "' , link , '"'
	catch.
		echo (13!:12) ''
		continue.
	end.
	catHtml =. (I. 'printfooter' E. catHtml) {. catHtml =. (I. 'mw-category-generated' E. catHtml) }. catHtml
	pagePat =. 'href="([^"]+)"[^>]+>([^<]+)<'
	pageOffsetLengths =. }."2 pagePat rxmatches catHtml
	data4 =. 5 ; headerId ; (nextCatId 1) ; category ; (# pageOffsetLengths) ; entry_index ; link
	echo data4
	wd 'msgs'
	sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < data4
	catId =. headerId getCategoryId category
	for_pageOl. pageOffsetLengths do.
		'pageLinkOffset pageLinkLength' =. 0 { pageOl
		'pageTitleOffset pageTitleLength' =. 1 { pageOl
		pageLink =. 'https://code.jsoftware.com' , pageLinkLength {.  pageLinkOffset }. catHtml
		pageTitle =. pageTitleLength {. pageTitleOffset }. catHtml
		data5 =. catId ; pageTitle ; pageLink
		sqlinsert__db 'wiki' ; (;: 'categoryid title link') ; < data5
	end.
	
end.
)

loadUserCategories =: 3 : 0
echo 'loadUserCategories'
allUrls =. ''
catUrl =. 'https://code.jsoftware.com/wiki/Special:AllPages?namespace=2'
while. 1 do. 
  pageListHtml =. , > getHtml < catUrl
  allUrls =. allUrls , 'href="(/wiki/User:[^"]*)"' extractFields pageListHtml
  relativeCatUrl =. '<a href="([^"]*)" title="Special:AllPages">Next' extractFields pageListHtml
  if. a: -: relativeCatUrl do. break. end.
  catUrl =. ('&amp;' ; '&') rxrplc 'https://code.jsoftware.com' , > {. relativeCatUrl
end.
users =. ~. >@{. &. > < ;. _2 &. > ,&'/' &. > 11&}. &. > allUrls
return.
cols =. ;: 'categoryid title link'
data =. ((# titles) # categoryId) ; titles ; < links
sqlinsert__db 'wiki' ; cols ; <data
echo 'end loadUserCategories'
)

prepToProcessCategory =: {{
visitedPairs =: ,: a: , a:
visitedChildren =: ''
pairsToVisit =: ,:  0 ; 1 ; 'Home' NB. Level ; ParentId ; Child Category.
emergencySeq =: 500
}}

processCategory =: 3 : 0
NB. Retrieve and processs the HTML.  Recurse to handle any child categories.
while. 0 < # pairsToVisit do.
	'level parentId childCategory' =. {. pairsToVisit
	pairsToVisit =: }. pairsToVisit
	if. (# visitedPairs) > visitedPairs i. (parentId ; childCategory) do. echo 'Skipping--visited.' ; parentId ; childCategory continue. end.
	if. 0 <: getCategoryIdNoParent childCategory do. echo 'Skipping--already in the db.' ; parentId ; childCategory continue. end.
	if. childCategory -: parentCategory =. getCategory parentId do. echo 'Skipping--parent=child' ; parentCategory ; childCategory continue. end.
	visitedPairs =: visitedPairs , (parentId ; childCategory)
	echo 'Processing category pair' ; parentId ; childCategory
	wd 'msgs'
	catWithUnderscores =. (' ';'_') rxrplc childCategory
	url =. 'https://code.jsoftware.com/wiki/Category:' , ('\)' ; '\\\)') rxrplc ('\(' ; '\\\(') rxrplc ('''' ; '\''') rxrplc urlencode catWithUnderscores
	html =. gethttp url
	patSubcategories =. rxcomp 'title="Category:([^"]+)"'
	shortenedHtml =. html
	if. 0 < # dropCount =. I. 'mw-subcategories' E. html do. shortenedHtml =. dropCount }. html end.
	if. 0 < # suffixDropIndex =. I. 'id="mw-hidden-catlinks"' E. shortenedHtml do. shortenedHtml =. suffixDropIndex {. shortenedHtml end.
	offsetLengths =. ,/ }."2 patSubcategories rxmatches shortenedHtml
	categories =. ('_' ; ' ')&rxrplc &. > (<"0 {:"1 offsetLengths) {. &. > ({."1 offsetLengths) <@}."0 1 shortenedHtml
	categories =. categories -. (<'Hidden categories (page does not exist)') , <'Home'
	patPageLink =. rxcomp '<li>[^<]*<a href="([^"]+)" title="([^"]+)"'
	offsetLengths =. }."2 patPageLink rxmatches shortenedHtml
	viewSourceHtml =. gethttp '"https://code.jsoftware.com/mediawiki/index.php?title=Category:' , catWithUnderscores , '&action=edit"'
	ol =. {: ((rxcomp '\|(\d+)\]\]') rxmatch viewSourceHtml)
	if. _1 = {. {. ol do.
		parentSeq =. emergencySeq
		emergencySeq =: >: emergencySeq
	else.
		parentSeq =. ". ({: ol) {. ({. ol) }. viewSourceHtml 
	end.
	parms =.'categories' ; (;: 'level parentid categoryid category parentseq link') ; < (level + 1) ; parentId ; (nextCatId 1) ; childCategory ; parentSeq ; ('Category:' , childCategory)
	echo parms
	sqlinsert__db parms
	count =. 0
	categoryId =. parentId getCategoryId childCategory
	echo categoryId ; $ categoryId
	if. ((# visitedChildren) = visitedChildren i. < childCategory) *. 0 < # offsetLengths do.
NB.		sqlcmd__db 'begin transaction'
		linkOffsetLengths =. 0 {"2 offsetLengths
		links =. (<"0 {:"1 linkOffsetLengths) {. &. > ({."1 linkOffsetLengths) <@}."0 1 shortenedHtml
		titleOffsetLengths =. 1 {"2 offsetLengths
		titles =. (<"0 {:"1 titleOffsetLengths) {. &. > ({."1 titleOffsetLengths) <@}."0 1 shortenedHtml
		count =. # titles
		if. 'Category:' -: 9 {. > {: titles do. NB. There's sometimes a stray "Category:" link at the bottom.
			links =. }: links
			titles =. }: titles
		end.
		cols =. ;: 'categoryid title link'
		data =. ((# titles) # categoryId) ; titles ; < links
		sqlinsert__db 'wiki' ; cols ; <data
NB.		sqlcmd__db 'commit transaction'
	end.
	echo 'parentId childCategory' ; parentId ; childCategory
	parms =.'categories' ; ('categoryid = ' , ": categoryId) ; (;: 'count') ; < count
	sqlupdate__db parms
	childCategories =. ('&#039;' ; '''')&rxrplc &. > categories
NB.	childCategories =. childCategories -. visitedChildren
NB.	if. 0 < # childCategories do.
NB.		links =. 'Category:'&, &. > childCategories
NB.	end.
	visitedChildren =: visitedChildren , < childCategory
	pairsToVisit =: pairsToVisit , (< level + 1) ,. (< categoryId) ,. childCategories
end.
)

setupTables =: 3 : 0
NB. Note that these should be the first rows inserted into the categories table.
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category parentseq count') ;      < 0 ; _1 ; 1 ; '' ; 0 ; _1
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 20 ; '*Live Search' ; _1 ; 7 ; ''
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 10 ; '*NuVoc' ; _1 ; 1 ; 'https://code.jsoftware.com/wiki/Category:NuVoc_R.1'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 15 ; '*Vocabulary' ; _1 ; 2 ; 'https://www.jsoftware.com/help/dictionary/vocabul.htm'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 30 ; '*Forums' ; _1 ; 3 ; 'https://www.jsoftware.com/mailman/listinfo/'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 50 ; '*JSaurus' ; _1 ; 5 ; 'https://jsaurus.info/'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 60 ; '*JPlayground' ; _1 ; 6 ; 'https://jsoftware.github.io/j-playground/bin/html2/'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 70 ; '*Users' ; _1 ; 8 ; 'https://code.jsoftware.com/wiki/Special:AllPages?namespace=2'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 1e6 ; '*Bookmarks' ; _1 ; 9 ; 'https://www.jsoftware.com/'
)

finishLoadingVocabulary =: 3 : 0
echo 'finishLoadingVocabulary'
cols =. ;: 'title categoryid link'
titles =. 'Vocabulary' ; 'Dictionary Contents'
links =. 'https://www.jsoftware.com/help/dictionary/vocabul.htm' ; 'https://www.jsoftware.com/help/dictionary/contents.htm'
data =. titles ; 15 15 ; < links
sqlinsert__db 'wiki' ; cols ; < data
)

finishLoadingForums =: 3 : 0
echo 'finishLoadingForums'
forumNames =. > 1 { sqlreadm__db 'select distinct forumname from forums'
forumId =. 1 getCategoryId '*Forums'
links =. 'https://www.jsoftware.com/mailman/listinfo/'&, &. > }. &. > forumNames
cols =. ;: 'level parentid categoryid category parentseq count link'
data =. (< 2 #~ # forumNames) , (< (#forumNames) # forumId) , (< nextCatId # links) , (< , forumNames) , (< i. # links) , (< _1 #~ # forumNames) , < , links
NB. echo data
sqlinsert__db 'categories';cols;<data
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
NB. Return the rowid of the category
result =. > {: sqlreadm__db 'select categoryid from categories where category = ''' , (n =. ('''' ; '''''') rxrplc y) , ''' and parentid = ' , ": x
if. 0 = # result do. _1 else. , > result end.
)

getParentId =: 3 : 0
NB. y Category id
NB. Return the rowid of the category's parent.
, > , > {: sqlreadm__db 'select parentid from categories where caategoryid = ' , ": y
)

NextCatId =: 1000

nextCatId =: 3 : 0
NB. y Number of ids needed
if. NextCatId = 0 do.
	result =. , > > {: sqlreadm__db 'select max(parentid) from categories where parentid < 1000000'
	if. 'NULL' -: result do. base =: 200 else. base =: >: {. result end.
else.
	base =: NextCatId
end.
ids =. base + i. y
NextCatId =: base + y
ids
)

NextUserCatId =: 0

nextUserCatId =: 3 : 0
NB. y Number of ids needed
if. NextUserCatId = 0 do.
	result =. , > > {: sqlreadm__db 'select max(parentid) from categories where parentid > 1000000' 
	if. 'NULL' -: result do. base =: 1000000 else. base =: >: {. result end.
else.
	base =: NextUserCatId
end.
ids =. base + i. y
NextUserCatId =: base + y
ids
)

dbOpenDb =: 3 : 0
db =: sqlopen_psqlite_ stageDbPath
)

getCurlDate =: 3 : 0
NB. Return a string date that cURL's -z (--time-cond) option will recognize.
json =. gethttp 'http://worldtimeapi.org/api/timezone/GMT'
'offset length' =. {: (rxcomp '"datetime":"([^"]+)"') rxmatch json
length {. offset }. json
)

setupDb =: 3 : 0
try. (1!:55) < stageDbPath catch. end.
db =: sqlcreate_psqlite_ stageDbPath
sqlcmd__db 'CREATE TABLE forums (forumname TEXT, year INTEGER, month INTEGER, day INTEGER, subject TEXT, author TEXT, link TEXT)'
sqlcmd__db 'CREATE TABLE wiki (title TEXT, categoryid INTEGER, link TEXT)'
sqlcmd__db 'CREATE TABLE categories (level INTEGER, parentid INTEGER, categoryid INTEGER, category TEXT, parentseq INTEGER, count INTEGER, link TEXT)'
sqlcmd__db 'CREATE TABLE vocabulary (groupnum INTEGER, pos TEXT, row INTEGER, glyph TEXT, monadicrank TEXT, label TEXT, dyadicrank TEXT, link TEXT)'
sqlcmd__db 'CREATE TABLE history (label TEXT, link TEXT)'
sqlcmd__db 'CREATE TABLE similar (word TEXT, count INTEGER)'
sqlcmd__db 'CREATE TABLE admin (key TEXT primary key, value TEXT)'
sqlcmd__db 'CREATE TABLE keyvalue (key TEXT primary key, value TEXT)'
sqlcmd__db 'CREATE VIRTUAL TABLE jindex USING FTS5 (body, tokenize="porter")'
sqlcmd__db 'CREATE TABLE auxiliary (rownum INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, year INTEGER, source TEXT, url TEXT, priority INTEGER, similar TEXT)'
NB. sqlcmd__db 'CREATE INDEX source_index ON auxiliary (source)'
sqlcmd__db 'CREATE TABLE github (content BLOB)'
)

writeStartTime =: 3 : 0
sqlinsert__db 'admin' ; (;: 'key value') ; < 'CrawlStart' ; getCurlDate ''
)

writeEndTime =: 3 : 0
sqlinsert__db 'admin' ; (;: 'key value') ; < 'CrawlEnd' ; getCurlDate ''
)

turnOnOptimization =: {{
sqlcmd__db 'PRAGMA optimize'
}}

compressDatabaseFile =: {{
dbString =. (1!:1) < stageDbPath
(lz4_compressframe dbString) (1!:2) < compressedDbPath
}}

setup =: 3 : 0
setupTempDirectory ''
setupDb ''
writeStartTime ''
setupTables ''
prepToProcessCategory ''
processCategory ''
loadVoc ''
loadAncillaryPages ''
loadTagCategories ''
NB. loadForum &. > ;: 'programming general beta chat source database '
writeEndTime ''
if. fexist masterDbFile do. updateMasterDbWithChangedWikiPages '' else. updateMasterDbWithAllWikiPages '' end.
copyForumRecordsToMaster ''
moveForumRecordsFromMasterToStage ''
NB. updateMasterDbWithGitHubJSoftwareProjects ''
NB. for_i. i.5 do.
NB.   updateMasterDbWithGitHubJRepos ''
NB. end.
sqlcmd__masterDb 'delete from content where sourcetype = "G"'
updateMasterDbWithGitHub ''
updateMasterDbWithRosettaCode ''
updateMasterDbWithQuora ''
updateMasterDbWithYouTube ''	
updateMasterDbWithForumPosts ''
finishLoadingForums ''
finishLoadingVocabulary ''
moveFullTextIndexIntoStage ''
buildMagic8Ball ''
turnOnOptimization ''
sqlclose__db ''
compressDatabaseFile ''
)