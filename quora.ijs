load 'web/gethttp'
load 'regex'
load 'data/sqlite'

dbFile =: jpath '~temp/loaddb/quora.db'
db =: ''

openOrCreateDatabase =: 3 : 0
NB. If necessary, create the quora database.  In any case, open it.
if. fexist dbFile do. 
	db =: sqlopen_psqlite_ dbFile
else.
	db =: sqlcreate_psqlite_ dbFile
	sqlcmd__db 'CREATE TABLE posts (link TEXT PRIMARY KEY, title TEXT, body TEXT, html TEXT)'
end.
)

parsePost =: 3 : 0
NB. (rxcomp '''og:title'' content=''(
)

encodeUrl =: 3 : 0
NB. y A url
NB. Return an encoded url
n =. urlencode y
n =. ('/';'%2f') rxrplc n
n =. (':';'%3A') rxrplc n
)

decodeHtml =: 3 : 0 
NB. y HTML with encoded characters.
NB. Return decoded HTML
s =. y
s =. ('&lt;';'<') rxrplc s
s =. ('&gt;';'>') rxrplc s
s =. ('&amp;';'&') rxrplc s
)

updateBody =: 4 : 0
NB. x a Url
NB. y The indexable body for the Url
try.
	sqlupdate__db 'posts' ; ('link = "' , x , '"') ; (;: 'link body') ; <  x ; y
catch. catcht. 
	smoutput 'Problem in updateBody: ' , (13!:12) ''
	smoutput 'DB error (if any): ' , sqlerror__db ''
end.
)

countPunctuation =: +/@e.&'`~!@#$%^&*+={}[];:><?/\|'
disallowedStrings =: 'function' ; 'window.' ; 'What' ; 'Brute' ; 'Find' ; 'Something' ; 'Internet'

checkChunk =: 3 : 0
NB. y A string.
NB. Return 0 if it contains any disallowed strings.
-. +./ +./ disallowedStrings e."1 0 (;: y -. '''')
)

extractBody =: 3 : 0
NB. y A string of html from an individual's Quora answer.  Return the text of the answer.
NB. pat =. '''og:description'' content=''(
pat =. rxcomp '>([^<]+)<'
html =. decodeHtml y
try.
	ol =. 1 {"2 pat rxmatches html
	chunks =. (1 {"1 ol) <@{."0 1 (0 {"1 ol) }."0 1 html 
	sieve1 =. (0&< *. 100&>) > # &. > chunks
	sieve2 =. 1 < > countPunctuation &. > chunks
	sieve3 =. > checkChunk &. > chunks
	chunks =. (sieve1 *. sieve2 *. sieve3) # chunks
NB.	smoutput (# &. > chunks) ,. 100{. &. > chunks
	' ' , ; chunks ,. < ' '
catch.
	' '
end.
)
 
getHtml =: {{
NB. y A url
NB. Return the raw html
NB. JScript: curl 'https://api.crawlbase.com/?token=JXODhIqe9SdsGFHeyeTGUQ&url=https%3A%2F%2Fgithub.com%2Fcrawlbase-source%3Ftab%3Drepositories'
NB. HTML: curl 'https://api.crawlbase.com/?token=VYb8a0W9wF1hk2BTgY5vQA&url=https%3A%2F%2Fgithub.com%2Fcrawlbase-source%3Ftab%3Drepositories'
NB. https://api.crawlbase.com/?token=JXODhIqe9SdsGFHeyeTGUQ&url=https%3A%2f%2fwww.quora.com%2fWhat-are-7-consecutive-primes-which-sum-to-the-same-number-when-the-digits-are-reversed%2fanswer%2fEllis-Cave&page_wait=2000&ajax_wait=true
NB. url =. 'https://www.quora.com/What-are-7-consecutive-primes-which-sum-to-the-same-number-when-the-digits-are-reversed/answer/Ellis-Cave'
NB. queryUrl =. 'https://api.crawlbase.com/?token=JXODhIqe9SdsGFHeyeTGUQ&url=https%3A%2f%2fwww.quora.com%2fWhat-are-7-consecutive-primes-which-sum-to-the-same-number-when-the-digits-are-reversed%2fanswer%2fEllis-Cave&page_wait=2000&ajax_wait=true'
queryUrl =. 'https://api.crawlbase.com/?token=JXODhIqe9SdsGFHeyeTGUQ&url=' , (encodeUrl y) , '&page_wait=2000&ajax_wait=true'
NB. queryUrl =. 'https://api.crawlbase.com/?token=JXODhIqe9SdsGFHeyeTGUQ&url=' , encodeUrl url
html =. gethttp queryUrl
NB. html (1!:2) < jpath '~temp/quoraOutput.html'
}}

processLink =: 3 : 0
NB. y A link to a Skip Cave Quora answer.
smoutput y
wd 'msgs'
title=. (- # '/answer/Ellis Cave') }. (# 'https://www.quora.com/') }. ('-';' ') rxrplc y
html =. getHtml y
NB. content =. parseHtml html
NB. smoutput content ; title ; y
sqlinsert__db 'posts' ; (;: 'link title html') ; < y ; title ; html
)

acquirePosts =: {{
openOrCreateDatabase ''
linksWeHave =. > {: sqlreadm__db 'select link from posts'
htmlFilenames =. jpath &. > '~temp/loaddb/quorahtml/'&, &. > {."1 (1!:0) < jpath '~temp/loaddb/quorahtml/*'
smoutput ,. htmlFilenames
report =. ; (1!:1)"0 htmlFilenames
pat =. rxcomp '"(https://[^"]+)"'
ol =. 1 {"2 pat rxmatches report
links =. linksWeHave -.~ ~. ({:"1 ol) <@{."0 1 ({."1 ol) }."0 1 report
sieve =: > +./@:('Ellis-Cave'&E.) &. > links
goodLinks =. sieve # links
smoutput '$ goodLinks' ; ($ goodLinks) ; 'size' ; (# report)
processLink &. > goodLinks
}}

extractBodies =: {{
openOrCreateDatabase ''
records =. > {: sqlreadm__db 'select link, html from posts'
bodies =. extractBody &. > 1 {"1 records
sqlcmd__db 'begin transaction'
({."1 records) updateBody &. > bodies
sqlcmd__db 'commit transaction'
smoutput (# bodies) , +/ a: = bodies
}}

