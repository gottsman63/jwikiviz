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

masterCols =: ;: 'link id sourcename sourcetype year monthindex day subject author body priority'

log =: 3 : 0
LF (1!:3) < logPath
y (1!:3) < logPath
echo y
)

initializeLog =: 3 : 0
'Log...' (1!:2) < logPath
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

createOrOpenMasterDb =: 3 : 0
if. fexist < masterDbFile do.
	masterDb =: sqlopen_psqlite_ masterDbFile
else.
	masterDb =: sqlcreate_psqlite_ masterDbFile
	NB. The id can be used with other columns to reconstruct the link, which may not be sent down to the client (since it's fairly long).
	sqlcmd__masterDb 'CREATE TABLE content (link TEXT PRIMARY KEY, id TEXT, sourcename TEXT, sourcetype TEXT, year INTEGER, monthindex INTEGER, day INTEGER, subject TEXT, author TEXT, body TEXT, priority INTEGER)'
end.
)

convertToWikiUrl =: 3 : 0
NB. Title of the form /wiki/...
'https://code.jsoftware.com/mediawiki/index.php?title=' , (urlencode 6 }. y) , '&action=edit'
)

getHtml =: 4 : 0
NB. x = 0 means return the raw html.
NB. x = 1 means use Lynx, returning a text representation of the page rather than the raw hTML.
NB. x = 3 means to return both the raw html and the Lynx output in a pair of boxes.
NB. y Boxed urls
NB. Return a list of boxed html, one for each url.  Remove any stray invalid UTF-8 characters.
log (": x) , ' getHtml...'
NB.echo ,. y
blockSize =. 100 <. # y
urlBlocks =. (- blockSize) <\ y
lynxResult =. ''
htmlResult =. ''
for_i. i. # urlBlocks do.
	urlBatch =. > i { urlBlocks
	urlSpec =. ; ('"'&, &. > ,&'"' &. > urlBatch) ,. <' '
	files =. (jpath '~temp/html/')&, &. > ,&'.html' &. > <@":"0 i. blockSize <. # urlBatch
	outputSpec =. ; (<' -o ') ,. files
	command =. 'curl --parallel ' , outputSpec , ' ' , urlSpec
	try.
		(2!:0) command
	catch.
		log (13!:12) ''
		log urlSpec
	end.		
	lynxCommands =. '/usr/local/bin/lynx -dump '&, &. > files
	iconvCommand =. ' | iconv -f utf-8 -t utf-8//IGNORE '
	fullLynxCommands =. ,&iconvCommand &. > lynxCommands
	lynxResult =. lynxResult , (2!:0) &. > fullLynxCommands
	fullHtmlCommands =. 'iconv -f utf-8 -t utf-8//IGNORE '&, &. > files
	htmlResult =. htmlResult , (2!:0) &. > fullHtmlCommands
end.
if. x = 0 do. htmlResult
elseif. x = 1 do. lynxResult
else. htmlResult ,. lynxResult
end.
)

NB. =========================== RosettaCode ===============================
getRosettaCodeChallengeUrlsAndTitles =: 3 : 0
log 'getRosettaCodeChallengeUrls...'
pat =. rxcomp '<li>[^<]*<a href="([^"]+)" title="([^"]+)"'
nextPagePat =. '<a href="(/wiki/Category:Programming_Tasks\?pagefrom[^"]+)"[^>]+>next page</a>'
html =. , > 0 getHtml < 'https://rosettacode.org/wiki/Category:Programming_Tasks'
fullListOfUrlTitles =. ''
while. 0 < # html do.
	try.
		c =. 1 2 {"2 pat rxmatches html
		urlTitles =. ({:"1 c) <@{."0 1 ({."1 c) }."0 1 html
		log 'found ' , (": # urlTitles) , ' RosettaCode urlTitles.'
		fullListOfUrlTitles =. fullListOfUrlTitles , urlTitles
		log 'about to check for the next page link...'
		if. 0 < {. c =. {: nextPagePat rxmatch html do.
			nextUrl =. 'https://rosettacode.org' , ({: c) {. ({. c) }. html
			html =. , > 0 getHtml < nextUrl
		else.
			html =. ''
		end.
	catch.
		log 'Problem ' , (13!:12) ''
		log sqlerror__masterDb ''
		log html
		break.
	end.
end.
}. fullListOfUrlTitles
)

extractJPortionOfRosettaCodeChallenge =: 4 : 0
NB. x Challenge title
NB. y Challenge text
NB. extract the J portion of the challenge from the text, translate.
NB. Return the content of the J challenge
try.
NB.   echo 'extractJPortionOfRosettaCodeChallenge...' , x
  text =. y
  candidateEndIndexes =. {."1 {."2 (rxcomp '^\[\d+\]') rxmatches text
  problemStartIndex =. {. {. (rxcomp '\s+\[\d+\]Task ') rxmatch text
  problemEndIndex =. {. candidateEndIndexes
  problem =. problemStartIndex }. problemEndIndex {. text
  solutionStartIndex =. {. {. (rxcomp '^\[\d+\]J') rxmatch text
  if. solutionStartIndex -: '' do.
    log 'No J code found for ' , x
    ' '
    return.
  end.
  solutionEndIndex =. (+/ solutionStartIndex >: candidateEndIndexes) { candidateEndIndexes
  jSolution =. solutionStartIndex }. solutionEndIndex {. text
  problem , ' ' , translateToJEnglish translateHtmlEncodings jSolution
catch.
  log 'Problem in extractJPortionOfRosettaCodeChallenge: ' , (13!:12) ''
  ' '
end.
)

crawlRosettaCode =: 3 : 0
NB. Return a table of titles, links and indexable challenge texts
log 'crawlRosettaCode...'
urlTitles =. getRosettaCodeChallengeUrlsAndTitles ''
titles =. 1 {"1 urlTitles
fullUrls =. 'https://rosettacode.org'&, &. > 0 {"1 urlTitles
fullChallengeTexts =. 1 getHtml fullUrls
jTexts =. titles extractJPortionOfRosettaCodeChallenge &. > fullChallengeTexts
jurls =. ,&'#J' &. > fullUrls
log '...crawlRosettaCode'
titles ,. jurls ,. jTexts
)

NB. ========================== End RosettaCode ============================

NB. ============================ Forums ===================================
crawlForums =: 3 : 0
NB. Return a table of subject ; url ; year ; monthindex ; day ; author ; body
log 'crawlForums...'
try.
  forumsDb =: sqlopen_psqlite_ forumsDbPath
  ftable =. > {: sqlreadm__forumsDb 'select link, id, sourcename, year, monthindex, day, subject, author, body from forum' 
  links =. 0 {" 1 ftable
  ids =. 1 {"1 ftable
  sourceNames =. 2 {"1 ftable
  years =. 3 {"1 ftable
  monthIndexes =. 4 {"1 ftable
  days =. 5 {"1 ftable
  subjects =. 6 {"1 ftable
  authors =. 7 {"1 ftable
  bodies =. 8 {"1 ftable
  log '...end updateMasterDbWithForumPosts'
  subjects ,. links ,. years ,. monthIndexes ,. days ,. authors ,. bodies
catch. catcht.
  log (13!:12) ''
  log sqlerror__forumsDb ''
end.
)
NB. ========================== End Forums =================================

NB. ============================= Wiki ====================================
crawlWikiForLinksAndTitles =: 3 : 0
NB. Return a table of url ; title
allUrls =. ''
allTitles =. ''
catUrl =. 'https://code.jsoftware.com/wiki/Special:AllPages?namespace=0'
while. 1 do. 
  pageListHtml =. , > 0 getHtml < catUrl
  allUrls =. allUrls , 'href="(/wiki/[^"]*)" title="[^"]*"' extractFields pageListHtml
  allTitles =. allTitles , 'href="/wiki/[^"]*" title="([^"]*)"' extractFields pageListHtml
  relativeCatUrl =. '<a href="([^"]*)" title="Special:AllPages">Next' extractFields pageListHtml
  if. a: -: relativeCatUrl do. break. end.
  catUrl =. ('&amp;' ; '&') rxrplc 'https://code.jsoftware.com' , > {. relativeCatUrl
end.
fullUrls =. 'https://code.jsoftware.com'&, &. > allUrls
fullUrls ,. allTitles
)

crawlWiki =: 3 : 0
NB. Return link ; title ; categories in a box ; text
linksTitles =. crawlWikiForLinksAndTitles ''
links =. {."1 linksTitles
titles =. {:"1 linksTitles
htmlTexts =. 3 getHtml links
htmls =. {."1 htmlTexts
texts =. {:"1 htmlTexts
sectionPat =. rxcomp '"mw-normal-catlinks"(.*?)</div'
categoryPat =. rxcomp '<a href="/wiki/Category:[^>]*>([^<]*)<'
sections =. sectionPat&extractField &. > htmls
categories =. categoryPat&extractFields &. > sections
titles ,. categories
) 
NB. =========================== End Wiki ==================================

initializeLog ''

crawl =: 3 : 0
crawlRosettaCode ''
updateMasterDbWithForumPosts ''
)