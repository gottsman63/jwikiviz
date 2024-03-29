load 'data/sqlite'
load 'web/gethttp'
load 'convert/pjson'
load 'regex'

indexDbFile =: jpath '~temp/jsearch.db'
forumDbFile =: jpath '~temp/forum.db'
wikiDbFile =: jpath '~temp/wiki.db'

jEnglishDict =: _2 ]\ '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'F:.' ; 'fcapcodot' ; 'F::' ; 'fcapcoco' ; 'F:' ; 'fcapco' ; 'F..' ; 'fcapdotdot' ; 'F.:' ; 'fcapdotco' ; 'F.' ; 'fcapdot' ; 'H.' ; 'hcapdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco' ; 'j.' ; 'jdot' ; 'L.' ; 'lcapdot' ; 'L:' ; 'lcapco' ; 'm.' ; 'mdot' ; 'M.' ; 'mcapdot' ; 'NB.' ; 'ncapbcapdot' ; 'o.' ; 'odot' ; 'p.' ; 'pdot' ; 'p:' ; 'pco' ; 'q:' ; 'qco' ; 'r.' ; 'rdot' ; 's:' ; 'sco' ; 't.' ; 'tdot' ; 'T.' ; 'tcapdot' ; 'u:' ; 'uco' ; 'x:' ; 'xco' ; 'Z:' ; 'zcapco' ; 'assert.' ; 'assertdot' ; 'break.' ; 'breakdot' ; 'continue.' ; 'continuedot' ; 'else.' ; 'elsedot' ; 'elseif.' ; ' elseifdot' ; 'for.' ; 'fordot' ; 'if.' ; 'ifdot' ; 'return.' ; 'returndot' ; 'select.' ; 'selectdot' ; 'case.' ; 'casedot' ; 'fcase.' ; 'fcasedot' ; 'try.' ; 'trydot' ; 'catch.' ; 'catchdot' ; 'catchd.' ; 'catchddot' ; 'catcht.' ; 'catchtdot' ; 'while.' ; 'whiledot' ; 'whilst.' ; 'whilstdot'         
jMnemonics =: , &. > 0 {"1 jEnglishDict
jEnglishWords =: 'J'&, &. > 1 {"1 jEnglishDict
wordsToTranslate =: _2 ]\ 'gt' ; '>' ; 'lt' ; '<' ; 'quot' ; '"' ; 'amp' ; '&'

createIndexDatabase =: 3 : 0
try. (1!:55) < indexDbFile catch. end.
try.
	indexDb =: sqlcreate_psqlite_ indexDbFile
NB.	sqlcmd__indexDb 'CREATE VIRTUAL TABLE jindex USING FTS5 (body, content=''''	)'
	sqlcmd__indexDb 'CREATE VIRTUAL TABLE jindex USING FTS5 (body)'
	sqlcmd__indexDb 'CREATE TABLE auxiliary (title TEXT, year INTEGER, source TEXT, url TEXT)'
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
startIndex =. (# startPost) + I. startPost E. y
endIndex =. I. endPost E. y
result =. (startIndex + # startIndex) }. endIndex {. y
catch.
smoutput 'extractTextFromForumPost failure!'
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
tokens =. ;: y -. ''''
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

translateWords =: 3 : 0
NB. y Text with words that should be punctuation
NB. Convert the words to punctuationo
rawTokens =. ;: y
hits =. ({."1 wordsToTranslate) i."1 0 rawTokens
; (hits {"0 1 ({:"1 wordsToTranslate) ,"1 0 rawTokens) ,. < ' '
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
NB. y Boxed urls
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

exportForums =: 3 : 0
openAddOnDatabase ''
rows =. > {: sqlreadm__addOnDb 'select forumname, year, month, subject, author, link from forums'
)

populateForumDatabase =: 3 : 0
NB. Add any new forum posts to the forum cache database.
openForumDatabase ''
openAddOnDatabase ''
try. addOnResult =. > {: sqlreadm__addOnDb 'select forumname, year, month, subject, author, link from forums' catcht. smoutput slqerror__addonDb '' end.
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
)

jsearchUser =: 'jsearchuser'
jsearchPassword =: 'Jsearch1!'
jsearchUrl =: 'https://search-jsearch-widrwfxb2alpzurmhbe2jyvcjm.eu-north-1.es.amazonaws.com/jsearch/'

convertPostToJson =: 3 : 0
NB. y forumname ; year ; month ; subject ; author ; url ; body
NB. Determine the day of the month for the post.
NB. Return a JSON string.
'forumName year month day subject author body' =. y
coreBody =. translateToJEnglish suppressUnicode 5 }. extractTextFromForumPost body
json =. enc_pjson_ ('forum' ; forumName) , ('year' ; year) , ('month' ; month) , ('day' ; day) , ('subject' ; subject) , ('author' ; author) ,: ('body' ; coreBody)
(json -. LF) , LF
)

suppressUnicode =: 3 : 0
NB. y A string that may contain characters above a.
y
NB.(a. i. y) { a. , '_'
)

extractDayOfMonth =: 3 : 0
NB. y Body of raw post
ol =. {: (rxcomp '<BR>[^<]*<I>\w\w\w\s\w\w\w\s+(\d+)\s') rxmatch y
". ({: ol) {. ({. ol) }. y
)

getAwsUrls =: 3 : 0
query =. '{"query": {"match_all": {}}, "_source":false}'
smoutput query
command =. 'curl -X GET -u "' , jsearchUser , ':' , jsearchPassword , '" ' , jsearchUrl , '_search --data-binary ''' , query , ''' -H "Content-Type: application/json"'
j =. dec_pjson_ (2!:0) command
NB. 1{"(1) 1 {"2 > > {: 2 { > {: 3 { j
)

populateAwsPage =: 4 : 0
NB. x Window
NB. y Page index
posts =. > {: sqlreadm__forumDb 'select forumname, year, month, subject, author, url, body from forums limit ' , (": x) , ' offset ' , ": y * x
bodies =. 6 {"1 posts
urls =. 5 {"1 posts
days =. extractDayOfMonth &. > bodies
docJson =. convertPostToJson &. > <"1 (0 1 2 {"1 posts) ,. days ,. 3 4 6 {"1 posts
commandJson =. '{"index":{"_index":"jsearch", "_id":"'&, &. > ,&('"}}' , LF) &. >  urls
json =. ; , commandJson ,. docJson
json (1!:2) < path =. jpath '~temp/index.json' 
command =. 'curl -X POST -u "' , jsearchUser , ':' , jsearchPassword , '" ' , jsearchUrl , '_bulk --data-binary @' , path , ' -H "Content-Type: application/json"' NB. ;charset=UTF-8"'
(2!:0) command
smoutput 'page index done' ; y
wd 'msgs'
NB. k =: ,. > {: 2 { dec_pjson_ (2!:0) command
)

populateAws =: 3 : 0
openForumDatabase ''
NB. rawPosts =. > {: sqlreadm__forumDb 'select forumname, year, month, subject, author, url, body from forums limit 100 offset 7000'
NB. smoutput rawPosts
NB. page =. 0
NB. indexedUrls =. ''
NB. while. 0 < # pageOfIndexedUrls =. getAwsUrls page do.	
NB. 	indexedUrls =. indexedUrls , pageOfIndexedUrls
NB. 	page =. >: page
NB. end.
NB. indexedUrls =: getAwsUrls ''
NB. smoutput 'AWS has document count' ; # indexedUrls
NB. postGroups =. _10 <\ (s =. -. rawUrls e. indexedUrls) # rawPosts
NB. smoutput s
NB. postGroups =. _10 <\ rawPosts
NB. smoutput '$ &. > postGroups' ; $ &. > postGroups
window =. 1000
maxPageCount =. >. window %~ , > > {: sqlreadm__forumDb 'select count(*) from forums'
smoutput 'maxPageCount' ; maxPageCount
pages =. 104 }. i. maxPageCount
smoutput 'pages' ; pages
window&populateAwsPage"(0) pages
)

createQuery =: 4 : 0
NB. x Earliest year to return
NB. y Text with J mnemonics and English words
NB. Convert the J mnemonics to JEnglish.
rawTokens =. ;: y
hits =. jMnemonics i."1 0 rawTokens
tokens =. hits {"0 1 jEnglishWords ,"1 0 rawTokens
englishPortion =. tokens -. jEnglishWords
jPortion =. tokens -. englishPortion
if. 0 < # englishPortion do. englishText =. ; ,&' ' &. > englishPortion else. englishText =. '' end.
if. 0 < # jPortion do. jText =. '\"' , (; ,&' ' &. > jPortion) , '\"' else. jText =. '' end.
if. (0 = # englishPortion) +. 0 = # jPortion do. and =. '' else. and =. ' AND ' end.
NB. '{"query": {"query_string": {"query": "\" ' , (; ,&' ' &. > jPortion) , ' \" AND ' , (; ,&' ' &. > englishPortion) , '"}}}'
NB. '{"_source":true, "query": {"query_string": {"query": "' , jText , and , englishText , ' "}}, "highlight": {"fields": {"body": {}}}}'
NB. '{"_source":true, "query": {"query_string": {"query": "' , jText , and , englishText , ' "}}, "range": {"_source.year": {"gte": 2005, "lte": 9999}},  "highlight": {"fields": {"body": {}}}}'
'{"_source":true, "query": {"query_string": {"query": "year:>=' , (": x) , ' AND ' , jText , and , englishText , ' "}}, "highlight": {"fields": {"body": {}}}}'
)

drill =: 4 : 0
NB. x A dot-notation label such as hits.total.value
NB. y A possibly-nested boxed structure whose left column has labels.
NB. Return the right box of the row whose left box contains the label x, drilling down at dots as necessary
labels =. < ;. _2 x , '.'
index =. ({."1 y) i. {. labels
if. index = # y do. 
	smoutput x , ' not found in box structure:'
	smoutput y
	a:
	return.
end.
if. 1 = # labels do.
	> {:"1 index { y
else.
	(}: ; ,&'.' &. > }. labels) drill > {:"1 index { y
end.
)

removeEmphasis =: 3 : 0
NB. y A phrase that may contain <em> tags.
('</em>';'') rxrplc ('<em>';'') rxrplc y
)

NB. https://opensearch.org/docs/latest/query-dsl/term/
NB. https://www.elastic.co/guide/en/elasticsearch/reference/current/search-fields.html # Suppress _source.
queryAws =: 4 : 0
NB. x Earliest year to return
NB. y Query string
query =. x createQuery y
smoutput query
NB. command =. 'curl -X GET -u "' , jsearchUser , ':' , jsearchPassword , '" ' , jsearchUrl , '_search --data-binary ''' , query , ''' -H "Content-Type: application/json"'
NB. command =. 'curl -X GET -u "' , jsearchUser , ':' , jsearchPassword , '" ' , 'https://xtidys25oj7v2loguchudxg6by0qrgvq.lambda-url.eu-north-1.on.aws/' , '_search --data-binary ''' , query , ''' -H "Content-Type: application/json"'
command =. 'curl -X POST -u "' , jsearchUser , ':' , jsearchPassword , '" ' , 'https://uslvuzgai5.execute-api.eu-north-1.amazonaws.com/test --data-binary ''' , query , ''' -H "Content-Type: application/json"'
NB. (2!:0) 'curl -X GET ' , 'https://xtidys25oj7v2loguchudxg6by0qrgvq.lambda-url.eu-north-1.on.aws?query=Hahahahaha'
smoutput command
time =. (6!:2) 'result =. (2!:0) command'
smoutput _180 ]\ result
return.
boxes =. dec_pjson_ result
smoutput boxes
if. 4 ~: # boxes do. 
	boxes
else.
	hits =. 'hits.hits' drill boxes
	hitCount =. 'hits.total.value' drill boxes
	titles =. translateWords &. > translateToJ &. > removeEmphasis &. > '_source.subject'&drill &. > hits
	years =. '_source.year'&drill &. > hits
	highlights =. translateWords &. > translateToJ &. > removeEmphasis &. > > {. &. > 'highlight.body'&drill &. > hits
end.
smoutput 'time' ; time ; 'json size' ; (# result) ; 'hitCount' ; hitCount
titles ,. highlights ,. years
)
NB. ====================== End Forum Database ==============================
