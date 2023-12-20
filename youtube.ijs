load 'data/sqlite'
load 'web/gethttp'
load 'convert/json'

dbFile =: jpath '~temp/loaddb/youtube.db'
db =: ''

getTranscript =: 3 : 0
NB. y A YouTube identifier.
NB. Return the title ; description ; transcript.
(6!:3) 1
try.
	token =. (1!:1) < jpath '~temp/loaddb/transcribetoken.txt'
	left =. '-H "X-Rapidapi-Key: ' , token , '" -H "X-Rapidapi-Host: youtube-transcriptor.p.rapidapi.com"' 
	k =. left gethttp 'https://youtube-transcriptor.p.rapidapi.com/transcript?video_id=' , y , '&lang=en'
	data =. dec_json k
	title =. > 0 { 1 { 0 { > data
	description =. > 1 { 1 { 0 { > data
	if. 0 = # description do. description =. ' ' end.
	transcript =. ; ": &. > , (<' ') ,. > {.@{: &. > > 5 { 1 { 0 { > data
	title ; description ; transcript
catch.
	a: , a: , a:
end.
)

getIds =: 3 : 0
NB. Return a list of YouTube IDs ; Titles derived from the video list page in code.jsoftware.com's wiki.
html =. gethttp 'https://code.jsoftware.com/mediawiki/index.php?title=VideoInstructionInJ&action=edit'
pat =. rxcomp 'www.youtube.com/watch\?v=(\S\S\S\S\S\S\S\S\S\S\S)\S*\s(.*)]'
ols =. 1 2 {"2 pat rxmatches html
p1 =. 0 {"2 ols
ids =. ({:"1 p1) <@{."0 1 ({."1 p1) }."0 1 html
p2 =. 1 {"2 ols
titles =. ({:"1 p2) <@{."0 1 ({."1 p2) }."0 1 html
sieve =. ~: ids
(sieve # ids) ,. sieve # titles
)

openOrCreateDatabase =: 3 : 0
NB. If necessary, create the YouTube database.  In any case, open it.
if. fexist dbFile do. 
	db =: sqlopen_psqlite_ dbFile
else.
	db =: sqlcreate_psqlite_ dbFile
	sqlcmd__db 'CREATE TABLE videos (link TEXT PRIMARY KEY, title TEXT, description TEXT, transcript TEXT)'
end.
)

processVideoId =: 3 : 0
NB. y A YouTube identifier ; A default title
'id defaultTitle' =. y
link =. 'https://www.youtube.com/watch?v=' , id
if. 0 < # > {: sqlreadm__db 'select * from videos where link = "' , link , '"' do. smoutput 'Skipping ' ; y return. end.
'title description transcript' =. getTranscript id
if. 0 = # title do. 
	title =. defaultTitle
	description =. ' '
	transcript =. ' '
end.
try.
	smoutput title ; description ; transcript
	sqlinsert__db 'videos' ; (;: 'link title description transcript') ; <  link ; title ; description ; < transcript
catch. catcht. 
	smoutput 'Problem in processVideoId: ' , (13!:12) ''
	smoutput 'DB error (if any): ' , sqlerror__db ''
end.
)

gotube =: 3 : 0
openOrCreateDatabase ''
for_id. getIds '' do.
	smoutput id
	wd 'msgs'
	processVideoId id
end.
)