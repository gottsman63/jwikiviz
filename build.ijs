NB. Build

NB. writesource_jp_ '~Projects/jwikiviz';'~Projects/jwikiviz/release/jwikiviz.ijs'

NB. builds.ijs

PDIR=: jpath'~Projects/jwikiviz/'

LIBS=: 0 : 0
ide/qt/gl2
data/sqlite
web/gethttp
regex
)

TARGETHEADER=: 0 : 0
NB. JWikiViz 1.0

)

TARGETFILE=: 'jwikiviz.ijs'

TARGETEXTRA=: 'view_run'''''

builds=: 3 : 0
load PDIR,'build.ijs'
out=. TARGETHEADER
out=. out, getstdenv_jp_''
out=. out, getlibs_jp_ LIBS
out=. out,freads PDIR,'jwikiviz.ijs'
out=. out,TARGETEXTRA,LF
out fwrites PDIR,'JViz.ijs'
)

builds''
