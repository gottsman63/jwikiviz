load 'data/sqlite'
load 'web/gethttp'

load 'regex'

indexDbFile =: '~temp/jsearch.db'

jEnglishDict =: _2 ]\ '=' ; 'eq' ; '=.' ; 'eqdot' ; '=:' ; 'eqco' ; '<' ; 'lt' ; '<.' ; 'ltdot' ; '<:' ; 'ltco' ;  '>' ; 'gt' ; '>.' ; 'gtdot' ; '>:' ; 'gtco' ; '_' ; 'under' ; '_.' ; 'underdot' ; '_:' ; 'underco' ; '+' ; 'plus' ; '+.' ; 'plusdot' ; '+:' ; 'plusco' ; '*' ; 'star'  ;  '*.' ; 'stardot'  ; '*:' ; 'starco' ; '-' ; 'minus' ; '-.' ; 'minusdot' ; '-:' ; 'minusco' ; '%' ; 'percent' ; '%.' ; 'percentdot' ; '%:' ; 'percentco' ; '^' ; 'hat' ; '^.' ; 'hatdot' ; '^:' ; 'hatco' ; '$' ; 'dollar' ; '$.' ; 'dollardot' ; '$:' ; 'dollarco' ; '~' ; 'tilde' ;  '~.' ; 'tildedot'  ; '~:' ; 'tildeco' ; '|' ; 'bar' ; '|.' ; 'bardot' ; '|:' ; 'barco' ; '.'  ; 'dot' ; ':.' ; 'codot' ; '::' ; 'coco' ; ',' ; 'comma' ; ',.' ; 'commadot' ; ',:' ; 'commaco' ; ';' ; 'semi' ; ';.' ; 'semidot' ; ';:' ; 'semico' ; '#' ; 'number' ; '#.' ; 'numberdot' ; '#:' ; 'numberco' ; '!' ; 'bang' ; '!.' ; 'bangdot' ; '!:' ; 'bangco' ; '/' ; 'slash' ; '/.' ; 'slashdot' ; '/:' ; 'slashco' ; '\' ; 'bslash' ; '\.' ; 'blsashdot' ; '\:' ; 'bslashco' ; '[' ; 'squarelf' ; '[.' ; 'squarelfdot' ; '[:' ; 'squarelfco' ; ']' ; 'squarert' ; '].' ; 'squarertdot' ; ']:' ; 'squarertco' ; '{' ; 'curlylf' ; '{.' ; 'curlylfdot' ; '{:' ; 'curlylfco' ; '{::' ; 'curlylfcoco' ; '}' ; 'curlyrt' ;  '}.' ; 'curlyrtdot' ; '}:' ; 'curlyrtco' ; '{{' ; 'curlylfcurlylf' ; '}}'  ; 'curlyrtcurlyrt' ; '"' ; 'quote' ; '".' ; 'quotedot' ; '":' ; 'quoteco' ; '`' ; 'grave' ; '@' ; 'at' ; '@.' ; 'atdot' ; '@:' ; 'atco' ; '&' ; 'ampm' ; '&.' ; 'ampmdot' ; '&:' ; 'ampmco' ; '?' ; 'query' ; '?.' ; 'querydot' ; 'a.' ; 'adot' ; 'a:' ; 'aco' ; 'A.' ; 'acapdot' ; 'b.' ; 'bdot' ; 'D.' ; 'dcapdot' ; 'D:' ; 'dcapco' ; 'e.' ; 'edot' ; 'E.' ; 'ecapdot' ; 'f.' ; 'fdot' ; 'i.' ; 'idot' ; 'i:' ; 'ico' ; 'I.' ; 'icapdot' ; 'I:' ; 'icapco'
jMnemonics =: , &. > 0 {"1 jEnglishDict
jEnglishWords =: 'J'&, &. > 1 {"1 jEnglishDict
  
dbError =: 3 : 0
sqlerror__db ''
)

createIndexDatabase =: 3 : 0
try. (1!:55) < indexDbFile catch. end.
try.
	db =: sqlcreate_psqlite_ indexDbFile
	sqlcmd__db 'CREATE VIRTUAL TABLE jindex USING FTS5 (title, linksource, partiallink, body)'
catcht.
smoutput sqlerror__db ''
end.
)

openIndexDatabase =: 3 : 0
db =: sqlopen_psqlite_ indexDbFile
)

extractTextFromForumPost =: 3 : 0
NB. y The text of a Forum post
startPost =. '<!--beginarticle-->'
endPost =. '<!--endarticle-->'
try.
result =. p {.~ I. endPost E. p =. ((# startPost) + I. startPost E. y) }. y
catch.
smoutput 'Failure!'
smoutput y
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
result =. > {: sqlreadm__db 'select title, snippet(jindex, 2, '''', '''', '''', 10), url from jindex where body MATCH ''' , query , ''' order by rank'
smoutput 1 {"1 result
snippets =. translateToJ &. > 1 {"1 result
(0 {"1 result) ,. snippets ,. 2 {"1 result
)

saveDocument =: 3 : 0
NB. y url ; title ; linkSource ; partialLink ; html
'url title linkSource partialLink html' =. y
cols =. ;: 'title linksource partiallink body'
text =: extractTextFromForumPost html
jEnglishText =. translateToJEnglish title , ' ' , text
sqlinsert__db 'jindex' ; cols ; < title ; linkSource ; partialLink ; jEnglishText
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

threads =: 3 : 0
while. (10 <. <: {: 8 T. '') > 1 T. '' do. 0 T. 0 end.
)

getHtml =: 3 : 0
NB. y urls
NB. Return a list of boxed html, one for each url
files =. (jpath '~temp/html/')&, &. > ,&'.html' &. > <@":"0 i. # y
urlSpec =. ; y ,. <' '
outputSpec =. ; (<' -o ') ,. files
command =. 'curl ' , outputSpec , ' ' , urlSpec
(2!:0) command
<@(1!:1)"0 files
NB. (2!:0) 'curl -O "' , jpath '~temp/html/' , (": y) , '.html" ' , (> 0 { y { UrlTitles) NB. , '&'
)

server =: 3 : 0
window =. 50
path =. jpath '~temp/html/'
while. 0 < # UrlTitles do.
	actualWindow =. window <. # UrlTitles
	entries =. actualWindow {. UrlTitles NB. url ; title ; source ; partialLink
	getHtmlTime =. (6!:2) 'html =. getHtml 0 {"1 entries'
	saveDocumentTime =. (6!:2) 'saveDocument"1 entries ,. html'
	UrlTitles =: actualWindow }. UrlTitles
	smoutput 'getHtmlTime' ; getHtmlTime ; 'saveDocumentTime' ; saveDocumentTime
	wd 'msgs'
end.
)

buildDatabase =: 3 : 0
createIndexDatabase ''
NB. openIndexDatabase ''
wikiDb =: sqlopen_psqlite_ '~temp/jwikiviz.db'
NB. result2 =. > {: sqlreadm__wikiDb 'select title, link from wiki '
NB. urls2 =. 'https://code.jsoftware.com/'&, &. > 1 {"1 result2
NB. (0 {"1 result2) saveUrl &. > urls2
forumResult =: > {: sqlreadm__wikiDb 'select forumname, year, month, subject, author, link from forums'
partialForumLinks =. 5 {"1 forumResult
NB. alreadyLoadedPartialLinks =. > {: sqlreadm__db 'select partiallink from jindex where linksource = "F"'
NB. (partialLinks i. alreadyLoadedPartialLinks) -. # partialLinks
forumUrls =: convertToForumUrl"1 forumResult
forumTitles =: 3 {"1 forumResult
UrlTitles =: forumUrls ,. forumTitles ,. (< 'F') ,. partialForumLinks
smoutput 5 {. UrlTitles
server ''
)
