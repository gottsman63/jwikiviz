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

createDatabase =: 3 : 0
try. (1!:55) < indexDbFile catch. end.
try.
	db =: sqlcreate_psqlite_ indexDbFile
	sqlcmd__db 'CREATE VIRTUAL TABLE jindex USING FTS5 (title, url, body)'
catcht.
smoutput sqlerror__db ''
end.
)

extractText =: 3 : 0
NB. y HTML from which to extract plain text
NB. Return plain text
pat =. '<(?:"[^"]*"[''"]*|''[^'']*''[''"]*|[^''">])+>'
raw =. (pat ; '') rxrplc y
('&amp;' ; '&') rxrplc y
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

saveUrl =: 4 : 0
NB. x The title of a document to index
NB. y The URL of a document to index
cols =. ;: 'title url body'
html =. gethttp y
text =: extractText html
jEnglishText =. translateToJEnglish text
sqlinsert__db 'jindex' ; cols ; < x ; y ; jEnglishText
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

buildDatabase =: 3 : 0
createDatabase ''
wikiDb =: sqlopen_psqlite_ '~temp/jwikiviz.db'
NB. result2 =. > {: sqlreadm__wikiDb 'select title, link from wiki '
NB. urls2 =. 'https://code.jsoftware.com/'&, &. > 1 {"1 result2
NB. (0 {"1 result2) saveUrl &. > urls2
result =. > {: sqlreadm__wikiDb 'select forumname, year, month, subject, author, link from forums'
urls =. convertToForumUrl"1 result
(3 {"1 result) saveUrl &. > urls
)
