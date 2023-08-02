load 'data/sqlite'
load 'web/gethttp'

load 'regex'

indexDbFile =: jpath '~temp/jsearch.db'
forumDbFile =: jpath '~temp/forum.db'
wikiDbFile =: jpath '~temp/wiki.db'

jEnglishDict =: _2 ]\ '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'F:.' ; 'fcapcodot' ; 'F::' ; 'fcapcoco' ; 'F:' ; 'fcapco' ; 'F..' ; 'fcapdotdot' ; 'F.:' ; 'fcapdotco' ; 'F.' ; 'fcapdot' ; 'H.' ; 'hcapdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco' ; 'j.' ; 'jdot' ; 'L.' ; 'lcapdot' ; 'L:' ; 'lcapco' ; 'm.' ; 'mdot' ; 'M.' ; 'mcapdot' ; 'NB.' ; 'ncapbcapdot' ; 'o.' ; 'odot' ; 'p.' ; 'pdot' ; 'p:' ; 'pco' ; 'q:' ; 'qco' ; 'r.' ; 'rdot' ; 's:' ; 'sco' ; 't.' ; 'tdot' ; 'T.' ; 'tcapdot' ; 'u:' ; 'uco' ; 'x:' ; 'xco' ; 'Z:' ; 'zcapco' ; 'assert.' ; 'assertdot' ; 'break.' ; 'breakdot' ; 'continue.' ; 'continuedot' ; 'else.' ; 'elsedot' ; 'elseif.' ; ' elseifdot' ; 'for.' ; 'fordot' ; 'if.' ; 'ifdot' ; 'return.' ; 'returndot' ; 'select.' ; 'selectdot' ; 'case.' ; 'casedot' ; 'fcase.' ; 'fcasedot' ; 'try.' ; 'trydot' ; 'catch.' ; 'catchdot' ; 'catchd.' ; 'catchddot' ; 'catcht.' ; 'catchtdot' ; 'while.' ; 'whiledot' ; 'whilst.' ; 'whilstdot'         
jMnemonics =: , &. > 0 {"1 jEnglishDict
jEnglishWords =: 'J'&, &. > 1 {"1 jEnglishDict

createIndexDatabase =: 3 : 0
try. (1!:55) < indexDbFile catch. end.
try.
	indexDb =: sqlcreate_psqlite_ indexDbFile
	sqlcmd__indexDb 'CREATE VIRTUAL TABLE jindex USING FTS5 (body)'
	sqlcmd__indexDb 'CREATE TABLE auxiliary (id INTEGER PRIMARY KEY, title TEXT, year INTEGER, source TEXT, url TEXT)'
	sqlcmd__indexDb 'CREATE INDEX year_index ON auxiliary (year)'
	sqlcmd__indexDb 'CREATE INDEX source_index ON auxiliary (source)'
catcht.
sqlerror__indexDb''
end.
)

openIndexDatabase =: 3 : 0
indexDb =: sqlopen_psqlite_ indexDbFile
)

openAddOnDatabase =: 3 : 0
addOnDb =: sqlopen_psqlite_ '~temp/jwikiviz.db'
)

extractTextFromForumPost =: 3 : 0
NB. y The text of a Forum post
startPost =. '<!--beginarticle-->'
endPost =. '<!--endarticle-->'
try.
result =. p {.~ I. endPost E. p =. ((# startPost) + I. startPost E. y) }. y
catch.
smoutput 'extractTextFromForumPost Failure!'
''
return.
end.
result
)

extractText =: 3 : 0
NB. y HTML from which to extract plain text
NB. Return plain text
pat =. '<(?:"[^"]*"[''"]*|''[^'']*''[''"]*|[^''">])+>'
raw =. (pat ; '') rxrplc y
('&amp;' ; '&') rxrplc y
('&quot;' ; '"') rxrplc y
)

extractTextFromWikiArticle =: 3 : 0
NB. y HTML
start =. '<textarea'
end =. '</textarea'
try.
result =. p {.~ I. end E. p =. ((# start) + I. start E. y) }. y
catch.
smoutput 'extractTextFromWikiArticle Failure! '
''
return.
end.
result
)

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
'NEAR("' , (; jPortion ,. <' ') , '" ' , ( ; englishPortion ,. <' ') , ')'
)

translateToJ =: 3 : 0
NB. y A string possibly containing JEnglish tokens
tokens =. ;: y
hits =. jEnglishWords i."1 0 tokens
; (hits {"0 1 jMnemonics ,"1 0 tokens) ,. <' '
)

search =: 3 : 0
NB. y A mixed English/J query string
NB. Treat the J code as a quoted phrase for query purposes.
NB. Treat the English (non-J) tokens separately in the query.
NB. Return a table of title ; Snippet ; Url
query =. createQuery y
smoutput 'query' ; query
result =. > {: sqlreadm__indexDb 'select title, snippet(jindex, 2, '''', '''', '''', 10), url from jindex where body MATCH ''' , query , ''' order by rank'
smoutput 1 {"1 result
snippets =. translateToJ &. > 1 {"1 result
(0 {"1 result) ,. snippets ,. 2 {"1 result
)

getIndexTableCount =: 3 : 0
NB. y Ignored
NB. Return the number of rows in the url table.
": {. , > > {: sqlreadm__indexDb 'select count(*) from url'
)

saveWikiDocument =: 3 : 0
NB. y title ; url ; body
'url title body' =. y
cols =. ;: 'title urlId body'
text =. extractTextFromWikiArticle body
jEnglishText =. translateToJEnglish title , ' ' , text
urlId =. getIndexTableCount ''
smoutput 'urlId ; url' ; urlId ; url ; $ urlId
sqlinsert__indexDb 'url' ; (;: 'id url') ; < urlId ; url
smoutput '...added id, url'
sqlinsert__indexDb 'jindex' ; cols ; < title ; urlId ; jEnglishText
)

saveForumDocument =: 3 : 0
NB. y title ; url ; body
'url title body' =. y
cols =. ;: 'title url body'
text =. extractTextFromForumPost body
jEnglishText =. translateToJEnglish title , ' ' , text
urlId =. getIndexTableCount ''
sqlinsert__indexDb 'url' ; (;: 'id url') ; < urlId ; url
sqlinsert__indexDb 'jindex' ; cols ; < title ; urlId ; jEnglishText
)

translateToJEnglish =: 3 : 0
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
raw =. ('''' ; '''''') rxrplc y
rawTokens =. ;: raw
hits =. jMnemonics i."1 0 rawTokens
string =. ; (hits {"0 1 jEnglishWords ,"1 0 rawTokens) ,. < ' '
)
   
convertToForumUrl =: 3 : 0
NB. y Boxed forumname year month subject author link
NB. Return a fully-qualified url.
NB. Sample Forum url: https://www.jsoftware.com/pipermail/programming/2023-July/062652.html
'name year month subject author link' =. y
months =. ;:'January February March April May June July August September October November December'
< 'https://www.jsoftware.com/pipermail/' , (}. name) , '/' , (": year) , '-' , (> month { months) , '/' , link , '.html'
)

convertToWikiUrl =: 3 : 0
NB. Title of the form /wiki/...
'https://code.jsoftware.com/mediawiki/index.php?title=' , (urlencode 6 }. y) , '&action=edit'
)

threads =: 3 : 0
while. (10 <. <: {: 8 T. '') > 1 T. '' do. 0 T. 0 end.
)

getHtml =: 3 : 0
NB. y urls
NB. Return a list of boxed html, one for each url
files =. (jpath '~temp/html/')&, &. > ,&'.html' &. > <@":"0 i. # y
urlSpec =. ; ('"'&, &. > ,&'"' &. > y) ,. <' '
smoutput urlSpec
outputSpec =. ; (<' -o ') ,. files
command =. 'curl ' , outputSpec , ' ' , urlSpec
try.
(2!:0) command
<@(1!:1)"0 files
catch.
smoutput (13!:12) ''
smoutput urlSpec
end.
)

spawnGetIndexedHtml =: 3 : 0
NB. y Indices into UrlTitles: indexUrl ; displayUrl ; title ; source
files =. (jpath '~temp/html/')&, &. > ,&'.html' &. > <@":"0 y
urlSpec =. ; ('"'&, &. > ,&'"' &. > 0 {"1 y { UrlTitles) ,. <' '
outputSpec =. ; (<' -o ') ,. files
command =. 'curl ' , outputSpec , ' ' , urlSpec , '&'
(2!:0) command
)

spawnServer =: 3 : 0
files =. {."1 (1!:0) < jpath '~temp/html/*.html'
indices =. > ". &. > -.&' '@": &. > a: -.~ < ;. _2 '0123456789' i. ; files
fullPaths =. jpath &. > '~temp/html/'&, &. > files
entriesWithHtml =. (indices { UrlTitles) ,. <@(1!:1)"0 fullPaths NB. indexUrl ; displayUrl ; title ; source ; html
forumEntries =. entriesWithHtml #~ (3 {"1 entriesWithHtml) = < 'F'
wikiEntries =. entriesWithHtml #~ (3 {"1 entriesWithHtml) = < 'W'
saveForumDocumentTime =. 0
saveWikiDocumentTime =. 0
if. 0 < # forumEntries do. saveForumDocumentTime =. saveForumDocument"(1) 1 2 4 {"1 forumEntries end.
if. 0 < # wikiEntries do. saveWikiDocumentTime =. saveWikiDocument"(1) 1 2 4 {"1 wikiEntries end.
(1!:55)"0 fullPaths
)

isUrlAlreadyProcessed =: 3 : 0
NB. y A url that may appear in the index database.
NB. Return 1 if it does.
* # > {: sqlreadm__db 'select url from url where url = "' , y , '"'
)

server =: 3 : 0
NB. y Unused
window =. 3
path =. jpath '~temp/html/'
while. 0 < # UrlTitles do.
	actualWindow =. window <. # UrlTitles
	entries =. actualWindow {. UrlTitles NB. indexUrl ; displayUrl ; title ; source
smoutput 'Processing ' ; # entries
	if. 0 < # entries do.
		getHtmlTime =. (6!:2) 'html =. getHtml 0 {"1 entries' 
		entriesWithHtml =. entries ,. html NB. indexUrl ; displayUrl ; title ; source ; html
		forumEntries =. entriesWithHtml #~ (3 {"1 entries) = < 'F'
		wikiEntries =. entriesWithHtml #~ (3 {"1 entries) = < 'W'
		saveForumDocumentTime =. 0
		saveWikiDocumentTime =. 0
		if. 0 < # forumEntries do. saveForumDocumentTime =. (6!:2) 'saveForumDocument"(1) 1 2 4 {"1 forumEntries' end.
		if. 0 < # wikiEntries do. saveWikiDocumentTime =. (6!:2) 'saveWikiDocument"(1) 1 2 4 {"1 wikiEntries' end.
	end.
	UrlTitles =: actualWindow }. UrlTitles
	smoutput 'getHtmlTime' ; getHtmlTime ; 'saveForumDocumentTime' ; saveForumDocumentTime ; 'saveWikiDocumentTime' ; saveWikiDocumentTime
	wd 'msgs'
end.
)

buildForumIndex =: 3 : 0
openForumDatabase ''
openIndexDatabase ''
result =. > {: sqlreadm__forumDb 'select subject, author, body, url, year from forums'
subjects =. ,&' ' &. > 0 {"1 result
authors =. ,&' ' &. > 1 {"1 result
bodies =. 2 {"1 result
urls =. 3 {"1 result
years =. > 4 {"1 result
combinedBodies =. translateToJEnglish &. > extractTextFromForumPost &. > <@;"1 subjects ,. authors ,. bodies
sqlinsert__indexDb 'jindex' ; (;: 'body') ; << combinedBodies
sqlinsert__indexDb 'auxiliary' ; (;: 'title year source url') ; < subjects ; years ; ((# years) # <'F') ; < urls
)

buildWikiIndex =: 3 : 0
openWikiDatabase ''
openIndexDatabase ''
result =. > {: sqlreadm__wikiDb 'select title, link, body from wiki'
titles =. 0 {"1 result
urls =. 1 {"1 result
bodies =. 2 {"1 result
combinedBodies =. translateToJEnglish &. > <@;"1 titles ,. bodies
data =. combinedBodies
sqlinsert__indexDb 'jindex' ; (;: ' body') ; << data
sqlinsert__indexDb 'auxiliary' ; (;: 'title year source url') ; < titles ; ((# urls) # 9999) ; ((# urls) # <'W') ; < urls
)

buildDatabase =: 3 : 0
createIndexDatabase ''
NB. openIndexDatabase ''
openWikiDatabase ''
openForumDatabase ''
forumResult =. > {: sqlreadm__wikiDb 'select forumname, year, month, subject, author, link from forums'
forumUrls =. convertToForumUrl"1 forumResult
forumTitles =. 3 {"1 forumResult
forumSieve =. -. > isUrlAlreadyProcessed &. > forumUrls
forumUrlTitles =. forumSieve # forumUrls ,. forumUrls ,. forumTitles ,. (< 'F')
smoutput # forumUrlTitles

wikiResult =. > {: sqlreadm__wikiDb 'select title, link from wiki'
wikiDisplayUrls =. 'https://code.jsoftware.com'&, &. > 1 {"1 wikiResult
wikiSieve =. -. > isUrlAlreadyProcessed &. > wikiDisplayUrls
wikiTitles =. 0 {"1 wikiResult
wikiIndexUrls =. convertToWikiUrl &. > wikiTitles
wikiUrlTitles =. wikiSieve # wikiIndexUrls ,. wikiDisplayUrls ,. wikiTitles ,. (< 'W')
smoutput # wikiUrlTitles

UrlTitles =: wikiUrlTitles , forumUrlTitles
UrlTitles =: UrlTitles #~ ~: 1 {"1 UrlTitles NB. indexUrl ; displayUrl ; title ; source
smoutput 'Url Count: ' ; # UrlTitles
server ''
)



NB. ======================== Wiki Cache Database ================================
initializeWikiDatabase =: 3 : 0
try. (1!:55) < wikiDbFile catch. end.
wikiDb =: sqlcreate_psqlite_ wikiDbFile
sqlcmd__wikiDb 'CREATE TABLE wiki (title, link, body)'
)

openWikiDatabase =: 3 : 0
wikiDb =: sqlopen_psqlite_ wikiDbFile
)

populateWikiDatabase =: 3 : 0
initializeWikiDatabase ''
openAddOnDatabase ''
try. addOnResult =. > {: sqlreadm__addOnDb 'select title, link from wiki' catch. catcht. smoutput sqlerror__addOnDb end.
indexUrls =. convertToWikiUrl &. > 1 {"1 addOnResult
displayUrls =. 'https://code.jsoftware.com'&, &. > 1 {"1 addOnResult
sieve =. ~: indexUrls
addOnTitles =. sieve # 0 {"1 addOnResult
indexUrls =. sieve # indexUrls
displayUrls =. sieve # displayUrls
postsToBeLoaded =. addOnTitles ,. indexUrls ,. displayUrls
window =. 100
cols =. ;: 'title link body'
while. 0 < # postsToBeLoaded do.
	actualWindow =. window <. # postsToBeLoaded
	postsInWindow =. actualWindow {. postsToBeLoaded
	smoutput 'Processing' ; # postsInWindow
	if. 0 < # postsInWindow do.
		html =. extractTextFromWikiArticle &. > getHtml 1 {"1 postsInWindow
		data =. ({."1 postsInWindow) ; (2 {"1 postsInWindow) ; < html
		sqlinsert__wikiDb 'wiki' ; cols ; < data
	end.
	postsToBeLoaded =. actualWindow }. postsToBeLoaded
	wd 'msgs'
end.
)
NB. ==================== End Wiki Cache Database ================================

NB. ======================== Forum Cache Database ================================
openForumDatabase =: 3 : 0
forumDb =: sqlopen_psqlite_ forumDbFile
)

populateForumDatabase =: 3 : 0
NB. Add any new forum posts to the forum cache database.
openForumDatabase ''
openAddOnDatabase ''
try. addOnResult =. > {: sqlreadm__addOnDb 'select forumname, year, month, subject, author, link from forums' catcht. smoutput slqerror__wikiDb '' end.
addOnUrls =. convertToForumUrl"1 addOnResult
try. forumUrls =. , > {: sqlreadm__forumDb 'select url from forums' catch. catcht. smoutput sqlerror__forumDb end.
postsToBeLoaded =. (sieve # addOnUrls) ,.~ ((sieve =. -. addOnUrls e. forumUrls) # addOnResult) 
window =. 100
cols =. ;: 'forumname year month subject author link url body'
smoutput '# postsToBeLoaded' ; (# postsToBeLoaded) ; '# forumUrls' ; (# forumUrls) ; '# addOnUrls' ; (# addOnUrls)
smoutput '$ postsToBeLoaded' ; ($ postsToBeLoaded) ; '$ addOnResult' ; ($ addOnResult)
while. 0 < # postsToBeLoaded do.
	actualWindow =. window <. # postsToBeLoaded
	postsInWindow =. actualWindow {. postsToBeLoaded 
	smoutput 'Processing ' ; # postsInWindow
	if. 0 < # postsInWindow do.
		html =. getHtml {:"1 postsInWindow
		augmentedPostsInWindow =. postsInWindow ,. html
		a =. augmentedPostsInWindow
		data =. (0 {"1 a) ; (> 1 {"1 a) ; (> 2 {"1 a) ; (3 {"1 a) ; (4 {"1 a) ; (5 {"1 a) ; (6 {"1 a) ; (< 7 {"1 a) 		
		sqlinsert__forumDb 'forums' ; cols ; < data
	end.
	postsToBeLoaded =. actualWindow }. postsToBeLoaded
	wd 'msgs'
end.
)

initializeForumDatabase =: 3 : 0
return.
try. (1!:55) < forumDbFile catch. smoutput (13!:12) '' end.
try.
	forumDb =: sqlcreate_psqlite_ forumDbFile
	sqlcmd__forumDb 'CREATE TABLE forums (forumname TEXT, year INTEGER, month INTEGER, subject TEXT, author TEXT, link TEXT, url TEXT, body TEXT)'
	sqlcmd__forumDb 'CREATE INDEX url_index ON forums (url)'
catcht.
smoutput sqlerror__forumDb ''
end.
NB. ====================== End Forum Database ==============================

)
