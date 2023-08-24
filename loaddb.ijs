NB. The wiki pages for jwikiviz.db have to be crawled so we can get the topic structure.
NB. The posts for jwikiviz.db need not be crawled.
NB. The posts for master.db need to be crawled, and may be crawled incrementally.
NB. The posts for jwikiviz.db could be taken from the post rows in master.db.



clear ''

load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'arc/lz4'

db =: ''
Months =: ;:'January February March April May June July August September October November December'

wikiUrlPrefix =: 'https://code.jsoftware.com'

appDir =: jpath '~temp/loaddb'
stageDbFile =: appDir , '/jwikiviz.stage.db'
wikiDir =: appDir , '/code.jsoftware.com/wiki'
codeSearchFile =: appDir , '/codesearch.html'
forumDir =: appDir , '/forums'
forumStderrDir =: forumDir , '/stderr'
forumHtmlDir =: forumDir , '/html'
masterDbFile =: appDir , '/master.db'
indexFile =: appDir , '/jwikiviz.fulltext.txt.lz4'
dateFile =: appDir , '/jwikiviz.dat'
tokenFile =: appDir , '/token.txt'

jEnglishDict =: _2 ]\ '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':' ; 'co' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'F:.' ; 'fcapcodot' ; 'F::' ; 'fcapcoco' ; 'F:' ; 'fcapco' ; 'F..' ; 'fcapdotdot' ; 'F.:' ; 'fcapdotco' ; 'F.' ; 'fcapdot' ; 'H.' ; 'hcapdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco' ; 'j.' ; 'jdot' ; 'L.' ; 'lcapdot' ; 'L:' ; 'lcapco' ; 'm.' ; 'mdot' ; 'M.' ; 'mcapdot' ; 'NB.' ; 'ncapbcapdot' ; 'o.' ; 'odot' ; 'p.' ; 'pdot' ; 'p:' ; 'pco' ; 'q:' ; 'qco' ; 'r.' ; 'rdot' ; 's:' ; 'sco' ; 't.' ; 'tdot' ; 'T.' ; 'tcapdot' ; 'u:' ; 'uco' ; 'x:' ; 'xco' ; 'Z:' ; 'zcapco' ; 'assert.' ; 'assertdot' ; 'break.' ; 'breakdot' ; 'continue.' ; 'continuedot' ; 'else.' ; 'elsedot' ; 'elseif.' ; ' elseifdot' ; 'for.' ; 'fordot' ; 'if.' ; 'ifdot' ; 'return.' ; 'returndot' ; 'select.' ; 'selectdot' ; 'case.' ; 'casedot' ; 'fcase.' ; 'fcasedot' ; 'try.' ; 'trydot' ; 'catch.' ; 'catchdot' ; 'catchd.' ; 'catchddot' ; 'catcht.' ; 'catchtdot' ; 'while.' ; 'whiledot' ; 'whilst.' ; 'whilstdot'         
jMnemonics =: , &. > 0 {"1 jEnglishDict
jEnglishWords =: 'J'&, &. > 1 {"1 jEnglishDict
jPrintedIndices =: 'J'&, &. > <@":"0 i. # jMnemonics
htmlEncodings =: _2 ]\ '&gt;' ; '>' ; '&lt;' ; '<' ; '&quot;' ; '"' ; '&amp;' ; '&' ; '<tt>' ; ' ' ; '</tt>' ; ' ' ; '<pre>' ; ' '

translateToJEnglish =: 3 : 0
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
NB. try. raw =. ('''' ; '''''') rxrplc y catch. ' ' return. end.
try. raw =. ('''' ; ' ') rxrplc y catch. smoutput 'Problem!' return. end.
translatedHtml =. translateHtmlEncodings raw
rawTokens =. ;: translatedHtml
hits =. jMnemonics i."1 0 rawTokens
; (hits {"0 1 jEnglishWords ,"1 0 rawTokens) ,. < ' '
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
blockSize =. 100 <. # y
urlBlocks =. (- blockSize) <\ y
result =. ''
for_i. i. # urlBlocks do.
	urlBatch =. > i { urlBlocks
	urlSpec =. ; ('"'&, &. > ,&'"' &. > urlBatch) ,. <' '
	files =. (jpath '~temp/html/')&, &. > ,&'.html' &. > <@":"0 i. blockSize <. # urlBatch
	outputSpec =. ; (<' -o ') ,. files
	command =. 'curl ' , outputSpec , ' ' , urlSpec
	try.
		(2!:0) command
	catch.
		smoutput (13!:12) ''
		smoutput urlSpec
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
NB. smoutput 'extractTextFromWikiArticle Failure! ' , 200 {. result
result
)

NB. ============================ Crawling GitHiub ======================================
indexSuffixes =: '.txt' ; '.ijs'

updateMasterDbWithGitHubDocs =: 3 : 0
NB. y Project name from the jsoftware section of GitHub
NB. Get the project, get contents of the relevant files, insert into master.db.
project =. y
token =. LF -.~ (1!:1) < tokenFile
cmd =. 'curl -H "Authorization: token ' , token , '" -L https://github.com/gottsman63/' , project , '/zipball/master/'
zip =. (2!:0) cmd =. 'curl -H "Authorization: token ' , token , '" -L https://github.com/jsoftware/' , project , '/zipball/master/'
zipFilename =. appDir , '/github/' , project , '.zip'
exdir =. appDir , '/github/' , project
zip (1!:2) < zipFilename
(2!:0) 'rm -r ' , exdir
(2!:0) 'unzip -o -d ' , exdir , ' ' , zipFilename
commands =. ('find ' , exdir , ' -type f -name "*')&, &. > ,&'"' &. > indexSuffixes
filenames =. ; < ;. _2 @(2!:0) &. > commands
contents =. <@(1!:1)"0 filenames
urls =. ('https://github.com/jsoftware/' , project , '/blob/master/')&, &. > ('^.*jsoftware[^/]+/' ; '')&rxrplc &. > filenames
data =. urls ; filenames ; ((<project) #~ # urls) ; ((< 'G') #~ # urls) ; (9999 #~ # urls) ; (0 #~ # urls) ; (0 #~ # urls) ; filenames ; filenames ; < contents
smoutput '$' ; $ &. > data
smoutput masterCols
sqlinsert__masterDb 'content' ; masterCols ; < data
smoutput sqlerror__masterDb ''
)

updateMasterDbWithGitHubProjects =: 3 : 0
NB. Update master.db with the jsoftware projects from GitHub.
createOrOpenMasterDb ''
sqlcmd__masterDb 'delete from content where sourcetype = "G"'
updateMasterDbWithGitHubDocs 'arc_zip'
)
NB. ========================== End Crawling GitHiub ====================================

NB. =================================== Master DB =============================================
masterCols =: ;: 'link id sourcename sourcetype year monthindex day subject author body'

createOrOpenMasterDb =: 3 : 0
if. fexist < masterDbFile do.
	masterDb =: sqlopen_psqlite_ masterDbFile
else.
	masterDb =: sqlcreate_psqlite_ masterDbFile
	NB. The id can be used with other columns to reconstruct the link, which may not be sent down to the client (since it's fairly long).
	sqlcmd__masterDb 'CREATE TABLE content (link TEXT PRIMARY KEY, id TEXT, sourcename TEXT, sourcetype TEXT, year INTEGER, monthindex INTEGER, day INTEGER, subject TEXT, jsubject TEXT, author TEXT, body TEXT)'
end.
)

moveForumRecordsFromMasterToStage =: 3 : 0
createOrOpenMasterDb ''
dbOpenDb ''
sqlcmd__db 'delete from forums'
f =. > {: sqlreadm__masterDb 'select id, sourcename, year, monthIndex, day, subject, author from content where sourcetype = "F"'
cols =. ;: 'forumname year month day subject author link'
data =. ('J'&, &. > 1 {"1 f) ; (> 2 {"1 f) ; (> 3 {"1 f) ; (> 4 {"1 f) ; (5 {"1 f) ; (6 {"1 f) ; < 0 {"1 f
sqlinsert__db 'forums' ; cols ; <data
smoutput 'moveForumRecordsFromMasterToStage: ' , ": # f
)

updateMasterDbWithPostsForDate =: 4 : 0
NB. x Forum name (programming, chat, etc.)
NB. y year, monthIndex
NB. Get posts from forum x for the date y and upsert them.
'year monthIndex' =. y
smoutput 'Processing' ; x ; year ; > monthIndex { Months
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
	title =. }: }: }: }: titleLength {. titleOffset }. html
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
		smoutput 'Failed to insert:'
		smoutput ,. data
	end.
end.
# links
)

updateMasterDbWithPosts =: 3 : 0
NB. Determine the most recent year-month for which we have posts.  
NB. Grab all of those posts as well as all posts since and upsert them into masterDb.
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
smoutput '$ startYear ' ; $ startYear
years =.  startMonth }. 12 # startYear + i. 1 + currentYear - startYear
months =. startMonth }. (12 * 1 + currentYear - startYear) $ i.12
dates =. years ,. months
forums =. ;: 'general chat programming database source beta'
(((# forums) * # dates) $ forums) updateMasterDbWithPostsForDate &. > <"(1) (# forums) # dates
)

updateMasterDbWithAllWikiPages =: 3 : 0
smoutput 'updateMasterDbWithAllWikiPages'
dbOpenDb ''
createOrOpenMasterDb ''
rawRows =. > {: sqlreadm__db 'select title, link from wiki'
rawTitles =. 0 {"1 rawRows
rawLinks =. 1 {"1 rawRows
prefixes =. (k =: > 'https:'&-: &. > 6&{. &. > rawLinks) { h =. wikiUrlPrefix ; ''
rawUrls =. prefixes , &. > rawLinks
uniqueRows =. (~: rawUrls) # rawTitles ,. rawUrls
smoutput 'Processing row count' ; # uniqueRows
wd 'msgs'
for_rowBatch. _100 < \ uniqueRows do.
	rows =. > rowBatch
	smoutput 'processing row count' ; # rows
	wd 'msgs'
	links =. 1 {"1 rows
	urls =. convertToWikiUrl &. > ids =. (# wikiUrlPrefix)&}. &. > links
	titles =. {."1 rows
	rawHtmls =. getHtml urls
	extractedHtmls =. extractTextFromWikiArticle &. > rawHtmls
	htmls =. translateToJEnglish &. > extractedHtmls
	data =. links ; ids ; ((<'wiki') #~ # urls) ; ((<'W') #~ # urls) ; (9999 #~ # urls) ; (11 #~ # urls) ; (0 #~ # urls) ; titles ; ((<' ') #~ # urls) ; < htmls
	try.
		sqlupsert__masterDb 'content' ; 'link' ; masterCols ; <data
	catch. catcht.
		smoutput (13!:12) ''
		smoutput sqlerror__masterDb '' 
	end.
end.
)

updateMasterDbWithChangedWikiPages =: 3 : 0
NB. Use the Mediawiki "changed" page to grab the last three days' changes...
NB. ...unless there are no wiki pages, in which case load the whole wiki.
smoutput 'updateMasterDbWithChangedWikiPages...'
dbOpenDb ''
createOrOpenMasterDb ''
if. 0 = # > > {: sqlreadm__masterDb 'select count(*) from content where sourcetype = "W"' do.
	updateMasterDbWithAllWikiPages ''
	return.
end.
changedLinkHtml =. gethttp 'https://code.jsoftware.com/wiki/Special:RecentChanges?hidebots=1&limit=50&days=3&enhanced=1&urlversion=2'
ol =. {:"2 (rxcomp '<a href="([^"]+)" class="mw-changeslist-title"') rxmatches changedLinkHtml
wikiLinks =. ~. ({:"1 ol) <@{."0 1 ({."1 ol) }."0 1 changedLinkHtml
ol =. {:"2 (rxcomp 'class="mw-changeslist-title" title="([^"]+)">') rxmatches changedLinkHtml
titles =. ~. ({:"1 ol) <@{."0 1 ({."1 ol) }."0 1 changedLinkHtml
smoutput 'Found ', (": # titles) , ' changed wiki pages.'
if. 0 = # titles do. return. end.
links =. (wikiUrlPrefix , '/')&, &. > wikiLinks
urls =. convertToWikiUrl &. > ids =. (# wikiUrlPrefix)&}. &. > links
htmls =. translateToJEnglish &. > extractTextFromWikiArticle &. > getHtml urls
data =. links ; ids ; ((<'wiki') #~ # urls) ; ((<'W') #~ # urls) ; (9999 #~ # urls) ; (11 #~ # urls) ; (0 #~ # urls) ; titles ; ((<' ') #~ # urls) ; < htmls
try.
	sqlupsert__masterDb 'content' ; 'link' ; masterCols ; <data
catch. catcht.
	smoutput (13!:12) ''
	smoutput sqlerror__masterDb '' 
end.
)
NB. ================================= End Master DB ===========================================

NB. ===================== Full-Text Search ================================
generateFullTextContentFile =: 3 : 0
NB. Create a string of (id sourceType year subject author body) separated by 1 { a.
createOrOpenMasterDb ''
table =. > {: sqlreadm__masterDb 'select link, sourcetype, year, subject, author, body from content'
formattedTable =. (0 1 {"1 table) ,. (": &. > 2 {"1 table) ,. 3 4 5 {"1 table
s =. lz4_compressframe ; ,&(2 3 4 { a.) &. > , formattedTable 
s (1!:2) < indexFile
)
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
smoutput 'loadAncillaryPages'
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
smoutput data
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < data
ancillaryId =. nuVocId getCategoryId 'Ancillary Pages'
sqlinsert__db 'wiki' ; (;: 'categoryid title link') ; < (ancillaryId #~ # links) ; titles ; <links
catcht.
	smoutput (13!:12) ''
	smoutput dbError ''
end.
)

extractField =: 4 : 0
NB. x Pattern string (assumes a parenthesized subpattern match)
NB. y String
NB. Return the first match of x in y
ol =. {: (rxcomp x) rxmatch y
({: ol) {. ({. ol) }. y
)

loadForum =: 3 : 0
NB. y Forum name (path component)
NB. Retrieve the forum archive files and add them to the forums table.
smoutput 'loadForum' ; y
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
smoutput 'loadTagCategories'
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
	catHtml =. (2!:0) 'curl "' , link , '"'
	catHtml =. (I. 'printfooter' E. catHtml) {. catHtml =. (I. 'mw-category-generated' E. catHtml) }. catHtml
	pagePat =. 'href="([^"]+)"[^>]+>([^<]+)<'
	pageOffsetLengths =. }."2 pagePat rxmatches catHtml
	data4 =. 5 ; headerId ; (nextCatId 1) ; category ; (# pageOffsetLengths) ; entry_index ; link
	smoutput data4
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

visitedPairs =: ,: a: , a:
visitedChildren =: ''
pairsToVisit =: ,:  0 ; 1 ; 'Home' NB. Level ; ParentId ; Child Category.
emergencySeq =: 500

processCategory =: 3 : 0
NB. Retrieve and processs the HTML.  Recurse to handle any child categories.
while. 0 < # pairsToVisit do.
	'level parentId childCategory' =. {. pairsToVisit
	pairsToVisit =: }. pairsToVisit
	if. (# visitedPairs) > visitedPairs i. (parentId ; childCategory) do. smoutput 'Skipping--visited.' ; parentId ; childCategory continue. end.
	if. 0 <: getCategoryIdNoParent childCategory do. smoutput 'Skipping--already in the db.' ; parentId ; childCategory continue. end.
	if. childCategory -: parentCategory =. getCategory parentId do. smoutput 'Skipping--parent=child' ; parentCategory ; childCategory continue. end.
	visitedPairs =: visitedPairs , (parentId ; childCategory)
	smoutput 'Processing category pair' ; parentId ; childCategory
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
	smoutput parms
	sqlinsert__db parms
	count =. 0
	categoryId =. parentId getCategoryId childCategory
	smoutput categoryId ; $ categoryId
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
	smoutput 'parentId childCategory' ; parentId ; childCategory
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
NB. sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 20 ; '*Search' ; _1 ; 2 ; 'https://code.jsoftware.com/wiki/Special:JwikiSearch'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 30 ; '*Forums' ; _1 ; 3 ; 'https://www.jsoftware.com/mailman/listinfo/'
NB. sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 200000 ; 40 ; '*Search' ; _1 ; 4 ; 'https://www.jsoftware.com/mailman/listinfo/'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 50 ; '*JSaurus' ; _1 ; 5 ; 'https://jsaurus.info/'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 60 ; '*JPlayground' ; _1 ; 6 ; 'https://jsoftware.github.io/j-playground/bin/html2/'
sqlinsert__db 'categories' ; (;: 'level parentid categoryid category count parentseq link') ; < 1 ; 1 ; 1e6 ; '*Bookmarks' ; _1 ; 8 ; 'https://www.jsoftware.com/'
)

finishLoadingForums =: 3 : 0
forumNames =. > 1 { sqlreadm__db 'select distinct forumname from forums'
forumId =. 1 getCategoryId '*Forums'
links =. 'https://www.jsoftware.com/mailman/listinfo/'&, &. > }. &. > forumNames
cols =. ;: 'level parentid categoryid category parentseq count link'
data =. (< 2 #~ # forumNames) , (< (#forumNames) # forumId) , (< nextCatId # links) , (< , forumNames) , (< i. # links) , (< _1 #~ # forumNames) , < , links
NB. smoutput data
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
db =: sqlopen_psqlite_ stageDbFile
)

getCurlDate =: 3 : 0
NB. Return a string date that cURL's -z (--time-cond) option will recognize.
json =. gethttp 'http://worldtimeapi.org/api/timezone/GMT'
'offset length' =. {: (rxcomp '"datetime":"([^"]+)"') rxmatch json
length {. offset }. json
)

setupDb =: 3 : 0
try. (1!:55) < stageDbFile catch. end.
db =: sqlcreate_psqlite_ stageDbFile
sqlcmd__db 'CREATE TABLE forums (forumname TEXT, year INTEGER, month INTEGER, day INTEGER, subject TEXT, author TEXT, link TEXT)'
sqlcmd__db 'CREATE TABLE wiki (title TEXT, categoryid INTEGER, link TEXT)'
sqlcmd__db 'CREATE TABLE categories (level INTEGER, parentid INTEGER, categoryid INTEGER, category TEXT, parentseq INTEGER, count INTEGER, link TEXT)'
sqlcmd__db 'CREATE TABLE vocabulary (groupnum INTEGER, pos TEXT, row INTEGER, glyph TEXT, monadicrank TEXT, label TEXT, dyadicrank TEXT, link TEXT)'
sqlcmd__db 'CREATE TABLE log (datetime TEXT, msg TEXT)'
sqlcmd__db 'CREATE TABLE history (label TEXT, link TEXT)'
sqlcmd__db 'CREATE TABLE admin (key TEXT primary key, value TEXT)'
sqlcmd__db 'CREATE TABLE keyvalue (key TEXT primary key, value TEXT)'
)

writeStartTime =: 3 : 0
sqlinsert__db 'admin' ; (;: 'key value') ; < 'CrawlStart' ; getCurlDate ''
)

writeEndTime =: 3 : 0
sqlinsert__db 'admin' ; (;: 'key value') ; < 'CrawlEnd' ; getCurlDate ''
)

writeDateFile =: 3 : 0
(": (6!:0) '') (1!:2) < dateFile
)

NB. uploadDb =: 3 : 0
NB. auth =. (1!:1) < jpath '~temp/upload.auth'
NB. (' -H "Authorization: Bearer ' , auth , '" -H "Content-Type: application/octet-stream" --data-binary @' , stageDbFile) gethttp 'https://api.upload.io/v2/accounts/12a1yBS/uploads/binary?filePath=/uploads/jwikiviz.stage.db'
NB. )

setup =: 3 : 0
setupTempDirectory ''
setupDb ''
writeStartTime ''
setupTables ''
processCategory ''
loadVoc ''
loadAncillaryPages ''
loadTagCategories ''
NB. loadForum &. > ;: 'programming general beta chat source database '
writeEndTime ''
if. fexist masterDbFile do. updateMasterDbWithChangedWikiPages '' else. updateMasterDbWithAllWikiPages '' end.
updateMasterDbWithPosts ''
moveForumRecordsFromMasterToStage ''
finishLoadingForums ''
generateFullTextContentFile ''
writeDateFile ''
)