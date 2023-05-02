NB. JWikiViz 1.0

18!:4 <'z'
3 : 0 ''

JLIB=: '9.4.22'

notdef=. 0: ~: 4!:0 @ <
hostpathsep=: ('/\'{~6=9!:12'')&(I. @ (e.&'/\')@] })
jpathsep=: '/'&(('\' I.@:= ])})
winpathsep=: '\'&(('/' I.@:= ])})
PATHJSEP_j_=: '/'
IFDEF=: 3 : '0=4!:0<''DEF'',y,''_z_'''
IF64=: 16={:$3!:3[2
IFBE=: 'a'~:{.2 (3!:4) a.i.'a'
'IFUNIX IFWIN IFWINCE'=: 5 6 7 = 9!:12''
IFJHS=: 0
IFWINE=: (0 ~: 'ntdll wine_get_version >+ x'&(15!:0)) ::(0:@(15!:10))`0:@.IFUNIX ''
if. notdef 'IFIOS' do.
  IFIOS=: 0
end.
if. notdef 'IFJA' do.
  IFJA=: 0
end.
if. notdef 'IFJNET' do.
  IFJNET=: 0
end.
if. notdef 'BINPATH' do.
  BINPATH=: '/j/bin'
end.
if. notdef 'UNAME' do.
  if. IFUNIX do.
    if. -.IFIOS do.
      if. 'wasm'-:4{.9!:56 ::('Unknown'"_)'cpu' do.
        UNAME=: 'Wasm'
      else.
        UNAME=: (2!:0 ::('Unknown'"_)'uname')-.10{a.
      end.
    else.
      UNAME=: 'Darwin'
    end.
  elseif. do.
    UNAME=: 'Win'
  end.
end.
if. notdef 'LIBFILE' do.
  LIBFILE=: BINPATH,'/',IFUNIX{::'j.dll';(UNAME-:'Darwin'){::'libj.so';'libj.dylib'
end.
if. notdef 'FHS' do.
  FHS=: IFUNIX>'/'e.LIBFILE
end.
if. notdef 'RUNJSCRIPT' do.
  RUNJSCRIPT=: 0
end.
if. notdef 'IFRASPI' do.
  if. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') do.
    IFRASPI=: (<9!:56'cpu') e. 'arm';'arm64'
  else.
    IFRASPI=: 0
  end.
end.
if. IF64 +. IFIOS do.
  IFWOW64=: 0
else.
  if. IFUNIX do.
    IFWOW64=: '64'-:_2{.(2!:0 ::(''"_)(UNAME-:'Android'){::'uname -m';'getprop ro.product.cpu.abi')-.10{a.
  else.
    IFWOW64=: 'AMD64'-:2!:5'PROCESSOR_ARCHITEW6432'
  end.
end.
if. notdef 'IFQT' do.
  IFQT=: 0
  libjqt=: IFUNIX{::'jqt.dll';'libjqt',(UNAME-:'Darwin'){::'.so';'.dylib'
  if. 0 ~: 1!:4 :: 0: < ((BINPATH,'/')&,) libjqt do.
    libjqt=: ((BINPATH,'/')&,) libjqt
  end.
end.
if. UNAME-:'Android' do.
  AndroidLibPath=: '/lib',~ ({.~i:&'/')^:2 BINPATH
end.

assert. IFQT *: IFJA
)
jcwdpath=: jpathsep@(1!:43@(0&$) ,`(, }.)@.(('/' = {:)@:[ *. ('/' = {.)@:]) ])@((*@# # '/'"_) , ])
jsystemdefs=: 3 : 0
xuname=. UNAME
if. 0=4!:0 <f=. y,'_',(tolower xuname),(IF64#'_64'),'_j_' do.
  0!:100 toHOST f~
else.
  0!:0 <jpath '~system/defs/',y,'_',(tolower xuname),(IF64#'_64'),'.ijs'
end.
)
18!:4 <'j'

setjdefs=: 4 : 'if. _1=4!:0 y do. (>y)=: x end.'

1 setjdefs"_ 0 <;._2 [ 0 : 0
RGBSEQ
)

(0 2$<'') setjdefs"_ 0 <;._2 [ 0 : 0
SystemFolders
UserFolders
)

3 : 0''
if. (<'bin') -.@e. {."1 SystemFolders do.
  SystemFolders=: SystemFolders, 'bin';BINPATH
end.

if. (<'home') -.@e. {."1 SystemFolders do.
  if. 'Win'-:UNAME do. t=. 2!:5'USERPROFILE'
  elseif. 'Android'-:UNAME do. t=. '/sdcard'
  elseif. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD';'Darwin') do. t=. (0-:t){::'';~t=. 2!:5'HOME'
  elseif. do. t=. ''
  end.
  if. (''-:t)+.((,'/')-:t)+.('/root'-:t)+.('/usr/'-:5{.t) do.
    t=. '/tmp/',":2!:6''
    1!:5 ::] <t
  end.
  SystemFolders=: SystemFolders, 'home';t
end.

if. (<'temp') -.@e. {."1 SystemFolders do.
  if. 'Win'-:UNAME do. 1!:5 ::] <t=. (2!:5'USERPROFILE'),'\Temp'
  elseif. 'Android'-:UNAME do. t=. '/sdcard'
  elseif. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD';'Darwin') do. 1!:5 ::] <t=. '/tmp/',":2!:6''
  elseif. do. t=. ''
  end.
  SystemFolders=: SystemFolders, 'temp';t
end.
''
)

4!:55 <'setjdefs'

18!:4 <'z'
18!:4 <'z'
UNXLIB=: ([: <;._1 ' ',]);._2 (0 : 0)
libc.so.6 libc.so.7 libc.so.7 libc.so libc.dylib libc.so
libz.so.1 libz.so.7 libz.so.6 libz.so libz.dylib libz.so
libsqlite3.so.0 libsqlite3.so.0 libsqlite3.so.0 libsqlite.so libsqlite3.dylib libsqlite3.so
libxml2.so.2 libxml2.so.18.0 libxml2.so.2 libxml2.so libxml2.dylib libxml2.so
libpcre2-8.so.0 libpcre2-8.so.0.6 libpcre2-8.so.0 libpcre2-8.so libpcre2-8.dylib libpcre2-8.so
)
3 : 0^:((<UNAME)e.'Linux';'OpenBSD';'FreeBSD')''
b=. (<UNAME)i.~'Linux';'OpenBSD';'FreeBSD'
a=. 2!:0 ::(''"_) b{::'/sbin/ldconfig -p';'/sbin/ldconfig -r';'/sbin/ldconfig -r'
if. #a1=. I. '/libc.so.' E. a do.
  UNXLIB=: (<({.~i.&(10{a.))}.a}.~{.a1) (<0,b)}UNXLIB
end.
if. #a1=. I. '/libz.so.' E. a do.
  UNXLIB=: (<({.~i.&(10{a.))}.a}.~{.a1) (<1,b)}UNXLIB
end.
if. #a1=. I. '/libsqlite3.so.' E. a do.
  UNXLIB=: (<({.~i.&(10{a.))}.a}.~{.a1) (<2,b)}UNXLIB
end.
if. #a1=. I. '/libxml2.so.' E. a do.
  UNXLIB=: (<({.~i.&(10{a.))}.a}.~{.a1) (<3,b)}UNXLIB
end.
if. #a1=. I. '/libpcre2-8.so.' E. a do.
  UNXLIB=: (<({.~i.&(10{a.))}.a}.~{.a1) (<4,b)}UNXLIB
end.
''
)
unxlib=: 3 : 0
r=. (;: 'c z sqlite3 libxml2 pcre2') i. <,y
c=. (;: 'Linux OpenBSD FreeBSD Android Darwin') i. <UNAME_z_
(<r,c) {:: UNXLIB_z_
)
18!:4 <'z'
anddf=: 4 : '''libj.so android_download_file > i *c *c'' 15!:0 x;y'
andunzip=: 3 : 0
'' andunzip y
:
'libj.so java_unzip_file > i *c *c' 15!:0 y;x
)
android_exec_am=: 3 : 0
'intent uri mimetype flags'=. 4{.y
user=. (UserNumber_ja_"_)^:(0=4!:0<'UserNumber_ja_') (_1)
2!:0 ::0: utf8 'am start ',((user>:0)#'--user ', ":user),' -a ', intent, ' -d ', (dquote uri), ((*#mimetype)#' -t ', mimetype), ((0~:flags)#' -f ', ":flags)
i.0 0
)

android_exec_host=: 2!:1@(3&{.)`android_exec_am@.(0=4!:0<'AndroidPackage')
android_getdisplaymetrics=: 3 : 0
dm=. 0 2 320 1280 2 720 243.247 244.273
if. 18<:APILEVEL_ja_ do.
  if. 0=4!:0<'android_getdisplaymetrics_memo_ja_' do.
    dm=. android_getdisplaymetrics_memo_ja_
  else.
    try.
      densityDpi=. 0&". ' '-.~ (}.~ i:&' ') LF-.~ 2!:0 'wm density'
      ('widthPixels heightPixels')=: 0&". ;._1 'x', ' '-.~ (}.~ i:&' ') LF-.~ 2!:0 'wm size'
      density=. (0.5*heightPixels>480) + (0.5*heightPixels>320) + densityDpi% 160
      dm=. 1 2 3 4 5 (density, densityDpi, heightPixels, density, widthPixels)}dm
    catch. end.
    android_getdisplaymetrics_memo_ja_=: dm
  end.
end.
'DM_density_ja_ DM_densityDpi_ja_ DM_scaledDensity_ja_'=: 1 2 4{dm
dm
)
18!:4 <'z'
'TAB LF FF CR DEL EAV'=: 9 10 12 13 127 255{a.
LF2=: LF,LF
CRLF=: CR,LF
EMPTY=: 0 0$0
Debug=: 0
'noun adverb conjunction verb monad dyad'=: 0 1 2 3 3 4
setalpha=: 16bff&$: : (4 : 0)
((_32&(34 b.))^:IF64 _8 (32 b.) x)&(23 b.) 16bffffff (17 b.) y
)
getalpha=: 16bff (17 b.) _24&(34 b.)
abspath=: 3 : 0
if. (1 e. '://'&E.) y=. ,jpathsep y do. y return. end.
if. IFWIN do.
  assert. 0<rc=. >@{. cdrc=. 'kernel32 GetFullPathNameW   i *w i *w *w'&cd (uucp y);((#;])1024$u:' '),<<0
  y=. jpathsep utf8 rc{.3{::cdrc
elseif. ('/' ~: {.) y do.
  y=. iospath^:IFIOS (1!:43'') , '/' , utf8 y
end.
y
)
apply=: 128!:2
assert=: 0 0 $ 13!:8^:((0 e. ])`(12"_))
bind=: 2 : 'u@(v"_)'
boxopen=: <^:(0&(>: L.))
boxxopen=: <^:((> L.)~ *@#)
bx=: I.
clear=: 3 : 0
". 'do_',(' '-.~y),'_ '' (#~ -.@(4!:55)) (4!:1) 0 1 2 3'''
)
cutLF=: 3 : 'if. 0 (<L.) y do. y else. a: -.~ <;._2 y,LF end.'
cutopen=: 3 : 0
y cutopen~ (' ',LF) {~ LF e. ,y
:
if. 0 (<L.) y do. y return. end.
if. 1 < #$y do. <"_1 y return. end.
(<'') -.~ (y e.x) <;._2 y=. y,1{.x
)
datatype=: 3 : 0
n=. 1 2 4 8 16 32 64 128 1024 2048 4096 8192 16384 32768 65536 131072 262144
t=. '/boolean/literal/integer/floating/complex/boxed/extended/rational'
t=. t,'/sparse boolean/sparse literal/sparse integer/sparse floating'
t=. t,'/sparse complex/sparse boxed/symbol/unicode/unicode4'
(n i. 3!:0 y) pick <;._1 t
)
def=: :
define=: : 0
H=. '0123456789ABCDEF'
h=. '0123456789abcdef'
dfh=: (16 #. 16 | (H,h) i. ]) :.hfd
hfd=: (h {~ 16 #.^:_1 ]) :.dfh
4!:55 'H';'h'
do=: ".
drop=: }.
each=: &.>
empty=: EMPTY"_
erase=: [: 4!:55 ;: ::]
every=: &>
evtloop=: EMPTY"_
exit=: 2!:55
expand=: #^:_1
file2url=: 3 : 0
if. (1 e. '://'&E.) ,y do. y return. end.
y=. (' ';'%20') stringreplace abspath y -. '"'
if. IFWIN do.
  if. '//'-:2{.y do.
    'file:',y
  else.
    'file:///',y
  end.
else.
  'file://',y
end.
)
fixdotdot=: 3 : 0
while. 1 e. r=. '../' E. y do.
  y=. ((2+p)}.y),~ ({.~ i:&'/') }: (p=. {.I.r){.y
end.
y
)
fliprgb=: 3 : 0
s=. $y
d=. ((#y),4)$2 (3!:4) y=. <.,y
d=. 2 1 0 3{"1 d
s$_2(3!:4),d
)
getargs=: 3 : 0
ARGV getargs y
:
argb=. (]`(([: < 1: {. }.) , [: < 2: }. ])@.('-'"_ = {.))&.> x
parm=. 32 = ;(3!:0)&.> argb
((-. parm)#argb);(>parm#argb);(". (0 = isatty 0)#'stdin ''''')
)
getenv=: 2!:5
inv=: inverse=: ^:_1
iospath=: 3 : 0
if. IFIOS *. ('/j'-:2{.y) do. y=. y,~ '/Documents',~ 2!:5 'HOME' end.
y
)
3 : 0''
if. IFUNIX do.
  isatty=: ((unxlib 'c'),' isatty > i i') & (15!:0)
else.
  isatty=: 2: = ('kernel32 GetFileType > i x' & (15!:0)) @ ('kernel32 GetStdHandle > x i'& (15!:0)) @ - @ (10&+)
end.
''
)
isutf8=: 0:`(1:@(7&u:) :: 0:)@.(2=3!:0)
isutf16=: 0:`(1:@(8&u:) :: 0:)@.(131072=3!:0)
items=: "_1
fetch=: {::
leaf=: L:0
list=: 3 : 0
w=. {.wcsize''
w list y
:
if. 0=#y do. i.0 0 return. end.
if. 2>#$y=. >y do.
  d=. (' ',LF) {~ LF e. y=. toJ ": y
  y=. [;._2 y, d #~ d ~: {: y
end.
y=. y-. ' '{.~ c=. {:$ y=. (": y),.' '
(- 1>. <. x % c) ;\ <"1 y
)
nameclass=: nc=: 4!:0
namelist=: 4!:1
nl=: 3 : 0
'' nl y
:
if. 0 e. #y do. y=. 0 1 2 3 end.

if. 1 4 8 e.~ 3!:0 y do.
  nms=. (4!:1 y) -. ;: 'x y x. y.'
else.
  nms=. cutopen_z_ y
end.

if. 0 e. #nms do. return. end.

if. #t=. x -. ' ' do.
  'n s'=. '~*' e. t
  t=. t -. '~*'
  b=. t&E. &> nms
  if. s do. b=. +./"1 b
  else. b=. {."1 b end.
  nms=. nms #~ n ~: b
end.
)
names=: list_z_ @ nl
Note=: 3 : '0 0 $ 0 : 0' : [
on=: @:
pick=: >@{
rows=: "1
script=: [: 3 : '0!:0 y [ 4!:55<''y''' jpath_z_ &.: >
scriptd=: [: 3 : '0!:1 y [ 4!:55<''y''' jpath_z_ &.: >
stdout=: 1!:2&4
stderr=: 1!:2&5
stdin=: 1!:1@3: :. stdout
sign=: *
sminfo=: 3 : 0
if. IFJHS do. smoutput >{:boxopen y
elseif. IFQT do. wdinfo_jqtide_ y
elseif. IFJA do. wdinfo_ja_ y
elseif. IFJNET do. wdinfo_jnet_ y
elseif. (0-:11!:0 ::0:'qwd') < 3=4!:0<'wdinfo' do. wdinfo y
elseif. do. smoutput >{:boxopen y end.
)
echo=: 0 0 $ 1!:2&2
smoutput=: 0 0 $ 1!:2&2
tmoutput=: 0 0 $ 1!:2&4
sort=: /:~ : /:
split=: {. ,&< }.
table=: 1 : 0~
:
(((#~LF-.@e.])5!:5<'u');,.y),.({.;}.)":x,y u/x
)
take=: {.
timespacex=: 6!:2 , 7!:2@]
timex=: 6!:2
tolist=: }.@;@:(LF&,@,@":&.>)
tolower=: 3 : 0`((((97+i.26){a.)(65+i.26)}a.) {~ a. i. ])@.(2 = 3!:0)
x=. I. 26 > n=. ((65+i.26){a.) i. t=. ,y
($y) $ ((x{n) { (97+i.26){a.) x}t
)

toupper=: 3 : 0`((((65+i.26){a.)(97+i.26)}a.) {~ a. i. ])@.(2 = 3!:0)
x=. I. 26 > n=. ((97+i.26){a.) i. t=. ,y
($y) $ ((x{n) { (65+i.26){a.) x}t
)

3 : 0''
try.
  tolower=: 0&(3!:12)
  toupper=: 1&(3!:12)
catch. end.
''
)
t=. <;._1 '/invalid name/not defined/noun/adverb/conjunction/verb/unknown'
type=: {&t@(2&+)@(4!:0)&boxopen
ucp=: 7&u:
ucpcount=: # @ (7&u:)
3 : 0''
if. IFUNIX do.
  usleep=: 3 : ('''',(unxlib 'c'),' usleep > i i''&(15!:0) >.y')
else.
  usleep=: 3 : '0: ''kernel32 Sleep > n i''&(15!:0) >.y % 1000'
end.
EMPTY
)
utf8=: 8&u:
uucp=: u:@(7&u:)
toJ=: (LF I.@(CR=])}]) @: (#~ -.@(CRLF&E.@,))
toCRLF=: 2&}. @: ; @: (((CR&,)&.>)@<;.1@(LF&,)@toJ)

3 : 0''
if. 5=9!:12'' do.
  toHOST=: ]
else.
  toHOST=: toCRLF
end.
1
)
18!:4 <'z'
coclass=: 18!:4 @ boxxopen
cocreate=: 18!:3
cocurrent=: 18!:4 @ boxxopen
codestroy=: coerase @ coname
coerase=: 18!:55
cofullname=: 3 : 0
y=. ,> y
if. #y do.
  if. ('_' = {: y) +: 1 e. '__' E. y do.
    y,'_',(>18!:5''),'_'
  end.
end.
)
coinsert=: 3 : 0
n=. ;: :: ] y
p=. ; (, 18!:2) @ < each n
p=. ~. (18!:2 coname''), p
(p /: p = <,'z') 18!:2 coname''
)
coname=: 18!:5
conames=: list_z_ @ conl
conew=: 3 : 0
c=. <y
obj=. cocreate''
coinsert__obj c
COCREATOR__obj=: coname''
obj
:
w=. conew y
create__w x
w
)
conl=: 18!:1 @ (, 0 1"_ #~ # = 0:)
copath=: 18!:2 & boxxopen
coreset=: 3 : 0
0 0$coerase conl 1
)
cocurrent 'z'
cofind=: 3 : 0
r=. (<,>y) (4 : 'try. x e. nl__y $0 catch. 0 end.'"0 # ]) 18!:1]0 1
if. 0=#r do. i.0 2 end.
)
cofindv=: 3 : 0
lcs=. cofind y
if. #lcs do.
  lcs ,. ". each (<y,'_') ,each lcs ,each '_'
end.
)
coinfo=: 3 : 0
ref=. boxxopen y
if. 0 e. $ref do. i.0 4 return. end.
if. 0=4!:0 <'COCREATOR__ref'
do. c=. COCREATOR__ref else. c=. a: end.
(conouns ref),ref,c,< ;:inverse copath ref
)
conouns=: 3 : 0 "0
n=. nl 0
t=. n#~ (<y)-:&> ".each n
< ;: inverse t
)
conounsx=: 3 : 0
r=. ''
if. #y do.
  s=. #y=. boxxopen y
  loc=. conl 0
  for_i. loc do. r=. r,conouns__i y end.
  r=. (r~:a:) # (y$~#r),.r,.s#loc
end.
/:~~.r
)
copathnl=: 3 : 0
'' copathnl y
:
r=. ''
t=. (coname''),copath coname''
for_i. t -. <,'z' do.
  r=. r,x nl__i y
end.
/:~~.r
)
copathnlx=: 3 : 0
'' copathnlx y
:
r=. ''
t=. (coname''),copath coname''
for_i. t=. t -. <,'z' do.
  r=. r,<x nl__i y
end.
n=. ~.;r
n,.|:( n&e. &> r) #each t
)
costate=: 3 : 0
r=. ,: ;:'refs id creator path'
if. #n=. conl 1 do. r,coinfo &> n /: 0 ".&> n end.
)
cocurrent 'z'
cd=: 15!:0
memr=: 15!:1
memw=: 15!:2
mema=: 15!:3
memf=: 15!:4
memu=: '' 1 : 'try. 15!:15 m catch. a: { ] return. end. 15!:15'
cdf=: 15!:5
cder=: 15!:10
cderx=: 15!:11
symget=: 15!:6
symset=: 15!:7
symdat=: 15!:14
cdcb=: 15!:13
JB01=: 1
JCHAR=: 2
JSTR=: _1,JCHAR
JINT=: 4
JPTR=: JINT
JFL=: 8
JCMPX=: 16
JBOXED=: 32
JSB=: 65536
JCHAR2=: 131072
JSTR2=: _1,JCHAR2
JCHAR4=: 262144
JSTR4=: _1,JCHAR4
JTYPES=: JB01,JCHAR,JINT,JPTR,JFL,JCMPX,JBOXED,JSB,JCHAR2,JCHAR4
JSIZES=: >IF64{1 1 4 4 8 16 4 4 2 4;1 1 8 8 8 16 8 8 2 4
SZI=: IF64{4 8
ic=: 3!:4
fc=: 3!:5
endian=: |.^:('a'={.2 ic a.i.'a')
Endian=: |.^:('a'~:{.2 ic a.i.'a')
AND=: $:/ : (17 b.)
OR=: $:/ : (23 b.)
XOR=: $:/ : (22 b.)
cocurrent 'z'
calendar=: 3 : 0
0 calendar y
:
a=. ((j<100)*(-100&|){.6!:0'')+j=. {.y
b=. (a-x)+-/<.4 100 400%~<:a
r=. 28+3,(~:/0=4 100 400|a),10$5$3 2
r=. (-7|b+0,+/\}:r)|."0 1 r(]&:>:*"1>/)i.42
m=. (<:}.y),i.12*1=#y
h=. 'JanFebMarAprMayJunJulAugSepOctNovDec'
h=. ((x*3)|.' Su Mo Tu We Th Fr Sa'),:"1~_3(_12&{.)\h
<"2 m{h,"2[12 6 21 ($,) r{' ',3":1+i.31 1
)
getdate=: 3 : 0
0 getdate y
:
r=. ''
opt=. x
chr=. [: -. [: *./ e.&'0123456789 '
dat=. ' ' (I. y e.',-/:') } y

if. chr dat do.
  opt=. 0
  dat=. a: -.~ <;._1 ' ',dat
  if. 1=#dat do. r return. end.
  typ=. chr &> dat
  dat=. (2{.typ{dat),{:dat
  mth=. 3{.>1{dat
  uc=. 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  lc=. 'abcdefghijklmnopqrstuvwxyz'
  mth=. (lc,a.) {~ mth i.~ uc,a.
  mos=. _3[\'janfebmaraprmayjunjulaugsepoctnovdec'
  mth=. <": >:mos i. mth
  dat=. ;' ',each mth 1 } dat
end.

dat=. ". :: (''"_) dat
if. 0 e. #dat do. return. end.

if. 3 ~: #dat do. r return. end.

if. 31 < {.dat do. 'y m d'=. dat
else. ((opt|.'d m '),' y')=. dat
end.

if. y<100 do.
  y=. y + (-100&|) {. 6!:0''
end.

(#~ valdate) y,m,d
)
isotimestamp=: 3 : 0
r=. }: $y
t=. _6 [\ , 6 {."1 y
d=. '--b:' 4 7 10 13 }"1 [ 4 3 3 3 3 ": <. 5{."1 <.t
d=. d ,. ':' 0 }"1 [ 7j3 ": ,. {:"1 t
c=. {: $d
d=. ,d
d=. '0' (I. d=' ')} d
d=. ' ' (I. d='b')} d
(r,c) $ d
)
todate=: 3 : 0
0 todate y
:
s=. $y
y=. s$ 0 (I. (,y) e. _ __)},y
a=. 657377.75 +, y=. <. p=. y
d=. <. a - 36524.25 * c=. <. a % 36524.25
d=. <.1.75 + d - 365.25 * y=. <. (d+0.75) % 365.25
r=. (1+12|m+2) ,: <. 0.41+d-30.6* m=. <. (d-0.59) % 30.6
if. 1<x do.
  h=. <. t=. 24*(1&|) ,p
  mm=. <. t=. 60*t-h
  ss=. 60*t-mm
  r=. s $ |: ((c*100)+y+m >: 10) ,r , |: h ,. mm,. ss
else.
  r=. s $ |: ((c*100)+y+m >: 10) ,r
end.
if. 1=x do. r=. 100 #. r end.
r
)
todayno=: 3 : 0
0 todayno y
:
a=. y
if. 1=x do. a=. 0 100 100 #: a end.
a=. ((*/r=. }: $a) , {:$a) $,a
if. 1<x do.
  'y m d h mm s'=. <"_1 |: a
else.
  'y m d'=. <"_1 |: a
end.
y=. 0 100 #: y - m <: 2
n=. +/ |: <. 36524.25 365.25 *"1 y
n=. n + <. 0.41 + 0 30.6 #. (12 | m-3),"0 d
if. 1<x do.
  n=. n + (24 60 60#.h,.mm,.s)%24*3600
end.
0 >. r $ n - 657378
)
tsdiff=: 4 : 0
r=. -/"2 d=. _6 (_3&([\)) \ ,x,"1 y
if. #i=. i#i.#i=. 0 > 2{"1 r do.
  j=. (-/0=4 100 400 |/ (<i;1;0){d)* 2=m=. (<i;1;1){d
  j=. _1,.j + m{0 31 28 31 30 31 30 31 31 30 31 30 31
  n=. <i;1 2
  r=. (j + n{r) n } r
end.
r +/ . % 1 12 365
)
tsrep=: 3 : 0
0 tsrep y
:
if. x do.
  r=. $y
  'w n t'=. |: 0 86400 1000 #: ,y
  w=. w + 657377.75
  d=. <. w - 36524.25 * c=. <. w % 36524.25
  d=. <.1.75 + d - 365.25 * w=. <. (d+0.75) % 365.25
  s=. (1+12|m+2) ,: <. 0.41+d-30.6* m=. <. (d-0.59) % 30.6
  s=. |: ((c*100)+w+m >: 10) ,s
  r $ s,. (_3{. &> t%1000) +"1 [ 0 60 60 #: n
else.
  a=. ((*/r=. }: $y) , {:$y) $, y
  'w m d'=. <"_1 |: 3{."1 a
  w=. 0 100 #: w - m <: 2
  n=. +/ |: <. 36524.25 365.25 *"1 w
  n=. n + <. 0.41 + 0 30.6 #. (12 | m-3),"0 d
  s=. 3600000 60000 1000 +/ .*"1 [ 3}."1 a
  r $ s+86400000 * n - 657378
end.
)
timestamp=: 3 : 0
if. 0 = #y do. w=. 6!:0'' else. w=. y end.
r=. }: $ w
t=. 2 1 0 3 4 5 {"1 [ _6 [\ , 6 {."1 <. w
d=. '+++::' 2 6 11 14 17 }"1 [ 2 4 5 3 3 3 ": t
mth=. _3[\'   JanFebMarAprMayJunJulAugSepOctNovDec'
d=. ,((1 {"1 t) { mth) 3 4 5 }"1 d
d=. '0' (I. d=' ') } d
d=. ' ' (I. d='+') } d
(r,20) $ d
)
tstamp=: timestamp
valdate=: 3 : 0
s=. }:$y
'w m d'=. t=. |:((*/s),3)$,y
b=. *./(t=<.t),(_1 0 0<t),12>:m
day=. (13|m){0 31 28 31 30 31 30 31 31 30 31 30 31
day=. day+(m=2)*-/0=4 100 400|/w
s$b*d<:day
)
weekday=: 7 | 3 + todayno
weeknumber=: 3 : 0
yr=. {.y
sd=. 1 ((i.~weekday){]) ((<:yr),.12,.29+i.3),yr,.1,.1+i.4
wk=. >.7%~>: y -&todayno sd
if. wk >weeksinyear yr do.
  (>:yr),1
elseif. wk=0 do.
  (,weeksinyear)<:yr
elseif. do.
  yr,wk
end.
)
weeksinyear=: 3 : '52+ +./"1 [ 4=weekday(1 1,:12 31),"0 1/~ y'
cocurrent 'z'
dbr=: 13!:0
dbs=: 13!:1
dbsq=: 13!:2
dbss=: 13!:3
dbrun=: 13!:4
dbnxt=: 13!:5
dbret=: 13!:6
dbjmp=: 13!:7
dbsig=: 13!:8
dbrr=: 13!:9
dbrrx=: 13!:10
dberr=: 13!:11
dberm=: 13!:12
dbstk=: 13!:13
dblxq=: 13!:14
dblxs=: 13!:15
dbtrace=: 13!:16
dbq=: 13!:17
dbst=: 13!:18
dbcut=: 13!:19
dbover=: 13!:20
dbinto=: 13!:21
dbout=: 13!:22
dbctx=: 10 10&$: : (4 : 0)
if. -.13!:17'' do. 0 0$'' return. end.
try.
  'before after'=. 2{. <. , x, 10 10
catch.
  'before after'=. 10 10
end.
if. 0= #d=. 13!:13'' do. 0 0$'' return. end.
if. '*' -.@e. sus=. >{:"1 d do. 0 0$'' return. end.
'name ln nc def src'=. 0 2 3 4 5{(sus i. '*'){d
dyad=. {: ':'&e.;._2 ] 13!:12''
if. (_2{.def) -: LF,')' do.
  def=. }.def [ def0=. {.def=. }:<;._2 def,LF
else.
  def=. ,<def [ def0=: ''
end.
if. def e.~ <,':' do.
  if. dyad do.
    def=. def}.~ >: def i. <,':'
  else.
    def=. def{.~ def i. <,':'
  end.
end.
min=. 0>.ln-before [ max=. (<:#def)<.ln+after
ctx=. ((,.ln=range){' >'),"1 '[',"1 (":,.range) ,"1 ('] ') ,"1 >def{~range=. min + i. >:max-min
; ,&LF&.> (<'@@ ', name, '[', (dyad#':'), (":ln) ,'] *', (nc{' acv'),' @@ ', src), def0, <@dtb "1 ctx
)
dbg=: 3 : 0
if. -.IFQT do.
  13!:0 y return.
end.
if. y do.
  if. _1 = 4!:0 <'jdb_open_jdebug_' do.
    0!:0 <jpath '~addons/ide/qt/debugs.ijs'
  end.
  jdb_open_jdebug_''
  13!:0 [ 1
else.
  jdb_close_jdebug_ :: ] ''
  13!:15 ''
  13!:0 [ 0
end.
)
dblocals=: _1&$: : (4 : 0)
stk=. }. 13!:13''
if. 0=#y do. y=. a: else. y=. (y e. i.#stk) # y end.
loc=. (<y ; 0 7) { stk
if. x-: 0 do.
  {."1 &.>@:{:"1 loc
elseif. -. x-:_1 do.
  t=. ;: ::] x
  f=. ({."1 e. t"_) # ]
  ({."1 loc) ,. f &.> {:"1 loc
end.
)
dbstack=: 3 : 0
hdr=. ;:'name en ln nc args locals susp'
stk=. }. 13!:13''
if. #y do.
  if. 2=3!:0 y do.
    stk=. stk #~ (<y)={."1 stk
  else.
    stk=. ((#stk)<.,y){.stk
  end.
end.
stk=. 1 1 1 1 0 0 1 1 1 #"1 stk
stk=. hdr, ": &.> stk
wds=. ({:@$@":@,.)"1 |: stk
len=. 20 >.<.-:({.wcsize'') - +/8, 4 {. wds
tc=. (len+1)&<.@$ {.!.'.' ({.~ len&<.@$)
tc@": each stk
)
dbstop=: 3 : 0
if. 0 e. #y -. ' ' do. 13!:3'' return. end.
t=. 13!:2''
if. #t do. t=. <;._2 t, ';' -. {:t end.
t=. ~. t, (;: ^: (L.=0:) y) ,&.> <' *:*'
13!:3 ; t ,&.> ';'
)
dbstops=: 3 : 0
13!:3 ; (;: ^: (L.=0:) y) ,&.> <' *:*;'
)
dbstopme=: 3 : 0
if. y do.
  if. 0 e. $c=. }. 13!:13'' do. return. end.
  c=. (> {. {. c), ' *:*'
  t=. 13!:2''
  if. #t do. t=. <;._2 t, ';' -. {:t end.
  t=. ~. t, <c
  13!:3 }: ; t ,&.> ';'
end.
)
dbstopnext=: 3 : 0
if. y do.
  if. 0 e. $c=. }. 13!:13'' do. return. end.
  'd n a'=. 0 2 6 { {. c
  c=. d,' ',(':'#~2=#a),":n+1
  t=. 13!:2''
  if. #t do. t=. <;._2 t, ';' -. {:t end.
  t=. ~. t, <c
  13!:3 }: ; t ,&.> ';'
end.
)
dbview=: 3 : 0
if. -.IFQT do. return. end.
if. _1 = 4!:0 <'jdbview_jdbview_' do.
  'require'~'~addons/ide/qt/dbview.ijs'
end.
jdbview_jdbview_ }. 13!:13''
)
dbhelp=: 0 : 0
The call stack (dbstk'') is a 9-column boxed matrix:
  0  name
  1  error number, or 0 if this call has no error.
  2  line number
  3  name class
  4  definition
  5  source script
  6  argument list
  7  locals
  8  suspense

f is the name of a verb
      dbss 'f 0'   monadic line 0
      dbss 'f :2'  dyadic line 2
      dbss 'f *:*' all lines

dbr     13!:0  reset, set suspension mode (0=disable, 1=enable)
dbs     13!:1  display stack
dbsq    13!:2  stop query
dbss    13!:3  stop set
dbrun   13!:4  run again (from current stop)
dbnxt   13!:5  run next (skip line and run)
dbret   13!:6  exit and return argument
dbjmp   13!:7  jump to line number
dbsig   13!:8  signal error
dbrr    13!:9  re-run with specified arguments
dbrrx   13!:10 re-run with specified executed arguments
dberr   13!:11 last error number
dberm   13!:12 last error message
dbstk   13!:13 call stack
dblxq   13!:14 latent expression query
dblxs   13!:15 latent expression set
dbtrace 13!:16 trace control
dbq     13!:17 queries suspension mode (set by dbr)
dbst    13!:18 returns stack text
(these 4 verbs are subject to change without notice)
dbcut   13!:19 cut back
dbover  13!:20 step over (13!:20'' or moveline 13!:20'')
dbinto  13!:21 step into ...
dbout   13!:22 step out  ...
(utilities)
dbctx       display context
dbg         turn debug window on/off
dblocals    display local names on stack
dbstack     display stack
dbstop      add stop definitions
dbstops     set all stop definitions
dbstopme    stop current definition
dbstopnext  stop current definition at next line
dbview      (GUI only) view stack
)
cocurrent 'z'
dir=: 3 : 0
'n' dir y
:
ps=. '/'
y=. jpath y,(0=#y)#'*'
y=. y,((':',ps) e.~ {:y)#'*'
if. 0=#dr=. 1!:0 y do. empty'' return. end.
fls=. 'd' ~: 4{"1>4{"1 dr
if. (1=#dr) *. 0={.fls do.
  r=. x dir y,ps,'*'
  if. #r do. r return. end.
end.
if. fmt=. 2=3!:0 x do. opt=. 2 1
else. opt=. 2{.x end.
if. 0={:opt do. fls=. 1#~#dr=. fls#dr end.
if. 0=#dr do. empty'' return. end.
nms=. {."1 dr
nms=. nms ,&.> fls{ps;''
ndx=. /: (":,.fls),.>nms
if. 0=opt do.
  list >ndx{nms
elseif. 1=opt do.
  path=. (+./\.y=ps)#y
  path&,&.>ndx{nms
elseif. fmt<2=opt do.
  ndx{nms,.}."1 dr
elseif. fmt do.
  'nms ts size'=. |:3{."1 dr
  ds=. '   <dir>    ' ((-.fls)#i.#fls) } 12 ":,.size
  mth=. _3[\'   JanFebMarAprMayJunJulAugSepOctNovDec'
  f=. > @ ([: _2&{. [: '0'&, ": )&.>
  'y m d h n s'=. f&> ,<"1 |: 100|ts
  m=. (1{"1 ts){mth
  time=. d,.'-',.m,.'-',.y,.' ',.h,.':',.n,.':',.s
  dat=. (>nms),.ds,.' ',.time
  dat /: fls,. /:/: >(3|'dns'i.x){ts;nms;size
elseif. 1 do.
  'invalid left argument'
end.
)
dircompare=: 3 : 0
0 dircompare y
:
if. 0=#y do.
  '''long dirtree timestamps'' dircompare dir1;dir2'
  return.
end.

opt=. 3 {. x
res=. opt dircompares y
if. 0 = L. res do. return. end.

ps=. '/'
'a b c'=. res

'x y'=. jpath each cutopen y
x=. x, ps #~ (*#x) *. ps~:_1{.x
y=. y, ps #~ (*#y) *. ps~:_1{.y

r=. 'comparing  ',x,'  and  ',y,LF

if. #a do.
  r=. r,LF,'not in  ',y,':',LF,,(list a),.LF
end.

if. #b do.
  r=. r,LF,'not in  ',x,':',LF,,(list b),.LF
end.

if. +/ # &> c do.
  'cf cd'=. c
  r=. r,LF,'not same in both:',LF,,(list cf),.LF
  if. {.opt do.
    r=. r,LF,;(,&(LF2)) &.> cd
  end.

end.

if. 0=+/# S:0 res do. r=. r,'no difference',LF end.

}:r
)
dircompares=: 3 : 0
0 dircompares y
:
ps=. '/'
opt=. 3{. x
'x y'=. jpath each cutopen y
x=. x, ps #~ (*#x) *. ps~:_1{.x
y=. y, ps #~ (*#y) *. ps~:_1{.y

if. 1{opt do.
  dx=. dirtree x [ dy=. dirtree y
else.
  dx=. 2 0 dir x [ dy=. 2 0 dir y
end.

if. dx -: dy do. 'no difference' return. end.
if. 0 e. #dx do. 'first directory is empty' return. end.
if. 0 e. #dy do. 'second directory is empty' return. end.

f=. #~ [: +./\. =&ps
sx=. f x
sy=. f y
fx=. {."1 dx
fy=. {."1 dy

if. 1{opt do.
  fx=. (#sx)}.&.>fx
  fy=. (#sy)}.&.>fy
  dx=. fx 0 }"0 1 dx
  dy=. fy 0 }"0 1 dy
end.

r=. <fx -. fy
r=. r , <fy -. fx

dx=. (fx e. fy)#dx
dy=. (fy e. fx)#dy

if. #j=. dx -. dy do.
  j=. {."1 j
  cmp=. <@fcompare"1 (sx&,&.>j),.sy&,&.>j

  if. 0=2{opt do.
    f=. 'no difference'&-: @ (_13&{.)
    msk=. -. f &> cmp
    j=. msk#j
    cmp=. msk#cmp
  end.

  r=. r,< j;<cmp
else.
  r=. r,a:
end.

r
)
dirfind=: 4 : 0
f=. [: 1&e. x&E.
g=. #~ [: -. [: +./\. =&'/'
d=. {."1 dirtree y
m=. f@g &> d
if. 1 e. m do. ; (m # d) ,each LF else. 0 0$'' end.
)
dirpath=: 3 : 0
0 dirpath y
:
r=. ''
t=. jpath y
ps=. '/'
if. #t do. t=. t, ps -. {:t end.
dirs=. <t
ifdir=. 'd'&= @ (4&{"1) @ > @ (4&{"1)
subdir=. ifdir # ]
while. #dirs do.
  fpath=. (>{.dirs) &,
  dirs=. }.dirs
  dat=. 1!:0 fpath '*'
  if. #dat do.
    dat=. subdir dat
    if. #dat do.
      r=. r, fpath each /:~ {."1 dat
      dirs=. (fpath @ (,&ps) each {."1 dat),dirs
    end.
  end.
end.
if. x do.
  f=. 1!:0 @ (,&(ps,'*'))
  g=. 0:`(0: e. ifdir)
  h=. g @. (*@#) @ f
  r=. r #~ h &> r
end.
if. #t do. r=. r,<}:t end.
/:~ r
)
dirss=: 4 : 0
if. (2=#x) *. 1=L. x do.
  x dirssrplc y return.
end.
sub=. ' '&(I.@(e.&(TAB,CRLF))@]})
fls=. {."1 dirtree y
if. 0 e. #fls do. 'not found: ',x return. end.
fnd=. ''
while. #fls do.
  dat=. 1!:1 <fl=. >{.fls
  fls=. }.fls
  ndx=. I. x E. dat
  if. rws=. #ndx do.
    dat=. (20$' '),dat,30$' '
    dat=. (rws,50)$sub(,ndx+/i.50){dat
    fnd=. fnd,LF2,fl,' (',(":#ndx),')'
    fnd=. fnd,,LF,.dat
  end.
end.
if. #fnd do. 2}.fnd else. 'not found: ',x end.
)
dirssrplc=: 4 : 0
fls=. {."1 dirtree y
if. 0 e. #fls do.
  'no files found' return.
end.
r=. (x&fssrplc) each fls
b=. r ~: <'no match found'
j=. >b # fls , each ': '&, each r
}: , j ,. LF
)
dirtree=: 3 : 0
0 dirtree y
:
if. 0=4!:0 <'DirTreeX_j_' do.
  ex=. cutopen DirTreeX_j_
else.
  ex=. ''
end.
r=. i.0 3
ps=. '/'
y=. jpath y
y=. y #~ (+./\ *. +./\.) y~:' '
y=. y,(0=#y)#'*'
if. ps={:y do. y=. y,'*' end.
if. -. '*' e. y do.
  if. 1 = #j=. 1!:0 y do.
    select. 'hd' = 1 4 { >4{,j
    case. 0 1 do. x dirtree y,ps,'*' return.
    case. 1 1 do. i.0 3 return.
    end.
  end.
end.
ts=. 100"_ #. 6: {. 0: >. <. - # {. 1980"_
'path ext'=. (b#y);(-.b=. +./\.y=ps)#y
if. #dl=. 1!:0 y do.
  att=. > 4{"1 dl
  fl=. (('h' ~: 1{"1 att) *. 'd' ~: 4{"1 att)#dl
  if. #fl do.
    r=. r,(path&,&.>{."1 fl),.1 2{"1 fl
  end.
end.
if. #dl=. 1!:0 path,'*' do.
  att=. > 4{"1 dl
  dr=. {."1 (('h' ~: 1{"1 att) *. 'd' = 4{"1 att) # dl
  dr=. dr -. ex
  if. #dr do.
    r=. r,;x&dirtree@(path&,@,&(ps,ext)) &.> dr
  end.
end.
r #~ (ts x) <: ts &> 1{"1 r
)
dirused=: [: (# , +/ @ ; @ (2: {"1 ])) 0&dirtree
cocurrent 'z'

fexists=: #~ fexist
f2utf8=: ]
fboxname=: <@(fixdotdot^:IFIOS)@jpath_j_@(8 u: >) ::]
fappend=: 4 : 0
(,x) (#@[ [ 1!:3) :: _1: fboxname y
)
fappends=: 4 : 0
(fputs x) (#@[ [ 1!:3) :: _1: fboxname y
)
fapplylines=: 1 : 0
0 u fapplylines y
:
y=. > fboxname y
s=. 1!:4 <y
if. s = _1 do. return. end.
p=. 0
dat=. ''
while. p < s do.
  b=. 1e6 <. s-p
  dat=. dat, 1!:11 y;p,b
  p=. p + b
  if. p = s do.
    len=. #dat=. dat, LF -. {:dat
  elseif. (#dat) < len=. 1 + dat i:LF do.
    'file not in LF-delimited lines' 13!:8[3
  end.
  if. x do.
    u ;.2 len {. dat
  else.
    u ;._2 CR -.~ len {. dat
  end.
  dat=. len }. dat
end.
)
fcopynew=: 4 : 0
dat=. fread each boxopen y
if. (<_1) e. dat do. _1 return. end.
dat=. ; dat
if. dat -: fread :: 0: x do. 0,#dat else.
  if. _1=dat fwrite x do. _1 else. 1,#dat end.
end.
)
fdir=: 1!:0@fboxname
ferase=: (1!:55 :: _1:) @ (fboxname &>) @ boxopen
fexist=: (1:@(1!:4) :: 0:) @ (fboxname &>) @ boxopen
fgets=: 3 : 0
y=. (-(26{a.)={:y) }. y
if. 0=#y do. '' return. end.
y,LF -. {:y=. toJ y
)
fmakex=: (] 1!:7~ 'x' 2 5 8} 1!:7) @ fboxname
fpathcreate=: 3 : 0
if. 0=#y do. 1 return. end.
p=. (,'/'-.{:) jpathsep y
if. # 1!:0 }: p do. 1 return. end.
for_n. I. p='/' do. 1!:5 :: 0: < n{.p end.
)
fpathname=: +./\.@:=&'/' (# ; -.@[ # ]) ]
fread=: 3 : 0
if. 1 = #y=. boxopen y do.
  1!:1 :: _1: fboxname y
else.
  1!:11 :: _1: (fboxname {.y),{:y
end.
:
x freads y
)
freadblock=: 3 : 0
1e6 freadblock y
:
'f p'=. y
f=. > fboxname f
s=. 1!:4 <f
if. s = _1 do. return. end.
if. (s = 0) +. p >: s do. '';p return. end.
if. x < s-p do.
  dat=. 1!:11 f;p,x
  len=. 1 + dat i: LF
  if. len > #dat do.
    'file not in LF-delimited lines' 13!:8[3
  end.
  p=. p + len
  dat=. len {. dat
else.
  dat=. 1!:11 f;p,s-p
  dat=. dat, LF -. {: dat
  p=. s
end.
(toJ dat);p
)
freadr=: 3 : 0
'f s'=. 2{.boxopen y
f=. fboxname f
max=. 1!:4 :: _1: f
if. max -: _1 do. return. end.
pos=. 0
step=. 10000
whilst. blk = cls
do.
  blk=. step<.max-pos
  if. 0=blk do. 'file not organized in records' return. end.
  dat=. 1!:11 f,<pos,blk
  cls=. <./dat i.CRLF
  pos=. pos+step
end.
len=. cls+pos-step
dat=. 1!:11 f,<len,2<.max-len
dlm=. +/CRLF e. dat
wid=. len+dlm
s=. wid*s,0 #~ 0=#s
dat=. 1!:11 f,<s
dat=. (-wid)[\dat
(-dlm)}."1 dat
)
freads=: 3 : 0
'' freads y
:
dat=. fread y
if. (dat -: _1) +. 0=#dat do. return. end.
dat=. fgets dat
if. 'b'e.x do. dat=. <;._2 dat
elseif. 'm'e.x do. dat=. ];._2 dat
end.
)
frename=: 4 : 0
x=. > fboxname x
y=. > fboxname y
if. x -: y do. 1 return. end.
if. IFUNIX do.
  0=((unxlib 'c'),' rename > i *c *c') 15!:0 y;x
else.
  'kernel32 MoveFileW > i *w *w' 15!:0 (uucp y);uucp x
end.
)
freplace=: 4 : 0
y=. boxopen y
dat=. ,x
f=. #@[ [ 1!:12
dat f :: _1: (fboxname {.y),{:y
)
fsize=: (1!:4 :: _1:) @ (fboxname &>) @ boxopen
fss=: 4 : 0
y=. fboxname y
size=. 1!:4 :: _1: y
if. size -: _1 do. return. end.
blk=. (#x) >. 100000 <. size
r=. i.pos=. 0
while. pos < size do.
  dat=. 1!:11 y,<pos,blk <. size-pos
  r=. r,pos+I. x E. dat
  pos=. pos+blk+1-#x
end.
r
)
fssrplc=: fstringreplace
fstamp=: (1: >@{ , @ (1!:0) @ fboxname) :: _1:
fputs=: 3 : 0
dat=. ":y
if. 0 e. $dat do.
  ''
else.
  if. 1>:#$dat do.
    toHOST dat,(-.({:dat) e. CRLF) # LF
  else.
    ,dat,"1 toHOST LF
  end.
end.
)
ftype=: 3 : 0
(1:@(1!:4) :: 0:)^:IFWIN < f=. }: ^: ('/' = {:) , > fboxname y
d=. 1!:0 f
if. #d do.
  >: 'd' = 4 { > 4 { ,d
else.
  0
end.
)
fview=: 3 : 0
if. 3 ~: nc <'textview_z_' do.
  sminfo 'textview not available.' return.
end.
txt=. freads y
if. txt -: _1 do.
  sminfo 'file not found: ',,>y return.
end.
textview txt
)
fwrite=: 4 : 0
(,x) (#@[ [ 1!:2) :: _1: fboxname y
)
fwritenew=: 4 : 0
dat=. ,x
if. dat -: fread y do. 0 return. end.
dat fwrite y
)
fwrites=: 4 : 0
(fputs x) (#@[ [ 1!:2) :: _1: fboxname y
)
cocurrent 'z'
install=: 3 : 0
require 'pacman'
do_install_jpacman_ y
)
getqtbin=: 3 : 0
if. (<UNAME) -.@e. 'Linux';'OpenBSD';'FreeBSD';'Darwin';'Win' do. return. end.
if. IFQT do.
  smoutput 'must run from jconsole' return.
end.
require 'pacman'
do_getqtbin_jpacman_ y
)
cocurrent 'z'
cuts=: 2 : 0
if. n=1 do. [: u (#@[ + E. i. 1:) {. ]
elseif. n=_1 do. [: u (E. i. 1:) {. ]
elseif. n= 2 do. [: u (E. i. 1:) }. ]
elseif. 1 do. [: u (#@[ + E. i. 1:) }. ]
end.
)
cut=: ' '&$: :([: -.&a: <;._2@,~)
deb=: #~ (+. 1: |. (> </\))@(' '&~:)
debc=: #~"1 [: (+. (1: |. (> </\))) ' '&(+./ .~:)
delstring=: 4 : ';(x E.r) <@((#x)&}.) ;.1 r=. x,y'
detab=: ' ' I.@(=&TAB@])} ]
3 : 0''
try.
dlb=: 1&(128!:11)
dltb=: 2&(128!:11)
dtb=: 0&(128!:11)
catch.
dlb=: }.~ =&' ' i. 0:
dltb=: #~ [: (+./\ *. +./\.) ' '&~:
dtb=: #~ [: +./\. ' '&~:
end.
''
)
joinstring=: ''&$: : (#@[ }. <@[ ;@,. ])
ljust=: (|.~ +/@(*./\)@(' '&=))"1
rjust=: (|.~ -@(+/)@(*./\.)@(' '&=))"1
ss=: I. @ E.
dropto=: ] cuts 2
dropafter=: ] cuts 1
taketo=: ] cuts _1
takeafter=: ] cuts _2
charsub=: 4 : 0
'f t'=. |: _2 ]\ x
l=. f i."1 0 y
x=. l { t,'?'
c=. l = #f
c } x ,: y
)
chopstring=: 3 : 0
(' ';'"') chopstring y
:
dat=. y
'fd sd'=. 2{. boxopen x
assert. 1 = #fd
if. #sd do.
  sd=. ~.sd
  if. 1 < #sd do.
    s=. {. '|`' -. fd
    dat=. dat charsub~ ,sd,.s
    sd=. s
  end.
  dat=. dat,fd
  b=. dat = fd
  c=. dat = {.sd
  d=. ~:/\ c
  fmsk=. b > d
  smsk=. (> (0 , }:)) c
  smsk=. -. smsk +. c *. 1|.fmsk
  y=. smsk#y,fd
  fmsk=. 0:^:(,@1: -: ]) smsk#fmsk
  fmsk <;._2 y
else.
  <;._2 dat,fd
end.
)
dltbs=: LF&$: : (4 : 0)
txt=. ({.x), y
a=. txt ~: ' '
b=. (a # txt) e. x
c=. b +. }. b, 1
d=. ~: /\ a #^:_1 c ~: }: 0, c
}. (a >: d) # txt
)
dquote=: ('"'&,@(,&'"'))@ (#~ >:@(=&'"'))
dquotex=: 3 : 0
s=. y#~ >: m=. (=&'"') y
p=. (i.#y)#~>: m
('"'&,@(,&'"')) '\' (p i.(I.m))}s
)
dtbs=: 3 : 0
CRLF dtbs y
:
txt=. y , {.x
blk=. txt ~: ' '
ndx=. +/\ blk
b=. blk < }. (txt e. x), 0
msk=. blk >: ndx e. b # ndx
}: msk # txt
)
rplc=: stringreplace~
rplci=: stringreplacei~
fstringreplace=: 4 : 0
nf=. 'no match found'
y=. fboxname y
try. size=. 1!:4 y catch. nf return. end.
if. size=0 do. nf return. end.
old=. freads y
new=. x stringreplace old
if. old -: new do. nf return. end.
new fwrites y
cnt=. +/ (0 pick x) E. old
(":cnt),' replacement',((1~:cnt)#'s'),' made'
)
quote=: (''''&,@(,&''''))@ (#~ >:@(=&''''))
nos=. i.@#@] e. #@[ ({~^:a:&0@(,&_1)@(]I.+) { _1,~]) I.@E.
splitnostring=: #@[ }.each [ (nos f. <;.1 ]) ,
splitstring=: #@[ }.each [ (E. <;.1 ]) ,
stringreplace=: 4 : 0

txt=. ,y
t=. _2 [\ ,x
old=. {."1 t
new=. {:"1 t
oldlen=. # &> old
newlen=. # &> new

if. *./ 1 = oldlen do.

  hit=. (;old) i. txt
  ndx=. I. hit < #old

  if. 0 e. $ndx do. txt return. end.

  cnt=. 1
  exp=. hit { newlen,1
  hnx=. ndx { hit
  bgn=. ndx + +/\ 0, (}: hnx) { newlen - 1

else.

  hit=. old I. @ E. each <txt
  cnt=. # &> hit

  if. 0 = +/ cnt do. txt return. end.

  bgn=. set=. ''

  pick=. > @ {
  diff=. }. - }:

  for_i. I. 0 < cnt do.
    ln=. i pick oldlen
    cx=. (i pick hit) -. set, ,bgn -/ i.ln
    while. 0 e. b=. 1, <:/\ ln <: diff cx do. cx=. b#cx end.
    hit=. (<cx) i} hit
    bgn=. bgn, cx
    set=. set, ,cx +/ i.ln
  end.

  cnt=. # &> hit
  msk=. 0 < cnt
  exp=. (#txt) $ 1
  del=. newlen - oldlen

  if. #add=. I. msk *. del > 0 do.
    exp=. (>: (add{cnt) # add{del) (;add{hit) } exp
  end.

  if. #sub=. I. msk *. del < 0 do.
    sbx=. ; (;sub{hit) + each (sub{cnt) # i. each sub{del
    exp=. 0 sbx } exp
  end.

  hit=. ; hit
  ind=. /: (#hit) $ 1 2 3
  hnx=. (/: ind { hit) { ind
  bgn=. (hnx { hit) + +/\ 0, }: hnx { cnt # del

end.

ind=. ; bgn + each hnx { cnt # i.each newlen
rep=. ; hnx { cnt # new
rep ind} exp # txt
)
stringreplacei=: 4 : 0

txt=. ,y
t=. _2 [\ ,x
old=. {."1 t
new=. {:"1 t
oldlen=. # &> old
newlen=. # &> new

if. *./ 1 = oldlen do.

  hit=. (;old) i.&tolower txt
  ndx=. I. hit < #old

  if. 0 e. $ndx do. txt return. end.

  cnt=. 1
  exp=. hit { newlen,1
  hnx=. ndx { hit
  bgn=. ndx + +/\ 0, (}: hnx) { newlen - 1

else.

  hit=. old (I. @ E.)&tolower each <txt
  cnt=. # &> hit

  if. 0 = +/ cnt do. txt return. end.

  bgn=. set=. ''

  pick=. > @ {
  diff=. }. - }:

  for_i. I. 0 < cnt do.
    ln=. i pick oldlen
    cx=. (i pick hit) -. set, ,bgn -/ i.ln
    while. 0 e. b=. 1, <:/\ ln <: diff cx do. cx=. b#cx end.
    hit=. (<cx) i} hit
    bgn=. bgn, cx
    set=. set, ,cx +/ i.ln
  end.

  cnt=. # &> hit
  msk=. 0 < cnt
  exp=. (#txt) $ 1
  del=. newlen - oldlen

  if. #add=. I. msk *. del > 0 do.
    exp=. (>: (add{cnt) # add{del) (;add{hit) } exp
  end.

  if. #sub=. I. msk *. del < 0 do.
    sbx=. ; (;sub{hit) + each (sub{cnt) # i. each sub{del
    exp=. 0 sbx } exp
  end.

  hit=. ; hit
  ind=. /: (#hit) $ 1 2 3
  hnx=. (/: ind { hit) { ind
  bgn=. (hnx { hit) + +/\ 0, }: hnx { cnt # del

end.

ind=. ; bgn + each hnx { cnt # i.each newlen
rep=. ; hnx { cnt # new
rep ind} exp # txt
)
undquote=: (#~ -.@('""'&E.))@}:@}.^:(('"' = {.) *. '"' = {:)
cutpara=: 3 : 0
txt=. topara y
txt=. txt,LF -. {:txt
b=. (}.b,0) < b=. txt=LF
b <;._2 txt
)
foldtext=: 4 : 0
if. 0 e. $y do. '' return. end.
y=. ; x&foldpara each cutpara y
y }.~ - (LF ~: |.y) i. 1
)
foldpara=: 4 : 0
if. 0=#y do. LF return. end.
r=. ''
x1=. >: x
txt=. y
while.
  ind=. ' ' i.~ |. x1{.txt
  s=. txt {.~ ndx=. x1 - >: x1 | ind
  s=. (+./\.s ~: ' ') # s
  r=. r, s, LF
  #txt=. (ndx + ind<x1) }. txt
do. end.
r
)
topara=: 3 : 0
if. 0=#y do. '' return. end.
b=. y=LF
c=. b +. y=' '
b=. b > (1,}:b) +. }.c,0
' ' (I. b) } y
)
18!:4 <'z'
3 : 0''
if. IFIOS do.
  r=. 'Engine: ',9!:14''
  r=. r,LF,'Library: ',JLIB
  r=. r,LF,'J/iOS Version: ',VERSION
  r=. r,LF,'Platform: ',UNAME,' ',IF64 pick '32';'64'
  r=. r,LF,'InstallPath: ', (2!:5'HOME'), '/Documents/j'
  JVERSION=: toJ r
end.
EMPTY
)
NB. break
NB.%break.ijs - break utilities
NB.-This script defines break utilities and is included in the J standard library.
NB.-Definitions are loaded into the z locale.
NB.-
NB.-`setbreak 'default'` is done by profile for Jqt. JHS and jconsole can use ctrl+c. 
NB.-
NB.-setbreak creates file `~break/Pid.Class` and writes 0 to the first byte.
NB.-
NB.-Pid is the process id and Class is normally 'default'.
NB.-
NB.-setbreak calls 9!:47 with this file.
NB.-
NB.-9!:47 maps the first byte of file, and JE tests this byte for break requests.
NB.-
NB.-Another task writes 1 or 2 to the file for attention/break.
NB.-
NB.-9!:46 returns the filename.
NB.-
NB.-`break 'abc'` sets break for JEs with class abc.
NB.-
NB.-JEs with the same class all get the break. A non-default class protects JE from the default break.
NB.-
NB.- A new setbreak replaces the old.
NB.-
NB.-`break 0'` shows breakhelp

cocurrent'z'

NB. =========================================================
NB.*break v break J execution
NB. y is class to signal - '' treated as 'default'
break=: 3 : 0
if. y-:0 do. breakhelp_j_ return. end.
breakclean_j_''
p=. jpath'~break/'
fs=. ((<p),each{."1[1!:0 p,'*')-.<9!:46''
pc=. (>:;fs i:each'/')}.each fs
i=. ;pc i.each'.'
pids=. _1".each i{.each pc
classes=. (>:i)}.each pc
if. y-:1 do. /:~(>":each pids),.>' ',each classes return. end.
'no task to break'assert #fs
if. (0=#y)+.2=3!:0 y do.
  b=. classes= (0=#y){y;'default'
  'bad class'assert +/b
  fs=. (<p),each (":each b#pids),each '.',each b#classes
else.
  i=. pids i.<y
  'bad pid'assert i~:#pids
  fs=. <p,(":;i{pids),'.',;i{classes
end.
for_f. fs do.
  v=. 2<.>:a.i.1!:11 f,<0 1
  (v{a.) 1!:12 f,<0
end.
i.0 0
)

NB. =========================================================
NB.*setbreak v set break file
NB.-Set break
NB. y is class
NB. Creates unique file ~break/Pid.Class
setbreak=: 3 : 0
if. (-.IFQT)*.y-:'default' do. i.0 0 return. end. NB. only for qt and not default
try.
  assert #y
  q=. jpath '~break/'
  1!:5 ::] <q
  f=. q,(":2!:6''),'.',y
  ({.a.) 1!:12 f;0
  9!:47 f
  breakclean_j_''
  f
catch. 13!:12'' end.
)

NB. =========================================================
NB.*breakclean v erase orphan break files
breakclean_j_=: 3 : 0
q=. jpath '~break/'
fs=. ((<q),each{."1[1!:0 q,'*')-.9!:46''
if. UNAME-:'Win' do.
  ferase fs NB. windows erase has not effect while file is in use
else.
  d=. dltb each}.<;._2 spawn_jtask_'ps -e'
  allpids=. ;0".each (d i.each ' '){.each d
  pc=. (>:;fs i:each'/')}.each fs
  pids=. ;_1".each (;pc i.each'.'){.each pc
  ferase (-.pids e. allpids)#fs
end.
)

NB. =========================================================
NB.*breakhelp n break help
breakhelp_j_=: 0 : 0
   break 0     NB. help
   break 1     NB. list other ~break pids and classes
   break ''    NB. break to all default class tasks
   break '...' NB. break to all ... class tasks
   break pid   NB. break to that pid

1st break stops execution at line start
2nd break stops execution mid-line, 6!:3 , socket select

profile does setbreak'default' for Jqt
profile does not do it for jconsole or JHS (use ctrl+c)

   setbreak'abc' NB. set break file for this pid and class abc

https://code.jsoftware.com/wiki/Standard_Library/break
)

cocurrent <'j'
Alpha=: a. {~ , (a.i.'Aa') +/ i.26
Num=: a. {~ (a.i.'0') + i.10
AlphaNum=: Alpha,Num
Boxes=: ((16+i.11) { a.),:'+++++++++|-'
ScriptExt=: '.ijs'
ProjExt=: '.jproj'

extnone=: {.~ i:&'.'
extproj=: , (ProjExt #~ '.'&e. < 0 < #)
extsrc=: , ('.ijs' #~ '.'&e. < 0 < #)

addfname=: , ('/' ~: {:) # i:&'/' }. ]
boxdraw=: 3 : '9!:7 y { Boxes'
hostcmd=: [: 2!:0 '(' , ,&' || true)'
fpath=: [: }: +./\.@:=&'/' # ]
isURL=: 1 e. '://'&E.
maxrecent=: 3 : '(RecentMax <. #r) {. r=. ~.y'
pack=: [: (,. ".&.>) ;: ::]
pdef=: 3 : '0 0$({."1 y)=: {:"1 y'
seldir=: #~ '-d'&-:"1 @ (1 4&{"1) @ > @ (4&{"1)
spath=: #~ [: *./\. '/'&~:
termLF=: , (0 < #) # LF -. {:
termsep=: , (0 < #) # '/' -. {:
remsep=: }.~ [: - '/' = {:

path2proj=: ,'/',ProjExt ,~ spath
win2lower=: 3 : 0
if. 0=#CasePaths_j_ do. tolower y return. end.
p=. jpathsep y
n=. 1 + p i. ':'
d=. n {. p
if. (<d) e. CasePaths_j_ do. y return. end.
b=. n }. p
p=. d,(('/'~:{.b)#'/'), b,'/'
p=. (1 + p i: '/') {. p
p=. (I.p='/') {.each <p
if. 1 e. p e. CasePaths_j_ do. y else. tolower y end.
)
3 : 0''
if. UNAME-:'Darwin' do.
  filecase=: tolower
  isroot=: '/' = {.
elseif. IFUNIX do.
  filecase=: ]
  isroot=: '/' = {.
elseif. do.
  filecase=: win2lower
  isroot=: ('\\' -: 2&{.) +. ('//' -: 2&{.) +. (':' = {.@}.)
end.
0
)
dirtreex=: 3 : 0
'' dirtreex y
:
y=. jpath y
p=. (+./\. y = '/') # y
d=. 1!:0 y,('/' = {:y) # '*'
if. 0 = #d do. '' return. end.
a=. > 4 {"1 d
m=. 'd' = 4 {"1 a
f=. (<p) ,each {."1 d
if. 1 e. m do.
  f=. f, ; dirtreex each (m#f) ,each <'/','*'
end.
if. #x do.
  f #~ (1 e. x E. ])&> f
end.
)
getfolderdefs=: 3 : 0
p=. (, '/' , ProjExt ,~ spath) each subdirtree y
t=. p #~ #@(1!:0)&> p
t;<fpath each (1+#y) }. each (-#ProjExt) }. each t
)
isconfigfile=: 3 : 0
'p f'=. fpathname y
x=. f i: '.'
(p -: jpath '~config/') *. '.cfg'-:x}.f
)
isdir=: 3 : 0
d=. 1!:0 fboxname y
if. 1 ~: #d do. 0 return. end.
'd' = 4 { 4 pick ,d
)
isfile=: 3 : 0
d=. 1!:0 fboxname y
if. 1 ~: #d do. 0 return. end.
'd' ~: 4 { 4 pick ,d
)
istempname=: 3 : 0
x=. y i: '.'
*./ ('.ijs'-:x}.y),(x{.y) e. Num
)
istempscript=: 3 : 0
'p f'=. fpathname y
(p -: jpath '~temp/') *. istempname f
)
jshowconsole=: 3 : 0
if. -.IFWIN do. 'only supported in windows' return. end.
t=. {.>'kernel32.dll GetConsoleWindow x'cd''
'user32.dll ShowWindow n x i'cd t;(0-:y){5 0
i.0 0
)
mkdir=: 3 : 0
a=. termsep jpath y
if. #1!:0 }:a do. 1 return. end.
for_n. I. a='/' do.
  1!:5 :: 0: < n{.a
end.
)
newtempscript=: 3 : 0
x=. ScriptExt
p=. jpath '~temp/'
d=. 1!:0 p,'*',x
a=. (-#x) }. each {."1 d
a=. a #~ (*./ .e.&'0123456789') &> a
a=. 0, {.@:(0&".) &> a
p, x ,~ ": {. (i. >: #a) -. a
)
nounrep=: 2 }. [: ; [: nounrep1 each ;:
nounrep1=: LF2 , ] , '=: ' , [: nounrep2 ".
nounrep2=: 3 : 0
if. 0 = #y do. '''''' return. end.
select. 3!:0 y
fcase. 32 do.
  y=. ; y ,each LF
case. 2 do.
  if. LF e. y do.
    y=. y, LF -. {:y
    '0 : 0', LF, ; <;.2 y,')'
  else.
    quote y
  end.
case. do.
  ": y
end.
)
octal=: 3 : 0
t=. ,y
if. LF e. t do.
  t=. octal each <;._2 t,LF
  }: ; t ,each LF return.
end.
u=. isutf8 t
x=. a. i. t
m=. (x e. 9 13) < x < 32
if. u > 1 e. m do. t return. end.
n=. I. m=. m +. u < x > 126
s=. '\',.}.1 ": 8 (#.^:_1) 255,n{x
s ((n+3*i.#n)+/i.4)} (>:3*m)#t
)
revinfo=: 3 : 0
v=. 9!:14''
if. '.' e. (v i. '/') {. v do.
  res=. 8 {. <;._1 '/',v
  a=. 0 pick res
  ndx=. a i. '-'
  beta=. {. 0 ". (ndx+5) }. a
  vno=. 100 #. (0 ".&> <;._1 '.' 0} ndx {. a), beta
  vno;res
else.
  res=. 9 {. <;._1 '/',v
  'a b'=. 0 3 { res
  res=. (<<<0 3) {res
  res=. (('www.jsoftware.com' -: 3 pick res){'na';'GPL3') 2} res
  'm n'=. ": each ver=. 0 100 #: 0 ". }. a
  num=. _97 + a.i. {:b
  if. 'r' = {. b do.
    rev=. (num+1),0
    vst=. 'j',m,'.',n,'.',":num+1
  else.
    rev=. 0,num
    vst=. 'j',m,'.',n,'.0-beta',":num
  end.
  (100 #.ver,rev);vst;res
end.
)
rmdir=: 3 : 0
r=. 1;'not a directory: ',":y
if. 0=#y do. r return. end.
d=. 1!:0 y
if. 1 ~: #d do. r return. end.
if. 'd' ~: 4 { 4 pick {. d do. r return. end.
if. IFWIN do.
  shell_jtask_ 'rmdir "',y,'" /S /Q'
else.
  hostcmd_j_ 'rm -rf ',((UNAME-:'Linux')#'--preserve-root '),y
end.
(#1!:0 y);''
)
runimmx0_j_=: 3 : 0
IMMX_j_=: utf8 y
9!:27 '0!:100 IMMX_j_'
9!:29 [ 1
)
runimmx1_j_=: 3 : 0
IMMX_j_=: utf8 y
9!:27 '0!:101 IMMX_j_'
9!:29 [ 1
)
scripts=: 3 : 0
if. 0=#y do.
  list 0{"1 Public
elseif. 'v'e.y do.
  dir=. Public
  a=. >0{"1 dir
  b=. >1{"1 dir
  a /:~ a,.' ',.b
elseif. 1 do.
  'invalid argument to scripts: ',,":y
end.
)
setfolder=: 3 : 0
if. 0=#y do.
  Folder=: FolderTree=: FolderIds=: '' return.
end.
assert. (<y) e. {."1 UserFolders
Folder=: y
'FolderTree FolderIds'=: getfolderdefs jpath '~',y
if. 3=nc <'snapshot_tree_jp_' do.
  snapshot_tree_jp_ FolderTree
end.
EMPTY
)
subdirtree=: 3 : 0
if. 0=#1!:0 y do. '' return. end.
r=. ''
dir=. <y,'/'
while. #dir do.
  fpath=. (>{.dir) &,
  dir=. }.dir
  dat=. seldir 1!:0 fpath '*'
  if. #dat do.
    dat=. fpath each {."1 dat
    r=. r,dat
    dir=. (dat ,each '/'),dir
  end.
end.
sort filecase each r
)
unixshell=: 3 : 0
f=. jpath '~temp/shell.sh'
t=. jpath '~temp/shell.txt'
e=. jpath '~temp/shell.err'
('#!/bin/sh',LF,y,LF) fwrite f
'rwx------' 1!:7 <f
hostcmd '"',f,'" > "',t,'" 2> "',e,'"'
r=. (fread t);fread e
ferase f;t;e
r
)
unixshellx=: 3 : 0
'res err'=. unixshell y
if. #err do.
  smoutput 'Shell command error: ',LF,LF,err
end.
res
)
browseref=: 3 : 0
htmlhelp 'dictionary/',y
)
dquote=: 3 : 0
if. '"' = {.y do. y else. '"',y,'"' end.
)
browse=: 3 : 0
if. -. isURL cmd=. dltb y do.
  if. -.fexist cmd do. EMPTY return. end.
end.
if. IFJHS do.
  redirecturl_jijxm_=: file2url cmd
  EMPTY return.
elseif. IFIOS do.
  jh '<a href="',(file2url cmd),'"</a>'
  EMPTY return.
end.
browser=. Browser_j_
select. UNAME
case. 'Win' do.
  ShellExecute=. 'shell32 ShellExecuteW > i x *w *w *w *w i'&cd
  SW_SHOWNORMAL=. 1
  NULL=. <0
  if. 0 = #browser do.
    r=. ShellExecute 0;(uucp 'open');(uucp winpathsep cmd);NULL;NULL;SW_SHOWNORMAL
  else.
    r=. ShellExecute 0;(uucp 'open');(uucp winpathsep browser);(uucp dquote winpathsep cmd);NULL;SW_SHOWNORMAL
  end.
  if. r<33 do. sminfo 'browse error:',browser,' ',cmd,LF2,1{::cderx'' end.
case. 'Android' do.
  android_exec_host 'android.intent.action.VIEW';(utf8 ('file://'&,)@abspath^:(-.@isURL) cmd);'text/html';16b0004000
case. do.
  if. 0 = #browser do.
    browser=. dfltbrowser''
  end.
  browser=. dquote (browser;Browser_nox_j_){::~ nox=. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') *. (0;'') e.~ <2!:5 'DISPLAY'
  cmd=. browser,' ',dquote cmd
  try.
    2!:1 cmd, (0=nox)#' >/dev/null 2>&1 &'
  catch.
    msg=. 'Could not run the browser with the command:',LF2
    msg=. msg, cmd,LF2
    if. IFQT do.
      msg=. msg, 'You can change the browser definition in Edit|Configure|Base',LF2
    end.
    sminfo 'Run Browser';msg
  end.
end.
EMPTY
)
dfltbrowser=: verb define
select. UNAME
case. 'Android' do. ''
case. 'Win' do. ''
case. 'Darwin' do. 'open'
case. do.
  try.
    2!:0'which x-www-browser 2>/dev/null'
    'x-www-browser' return. catch. end.
  try.
    2!:0'which google-chrome 2>/dev/null'
    'google-chrome' return. catch. end.
  try.
    2!:0'which chromium 2>/dev/null'
    'chromium' return. catch. end.
  try.
    2!:0'which chromium-browser 2>/dev/null'
    'chromium-browser' return. catch. end.
  try.
    2!:0'which firefox 2>/dev/null'
    'firefox' return. catch. end.
  try.
    2!:0'which konqueror 2>/dev/null'
    'konqueror' return. catch. end.
  try.
    2!:0'which opera 2>/dev/null'
    'opera' return. catch. end.
  '' return.
end.
)
viewpdf=: 3 : 0
if. -. isURL cmd=. dltb y do.
  if. -.fexist cmd do. EMPTY return. end.
end.
if. IFJHS do.
  redirecturl_jijxm_=: file2url cmd
  EMPTY return.
elseif. IFIOS do.
  jh '<a href="',(file2url cmd),'"</a>'
  EMPTY return.
end.
PDFReader=. PDFReader_j_
select. UNAME
case. 'Win' do.
  ShellExecute=. 'shell32 ShellExecuteW > i x *w *w *w *w i'&cd
  SW_SHOWNORMAL=. 1
  NULL=. <0
  if. 0 = #PDFReader do.
    r=. ShellExecute 0;(uucp 'open');(uucp winpathsep cmd);NULL;NULL;SW_SHOWNORMAL
  else.
    r=. ShellExecute 0;(uucp 'open');(uucp winpathsep PDFReader);(uucp dquote winpathsep cmd);NULL;SW_SHOWNORMAL
  end.
  if. r<33 do. sminfo 'view pdf error:',PDFReader,' ',cmd,LF2,1{::cderx'' end.
case. 'Android' do.
  android_exec_host 'android.intent.action.VIEW';(utf8 ('file://'&,)@abspath^:(-.@isURL) cmd);'application/pdf';0
case. do.
  PDFReader=. dquote PDFReader
  cmd=. PDFReader,' ',(dquote cmd),' &'
  try.
    2!:1 cmd
  catch.
    msg=. 'Could not run the PDFReader with the command:',LF2
    msg=. msg, cmd,LF2
    if. IFQT do.
      msg=. msg, 'You can change the PDFReader definition in Edit|Configure|Base',LF2
    end.
    sminfo 'Run PDFReader';msg
  end.
end.
EMPTY
)

linux_pdfreader=: <;._2]0 :0
xdg-open
evince
kpdf
xpdf
okular
acroread
)
dfltpdfreader=: verb define
select. UNAME
case. 'Win' do. ''
case. 'Android' do. ''
case. 'Darwin' do. 'open'
case. do.
  nox=. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') *. (0;'') e.~ <2!:5 'DISPLAY'
  if. (((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') > nox) *. ''-: te=. nox{::PDFReader_j_;PDFReader_nox_j_ do.
    for_t. linux_pdfreader do.
      try. 2!:0'which ',(>t),' 2>/dev/null'
        te=. >t
        break.
      catch. end.
    end.
  end.
  te
end.
)
Folder=: ''
FolderTree=: FolderIds=: 0

Cwh=: 79 24
jpath=: 3 : 0
nam=. jpathsep y
if. '~' ~: {. nam do. return. end.
fld=. SystemFolders, UserFolders
ind=. nam i. '/'
tag=. }. ind {. nam
if. 0=#tag do.
  tag=. 'home'
  nam=. '~home',}.nam
  ind=. nam i. '/'
end.
if. tag -: 'addons' do.
  bal=. 8 }. nam
end.
par=. '.' = {. tag
if. par do.
  len=. ('.' = tag) i. 0
  tag=. len }. tag
end.
ndx=. ({."1 fld) i. <tag
if. ndx < # fld do.
  bal=. ind }. nam
  pfx=. 1 pick ndx { fld
  if. '~' = {.pfx do.
    pfx=. jpath pfx
  end.
  if. par do.
    pfx=. ((#pfx) | (+/\. pfx='/') i: len) {. pfx
  end.
  nam=. pfx,bal
end.
nam
)
tofoldername=: 3 : 0
if. 0=#y do. '' return. end.
folders=. UserFolders,SystemFolders
pds=. {."1 folders
pps=. termsep each {:"1 folders
ndx=. \: # &> pps
pds=. ndx{pds
pps=. ndx{pps
res=. filecase each boxxopen y
len=. # &> pps
for_i. i.#res do.
  nam=. i pick res
  if. '~' = {. nam,'~' do. continue. end.
  msk=. pps = len {. each <nam,'/'
  if. 1 e. msk do.
    ndx=. ((i. >./) msk # len) { I. msk
    nam=. ('~', > ndx { pds),(<: ndx { len) }. nam
    res=. (<nam) i } res
  end.
end.
pps=. }: each pps
ndx=. 1 + pps i: &> '/'
msk=. ndx < len
pps=. msk # ndx {.each pps
pds=. msk # pds
len=. # &> pps
for_i. i.#res do.
  nam=. i pick res
  if. '~' = {. nam,'~' do. continue. end.
  if. '/' = {. nam do. continue. end.
  msk=. pps = len {. each <nam
  if. 1 e. msk do.
    ndx=. ((i. >./) msk # len) { I. msk
    nam=. ('~.', > ndx { pds),(<: ndx { len) }. nam
    res=. (<nam) i } res
  end.
end.
if. L. y do. res else. >res end.
)
Loaded=: ''
Public=: i. 0 2
UserFolders=: i. 0 2
getignore=: 3 : 0
r=. ' colib compare convert coutil dates dir dll files libpath strings text gl2 graphics/gl2'
Ignore=: <;._1 r
)

getignore''
buildpublic=: 3 : 0
dat=. deb toJ y
dat=. a: -.~ <;._2 dat, LF
ndx=. dat i. &> ' '
short=. ndx {.each dat
long=. ndx }. each dat
long=. extsrc@jpathsep@deb each long
msk=. (<'system','/') = 7 {. each long
long=. (msk{'';'~') ,each long
msk=. (i. ~.) {."1 Public=: Public,~ short,.long
Public=: sort msk{Public
empty''
)
cutnames=: 3 : 0
if. LF e. y do.
  txt=. y, LF
  nms=. (txt = LF) <;._2 txt
else.
  txt=. y, ' '
  msk=. txt = '"'
  com=. (txt = ' ') > ~: /\ msk
  msk=. (msk *. ~:/\msk) < msk <: 1 |. msk
  nms=. (msk # com) <;._2 msk # txt
end.
nms -. a:
)
3 : 0''
if. 0=9!:24'' do.
  exist=: fexist
else.
  exist=: 0:
end.
1
)
fullname=: 3 : 0
p=. '/'
d=. jpath y
if. </ d i. ':',p do.
elseif. (2{.d) -: 2#p do.
elseif. p ~: 1{.d do.
  jcwdpath d
elseif. IFWIN do.
  (2{.jcwdpath''),d
end.
)
getscripts=: 3 : 0
if. 0=#y do. '' return. end.
if. 0=L.y do.
  if. isfile y do.
    fullname each fboxname y return.
  end.
  y=. cutnames y
end.
y=. y -. Ignore
if. 0=#y do. '' return. end.
ndx=. ({."1 Public) i. y
ind=. I. ndx < # Public
y=. ((ind { ndx) { 1 {"1 Public) ind } y
ind=. (I.-.isroot&>y) -. ind
if. #ind do.
  bal=. jpath each ind { y
  msk=. (isfile &> bal) +. '/'={:&> bal
  y=. (msk#bal) (msk#ind) } y
  ind=. (-.msk)#ind
  if. #ind do.
    bal=. (-.msk)#bal
    msk=. -. '.'&e.@(}.~i:&'/') &> bal
    msk=. msk *. *./@:((a.{~, 65 97 +/i.26)e.~])@:({.~i.&'/') &> bal
    msk=. msk > isroot &> bal
    cnt=. ('/' +/ .= ]) &> bal
    ndx=. I. msk *. cnt=1
    bal=. (addfname each ndx { bal) ndx } bal
    ndx=. I. msk *. cnt > 0
    bal=. (<jpath '~addons/') ,each (ndx{bal) ,each <'.ijs'
    y=. bal (ndx{ind) } y
  end.
end.
fullname each y
)
getpath=: ([: +./\. =&'/') # ]
xedit=: 0&$: : (4 : 0)
'file row'=. 2{.(boxopen y),<0
file=. dltb file
if. -.fexist file do. EMPTY return. end.
if. IFJHS do.
  xmr ::0: file
  EMPTY return.
end.
if. UNAME-:'Android' do.
  if. IFJA do.
    android_exec_host 'android.intent.action.VIEW';(utf8 ('file://'&,)@abspath^:(-.@isURL) file);'text/plain';0
  elseif. 1=ftype '/system/bin/vi' do.
    2!:1 '/system/bin/vi', ' ', (dquote >@fboxname file)
  elseif. 1=ftype '/system/xbin/vi' do.
    2!:1 '/system/xbin/vi', ' ', (dquote >@fboxname file)
  elseif. #Editor_j_ do.
    2!:1 Editor_j_, ' ', (dquote >@fboxname file)
  end.
  EMPTY return.
end.
editor=. (Editor_j_;Editor_nox_j_){::~ nox=. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') *. (0;'') e.~ <2!:5 'DISPLAY'
if. 0=#editor do. EMPTY return. end.
nox=. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') *. (0;'') e.~ <2!:5 'DISPLAY'
if. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD')>nox do.
  if. 1 e. r=. 'term' E. editor do.
    if. '-e ' -: 3{. editor=. dlb (}.~ i.&' ') ({.I.r)}.editor do.
      editor=. TermEmu, (('gnome-terminal'-:TermEmu){::' -e ';' -- '), dlb 3}.editor
    else.
      editor=. TermEmu, ' ', editor
    end.
  else.
    editor=. TermEmu, (('gnome-terminal'-:TermEmu){::' -e ';' -- '), editor
  end.
end.
if. 1 e. '%f' E. editor do.
  cmd=. editor stringreplace~ '%f';(dquote >@fboxname file);'%l';(":>:row)
else.
  cmd=. editor, ' ', (dquote >@fboxname file)
end.
try.
  if. IFUNIX do.
    if. x do.
      2!:1 cmd
    else.
      2!:1 cmd, (0=nox)#' 1>/dev/null &'
    end.
  else.
    (x{0 _1) fork_jtask_ cmd
  end.
catch.
  msg=. '|Could not run the editor:',cmd,LF
  msg=. msg,'|You can change the Editor definition in Edit|Configure|Base'
  smoutput msg
end.
EMPTY
)

linux_terminal=: <;._2]0 :0
x-terminal-emulator
gnome-terminal
mate-terminal
konsole
urxvt
rxvt
lxterminal
xfce4-terminal
eterm
terminator
terminology
st
xterm
)
dflttermemu=: verb define
nox=. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') *. (0;'') e.~ <2!:5 'DISPLAY'
if. (((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') > nox) *. ''-: te=. nox{::TermEmu_j_;TermEmu_nox_j_ do.
  for_t. linux_terminal do.
    try. 2!:0'which ',(>t),' 2>/dev/null'
      te=. >t
      break.
    catch. end.
  end.
end.
te
)
viewimage=: 3 : 0
if. -. isURL cmd=. dltb y do.
  if. -.fexist cmd do. EMPTY return. end.
end.
if. IFJHS do.
  redirecturl_jijxm_=: file2url cmd
  EMPTY return.
elseif. IFIOS do.
  jh '<a href="',(file2url cmd),'"</a>'
  EMPTY return.
end.
nox=. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') *. (0;'') e.~ <2!:5 'DISPLAY'
ImageViewer=. nox{::ImageViewer_j_;ImageViewer_nox_j_
select. UNAME
case. 'Win' do.
  ShellExecute=. 'shell32 ShellExecuteW > i x *w *w *w *w i'&cd
  SW_SHOWNORMAL=. 1
  NULL=. <0
  r=. ShellExecute 0;NULL;(uucp winpathsep cmd);NULL;NULL;SW_SHOWNORMAL
  if. r<33 do. sminfo 'view image error: ',cmd,LF2,1{::cderx'' end.
case. 'Android' do.
  android_exec_host 'android.intent.action.VIEW';(utf8 ('file://'&,)@abspath^:(-.@isURL) cmd);'image/*';0
case. do.
  if. 0 = #ImageViewer do.
    ImageViewer=. dfltimageviewer''
  end.
  if. 0 = #ImageViewer do.
    browser=. Browser_j_
    if. 0 = #browser do.
      browser=. dfltbrowser''
    end.
    browser=. dquote (browser;Browser_nox_j_){::~ nox=. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD') *. (0;'') e.~ <2!:5 'DISPLAY'
  else.
    browser=. dquote ImageViewer
  end.
  cmd=. browser,' ',dquote cmd
  try.
    2!:1 cmd, (0=nox)#' >/dev/null 2>&1 &'
  catch.
    msg=. 'Could not run the image viewer with the command:',LF2
    msg=. msg, cmd,LF2
    if. IFQT do.
      msg=. msg, 'You can change the imageviewer definition in Edit|Configure|Base',LF2
    end.
    sminfo 'Run image viewer';msg
  end.
end.
EMPTY
)
dfltimageviewer=: verb define
select. UNAME
case. 'Win' do. ''
case. 'Android' do. ''
case. 'Darwin' do. 'open'
case. do.
  try.
    2!:0'which xdg-open 2>/dev/null'
    'xdg-open' return. catch. end.
  try.
    2!:0'which eog 2>/dev/null'
    'eog' return. catch. end.
  '' return.
end.
)
cocurrent 'z'
jpath=: jpath_j_
load=: 3 : 0
0 load y
:
fls=. getscripts_j_ y
fn=. ('script',x#'d')~
for_fl. fls do.
  if. Displayload_j_ do. smoutput > fl end.
  if. -. fexist fl do.
    smoutput 'not found: ',>fl
  end.
  fn fl
  Loaded_j_=: ~. Loaded_j_,fl
end.
empty''
)
loadd=: 1&load
require=: 3 : 0
fls=. Loaded_j_ -.~ getscripts_j_ y
if. # fls do. load fls else. empty'' end.
)
scripts=: scripts_j_
show=: 3 : 0
y=. y,(0=#y)#0 1 2 3
if. (3!:0 y) e. 2 32 do. y=. cutopen y
else. y=. (4!:1 y) -. (,'y');,'y.' end.
wid=. {.wcsize''
sub=. '.'&(I. @(e.&(9 10 12 13 127 254 255{a.))@]})
den=: {{ try. 0 $.y [ 3 $. y catch. y end. }}
j=. '((1<#$t)#(":$t),''$''),":,t'
j=. 'if. L. t=. den ".y do. 5!:5 <y return. end.';j
j=. 'if. 0~:4!:0 <y do. 5!:5 <y return. end.';j
a=. (,&'=: ',sub @ (3 : j)) each y
}: ; ((wid <. #&> a) {.each a) ,each LF
)
xedit=: xedit_j_
wcsize=: 3 : 0
if. (IFQT+.IFJNET+.IFJHS+.IFIOS+.UNAME-:'Android') < IFUNIX do.
  |.@".@(-.&LF)@(2!:0) :: (Cwh_j_"_) '/bin/stty size 2>/dev/null'
else.
  (Cwh_j_"_)`((0 ". wd) :: (Cwh_j_"_))@.IFQT 'sm get termcwh'
end.
)
coclass 'jcompare'

MAXPFX=: 100
MAXLCS=: *: MAXPFX
cin=: e. ,
fmt0=: 'p<0 [>q<] >' & (8!:0)
fmt1=: 'p<1 [>q<] >' & (8!:0)
lcs=: * * 1 + >./\@:(_1&|.)@:(>./\"1@:(_1&|."1))
mindx=: }.@{.@/:~@(+/"1 ,. ])
remltws=: 3 : 0
y=. y, LF
dat=. <;._2 y
msk=. CR = {: &> dat
dat=. (-msk) }. each dat
fn=. #~ ([: (+./\ *. +./\.) -.@(e.&(' ',TAB)))
dat=. fn each dat
dat=. dat ,each msk{'';CR
}: ; dat ,each LF
)
comp=: 4 : 0

sep=. ((LF cin x) +. LF cin y) { CRLF
if. 2=#$x do. x=. <@dtb"1 x
else. x=. <;._2 x,sep -. {:x end.
if. 2=#$y do. y=. <@dtb"1 y
else. y=. <;._2 y,sep -. {:y end.
if. x -: y do. 'no difference' return. end.
XY=: x,y
AX=: X=: XY i. x
AY=: Y=: XY i. y
NX=: i.#x
NY=: i.#y
SX=: SY=: ''
while. compend'' do. complcs'' end.
sx=. /:~ SX
sy=. /:~ SY
x=. (fmt0 sx) ,each (sx { AX) { XY
y=. (fmt1 sy) ,each (sy { AY) { XY
r=. (x,y) /: (sx,.0),sy,.1
}: ; r ,each LF
)
fcomp=: 4 : 0
'p j n'=. 3 {. x
'ifws ifsep'=. 2 2 #: j
'x y'=. _2 {. ,&p each cutopen y
if. L. n do.
  'nx ny'=. n
else.
  nx=. x [ ny=. y
end.
f=. 1!:1 :: _1:
tx=. f x=. fboxname x
if. tx -: _1 do. 'unable to read ',nx return. end.
ty=. f y=. fboxname y
if. ty -: _1 do. 'unable to read ',ny return. end.
tx=. f2utf8 tx
ty=. f2utf8 ty
if. ifsep do.
  tx=. toJ tx
  ty=. toJ ty
end.
if. ifws do.
  tx=. remltws tx
  ty=. remltws ty
end.
f=. _3&{.@('0'&,@(":@]))
mth=. _3[\'   JanFebMarAprMayJunJulAugSepOctNovDec'
'a m d h n s'=. 6{.1 pick dx=. ,1!:0 x
fx=. (4":d),' ',(m{mth),'  ::' 0 3 6 9};f &.> 100|a,h,n,s
'a m d h n s'=. 6{.1 pick dy=. ,1!:0 y
fy=. (4":d),' ',(m{mth),'  ::' 0 3 6 9};f &.> 100|a,h,n,s
'nx ny'=. <"1>nx;ny
r=. 'comparing:',LF
r=. r,nx,fx,'  ',(":2 pick dx),LF
r=. r,ny,fy,'  ',(":2 pick dy),LF
r,tx compare ty
)
compare=: 4 : 0
if. x -: y do. 'no difference' return. end.
if. 0=#x do. 'empty left argument' return. end.
if. 0=#y do. 'empty right argument' return. end.
a=. conew 'jcompare'
r=. x comp__a y
coerase a
r
)
fcompare=: 3 : 0
('';0) fcomp y
:
(x;0) fcomp y
)
fcompares=: 3 : 0
('';1) fcomp y
:
(x;1) fcomp y
)
compend=: 3 : 0
old=. 0 0
len=. (#X),#Y

while. -. len -: old do.
  old=. len
  t=. <./len
  m=. 0 i.~ (t {. X) = t {. Y
  X=: m }. X
  Y=: m }. Y
  t=. m - t
  n=. - +/ *./\. (t {. X) = t {. Y
  X=: n }. X
  Y=: n }. Y
  NX=: m }. n }. NX
  NY=: m }. n }. NY
  m=. X e. Y
  if. 0 e. m do.
    SX=: SX,(-.m)#NX
    X=: m # X
    NX=: m # NX
  end.
  m=. Y e. X
  if. 0 e. m do.
    SY=: SY,(-.m)#NY
    Y=: m # Y
    NY=: m # NY
  end.
  len=. (#X),#Y
end.
if. -. 0 e. len do. 1 return. end.
SX=: SX,NX
SY=: SY,NY
0
)
complcs=: 3 : 0
lx=. #X
ly=. #Y
if. MAXLCS < lx * ly do.
  select. MAXPFX < lx,ly
  case. 0 1 do.
    ly=. <. MAXLCS % lx
  case. 1 0 do.
    lx=. <. MAXLCS % ly
  case. do.
    lx=. ly=. MAXPFX
  end.
end.
a=. lx {. X
b=. ly {. Y
m=. ((b =/ a),.0),0
cm=. lcs ^:_ m
len=. >./ ,cm
rc=. 1 + mindx ($cm) #: I. len = ,cm
cm=. , rc {. cm
msk=. (1+i.len) =/ cm
ndx=. <@I."1 msk
pos=. ; (<rc) #: each ndx
pos=. (+/"1 pos),.pos
pos=. ((# &> ndx) # i.len),.pos
pos=. /:~ pos
'ib ia'=. |: 2 }."1 (~:{."1 pos)#pos
n=. 1 + {: ia
SX=: SX,(<<<ia) { n {. NX
X=: n }. X
NX=: n }. NX
n=. 1 + {: ib
SY=: SY,(<<<ib) { n {. NY
Y=: n }. Y
NY=: n }. NY
0
)
compare_z_=: compare_jcompare_
fcompare_z_=: fcompare_jcompare_
fcompares_z_=: fcompares_jcompare_
cocurrent <'base'
NB. task
NB.
NB. executing tasks with optional timeout or I/O
NB.
NB. TASKS WITHOUT I/O
NB.
NB.   fork_jtask_ 'notepad.exe'           NB. run notepad, no wait, no I/O
NB.   5000 fork_jtask_ 'notepad.exe'      NB. run notepad, wait 5 sec, no I/O
NB.   _1 fork_jtask_ 'notepad.exe'        NB. run notepad, until closed, no I/O
NB.
NB.   5000 fork_jtask_ 'cmd /k dir'  NB. show dir in cmd window for 5 sec and close
NB.   _1 fork_jtask_ 'cmd /k dir'    NB. show dir in cmd window until user closes it
NB.
NB.   launch jpath'~system'        NB. run default application, no wait
NB.
NB. TASKS WITH I/O
NB.
NB.   spawn_jtask_ 'net users'                    NB. get stdout from process
NB.   '+/i.3 4' spawn_jtask_ 'jconsole'           NB. call process with I/O
NB.   12 15 18 21
NB.
NB. SHELL COMMANDS (WITH I/O)
NB.
NB.   shell'echo.|time'                    NB. get result of shell command
NB. The current time is:  8:04:13.09
NB. Enter the new time:
NB.
NB.   (shell'dir /b')shell'find ".dll"'    NB. get all DDL names by piping
NB. j.dll
NB. jregexp.dll
NB.
NB. NOTE: the implementation uses C-type structures
NB.       by the original Method of Named Fields
NB.
NB. Script developed by Oleg Kobchenko.

coclass <'jtask'
NB. task util

int=: {.@:(_2&ic)
sint=: 2&ic

i64=: {.@:(_3&ic)
si64=: 3&ic

ptr=: int`i64@.IF64
sptr=: sint`si64@.IF64

NB. =========================================================
NB. METHOD OF NAMED FIELDS
sndx=: i.@#@[ + {.@I.@E.

NB. struct=. 'valu' 'memb' sset structdef struct
sset=: 2 : '(m sndx n)}'

NB. value=. 'memb' sget structdef struct
sget=: 2 : '(m sndx n)&{'

szero=: # # (0{a.)"_

st64=: -.&'.'^:(-.IF64)

t=. 'Cbyt....Resv....Desk....Titl....XposYposXsizYsizXcntYcnt'
STARTUPINFO=:  st64 t,'FillFlagSwRs....Resv....Inph....Outh....Errh....'
PROCESSINFO=:  st64 'Proh....Thrh....PridThid'
SECURITYATTR=: st64 'Cbyt....Secd....Inhe'

'Outh Errh Inph Proh Thrh'=: ,"1&'....'^:IF64>;:'Outh Errh Inph Proh Thrh'

STARTF_USESTDHANDLES=: 16b100
STARTF_USESHOWWINDOW=: 1
WAIT_TIMEOUT=: 258
CREATE_NEW_CONSOLE=: 16b10
DUPLICATE_SAME_ACCESS=: 2

cdk=: 1 : '(''kernel32 '',m)&cd'

WaitForSingleObject=: 'WaitForSingleObject > i x i' cdk
CloseHandle=:         'CloseHandle         > i x' cdk"0
TerminateProcess=:    'TerminateProcess    > i x i' cdk
ReadFile=:            'ReadFile              i x *c i *i x' cdk
WriteFile=:           'WriteFile             i x *c i *i x' cdk
GetCurrentProcess=:   'GetCurrentProcess   > x' cdk

DuplicateHandleF=:    'DuplicateHandle       i  x x  x *x  i i i' cdk
CreatePipeF=:         'CreatePipe            i *x *x *c i' cdk
CreateProcessF=:      'CreateProcessW        i x *w x x i  i x x *c *c' cdk

DuplicateHandle=: 3 : 0
p=. GetCurrentProcess ''
h=. {. 4{:: DuplicateHandleF p;y;p;(,_1);0;0;DUPLICATE_SAME_ACCESS
CloseHandle y
h
)

NB. =========================================================
NB. 'hRead hWrite'=. CreatePipe Inheritable=0
NB.    ... FileRead/FileWrite ...
NB. CloseHandle hRead,hWrite
NB.
NB. Inheritable: 0 none, 1 for read, 2 for write
CreatePipe=: 3 : 0
'inh size'=. 2{.y,0
sa=. szero SECURITYATTR
sa=. (sint #SECURITYATTR) 'Cbyt' sset SECURITYATTR sa
sa=. (sint *inh) 'Inhe' sset SECURITYATTR sa
'hRead hWrite'=. ; 1 2{ CreatePipeF (,_1);(,_1);sa;size
if. 1=inh do. hRead=. DuplicateHandle hRead end.
if. 2=inh do. hWrite=. DuplicateHandle hWrite end.
hRead,hWrite
)

NB. =========================================================
NB. hProcess=. [hWriteOut[,hReadIn]] CreateProcess 'program agr1 agr2 ...'
NB.    ...
NB. CloseHandle hProcess
CreateProcess=: 3 : 0
'' CreateProcess y
:
'ow ir'=. 2{.x,0
si=. szero STARTUPINFO
si=. (sint #STARTUPINFO) 'Cbyt' sset STARTUPINFO si
f=. inh=. 0
if. +/ir,ow do.
  inh=. 1
  f=. CREATE_NEW_CONSOLE
  si=. (sint STARTF_USESTDHANDLES+STARTF_USESHOWWINDOW) 'Flag' sset STARTUPINFO si
  if. ow do.
    si=. (sptr ow) Outh sset STARTUPINFO si
    si=. (sptr ow) Errh sset STARTUPINFO si
  end.
  if. ir do. si=. (sptr ir) Inph sset STARTUPINFO si end.
end.
pi=. szero PROCESSINFO
'r pi'=. 0 _1{ CreateProcessF 0;(uucp y);0;0;inh; f;0;0;si;pi
if. 0=r do. 0 return. end.
ph=. ptr Proh sget PROCESSINFO pi
th=. ptr Thrh sget PROCESSINFO pi
CloseHandle th
ph
)

NB. =========================================================
NB. ph=. h CreateProcess 'program agr1 agr2 ...'
NB.    ...
NB. Wait ph;5000
NB. CloseHandle ph
Wait=: 3 : 0
r=. WaitForSingleObject y
if. WAIT_TIMEOUT=r do. TerminateProcess (0 pick y);_1 end.
)

NB. =========================================================
NB. ph=. h CreateProcess 'program agr1 agr2 ...'
NB.    ...
NB. r=. ReadAll h
NB. CloseHandle h,ph
ReadAll=: 3 : 0
ret=. ''
str=. 4096#'z'
while. 1 do.
  'r str len'=. 0 2 4{ ReadFile y;str;(#str);(,_1);0
  len=. {.len
  if. (0=r)+.0=len do.
    'ec es'=: cderx''
    if. -.ec e.0 109 do. ret=. _1 end.
    break.
  end.
  ret=. ret,len{.str
end.
ret
)

NB. =========================================================
NB. ph=. hr,hw CreateProcess 'program agr1 agr2 ...'
NB. r=. WriteAll hw
NB. CloseHandle hw
NB. r=. ReadAll hr
NB. CloseHandle hr,ph
WriteAll=: 3 : 0
:
while. #x do.
  'r x len'=. 0 2 4{ WriteFile y;x;(#x);(,_1);0
  len=. {.len
  if. (0=r)+.0=len do.
    'ec es'=: cderx''
    if. -.ec e.0 109 do. ret=. _1 end.
    break.
  end.
  x=. len}.x
end.
1
)
NB. task main

NB. =========================================================
NB.*fork v run task and optionally wait for completion
NB.
NB. form: [timeout=0] fork cmdline
NB.
NB.   timeout: 0 no wait, _1 infinite, >0 timeout
NB.   cmdline: 'shortcmd arg1 arg2 ...'
NB.   cmdline: '"command with space" arg1 ...'
NB.
NB. e.g. fork_jtask_ 'notepad.exe'
fork=: (3 : 0)`([: 2!:1 '(' , ')&' ,~ ])@.IFUNIX
0 fork y
:
ph=. CreateProcess y
if. x do. Wait ph;x end.
CloseHandle ph
empty''
)

NB. =========================================================
NB.*spawn v [monad] get stdout of executed task
NB.
NB. form:  stdout=. spawn cmdline
NB.
NB.   stdout: _1 fail, '' or stdout stream value if success
NB.   cmdline: 'shortcmd arg1 arg2 ...'
NB.   cmdline: '"command with space" arg1 ...'
NB.
NB. e.g. spawn 'net users'

NB.*spawn v [dyad] send stdin and get stdout of task
NB.
NB. form: stdout=. [stdin=''] spawn cmdline
NB.
NB.   stdin: input to stream as stdin, '' no input
NB.
NB. e.g. 'i.3 4'spawn'jconsole'
spawn=: (3 : 0)`(2!:0@])@.IFUNIX
'' spawn y
:
'or ow'=. CreatePipe 1
'ir iw'=. CreatePipe 2,#x
ph=. (ow,ir) CreateProcess y
CloseHandle ir
if. #x do. x WriteAll iw end.
CloseHandle iw
CloseHandle ow
r=. ReadAll or
CloseHandle or
CloseHandle ph
r
)

NB. =========================================================
NB.*shell v [monad] get stdout of shell command
NB.
NB.   e.g. shell 'dir /b/s'

NB.*shell v [dyad] send stdin and get stdout of shell command
NB.
NB.   e.g. (shell 'dir /b/s') shell 'find ".dll"'
SHELL=: IFUNIX{::'cmd /c ';''

shell=: ''&$: : (spawn SHELL,])

NB. =========================================================
NB.*launch v [monad] launch default application for parameter
NB.
NB.    launch jpath'~system'              NB. file manager
NB.    launch jpath'~bin/installer.txt'   NB. text editor
NB.    launch 'http://jsoftware.com'      NB. web browser

3 : 0''
LAUNCH=: ('gnome-open';'gnome-open';'gnome-open';'open';'start';'') {::~ ('Linux';'OpenBSD';'FreeBSD';'Darwin';'Win')i.<UNAME
if. 0=nc<'LAUNCH_j_'do.if. 0<#LAUNCH_j_ do.LAUNCH=: LAUNCH_j_ end.end.
)
launch=: 3 : 'shell LAUNCH,'' '',y'
NB. task zdefs

NB. fork_z_=: fork_jtask_
NB. spawn_z_=: spawn_jtask_
shell_z_=: shell_jtask_
launch_z_=: launch_jtask_
load_z_=: require_z_=: script_z_=: ]
hostdefs_aix_j_=: 0 : 0
NB. do not edit -- created by sym2ijs
cocurrent<'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 8
O_CREAT=: 256
O_EXCL=: 1024
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 512
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 2048
O_NONBLOCK=: 4
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 6
F_SETLKW=: 7
F_GETLK=: 5
F_UNLCK=: 3
F_WRLCK=: 2
flock_sz=: 24
l_len_off=: 8
l_len_sz=: 4
l_pid_off=: 16
l_pid_sz=: 4
l_start_off=: 4
l_start_sz=: 4
l_type_off=: 0
l_type_sz=: 2
l_whence_off=: 2
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 256

REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 8
REG_NEWLINE=: 4

regex_t_sz=: 360
re_nsub_off=: 0
re_nsub_sz=: 4
regmatch_t_sz=: 8
rm_so_off=: 0
rm_so_sz=: 4
rm_eo_off=: 4
rm_eo_sz=: 4


fd_set_sz=: 4096
fds_bits_off=: 0
fds_bits_sz=: 4096
FD_SETSIZE=: 32767
timeval_sz=: 8
tv_sec_off=: 0
tv_sec_sz=: 4
tv_usec_off=: 4
tv_usec_sz=: 4

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 11
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 49
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 109
ESRCH=: 3
EDEADLK=: 45
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 17
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 86

EINPROGRESS=: 55
ECANCELED=: 117
ETIMEDOUT=: 78
EMSGSIZE=: 59
ENOTSUP=: 124
)
hostdefs_android_j_=: 0 : 0
NB. do not edit -- created by sym2ijs

cocurrent <'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 1024
O_CREAT=: 64
O_EXCL=: 128
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 512
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 256
O_NONBLOCK=: 2048
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 6
F_SETLKW=: 7
F_GETLK=: 5
F_UNLCK=: 2
F_WRLCK=: 1
flock_sz=: 16
l_len_off=: 8
l_len_sz=: 4
l_pid_off=: 12
l_pid_sz=: 4
l_start_off=: 4
l_start_sz=: 4
l_type_off=: 0
l_type_sz=: 2
l_whence_off=: 2
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 16

REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 4
REG_NEWLINE=: 8

regex_t_sz=: 16
re_nsub_off=: 4
re_nsub_sz=: 4
regmatch_t_sz=: 8
rm_so_off=: 0
rm_so_sz=: 4
rm_eo_off=: 4
rm_eo_sz=: 4


fd_set_sz=: 128
fds_bits_off=: 0
fds_bits_sz=: 128
FD_SETSIZE=: 1024
timeval_sz=: 8
tv_sec_off=: 0
tv_sec_sz=: 4
tv_usec_off=: 4
tv_usec_sz=: 4

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 11
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 37
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 38
ESRCH=: 3
EDEADLK=: 35
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 39
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 36

EINPROGRESS=: 115
ECANCELED=: 125
ETIMEDOUT=: 110
EMSGSIZE=: 90
ENOTSUP=: 95
)
hostdefs_android_64_j_=: 0 : 0
NB. do not edit -- created by sym2ijs

cocurrent <'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 1024
O_CREAT=: 64
O_EXCL=: 128
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 512
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 256
O_NONBLOCK=: 2048
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 6
F_SETLKW=: 7
F_GETLK=: 5
F_UNLCK=: 2
F_WRLCK=: 1
flock_sz=: 32
l_len_off=: 16
l_len_sz=: 8
l_pid_off=: 24
l_pid_sz=: 4
l_start_off=: 8
l_start_sz=: 8
l_type_off=: 0
l_type_sz=: 2
l_whence_off=: 2
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 16

REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 4
REG_NEWLINE=: 8

regex_t_sz=: 32
re_nsub_off=: 8
re_nsub_sz=: 8
regmatch_t_sz=: 16
rm_so_off=: 0
rm_so_sz=: 8
rm_eo_off=: 8
rm_eo_sz=: 8


fd_set_sz=: 128
fds_bits_off=: 0
fds_bits_sz=: 128
FD_SETSIZE=: 1024
timeval_sz=: 16
tv_sec_off=: 0
tv_sec_sz=: 8
tv_usec_off=: 8
tv_usec_sz=: 8

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 11
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 37
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 38
ESRCH=: 3
EDEADLK=: 35
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 39
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 36

EINPROGRESS=: 115
ECANCELED=: 125
ETIMEDOUT=: 110
EMSGSIZE=: 90
ENOTSUP=: 95
)
hostdefs_darwin_j_=: 0 : 0
NB. do not edit -- created by sym2ijs
cocurrent<'jdefs'

F_OK =: 0
R_OK =: 4
W_OK =: 2
X_OK =: 1
STDIN_FILENO =: 0
STDOUT_FILENO =: 1
STDERR_FILENO =: 2
SEEK_CUR =: 1
SEEK_END =: 2
SEEK_SET =: 0

O_APPEND =: 8
O_CREAT =: 512
O_EXCL =: 2048
O_RDONLY =: 0
O_RDWR =: 2
O_TRUNC =: 1024
O_WRONLY =: 1

O_ACCMODE =: 3
O_NOCTTY =: 0
O_NONBLOCK =: 4
FD_CLOEXEC =: 1
F_DUPFD =: 0
F_GETFD =: 1
F_SETFD =: 2
F_GETFL =: 3
F_SETFL =: 4
F_SETLK =: 8
F_SETLKW =: 9
F_GETLK =: 7
F_UNLCK =: 2
F_WRLCK =: 3
flock_sz =: 24
l_len_off =: 8
l_len_sz =: 8
l_pid_off =: 16
l_pid_sz =: 4
l_start_off =: 0
l_start_sz =: 8
l_type_off =: 20
l_type_sz =: 2
l_whence_off =: 22
l_whence_sz =: 2

PROT_READ =: 1
PROT_WRITE =: 2
PROT_EXEC =: 4
PROT_NONE =: 0
MAP_SHARED =: 1
MAP_PRIVATE =: 2
MAP_FIXED =: 16

REG_EXTENDED =: 1
REG_ICASE =: 2
REG_NOSUB =: 4
REG_NEWLINE =: 8

regex_t_sz =: 16
re_nsub_off =: 4
re_nsub_sz =: 4
regmatch_t_sz =: 16
rm_so_off =: 4
rm_so_sz =: 4
rm_eo_off =: 12
rm_eo_sz =: 4


fd_set_sz =: 128
fds_bits_off =: 0
fds_bits_sz =: 128
FD_SETSIZE =: 1024
timeval_sz =: 8
tv_sec_off =: 0
tv_sec_sz =: 4
tv_usec_off =: 4
tv_usec_sz =: 4

E2BIG =: 7
EFAULT =: 14
ENFILE =: 23
ENOTTY =: 25
EACCES =: 13
EFBIG =: 27
ENODEV =: 19
ENXIO =: 6
EAGAIN =: 35
ENOENT =: 2
EPERM =: 1
EBADF =: 9
EINTR =: 4
ENOEXEC =: 8
EPIPE =: 32
EINVAL =: 22
ENOLCK =: 77
ERANGE =: 34
EBUSY =: 16
EIO =: 5
ENOMEM =: 12
EROFS =: 30
EISDIR =: 21
ENOSPC =: 28
ESPIPE =: 29
ECHILD =: 10
EMFILE =: 24
ENOSYS =: 78
ESRCH =: 3
EDEADLK =: 11
EMLINK =: 31
ENOTDIR =: 20
EDOM =: 33
ENOTEMPTY =: 66
EXDEV =: 18
EEXIST =: 17
ENAMETOOLONG =: 63

EINPROGRESS =: 36
ECANCELED =: 89
ETIMEDOUT =: 60
EMSGSIZE =: 40
ENOTSUP =: 45
)
hostdefs_darwin_64_j_=: 0 : 0
NB. do not edit -- created by sym2ijs

cocurrent <'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 8
O_CREAT=: 512
O_EXCL=: 2048
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 1024
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 131072
O_NONBLOCK=: 4
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 8
F_SETLKW=: 9
F_GETLK=: 7
F_UNLCK=: 2
F_WRLCK=: 3
flock_sz=: 24
l_len_off=: 8
l_len_sz=: 8
l_pid_off=: 16
l_pid_sz=: 4
l_start_off=: 0
l_start_sz=: 8
l_type_off=: 20
l_type_sz=: 2
l_whence_off=: 22
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 16

REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 4
REG_NEWLINE=: 8

regex_t_sz=: 32
re_nsub_off=: 8
re_nsub_sz=: 8
regmatch_t_sz=: 16
rm_so_off=: 0
rm_so_sz=: 8
rm_eo_off=: 8
rm_eo_sz=: 8


fd_set_sz=: 128
fds_bits_off=: 0
fds_bits_sz=: 128
FD_SETSIZE=: 1024
timeval_sz=: 16
tv_sec_off=: 0
tv_sec_sz=: 8
tv_usec_off=: 8
tv_usec_sz=: 4

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 35
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 77
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 78
ESRCH=: 3
EDEADLK=: 11
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 66
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 63

EINPROGRESS=: 36
ECANCELED=: 89
ETIMEDOUT=: 60
EMSGSIZE=: 40
ENOTSUP=: 45
)
hostdefs_freebsd_64_j_=: 0 : 0
NB. do not edit -- created by sym2ijs

cocurrent <'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 8
O_CREAT=: 512
O_EXCL=: 2048
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 1024
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 32768
O_NONBLOCK=: 4
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 12
F_SETLKW=: 13
F_GETLK=: 11
F_UNLCK=: 2
F_WRLCK=: 3
flock_sz=: 32
l_len_off=: 8
l_len_sz=: 8
l_pid_off=: 16
l_pid_sz=: 4
l_start_off=: 0
l_start_sz=: 8
l_type_off=: 20
l_type_sz=: 2
l_whence_off=: 22
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 16

REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 4
REG_NEWLINE=: 8

regex_t_sz=: 32
re_nsub_off=: 8
re_nsub_sz=: 8
regmatch_t_sz=: 16
rm_so_off=: 0
rm_so_sz=: 8
rm_eo_off=: 8
rm_eo_sz=: 8


fd_set_sz=: 128
fds_bits_off=: 0
fds_bits_sz=: 128
FD_SETSIZE=: 1024
timeval_sz=: 16
tv_sec_off=: 0
tv_sec_sz=: 8
tv_usec_off=: 8
tv_usec_sz=: 8

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 35
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 77
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 78
ESRCH=: 3
EDEADLK=: 11
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 66
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 63

EINPROGRESS=: 36
ECANCELED=: 85
ETIMEDOUT=: 60
EMSGSIZE=: 40
ENOTSUP=: 45
)
hostdefs_linux_j_=: 0 : 0
NB. do not edit -- created by sym2ijs
cocurrent<'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 1024
O_CREAT=: 64
O_EXCL=: 128
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 512
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 256
O_NONBLOCK=: 2048
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 6
F_SETLKW=: 7
F_GETLK=: 5
F_UNLCK=: 2
F_WRLCK=: 1
flock_sz=: 16
l_len_off=: 8
l_len_sz=: 4
l_pid_off=: 12
l_pid_sz=: 4
l_start_off=: 4
l_start_sz=: 4
l_type_off=: 0
l_type_sz=: 2
l_whence_off=: 2
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 16

REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 8
REG_NEWLINE=: 4

regex_t_sz=: 32
re_nsub_off=: 24
re_nsub_sz=: 4
regmatch_t_sz=: 8
rm_so_off=: 0
rm_so_sz=: 4
rm_eo_off=: 4
rm_eo_sz=: 4


fd_set_sz=: 128
fds_bits_off=: 0
fds_bits_sz=: 128
FD_SETSIZE=: 1024
timeval_sz=: 8
tv_sec_off=: 0
tv_sec_sz=: 4
tv_usec_off=: 4
tv_usec_sz=: 4

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 11
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 37
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 38
ESRCH=: 3
EDEADLK=: 35
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 39
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 36

EINPROGRESS=: 115
ECANCELED=: 125
ETIMEDOUT=: 110
EMSGSIZE=: 90
ENOTSUP=: 95
)
hostdefs_linux_64_j_=: 0 : 0
NB. do not edit -- created by sym2ijs

cocurrent <'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 1024
O_CREAT=: 64
O_EXCL=: 128
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 512
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 256
O_NONBLOCK=: 2048
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 6
F_SETLKW=: 7
F_GETLK=: 5
F_UNLCK=: 2
F_WRLCK=: 1
flock_sz=: 32
l_len_off=: 16
l_len_sz=: 8
l_pid_off=: 24
l_pid_sz=: 4
l_start_off=: 8
l_start_sz=: 8
l_type_off=: 0
l_type_sz=: 2
l_whence_off=: 2
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 16

REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 8
REG_NEWLINE=: 4

regex_t_sz=: 64
re_nsub_off=: 48
re_nsub_sz=: 8
regmatch_t_sz=: 8
rm_so_off=: 0
rm_so_sz=: 4
rm_eo_off=: 4
rm_eo_sz=: 4


fd_set_sz=: 128
fds_bits_off=: 0
fds_bits_sz=: 128
FD_SETSIZE=: 1024
timeval_sz=: 16
tv_sec_off=: 0
tv_sec_sz=: 8
tv_usec_off=: 8
tv_usec_sz=: 8

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 11
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 37
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 38
ESRCH=: 3
EDEADLK=: 35
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 39
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 36

EINPROGRESS=: 115
ECANCELED=: 125
ETIMEDOUT=: 110
EMSGSIZE=: 90
ENOTSUP=: 95
)
hostdefs_openbsd_64_j_=: 0 : 0
NB. do not edit -- created by sym2ijs

cocurrent <'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 8
O_CREAT=: 512
O_EXCL=: 2048
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 1024
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 32768
O_NONBLOCK=: 4
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 8
F_SETLKW=: 9
F_GETLK=: 7
F_UNLCK=: 2
F_WRLCK=: 3
flock_sz=: 24
l_len_off=: 8
l_len_sz=: 8
l_pid_off=: 16
l_pid_sz=: 4
l_start_off=: 0
l_start_sz=: 8
l_type_off=: 20
l_type_sz=: 2
l_whence_off=: 22
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 16

REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 4
REG_NEWLINE=: 8

regex_t_sz=: 32
re_nsub_off=: 8
re_nsub_sz=: 8
regmatch_t_sz=: 16
rm_so_off=: 0
rm_so_sz=: 8
rm_eo_off=: 8
rm_eo_sz=: 8


fd_set_sz=: 128
fds_bits_off=: 0
fds_bits_sz=: 128
FD_SETSIZE=: 1024
timeval_sz=: 16
tv_sec_off=: 0
tv_sec_sz=: 8
tv_usec_off=: 8
tv_usec_sz=: 8

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 35
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 77
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 78
ESRCH=: 3
EDEADLK=: 11
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 66
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 63

EINPROGRESS=: 36
ECANCELED=: 88
ETIMEDOUT=: 60
EMSGSIZE=: 40
ENOTSUP=: 91
)
hostdefs_sunos_j_=: 0 : 0
NB. do not edit -- created by sym2ijs
cocurrent<'jdefs'
cocurrent <'jdefs'

F_OK=: 0
R_OK=: 4
W_OK=: 2
X_OK=: 1
STDIN_FILENO=: 0
STDOUT_FILENO=: 1
STDERR_FILENO=: 2
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 8
O_CREAT=: 256
O_EXCL=: 1024
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 512
O_WRONLY=: 1

O_ACCMODE=: 3
O_NOCTTY=: 2048
O_NONBLOCK=: 128
FD_CLOEXEC=: 1
F_DUPFD=: 0
F_GETFD=: 1
F_SETFD=: 2
F_GETFL=: 3
F_SETFL=: 4
F_SETLK=: 6
F_SETLKW=: 7
F_GETLK=: 14
F_UNLCK=: 3
F_WRLCK=: 2
flock_sz=: 36
l_len_off=: 8
l_len_sz=: 4
l_pid_off=: 16
l_pid_sz=: 4
l_start_off=: 4
l_start_sz=: 4
l_type_off=: 0
l_type_sz=: 2
l_whence_off=: 2
l_whence_sz=: 2

PROT_READ=: 1
PROT_WRITE=: 2
PROT_EXEC=: 4
PROT_NONE=: 0
MAP_SHARED=: 1
MAP_PRIVATE=: 2
MAP_FIXED=: 16

REG_EXTENDED=: 1
REG_ICASE=: 4
REG_NOSUB=: 2
REG_NEWLINE=: 8

regex_t_sz=: 24
re_nsub_off=: 0
re_nsub_sz=: 4
regmatch_t_sz=: 24
rm_so_off=: 8
rm_so_sz=: 4
rm_eo_off=: 12
rm_eo_sz=: 4


fd_set_sz=: 128
fds_bits_off=: 0
fds_bits_sz=: 128
FD_SETSIZE=: 1024
timeval_sz=: 8
tv_sec_off=: 0
tv_sec_sz=: 4
tv_usec_off=: 4
tv_usec_sz=: 4

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 11
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 46
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 89
ESRCH=: 3
EDEADLK=: 45
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 93
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 78

EINPROGRESS=: 150
ECANCELED=: 47
ETIMEDOUT=: 145
EMSGSIZE=: 97
ENOTSUP=: 48
)
hostdefs_win_j_=: 0 : 0
NB. do not edit -- created by sym2ijs
cocurrent<'jdefs'

F_OK=:0
R_OK=:4
W_OK=:2
X_OK=:1
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 8
O_CREAT=: 256
O_EXCL=: 1024
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 512
O_WRONLY=: 1


REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 8
REG_NEWLINE=: 4

regex_t_sz=: 280
re_nsub_off=: 8
re_nsub_sz=: 4
regmatch_t_sz=: 12
rm_so_off=: 0
rm_so_sz=: 4
rm_eo_off=: 4
rm_eo_sz=: 4


FD_SETSIZE=: 64
timeval_sz=: 8
tv_sec_off=: 0
tv_sec_sz=: 4
tv_usec_off=: 4
tv_usec_sz=: 4

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 11
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 39
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 40
ESRCH=: 3
EDEADLK=: 36
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 41
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 38

)
hostdefs_win_64_j_=: 0 : 0
NB. do not edit -- created by sym2ijs

cocurrent <'jdefs'

F_OK=:0
R_OK=:4
W_OK=:2
X_OK=:1
SEEK_CUR=: 1
SEEK_END=: 2
SEEK_SET=: 0

O_APPEND=: 8
O_CREAT=: 256
O_EXCL=: 1024
O_RDONLY=: 0
O_RDWR=: 2
O_TRUNC=: 512
O_WRONLY=: 1


REG_EXTENDED=: 1
REG_ICASE=: 2
REG_NOSUB=: 8
REG_NEWLINE=: 4

regex_t_sz=: 304
re_nsub_off=: 16
re_nsub_sz=: 8
regmatch_t_sz=: 12
rm_so_off=: 0
rm_so_sz=: 4
rm_eo_off=: 4
rm_eo_sz=: 4


FD_SETSIZE=: 64
timeval_sz=: 8
tv_sec_off=: 0
tv_sec_sz=: 4
tv_usec_off=: 4
tv_usec_sz=: 4

E2BIG=: 7
EFAULT=: 14
ENFILE=: 23
ENOTTY=: 25
EACCES=: 13
EFBIG=: 27
ENODEV=: 19
ENXIO=: 6
EAGAIN=: 11
ENOENT=: 2
EPERM=: 1
EBADF=: 9
EINTR=: 4
ENOEXEC=: 8
EPIPE=: 32
EINVAL=: 22
ENOLCK=: 39
ERANGE=: 34
EBUSY=: 16
EIO=: 5
ENOMEM=: 12
EROFS=: 30
EISDIR=: 21
ENOSPC=: 28
ESPIPE=: 29
ECHILD=: 10
EMFILE=: 24
ENOSYS=: 40
ESRCH=: 3
EDEADLK=: 36
EMLINK=: 31
ENOTDIR=: 20
EDOM=: 33
ENOTEMPTY=: 41
EXDEV=: 18
EEXIST=: 17
ENAMETOOLONG=: 38

)
NB. J qtide

require 'project'

coclass 'jqtide'

3 : 0''
if. IFQT do.
  require 'ide/qt/qtlib'
end.
EMPTY
)
'jws_onOpen jws_onClose jws_onMessage jws_onError jws_onSslError jws_onStateChange'=: i.6
boxj2utf8=: 3 : 0
if. 1 < #$y do. y return. end.
b=. (16+i.11) { a.
if. -. 1 e. b e. y do. y return. end.
y=. ucp y
a=. ucp '┌┬┐├┼┤└┴┘│─'
x=. I. y e. b
utf8 (a {~ b i. x { y) x } y
)
clipread=: wd@('clippaste'"_)
clipwrite=: 3 : 0
txt=. boxj2utf8 flatten ":y
wd 'clipcopy *',txt
#txt
)
dbjqt=: 3 : 0
if. y do.
  if. _1 = 4!:0 <'jdb_open_jdebug_' do.
    0!:0 <jpath '~addons/ide/qt/debugs.ijs'
  end.
  jdb_open_jdebug_''
else.
  jdb_close_jdebug_ :: ] ''
end.
)
flatten=: 3 : 0
dat=. ": y
select. # $ dat
case. 1 do.
case. 2 do.
  }. , LF ,. dat
case. do.
  dat=. 1 1}. _1 _1}. ": < dat
  }: (,|."1 [ 1,.-. *./\"1 |."1 dat=' ')#,dat,.LF
end.
)
gridindex=: 3 : 0
'rws cls sel ndx shp'=. y
d=. (sel,rws,cls) |: i.shp
r=. (sel{shp),(*/rws{shp),*/cls{shp
,(<ndx) { r ($,) d
)
showevents=: 3 : 0
select. {. y,1
case. 0 do.
  4!:55 <'wdhandler_debug_z_'
case. 1 do.
  wdhandler_debug_z_=: 3 : 'smoutput sysevent'
case. 2 do.
  wdhandler_debug_z_=: 3 : 'smoutput wdq'
case. 3 do.
  wdhandler_debug_z_=: 3 : 'if. -. ''_mmove''-:_6{.sysevent do. smoutput sysevent end.'
case. 4 do.
  wdhandler_debug_z_=: 3 : 'if. -. ''_mmove''-:_6{.sysevent do. smoutput wdq end.'
end.
EMPTY
)
textview=: 3 : 0
p=. boxopen y
if. 1<#$p do.
  p=. <":p
elseif. 2=#p do.
  p=. 1 0 1 #^:_1 p
end.
'title caption text'=. _3 {. p
wd 'textview *;',title,';',caption,';',flatten text
)
echo_z_=: wd@'msgs'^:2 [ 1!:2&2
addons_msg=: 0 : 0
The XX are not yet installed.

To install, select menu Tools|Package Manager and install package YY.
)
addons_missing=: 3 : 0
'name addon script'=. y
if. fexist script do. 0 return. end.
sminfo name;addons_msg rplc 'XX';name;'YY';addon
1
)
demoqt=: 3 : 0
p=. jpath '~addons/demos/qtdemo/qtdemo.ijs'
if. addons_missing 'qt demos';'demos/qtdemo';p do. return. end.
load p
)
demowd=: 3 : 0
p=. jpath '~addons/demos/wd/demos.ijs'
if. addons_missing 'Showcase demos';'demos/wd';p do. return. end.
load p
)
labs_run=: 3 : 0
p=. jpath '~addons/labs/labs/lab.ijs'
if. addons_missing 'labs';'labs/labs';p do. return. end.
require p
if. 0 e. $y do.
  require '~addons/labs/labs/labs805.ijs'
  labselect_jlab805_'' return.
end.
if. y -: 1 do. y=. ':' end.
empty lab_jlab_ y
)
coclass 'jqtide'

Qt_Key_Escape                 =: 16b00f800
Qt_Key_Tab                    =: 16b00f801
Qt_Key_Backtab                =: 16b00f802
Qt_Key_Backspace              =: 16b00f803
Qt_Key_Return                 =: 16b00f804
Qt_Key_Enter                  =: 16b00f805
Qt_Key_Insert                 =: 16b00f806
Qt_Key_Delete                 =: 16b00f807
Qt_Key_Pause                  =: 16b00f808
Qt_Key_Print                  =: 16b00f809
Qt_Key_SysReq                 =: 16b00f80a
Qt_Key_Clear                  =: 16b00f80b
Qt_Key_Home                   =: 16b00f810
Qt_Key_End                    =: 16b00f811
Qt_Key_Left                   =: 16b00f812
Qt_Key_Up                     =: 16b00f813
Qt_Key_Right                  =: 16b00f814
Qt_Key_Down                   =: 16b00f815
Qt_Key_PageUp                 =: 16b00f816
Qt_Key_PageDown               =: 16b00f817
Qt_Key_Shift                  =: 16b00f820
Qt_Key_Control                =: 16b00f821
Qt_Key_Meta                   =: 16b00f822
Qt_Key_Alt                    =: 16b00f823
Qt_Key_CapsLock               =: 16b00f824
Qt_Key_NumLock                =: 16b00f825
Qt_Key_ScrollLock             =: 16b00f826
Qt_Key_F1                     =: 16b00f830
Qt_Key_F2                     =: 16b00f831
Qt_Key_F3                     =: 16b00f832
Qt_Key_F4                     =: 16b00f833
Qt_Key_F5                     =: 16b00f834
Qt_Key_F6                     =: 16b00f835
Qt_Key_F7                     =: 16b00f836
Qt_Key_F8                     =: 16b00f837
Qt_Key_F9                     =: 16b00f838
Qt_Key_F10                    =: 16b00f839
Qt_Key_F11                    =: 16b00f83a
Qt_Key_F12                    =: 16b00f83b
helpcontext0=: 3 : 0
require '~addons/ide/qt/help.ijs'
helpcontext y
)

helpcontext1=: 3 : 0
require '~addons/ide/qt/help.ijs'
helpcontext1 y
)
Multiline=: (,each '01234'),;:'noun adverb conjunction verb monad dyad'

ismultiline=: 3 : 0
if. 0=#y do. 0 return. end.
t=. ;: :: 0: y
if. t-:0 do. 0 return. end.
if. (<'Note') = {.t do. 1 return. end.
n=. I. }: t e. Multiline
if. 0=#n do. 0 return. end.
if. (<'define') e. (n+1){t do. 1 return. end.
(,each ':0') e. (n+/1 2){t,<''
)
dirdef_begin=: 3 : 0
t=. ;: :: 0: y
if. t-:0 do. return. end.
b=. t = <'{{'
e=. (t = <'}}') *. +./\ b
0 >. +/ b - e
)
dirdef_end=: 3 : 0
t=. ;: :: 0: y
if. t-:0 do. return. end.
b=. t = <'{{'
e=. t = <'}}'
+/ e - b
)
getnextentry=: 3 : 0
p=. 1
s=. 0 pick y
t=. }.y
if. n=. dirdef_begin s do.
  while. #t do.
    p=. p + 1
    s=. s,LF,w=. 0 pick t
    n=. n - dirdef_end w
    if. n <: 0 do. break. end.
    t=. }.t
  end.
end.
if. ismultiline s do.
  n=. 1 + t i. <,')'
  s=. s,LF,tolist n {. t
  p=. p + n
end.
p;s
)
cocurrent IFQT{'jqtide';'z'
wd=: 3 : 0"1
'r c l p n'=. wd1 (,y);(#,y);(,2);(,0)
select. r
case. 0 do.
  EMPTY
case. _1 do.
  memr p,0,n
case. _2 do.
  _2 [\ <;._2 memr p,0,n
case. do.
  (LF,~wd ::(''"_)'qer') (13!:8) 3
end.
)

wd1=: ('"',libjqt,'" wd ', (IFWIN#'+'),' i *c i *x *i') & cd f.
wdhandler_0=: 3 : 0
wdq=: wd 'q'
wd_val=. {:"1 wdq
({."1 wdq)=: wd_val
if. 3=4!:0<'wdhandler_debug' do.
  try. wdhandler_debug'' catch. end.
end.
wd_ndx=. 1 i.~ 3 = 4!:0 [ 3 {. wd_val
if. 3 > wd_ndx do.
  wd_fn=. > wd_ndx { wd_val
  if. 13!:17'' do.
    wd_fn~''
  else.
    try. wd_fn~''
    catch.
      wd_err=. 13!:12''
      if. 0=4!:0 <'ERM_j_' do.
        wd_erm=. ERM_j_
        ERM_j_=: ''
        if. wd_erm -: wd_err do. i.0 0 return. end.
      end.
      wd_err=. LF,,LF,.(}.^:('|'e.~{.));._2 ,&LF^:(LF~:{:) wd_err
      wdinfo 'wdhandler';'error in: ',wd_fn,wd_err
    end.
  end.
end.
i.0 0
)
wdhandler=: 3 : 0
wdq=: wd 'q'
wd_val=. {:"1 wdq
({."1 wdq)=: wd_val
if. 3=4!:0<'wdhandler_debug' do.
  try. wdhandler_debug'' catch. end.
end.
wd_ndx=. 1 i.~ 3 = 4!:0 [ 3 {. wd_val
if. 3 > wd_ndx do.
  wd_fn=. > wd_ndx { wd_val
  if. 13!:17'' do.
    wd_fn~''
  else.
    try. wd_fn~''
    catch.
      wd_err=. 13!:12''
      if. 0=4!:0 <'ERM_j_' do.
        wd_erm=. ERM_j_
        ERM_j_=: ''
        if. wd_erm -: wd_err do. i.0 0 return. end.
      end.
      wd_err=. LF,,LF,.(}.^:('|'e.~{.));._2 ,&LF^:(LF~:{:) wd_err
      wdinfo 'wdhandler';'error in: ',wd_fn,wd_err
    end.
  i.0 0
  end.
else. i. 0 0
end.
)
wdhandlerx=: 3 : 0
loc=. <,y
if. 0 <: 18!:0 loc do.
  wdhandler__loc''
else.
  msg=. 'no locale for event handler: ',>loc
  if. #wdq=. wd 'q' do.
    msg=. msg, ', event: ',(<1 1) pick wdq
  end.
  smoutput msg
end.
)
wdclippaste=: (wd bind 'clippaste') :: (''"_)
wdqq=: (wd bind 'q') :: (''"_)
wdqchildxywh=: (0 ". [: wd 'qchildxywh ' , ]) :: (0 0 0 0"_)
wdqcolor=: (0 ". [: wd 'qcolor ' , ":) :: ( 0 0 0"_)
wdqd=: (wd bind 'qd') :: (''"_)
wdqer=: (wd bind 'qer') :: (''"_)
wdqform=: (0 ". wd bind 'qform') :: (0 0 800 600"_)
wdqhinst=: (0 ". wd bind 'qhinst') :: 0:
wdqhwndc=: (0 ". [: wd 'qhwndc ' , ]) :: 0:
wdqhwndp=: (0 ". wd bind 'qhwndp') :: 0:
wdqhwndx=: (0 ". wd bind 'qhwndx') :: 0:
wdqm=: (0 ". wd bind 'qm') :: (800 600 8 16 1 1 3 3 4 4 19 19 0 0 800 570"_)
wdqp=: (wd bind 'qp') :: (''"_)
wdqprinters=: (wd bind 'qprinters') :: (''"_)
wdqpx=: (wd bind 'qpx') :: (''"_)
wdqscreen=: (0 ". wd bind 'qscreen') :: (264 211 800 600 96 96 32 1 _1 36 36 51"_)
wdqwd=: (wd bind 'qwd') :: ('jqt'"_)
wdcenter=: 0:
wdfit=: 0:

wdreset=: wd bind 'reset'
wdforms=: <;._2;._2 @ wd bind 'qpx'
wdisparent=: (boxopen e. 0: {"1 wdforms) ::0:
wdishandle=: (boxopen e. 1: {"1 wdforms) ::0:
wdinfo=: 3 : 0
'a b'=. _2{. boxopen y
if. 2=#$b=. ":b do. b=. }.,LF,.b end.
f=. 8 u: DEL&, @ (,&DEL) @ -.&(0 127{a.)
empty wd 'mb info ',(f a),' ',(f b)
)
wdquery=: 3 : 0
0 3 wdquery y
:
msg=. ' mb_'&,&.> res=. ;:'ok cancel yes no save discard'
t=. x [ 'a b'=. _2{. boxopen y
if. 2=#$b=. ":b do. b=. }.,LF,.b end.
f=. 8 u: DEL&, @ (,&DEL) @ -.&(0 127{a.)
m=. 'mb query', (;t{msg), ' ', (f a),' ',(f b)
res i. <wd m
)
mbopen=: 3 : 0
jpathsep wd 8 u: 'mb open1 ',y
)
mbsave=: 3 : 0
jpathsep wd 8 u: 'mb save ',y
)
wdget=: 4 : 0
nms=. {."1 y
vls=. {:"1 y
if. L. x do. vls {~ nms i. ,&.>x
else. > vls {~ nms i. <,x
end.
)

wdpclose=: [: wd :: empty 'psel ' , ';pclose' ,~ ":
3 : 0^:(IFQT > IFJHS)''
dirmatch=: 3 : 'wd ''dirmatch '', ; dquote&.> 2 {. boxopen y'
open=: 3 : 'wd ''openj *'' , > {. getscripts_j_ y'
immexj=: [: wd 'immexj *'&,
smact=: wd bind 'smact'

clipread=: clipread_jqtide_
clipwrite=: clipwrite_jqtide_
textview=: textview_jqtide_
EMPTY
)
coclass 'jqtide'
JQTREQ=: '1.8.1'
JQTMSG=: 0 : 0
The JQt binary needs updating.

To do so, close this session, then load jconsole and run:

   getqtbin''
or
   getqtbin'slim'

or run XX in the J installation folder.
)
checkjqtversion=: 3 : 0
f=. 1000 #. 0 ". ' ' I.@('.'=])} ]
ver=. wd 'version'
ver=. (ver i.'(') {. ver
JQTVER=: f (1+ver i.'/') }. ver
act=. f (<./ ver i.'/s') {. ver
req=. f JQTREQ
if. req <: act do. return. end.
msg=. JQTMSG rplc 'XX';'updatejqt.',IFWIN pick 'sh';'cmd'
sminfo 'JQt';msg
)
checkjqtversion^:IFQT''

cocurrent 'base'
NB. gl2 init

coclass 'jgl2'

3 : 0''
if. 0~: 4!:0 <'PROFONT_z_' do. PROFONT=: (('Linux';'Darwin';'Android';'Win') i. <UNAME){:: 'Sans 10' ; '"Lucida Grande" 10' ; (IFQT{::'Sans 10';'"Droid Sans" 10') ; 'Tahoma 10' else. PROFONT=: PROFONT_z_ end.
if. 0~: 4!:0 <'FIXFONT_z_' do. FIXFONT=: (('Linux';'Darwin';'Android';'Win') i. <UNAME){:: 'mono 10' ; 'Monaco 10' ; (IFQT{::'monospace 10';'"Droid Sans Mono" 10') ; '"Lucida Console" 10' else. FIXFONT=: FIXFONT_z_ end.
)

NB. gl2 constant

PS_NULL=: 0
PS_SOLID=: 1
PS_DASH=: 2
PS_DOT=: 3
PS_DASHDOT=: 4
PS_DASHDOTDOT=: 5

IDC_ARROW=: 0
IDC_UPARROW=: 1
IDC_CROSS=: 2
IDC_WAIT=: 3
IDC_IBEAM=: 4
IDC_SIZEVER=: 5
IDC_SIZEHOR=: 6
IDC_SIZEBDIAG=: 7
IDC_SIZEFDIAG=: 8
IDC_SIZEALL=: 9
IDC_BLANK=: 10
IDC_SPLITV=: 11
IDC_SPLITH=: 12
IDC_POINTINGHAND=: 13
IDC_FORBIDDEN=: 14
IDC_OPENHAND=: 17
IDC_CLOSEDHAND=: 18
IDC_WHATSTHIS=: 15
IDC_BUSY=: 16
IDC_DRAGMOVE=: 20
IDC_DRAGCOPY=: 19
IDC_DRAGLINK=: 21
IDC_UNSET=: _1

NB. numeric constants used in glcmds

glarc_n=: 2001
glbrush_n=: 2004
glbrushnull_n=: 2005
glcapture_n=: 2062
glcaret_n=: 2065
glclear_n=: 2007
glclip_n=: 2078
glclipreset_n=: 2079
glcmds_n=: 2999
glcursor_n=: 2069
glellipse_n=: 2008
glemfopen_n=: 2084
glemfclose_n=: 2085
glemfplay_n=: 2086
glfile_n=: 2066
glfill_n=: 2093
glfont_n=: 2012
glfontextent_n=: 2094
gllines_n=: 2015
glnodblbuf_n=: 2070
glpaint_n=: 2020
glpaintx_n=: 2021
glpen_n=: 2022
glpie_n=: 2023
glpixel_n=: 2024
glpixelsx_n=: 2075
glpixels_n=: 2076
glprint_n=: 2089
glprintmore_n=: 2091
glpolygon_n=: 2029
glqextent_n=: 2057
glqextentw_n=: 2083
glqpixels_n=: 2077
glqpixelm_n=: 2080
glqprintpaper_n=: 2092
glqprintwh_n=: 2088
glqtextmetrics_n=: 2058
glqtype_n=: 2095
glqwh_n=: 2059
glqhandles_n=: 2060
glrect_n=: 2031
glrgb_n=: 2032
glroundr_n=: 2033
glsel_n=: 2035
gltext_n=: 2038
gltextcolor_n=: 2040
gltextxy_n=: 2056
glwindoworg_n=: 2045

glbkmode_n=: 2003
glnoerasebkgnd_n=: 2071

glfont2_n=: 2312
glfontangle_n=: 2342
glrgba_n=: 2343
glsel2_n=: 2344

NB. opengl only
glwaitgl_n=: 2345
glwaitnative_n=: 2346

NB. keyboard events
kbBS=: Qt_Key_Backspace_jqtide_
kbTAB=: Qt_Key_Tab_jqtide_
kbLF=: Qt_Key_Enter_jqtide_
kbENTER=: Qt_Key_Enter_jqtide_
kbRETURN=: Qt_Key_Return_jqtide_
kbPUP=: Qt_Key_PageUp_jqtide_
kbPDOWN=: Qt_Key_PageDown_jqtide_
kbEND=: Qt_Key_End_jqtide_
kbHOME=: Qt_Key_Home_jqtide_
kbLEFT=: Qt_Key_Left_jqtide_
kbUP=: Qt_Key_Up_jqtide_
kbRIGHT=: Qt_Key_Right_jqtide_
kbDOWN=: Qt_Key_Down_jqtide_
kbESC=: Qt_Key_Escape_jqtide_
kbINS=: Qt_Key_Insert_jqtide_
kbDEL=: Qt_Key_Delete_jqtide_
kbMETA=: Qt_Key_Meta_jqtide_
kbALT=: Qt_Key_Alt_jqtide_
kbSHIFT=: Qt_Key_Shift_jqtide_
kbCTRL=: Qt_Key_Control_jqtide_
NB. qt gl2

chkgl2=: 13!:8@3:^:(0&<)@>@{.

NB. =========================================================
glarc=: chkgl2 @: (('"',libjqt,'" glarc >',(IFWIN#'+'),' i *i') cd <) "1
glbrush=: chkgl2 @: (('"',libjqt,'" glbrush >',(IFWIN#'+'),' i')&cd bind '') "1
glbrushnull=: chkgl2 @: (('"',libjqt,'" glbrushnull >',(IFWIN#'+'),' i')&cd bind '') "1
glcapture=: chkgl2 @: (('"',libjqt,'" glcapture >',(IFWIN#'+'),' i i')&cd) "1
glcaret=: chkgl2 @: (('"',libjqt,'" glcaret >',(IFWIN#'+'),' i *i') cd <) "1
glclear=: (('"',libjqt,'" glclear >',(IFWIN#'+'),' i')&cd bind '') "1
glclip=: chkgl2 @: (('"',libjqt,'" glclip >',(IFWIN#'+'),' i *i') cd <) "1
glclipreset=: chkgl2 @: (('"',libjqt,'" glclipreset >',(IFWIN#'+'),' i')&cd bind '') "1
glcmds=: chkgl2 @: (('"',libjqt,'" glcmds >',(IFWIN#'+'),' i *i i') cd (;#)) "1
glcursor=: chkgl2 @: (('"',libjqt,'" glcursor >',(IFWIN#'+'),' i i')&cd) "1
glellipse=: chkgl2 @: (('"',libjqt,'" glellipse >',(IFWIN#'+'),' i *i') cd <@:<.) "1
glfill=: chkgl2 @: (('"',libjqt,'" glfill >',(IFWIN#'+'),' i *i') cd <@:<.) "1
glfont=: chkgl2 @: (('"',libjqt,'" glfont >',(IFWIN#'+'),' i *c') cd <@,) "1
glfont2=: chkgl2 @: (('"',libjqt,'" glfont2 >',(IFWIN#'+'),' i *i i') cd (;#)@:<.) "1
glfontangle=: chkgl2 @: (('"',libjqt,'" glfontangle >',(IFWIN#'+'),' i i')&cd) "1
glfontextent=: chkgl2 @: (('"',libjqt,'" glfontextent >',(IFWIN#'+'),' i *c') cd <@,) "1
gllines=: chkgl2 @: (('"',libjqt,'" gllines >',(IFWIN#'+'),' i *i i') cd (;#)) "1
glnodblbuf=: chkgl2 @: (('"',libjqt,'" glnodblbuf >',(IFWIN#'+'),' i i') cd {.@(,&0)) "1
glpen=: chkgl2 @: (('"',libjqt,'" glpen >',(IFWIN#'+'),' i *i') cd <@:(2 {. (,&1))) "1
glpie=: chkgl2 @: (('"',libjqt,'" glpie >',(IFWIN#'+'),' i *i') cd <) "1
glpixel=: chkgl2 @: (('"',libjqt,'" glpixel >',(IFWIN#'+'),' i *i') cd <) "1
glpixels=: chkgl2 @: (('"',libjqt,'" glpixels >',(IFWIN#'+'),' i *i i') cd (;#)@:<.) "1
glpixelsx=: chkgl2 @: (('"',libjqt,'" glpixelsx >',(IFWIN#'+'),' i *i') cd <@:<.) "1
glpolygon=: chkgl2 @: (('"',libjqt,'" glpolygon >',(IFWIN#'+'),' i *i i') cd (;#)@:<.) "1
glrect=: chkgl2 @: (('"',libjqt,'" glrect >',(IFWIN#'+'),' i *i') cd <) "1
glrgb=: chkgl2 @: (('"',libjqt,'" glrgb >',(IFWIN#'+'),' i *i') cd <@:<.) "1
glrgba=: chkgl2 @: (('"',libjqt,'" glrgba >',(IFWIN#'+'),' i *i') cd <@:<.) "1
glsel1=: chkgl2 @: (('"',libjqt,'" glsel >',(IFWIN#'+'),' i x')&cd) "1
glsel2=: chkgl2 @: (('"',libjqt,'" glsel2 >',(IFWIN#'+'),' i *c') cd <@,) "1
gltext=: chkgl2 @: (('"',libjqt,'" gltext >',(IFWIN#'+'),' i *c') cd <@,) "1
gltextcolor=: chkgl2 @: (('"',libjqt,'" gltextcolor >',(IFWIN#'+'),' i')&cd bind '') "1
gltextxy=: chkgl2 @: (('"',libjqt,'" gltextxy >',(IFWIN#'+'),' i *i') cd <@:<.) "1
glwaitgl=: chkgl2 @: (('"',libjqt,'" glwaitgl >',(IFWIN#'+'),' i')&cd bind '') "1
glwaitnative=: chkgl2 @: (('"',libjqt,'" glwaitnative >',(IFWIN#'+'),' i')&cd bind '') "1
glwindoworg=: chkgl2 @: (('"',libjqt,'" glwindoworg >',(IFWIN#'+'),' i *i') cd <@:<.) "1

glsetlocale=: chkgl2 @: (('"',libjqt,'" glsetlocale >',(IFWIN#'+'),' i *c') cd <@,@>) "1

NB. =========================================================
NB. immediate paint
glpaint=: 3 : 0 "1
('"',libjqt,'" glpaint >',(IFWIN#'+'),' i')&cd ''
0
)

NB. =========================================================
NB. paint
glpaintx=: 3 : 0 "1
('"',libjqt,'" glpaintx >',(IFWIN#'+'),' i')&cd ''
0
)

NB. =========================================================
glqhandles=: 3 : 0"1
hs=. 3#2-2
chkgl2 cdrc=. ('"',libjqt,'" glqhandles  ',(IFWIN#'+'),' i *x') cd <hs
1{::cdrc
)

NB. =========================================================
glqtype=: 3 : 0"1
type=. 1#2-2
chkgl2 cdrc=. ('"',libjqt,'" glqtype  ',(IFWIN#'+'),' i *i') cd <type
1{::cdrc
)

NB. =========================================================
glqwh=: 3 : 0"1
wh=. 2#2-2
chkgl2 cdrc=. ('"',libjqt,'" glqwh  ',(IFWIN#'+'),' i *i') cd <wh
1{::cdrc
)

NB. =========================================================
NB. return matrix of pixels
NB. wh is limited to pixmap size
NB. -1 in w or h means read to end
glqpixelm=: 3 : 0"1
n=. */ 2{.2}.y
pix=. n#2-2
shape=. 2#2-2
chkgl2 cdrc=. ('"',libjqt,'" glqpixelm  ',(IFWIN#'+'),' i *i *i *i') cd y;shape;pix
(2&{:: $ 3&{::) cdrc
)

NB. =========================================================
NB. result is in opengl form
NB. pixels top to bottom, RGB24
NB. TODO
glqpixels=: 3 : 0"1
n=. */ 2{.2}.y
pix=. n#2-2
chkgl2 cdrc=. ('"',libjqt,'" glqpixels  ',(IFWIN#'+'),' i *i *i') cd y;pix
2{::cdrc
)

NB. =========================================================
NB. TODO
glqextent=: 3 : 0"1
wh=. 2#2-2
chkgl2 cdrc=. ('"',libjqt,'" glqextent  ',(IFWIN#'+'),' i *c *i') cd (,y);wh
2{::cdrc
)

NB. =========================================================
NB. TODO
glqextentw=: 3 : 0"1
y=. y,(LF~:{:y)#LF [ y=. ,y
w=. (+/LF=y)#2-2
chkgl2 cdrc=. ('"',libjqt,'" glqextentw  ',(IFWIN#'+'),' i *c *i') cd y;w
2{::cdrc
)

NB. =========================================================
NB. font information: Height, Ascent, Descent, InternalLeading, ExternalLeading, AverageCharWidth, MaxCharWidth
NB. TODO
glqtextmetrics=: 3 : 0"1
tm=. 7#2-2
chkgl2 cdrc=. ('"',libjqt,'" glqtextmetrics  ',(IFWIN#'+'),' i *i') cd <tm
1{::cdrc
)

NB. =========================================================
glsetbrush=: glbrush @ glrgb
glsetpen=: glpen @ ((1 1 [ glrgb) :((2 {. (,&1)) glrgb))

NB. =========================================================
NB. printer

NB. not implemented
glprint=: [:
glprintmore=: [:
glqprintpaper=: [:
glqprintwh=: [:

NB. not implemented
glemfclose=: [:
glemfopen=: [:
glemfplay=: [:
glfile=: [:
glroundr=: [:

NB. =========================================================
glsel=: glsel2@:(":^:(2~:3!:0))
NB. util

NB. =========================================================
RGBA=: 3 : 'r (23 b.) 8 (33 b.) g (23 b.) 8 (33 b.) b (23 b.) 8 (33 b.) a [ ''r g b a''=. <.y'
BGRA=: 3 : 'b (23 b.) 8 (33 b.) g (23 b.) 8 (33 b.) r (23 b.) 8 (33 b.) a [ ''r g b a''=. <.y'

NB. =========================================================
NB. pafc v Polar angle from cartesian coords
pafc=: 2p1&|@{:@:(*.@(j./))

rfd=: *&(1p1%180)
dfr=: *&(180%1p1)

NB. calcAngle gives polar angle in radians with zero at 3-o'clock
NB. from rectangular coordiates with origin (0,0) at the top, left
NB. (xctr,yctr) calcAngle xpt,ypt
calcAngle=: ([: pafc _1 1 * -)"1

NB. =========================================================
NB. convert radians to 64ths-of-a-degree
degree64=: 0.5 <.@:+ 64 * dfr

NB. =========================================================
NB. opengl (and normal folk?) are ARGB with A 0
NB. glpixels and glqpixels need to make these adjustments
3 : 0''
if. IF64 do.
  ALPHA=: 0{_3 ic 0 0 0 255 255 255 255 255{a.
else.
  ALPHA=: 0{_2 ic 0 0 0 255{a.
end.
''
)
NOTALPHA=: 0{_2 ic 255 255 255 0{a.
ALPHARGB=: IF64{::_1;16bffffffff

NB. =========================================================
NB. arc drawing - glellipse, glarc, glpie
NB. draw arc on the ellipse defined by rectangle
NB. arc starts at xa,ya and ends at xz,yz (counterclockwise)
NB. points need not lie on the ellipse
NB. they define a line from the center that intersects ellipse
NB. gdk arc has same xywh but args are start and end angles
NB. counterclockwise in 64th degrees

NB. =========================================================
parseFontname=: 3 : 0
font=. ' ',y
b=. (font=' ') > ~:/\font='"'
a: -.~ b <@(-.&'"');._1 font
)

NB.*FontStyle n Regular Bold Italic Underline Strikeout
NB.             0       1    2      4         8
FontStyle=: ;:'regular bold italic underline strikeout'

parseFontSpec=: 3 : 0
'ns styleangle'=. 2 split parseFontname y
'face size'=. ns
size=. 12". size
style=. FontStyle i. tolower each styleangle
style=. <.+/2^<:(style ((> 0) *. <) #FontStyle) # style
if. 1 e. an=. ('angle'-:5&{.)&> styleangle do.
  degree=. 10%~ 0". 5}.>(an i. 1){styleangle
else.
  degree=. 0
end.
face;size;style;degree
)

NB. delete leading white spaces
dlws=: 3 : 0
y }.~ +/ *./\ (y e. ' ')+.(y e. LF)+.(y e. TAB)
)

NB. count leading white spaces
clws=: 3 : 0
+/ *./\ (y e. ' ')+.(y e. LF)+.(y e. TAB)
)

NB. get first argument and remove enclosing dquotes or DEL
NB. update global noun wdglptr on exit
wdglshiftarg=: 3 : 0
if. (#wdglstr) = wdglptr=: wdglptr + clws wdglptr}. wdglstr do. '' return. end.
y=. wdglptr}.wdglstr
b=. y e. ' '
a=. y e. '*'
q=. 2| +/\ y e. '"'
d=. 2| +/\ y e. DEL
b=. b *. -.q+.d
a=. a *. -.q+.d
if. 1={.a do.     NB. *argument
  z=. }.y
  wdglptr=: #wdglstr
elseif. (1={.d)+.(1={.q) do.   NB. enclosed between DEL or "
  p2=. 1+ (}.y) i. {.y
  z=. }.p2{.y
  wdglptr=: wdglptr+ p2+1
elseif. 1 e. b do. NB. space delimited
  p2=. {.I.b
  z=. p2{.y
  wdglptr=: wdglptr+ 1+p2
elseif. do.
  z=. y
  wdglptr=: #wdglstr
end.
<z
)

NB. get all arguments by repeating calling wdglshiftarg
wdglshiftargs=: 3 : 0
wdglptr=: 0 [ wdglstr=: y
z=. 0$<''
while. wdglptr < #wdglstr do. z=. z, wdglshiftarg'' end.
z
)

tors=: 3 : 0
(2{.y),(2{.y)+2}.y
)
coclass 'psqlite'
CH=: i.0
DBS=: i.0 3
Debug=: 0
LastError=: ''
Timeout=: 60000
SQLITE_INTEGER=: 1
SQLITE_FLOAT=: 2
SQLITE_TEXT=: 3
SQLITE_BLOB=: 4
SQLITE_NULL_INTEGER=: <.-2^<:32*1+IF64
SQLITE_NULL_FLOAT=: __
SQLITE_NULL_TEXT=: 'NULL'
create=: 3 : 0
'file opt'=. 2 {. boxopen y
file=. 0 pick fboxname file
flags=. SQLITE_OPEN_FULLMUTEX,SQLITE_OPEN_WAL
if. (;:'nowal') e. ;:opt do.
  flags=. flags-.SQLITE_OPEN_WAL
end.
if. (;:'readonly') e. ;:opt do.
  flags=. flags,~SQLITE_OPEN_READONLY
else.
  flags=. flags,~SQLITE_OPEN_READWRITE
end.
opts=. SQLITE_OPEN_CREATE
flags=. +/flags,opts #~ (;:'create') e. ;:opt
handle=. ,_1
nul=. SQLITE_NULL_INTEGER;SQLITE_NULL_FLOAT;SQLITE_NULL_TEXT
if. SQLITE_OK ~: >@{. cdrc=. sqlite3_extopen file;handle;flags;nul,<<0 do.
  throw 'unable to open database' return.
end.
CH=: {.handle=. 2{::cdrc
sqlite3_extended_result_codes CH, 1
sqlite3_busy_timeout CH, Timeout
connadd CH;file;coname''
)
destroy=: 3 : 0
sqlite3_close CH
conndel CH
codestroy''
)
0 0$".'p<c>q<=:>,q<&{"1>' 8!:2 ,.~i.3

boxindexof=: i.&>~@[ i.&|: i.&>
boxmember=: i.&>~ e.&|: i.&>~@]

col=: ,.@:>each :($:@([ {.each ]))
commasep=: }.@;@:((',' , ":)each)
intersect=: e. # [
isboxed=: 0 < L.
ischar=: 2=3!:0
isfloat=: 8=3!:0
round=: [ * [: <. 0.5 + %~
samesize=: 1 = #@~.@:(#&>)
strlen=: ;#
termLF=: , (0 < #) # LF -. {:
astable=: 3 : 0
'cls dat'=. y
cls,:col dat
)
connadd=: 3 : 0
empty DBS_psqlite_=: DBS,y
)
conndel=: 3 : 0
ndx=. (;c0 DBS) i. CH
if. ndx<#DBS do.
  DBS_psqlite_=: (<<<ndx) { DBS
end.
EMPTY
)
cutat=: 4 : 0
cls=. {:$y
rem=. x|cls
dat=. |: (-x) <\"1 y
}. ; ([:<@:,LF,.":@:>) "1 dat
)
fixcol=: 3 : 0
if. isboxed y do.
  ,dquote each ": each y
elseif. ischar y do.
  ,dquote each dtb each <"1 y
elseif. do.
  ,8!:0 y
end.
)
fixselect=: 3 : 0
sel=. fixselect1 y
if. -. '.' e. sel do. return. end.
if. 'pragma' -: 6 {. sel do. return. end.
if. -. '"' e. sel do. return. end.
b=. (sel e. ' ,<>!=') > ~:/\sel='"'
t=. (1,b) <;.1 ' ',sel
m=. I. ('.' e. &> t) > '"' e.&> t
if. -. 1 e. m do. sel return. end.
dq=. {. , '"' , '"' ,~ }.
}. ; (dq each m{t) m} t
)
fixselect1=: 3 : 0
sel=. dltb y
hdr=. tolower 7 {. sel
if. (<hdr) e. 'pragma ';'select ' do. sel return. end.
if. 1 e. ' from ' E. sel do.
  'select ',sel return.
end.
'select * from ',sel
)
fixselectx=: 3 : 0
sel=. fixselect y
cls=. 0 pick splitselect sel
if. -. 1 e. (' rowid,' E. cls) +. ' rowid ' E. cls do.
  'select rowid,',dlb 6 }. sel
end.
)
getlastrows=: 3 : 0
'len tab where'=. y
rws=. sqlexec 'select rowid from ',tab,where
(-len <. #rws) {. rws
)
list2mat=: 3 : 0
|: > (I. 0 = L. &> y) <"0 xeach y
)
listvalues=: 3 : 0
if. ischar y do.
  y=. dtb each <"1 y
end.
if. isboxed y do.
  r=. commasep '"' ,each y ,each '"'
else.
  r=. '-' (I. r='_')} r=. commasep y
end.
'(',r,')'
)
shellcmd=: 3 : 0
if. IFUNIX do.
  hostcmd_j_ y
else.
  spawn_jtask_ y
end.
)
splitselect=: 3 : 0
n=. 6 + 1 i.~ ' from ' E. y
f=. dlb n{.y
y=. deb n}.y
n=. y i. ' '
t=. n{.y
y=. n }.y
n=. 1 i.~ ' order by ' E. y
w=. n{.y
s=. n}.y
f;t;w;s
)
throw=: 3 : 0
if. #y do.
  LastError=: y
else.
  s=. sqlite3_errcode CH
  if. p=. sqlite3_errmsg CH do.
    msg=. memr p, 0 _1
  else.
    msg=. ''
  end.
  LastError=: 'sqlite rc=',(":s),' ',msg
end.
if. Debug do. sminfo LastError end.
throw.
)
xeach=: 1 : (':';'(u each x{y) x}y')
3 : 0''
if. UNAME-:'Android' do.
  arch=. LF-.~ 2!:0'getprop ro.product.cpu.abi'
  if. IF64 < arch-:'arm64-v8a' do.
    arch=. 'armeabi-v7a'
  elseif. IF64 < arch-:'x86_64' do.
    arch=. 'x86'
  end.
  2!:0 'mkdir -p ', jpath'~bin/../libexec/',arch
  libsqlite=: (jpath'~bin/../libexec/',arch,'/libjsqlite3.so')
else.
  ext=. (('Darwin';'Linux') i. <UNAME) pick ;:'dylib so dll'
  libsqlite=: jpath '~addons/data/sqlite/lib/libjsqlite3',((-.IF64)#'_32'),'.',ext
end.
)
binreq=: 108
relreq=: 901
checklibrary=: 3 : 0
if. ((<UNAME) e.'Darwin';'Linux')>IF64+.IFRASPI do.
  sminfo 'Sqlite';'The data/sqlite addon is for J64 only.' return.
end.
if. -. fexist libsqlite do.
  getbinmsg 'The data/sqlite binary has not yet been installed.',LF2,'To install, ' return.
end.
extver=. 100 * 0 ". sqlite_extversion''
if. binreq = extver do. return. end.
if. binreq > extver do.
  getbinmsg 'The data/sqlite binary is out of date.',LF2,'To get the latest, ' return.
end.
sminfo 'Sqlite';'The data/sqlite addon is out of date. Please install the latest version.' return.
)
getbin=: 3 : 0
if. ((<UNAME) e.'Darwin';'Linux')>IF64+.IFRASPI do. return. end.
require 'pacman'
path=. 'http://www.jsoftware.com/download/sqlitebin/',(":relreq),'/'
arg=. HTTPCMD_jpacman_
tm=. TIMEOUT_jpacman_
dq=. dquote_jpacman_ f.
to=. libsqlite_psqlite_
if. UNAME-:'Android' do.
  arch=. LF-.~ 2!:0'getprop ro.product.cpu.abi'
  if. IF64 < arch-:'arm64-v8a' do.
    arch=. 'armeabi-v7a'
  elseif. IF64 < arch-:'x86_64' do.
    arch=. 'x86'
  end.
  fm=. path,'android/libs/',z=. arch,'/libjsqlite3.so'
  'res p'=. httpget_jpacman_ fm
  if. res do.
    smoutput 'Connection failed: ',z return.
  end.
  (<to) 1!:2~ 1!:1 <p
  2!:0 ::0: 'chmod 644 ', dquote to
  1!:55 ::0: <p
  smoutput 'Sqlite binary installed.'
  return.
end.
fm=. path,(IFRASPI#'raspberry/'),1 pick fpathname to
lg=. jpath '~temp/getbin.log'
cmd=. arg rplc '%O';(dquote to);'%L';(dquote lg);'%t';'3';'%T';(":tm);'%U';fm
res=. ''
fail=. 0
try.
  fail=. _1-: res=. shellcmd cmd
  2!:0 ::0:^:(UNAME-:'Linux') 'chmod 644 ', dquote to
catch. fail=. 1 end.
if. fail +. 0 >: fsize to do.
  if. _1-:msg=. freads lg do.
    if. (_1-:msg) +. 0=#msg=. res do. msg=. 'Unexpected error' end. end.
  ferase to,lg
  smoutput 'Connection failed: ',msg
else.
  ferase lg
  smoutput 'Sqlite binary installed.'
end.
)
getbinmsg=: 3 : 0
msg=. y,' run the getbin_psqlite_'''' line written to the session.'
smoutput '   getbin_psqlite_'''''
sminfo 'Sqlite';msg
)
SQLITE_OK=: 0
SQLITE_DONE=: 101
SQLITE_OPEN_READONLY=: 16b00000001
SQLITE_OPEN_READWRITE=: 16b00000002
SQLITE_OPEN_CREATE=: 16b00000004
SQLITE_OPEN_NOMUTEX=: 16b00008000
SQLITE_OPEN_FULLMUTEX=: 16b00010000
SQLITE_OPEN_SHAREDCACHE=: 16b00020000
SQLITE_OPEN_PRIVATECACHE=: 16b00040000
SQLITE_OPEN_WAL=: 16b00080000
lib=. '"',libsqlite,'"'
sqlite3_busy_timeout=: (lib, ' sqlite3_busy_timeout > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_close=: (lib, ' sqlite3_close > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_errcode=: (lib, ' sqlite3_errcode > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_errmsg=: (lib, ' sqlite3_errmsg > ',(IFWIN#'+'),' x x' ) &cd
sqlite3_exec=: (lib, ' sqlite3_exec > ',(IFWIN#'+'),' i x *c x x *x' ) &cd
sqlite3_extended_result_codes=: (lib, ' sqlite3_extended_result_codes > ',(IFWIN#'+'),' i x i' ) &cd
sqlite3_free=: (lib, ' sqlite3_free > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_last_insert_rowid=: (lib, ' sqlite3_last_insert_rowid > ',(IFWIN#'+'),' i x' ) &cd
sqlite3_libversion=: (lib, ' sqlite3_libversion > ',(IFWIN#'+'),' x' ) &cd
sqlite3_sourceid=: (lib, ' sqlite3_sourceid > ',(IFWIN#'+'),' x' ) &cd
sqlite3_extopen=: (lib, ' sqlite3_extopen ',(IFWIN#'+'),' i *c *x i x d *c *c' ) &cd
sqlite3_extversion=: (lib, ' sqlite3_extversion > ',(IFWIN#'+'),' x') &cd
sqlite3_exec_values=: (lib, ' sqlite3_exec_values > ',(IFWIN#'+'),' i x *c i i *i *i *c') &cd
sqlite3_free_values=: (lib, ' sqlite3_free_values > ',(IFWIN#'+'),' i *') &cd
sqlite3_read_values=: (lib, ' sqlite3_read_values ',(IFWIN#'+'),' i x *c *') &cd
sqlite3_select_values=: (lib, ' sqlite3_select_values ',(IFWIN#'+'),' i x *c * i *i *i *c') &cd
sqlite_extversion=: 3 : 0
try.
  ":0.01*sqlite3_extversion''
catch.
  '0.00'
end.
)
sqlite_info=: 3 : 0
v=. memr (sqlite3_libversion''),0 _1
s=. memr (sqlite3_sourceid''),0 _1
v;s
)
sqlinsert=: 3 : 0
if. 0 -: args=. writeargs y do. 0 return. end.
'tab nms typ dat'=. args
sel=. }. (+:#nms) $ ',?'
sel=. 'insert into ',tab,' ',(listvalues nms),' values(',sel,')'
execparm sel;nms;typ;<dat
)
sqllastrowid=: 3 : 0
sqlite3_last_insert_rowid CH
)
sqlclose=: destroy
sqldebug=: 3 : 'Debug=: y'
sqlerror=: 3 : 'LastError'
sqlcmd=: 3 : 0
rc=. sqlite3_exec CH;y;0;0;,0
if. rc do. throw '' end.
)
sqlcolinfo=: 3 : 0
sel=. 'select * from ',y,' limit 0'
'rc res'=. 0 3 { sqlite3_read_values CH;sel;,2
if. rc ~: SQLITE_DONE do. throw'' return. end.
'j typ nms len j cls'=. memr res, 0 6 4
names=. <;._2 memr nms,0,len
types=. memr typ,0,cls,4
sqlite3_free_values <res
names;types
)
sqlcols=: 3 : 0
1 pick sqlexec 'pragma table_info(',y,')'
)
sqlcopy=: 3 : 0
'from to'=. fboxname each y
if. _1 -: (fread from) fwrite to do.
  throw 'unable to copy database' return.
end.
sqlopen to
)
sqlcreate=: 3 : 0
db=. fboxname y
ndx=. (1{"1 DBS) i. db
if. ndx < #DBS do.
  loc=. ndx{2{"1 DBS
  sqlclose__loc''
end.
'' fwrite db
(db;'create') conew 'psqlite'
)
sqlexist=: 3 : 0
sqlexec 'select count(*) from sqlite_master where type="table" and name="',y,'"'
)
sqlfkey=: 3 : 0
sqlreads 'pragma foreign_key_list(',y,')'
)
sqlindex=: 3 : 0
sqlreads 'pragma index_list(',y,')'
)
sqlmeta=: 3 : 0
sqlreads 'pragma table_info(',y,')'
)
sqlname=: 3 : 0
((;c0 DBS) i. CH) pick c1 DBS
)
sqlopen=: 3 : 0
ndx=. (c1 DBS) i. fboxname y
if. ndx < #DBS do.
  ndx{c2 DBS return.
end.
y conew 'psqlite'
)
sqlreset=: 3 : 0
for_loc. (2{"1 DBS) intersect conl 1 do.
  sqlclose__loc''
end.
EMPTY
)
sqlschema=: 3 : 0
cmd=. 'select sql from main.sqlite_master where name="',y,'" and type in ("table","view")'
0 pick sqlexec cmd
)
sqlsize=: 3 : 0
{. sqlexec 'select count(*) from ',y
)
sqltables=: 3 : 0
r=. sqlexec 'name from main.sqlite_master where type="table"'
r=. r #~ (<'sqlite_') ~: 7 {.each r
sort r #~ (1 e. y E. ]) &> r
)
sqlviews=: 3 : 0
r=. sort sqlexec 'name from main.sqlite_master where type="view"'
r #~ (1 e. y E. ]) &> r
)
sqlparm=: 3 : 0
if. 2=#y do.
  'sel dat'=. y
  typ=. parmtype &> boxxopen dat
else.
  'sel typ dat'=. y
end.
typ=. ,typ
nms=. ('item',":) each i.#typ
'nms dat'=. parmargs nms;<dat
execparm sel;nms;typ;<dat
)
execparm=: 3 : 0
'sel nms typ dat'=. y
rws=. #0 pick dat
val=. typ fixparm each dat
if. (<0) e. val do.
  throw 'invalid data for',;' ' ,each nms #~ (<0)=val return.
end.
typval=. (#typ);typ;(#&>val);;val
if. 'select ' -: 7 {. sel do.
  readvalues sqlite3_select_values CH;sel;(,2);typval
else.
  rc=. sqlite3_exec_values CH;sel;rws;typval
  if. rc do. throw '' end.
end.
)
fixparm=: 4 : 0
if. (x=0) +. 1 < #$y do. 0 return. end.
t=. 3!:0 y
if. x=1 do.
  if. t e. 1 4 do. (2+IF64) (3!:4) y else. 0 end. return.
end.
if. x=2 do.
  if. t e. 1 4 8 do. 2 (3!:5) y else. 0 end. return.
end.
if. t ~: 32 do. 0 return. end.
if. 0 e. 2 = 3!:0 &> y do. 0 return. end.
if. x=3 do. ; y ,each {.a. else. (2 (3!:4) # &> y),;y end.
)
parmargs=: 3 : 0
'nms dat'=. y

nms=. ,each boxxopen nms

if. 0 e. $dat do. 0 return. end.
dat=. boxxopen dat
ndx=. I. 2=3!:0 &> dat
dat=. (<each ndx{dat) ndx} dat

rws=. {. len=. # &> dat
if. 0=rws do. 0 return. end.
if. 0 e. rws = len do.
  throw 'column data not of same length: ',":len return.
end.

nms;<dat
)
parmtype=: 3 : 0
t=. 3!:0 y
if. t e. 1 4 do. SQLITE_INTEGER
elseif. t=8 do. SQLITE_FLOAT
elseif. t e. 2 32 do. (({.a.) e. ;y) pick SQLITE_TEXT;SQLITE_BLOB
elseif. do. throw 'unsupported datatype: ',":t
end.
)
writeargs=: 3 : 0
'tab nms dat'=. y

if. 0=args=. parmargs nms;<dat do. 0 return. end.
'nms dat'=. args

'names types'=. sqlcolinfo tab

if. 0=#nms do.
  nms=. names
elseif. 0 e. nms e. names do.
  throw 'column not found:',; ' ' ,each nms -. names return.
end.
typ=. (names i. nms) { types

tab;nms;typ;<dat
)
sqlread=: 3 : 0
sel=. fixselect y
readvalues sqlite3_read_values CH;sel;,2
)
readvalues=: 3 : 0
'rc res'=. 0 3 { y
if. rc ~: SQLITE_DONE do. throw'' return. end.
SZI=. IF64{4 8
'buf typ nms len rws cls'=. memr res, 0 6 4
colnames=. <;._2 memr nms,0,len
pointers=. memr buf,0,cls,4
types=. memr typ,0,cls,4
data=. ''
for_p. pointers do.
  select. p_index{types
  case. 1 do.
    val=. memr p,0,rws,4
  case. 2 do.
    val=. memr p,0,rws,8
  case. 3 do.
    len=. memr p, 0 1 4
    val=. <;._2 memr p,SZI,len-SZI
  case. 4 do.
    cnt=. memr p,SZI,rws,4
    pos=. SZI * rws+1
    dat=. memr p,pos,+/cnt
    if. 0=#dat do.
      val=. (#cnt)#<''
    else.
      if. 0 e. cnt do.
        msk=. 1 (0,+/\}:cnt-.0)} (#dat)$0
        val=. (cnt>0) #^:_1 msk <;.1 dat
      else.
        msk=. 1 (0,+/\}:cnt)} (#dat)$0
        val=. msk <;.1 dat
      end.
    end.
  end.
  data=. data,<val
end.
sqlite3_free_values <res
colnames;<data
)
sqlreadx=: 3 : 'sqlread fixselectx y'
sqlreads=: astable @ sqlread
sqlreadsx=: astable @ sqlreadx
sqldict=: 3 : 0
'cls dat'=. sqlread y
if. 1 = #>{.dat do.
  dat=. 0 pick each dat
end.
cls,.dat
)
sqlendsx=: 3 : 0
5 sqlendsx y
:
'cls dat'=. <"1 x sqlheadx y
ext=. 1{x sqltailx y
msk=. -. (0 pick ext) e. 0 pick dat
cls,:dat ,each msk&# each ext
)

sqlends=: }."1 @: sqlendsx
sqlexec=: 3 : 0
r=. 1 pick sqlread y
if. 1=#r do.
  0 pick r
end.
)
sqlexecx=: 3 : 0
r=. 1 pick sqlreadx y
if. 1=#r do.
  0 pick r
end.
)
sqlhead=: 3 : 0
10 sqlhead y
:
if. x<0 do.
  (|x) sqltail y
else.
  sqlreads y,(x>0)#' limit ',":x
end.
)
sqlheadx=: 3 : 0
10 sqlheadx y
:
if. x<0 do.
  (|x) sqltailx y
else.
  sqlreadsx y,(x>0)#' limit ',":x
end.
)
sqlkeysum=: 3 : 0
'tab key sum'=. y
key=. commasep boxxopen key
sum=. commasep (<'sum(') ,each (boxxopen sum) ,each ')'
sqlread 'select ',key,',',sum,' from ',tab,' group by ',key, ' order by ',key
)
sqlrand=: 3 : 0
10 sqlrand y
:
id=. dbexec 'rowid from ',y
if. x<#id do.
  id=. sort id {~ x ? #id
end.
sqlreads y,' where rowid in ',listvalues id
)
sqlrandx=: 3 : 0
10 sqlrandx y
:
id=. dbexec 'rowid from ',y
if. x<#id do.
  id=. sort id {~ x ? #id
end.
sqlreadsx y,' where rowid in ',listvalues id
)
sqlreadm=: 3 : 0
'cls dat'=. sqlread y
cls;<list2mat dat
)
sqltail=: 3 : 0
10 sqltail y
:
if. x-:0 do. sqlreads y return. end.
'frm tab whr ord'=. splitselect fixselect y
sqlreads frm,tab,' where rowid in ',listvalues getlastrows x;tab;whr
)
sqltailx=: 3 : 0
10 sqltailx y
:
if. x-:0 do. sqlreadx y return. end.
'frm tab whr ord'=. splitselect fixselect y
sqlreadsx frm,tab,' where rowid in ',listvalues getlastrows x;tab;whr
)
sqlite3do=: 3 : 0
'db cmd'=. y
db=. jpath db
cmd=. a: -.~ <;._2 cmd,LF
ndx=. I. '.' ~: {. &> cmd
f=. , ';' -. {:
cmd=. (f each ndx{cmd) ndx} cmd
cmd=. ; cmd ,each LF
cmd fwrites tmp=. jpath '~temp/sqlite3shell.cmd'
if. IFWIN do.
  r=. spawn_jtask_ 'sqlite3.exe "',(winpathsep db),'" < "',(winpathsep tmp),'"'
else.
  r=. 2!:0 '/usr/bin/sqlite3 "',db,'" < "',tmp,'"'
end.
r[ferase tmp
)
sqlite3=: 3 : 0
sqlite3do (sqlname'');y
)
sqlimportcsv=: 3 : 0
'table def sep csvfile'=. y
cmd=. (termLF def),'.separator "',sep,'"',LF,'.import "',csvfile,'" ',table
sqlite3 cmd
)
sqlupdate=: 3 : 0
'tab whr nms dat'=. y
if. 0 -: args=. writeargs tab;nms;<dat do. 0 return. end.
'tab nms typ dat'=. args
whr=. ('where ' #~ -.'where ' -: 6 {. whr),whr
set=. }:;nms ,each <'=?,'
sel=. 'update ',tab,' set ',set,' ',whr
execparm sel;nms;typ;<dat
)
sqlupsert=: 3 : 0
'tab keys nms dat'=. y
keys=. boxxopen keys
nms=. ,each boxxopen nms
if. 0=#keys do. throw 'upsert keys names not given' return. end.
if. #keys -. nms do. throw 'upsert keys names not in column names' return. end.

if. 0 -: args=. writeargs tab;nms;<dat do. 0 return. end.
'tab nms typ dat'=. args

sel=. ''
for_key. keys do.
  ndx=. nms i. key
  sel=. sel,' AND ',(>key),' in ',listvalues ~.ndx pick dat
end.
old=. sqlexec ('rowid,',commasep keys),' from ',tab,' where ',5 }.sel
row=. 0 pick old
if. 0=#row do. sqlinsert 0 2 3{y return. end.

old=. }.old
new=. (nms i. keys) { dat
ind=. old boxindexof new

msk=. ind=#row
if. 1 e. msk do.
  sqlinsert tab;nms;<msk&# each dat
  if. -. 0 e. msk do. return. end.
  ind=. (-.msk)#ind
  dat=. (-.msk)&# each dat
end.
row=. ind{row

old=. sqlexec 'rowid,',(commasep nms),' from ',tab,' where rowid in ',listvalues row
msk=. -. dat boxmember }.old
if. -. 1 e. msk do. 0 return. end.

row=. msk#row
dat=. msk&# each dat
cls=. #nms

cmd=. 'update ',tab,' set ', (}: ; nms ,each <'=?,'),' where rowid='
for_r. row do.
  execparm (cmd,":r);nms;typ;<r_index {each dat
end.
#row
)
checklibrary$0
cocurrent 'base'
NB. =========================================================
NB. web/gethttp
NB. J interface for Wget/cURL to retrieve files using http, ftp, https

require 'task strings socket'

coclass 'wgethttp'

3 : 0 ''

  IFWGET=: 0
  HTTPCMD=: ''
  select. <UNAME
  case. 'Android' do.
    if. 1=ftype f=. '/system/xbin/wget' do.  NB. android busybox
      IFWGET=: 1
      HTTPCMD=: f
    elseif. 1=ftype f=. '/system/bin/wget' do.  NB. alternate location
      IFWGET=: 1
      HTTPCMD=: f
    end.
  case. 'Win' do.
    if. fexist f=. jpath '~addons/web/gethttp/bin/curl.exe' do.
      HTTPCMD=: f
    elseif. fexist f=. jpath '~tools/ftp/wget.exe' do.
      IFWGET=: 1
      HTTPCMD=: f
    end.
  case. 'Darwin' do.
    HTTPCMD=: 'curl'
  case. do.   NB. Linux
    try.
      2!:0'which curl 2>/dev/null'
      HTTPCMD=: 'curl'
    catch.
      try.
        2!:0'which wget 2>/dev/null'
        IFWGET=: 1 [ HTTPCMD=: 'wget'
      catch. end.
    end.
  end.
  if. IFUNIX do.   NB. fix task.ijs definition of spawn on mac/unix
    quot=: '"','"',~rplc&(,(];'\',])"0'\$"')
    spawn=: [: 2!:0 '(' , ' || true)' ,~ ]
  else.
    quot=: ]
    spawn=: spawn_jtask_
  end.
  ''
)

NB. ---------------------------------------------------------
NB. Utility verbs
safe=. (33}.127{.a.)-.'=&%+'
encode=:  [: toupper ('%',(I.'6'=,3!:3'f') {&, 3!:3)
nvp=: >@{.,'=',urlencode@":@>@{:
args=: [: }.@; ('&'<@,nvp)"1

NB. ---------------------------------------------------------
NB. Public verbs

NB.*urlencode v Encode string as valid url
urlencode=:  [: ; encode^:(safe -.@e.~ ])&.>

NB.*urlquery v Creates urlencoded string of namevalue pairs.
NB. returns: urlencoded string of namevalue pairs for appending to url
NB. y is: rank 1 or 2 array of boxed namevalue pairs
NB.        rank 1 assumes name;value;name;value...
NB.        rank 2 assumes 0{"1 is names & 1{"1 is values
NB. eg: urlquery ('action';'query'),('name';'S&P Inc'),:('format';'json')
urlquery=: 3 : 0
  if. 0 e. $y do. '' return. end.
  'arg should be boxed' assert 32 = 3!:0 y
  'arg should be rank 1 or 2' assert 1 2 e.~ rnk=. #$y
  if. rnk = 1 do. 
    'arg should be name-value pairs' assert 0 = 2|#y
    y=. _2]\ y
  else. 'arg should only have 2 cols' assert 2 = {:$y end.
  args y
)

NB.*gethttp v Retrieve URI using Wget/cURL tools
NB. [option] gethttp uri
NB. result: depends on options, Default is URI contents
NB. y is: URI to retrieve
NB. x is: Optional retrieval options. One of:
NB.       'stdout' (Default)
NB.       'help'
NB.       'file' or ('file';jpath '~temp/myfile.htm')
NB.       Anything else is assumed to be a valid Wget/cURL option string
NB. eg: 'file' gethttp 'http://www.jsoftware.com'
NB. eg: ('-o - --stderr ',jpath '~temp/gethttp.log') gethttp 'http://www.jsoftware.com'
gethttp=: 3 : 0
  'stdout' gethttp y
:
  url=. y
  'jopts fnme'=. 2{. boxopen x
  if. IFIOS +. HTTPCMD-:'' do.
    if. 'http://'-.@-:7{.url do.
      'only http:// supported' return.
    end.
    output=. 0
    fil=. ''
    select. jopts
    case. 'stdout' do.  NB. content retrieved from stdout, log suppressed
    case. 'help' do.    NB. help
      'no help available' return.
    case. 'file' do.
      output=. 1
      if. #fnme do.     NB. save as filename
        fil=. fnme
      end.
    end.
    server=. ({.~ i.&'/') (7}.url)
    aurl=. }.(}.~ i.&'/') (7}.url)
    try.
    'header data'=. jwget server;aurl
    catch.
    'getHTTP error' return.
    end.
    if. 0=output do.
      data return.
    else.
      if. #fil do.
        if. '/' e. fil=. jpathsep fil do. mkdir_j_ ({.~ i:&'/') fil end.
        data fwrite fil
      else.
        fil=. }:^:('/'={:) aurl
        fil=. (}.~ i:&'/') fil
        fil=. }.^:('/'={.) fil
        if. 0=#fil do. fil=. 'httpresult' end.
        data fwrite fil
      end.
      '' return.
    end.
  end.
  select. jopts
  case. 'stdout' do.  NB. content retrieved from stdout, log suppressed
    opts=. IFWGET{:: '-o - -s -S';'-O - -q'
  case. 'file' do. 
    if. #fnme do.     NB. save as filename
      opts=. IFWGET{:: '--stderr - -o ';'-O '
      opts=. opts,fnme
    else.             NB. copy file to current dir
      opts=. IFWGET{:: '-O --stderr -';' '
    end.
  case. 'help' do.    NB. help
    opts=. '--help'
  case. do.           NB. custom option string?
    if. 2 131072 262144 e.~ 3!:0 x do. opts=. utf8 x
    else. 'Invalid left argument for getHTTP' return. end.
  end.
  NB. curl: follow redirects (wget does by default); wget: decompress transport-level gzip (curl does by default)
  opts=. ' ',opts,IFWGET{:: ' -L ';' --compression=auto '
  spawn HTTPCMD , opts , quot url
)

NB. =========================================================
NB.! does not work when server response with HTTP 1.1

NB.! following code should be made as robust and general as possible
NB.  it should then be refactored into JHS (where it came from)

NB. send socket data
NB. return count of bytes sent
NB. errors: timeout, socket error, no data sent (disconnect)
ssend=: 4 : 0
'socket timeout'=. y
z=. sdselect_jsocket_ '';socket;'';timeout
'server send not ready' assert socket=>2{z
'c r'=. x sdsend_jsocket_ socket,0
('server send error: ',sderror_jsocket_ c) assert 0=c
'server send no data' assert 0<r
r
)

NB. data putdata socket,timeout
putdata=: 4 : 'while. #x do. x=. (x ssend y)}.x end.'

ssrecv=: 3 : 0
'socket timeout bufsize'=. y
z=. sdselect_jsocket_ socket;'';'';timeout
'server recv timeout' assert  socket e.>1{z  NB.0;'';'';'' is a timeout
'server recv not ready' assert socket=>1{z
'c r'=. sdrecv_jsocket_ socket,bufsize,0
('server recv error: ',sderror_jsocket_ c) assert 0=c
'server recv no data'       assert 0<#r
r
)

NB. get/post data - headers end with CRLF,CRLF
NB. post has Content-Length: bytes after the header
NB. listen and read until a complete request is ready
getdata=: 3 : 0
'socket timeout bufsize'=. y
h=. d=. ''
cl=. 0
while. (0=#h)+.cl>#d do. NB. read until we have header and all data
 r=. ssrecv socket,timeout,bufsize
 d=. d,r
 if. 0=#h do. NB. get headers
  i=. (d E.~ CRLF,CRLF)i.1 NB. headers CRLF delimited with CRLF at end
  if. i<#d do. NB. have headers
   i=. 4+i
   h=. i{.d NB. headers
   d=. i}.d
   i=. ('Content-Length:'E. h)i.1
   if. i<#h do.
    t=. (15+i)}.h
    t=. (t i.CR){.t
    cl=. _1".t
    assert _1~:cl
   else.
    cl=._1
   end.
  end.
 end.
end.
h;d
)

RECVBUFSIZE=: 50000
SENDTIMEOUT=: 20*60*1000 NB. 20 minutes for a send
TIMEOUT=: 20*60*1000 NB. 20 minutes for a response

jwget=: 3 : 0
'server url'=. y
i=. server i.':'
server=. i{.server
port=. {. 0".(>:i)}.server
port=. (0=port){port,80
if. #server-.'0123456789.' do.
  ip=. >2{sdgethostbyname_jsocket_ server
else.
  ip=. server
end.
try.
 t=. gettemplate rplc '<SERVER>';server;'<URL>';url
 sk=. >0{sdcheck_jsocket_ sdsocket_jsocket_''
NB. sdcheck_jsocket_ sdioctl_jsocket_ sk,FIONBIO_jsocket_,1
 sdcheck_jsocket_ sdconnect_jsocket_ sk;AF_INET_jsocket_;ip;port
 t putdata sk,SENDTIMEOUT
 hd=. getdata sk,RECVBUFSIZE,TIMEOUT
catch.
 sdclose_jsocket_ sk
 (13!:12'') assert 0
end.
sdclose_jsocket_ sk
hd
)

gettemplate=: toCRLF 0 : 0
GET /<URL> HTTP/1.0
User-Agent: Mozilla/5.0 (Linux; Android 4.4; Nexus 5 Build/_BuildID_) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36
Accept: */*
Host: <SERVER>
Connection: Keep-Alive

)

NB. =========================================================
NB. Export z locale

gethttp_z_ =: gethttp_wgethttp_
urlencode_z_=: urlencode_wgethttp_
urlquery_z_=: urlquery_wgethttp_
NB. regular expressions
NB.%regex.ijs - regular expressions
NB.-This script defines regular expression utilities
NB.-Definitions are loaded into the jregex locale with
NB.-cover functions in the z locale

coclass <'jregex'
NB. util

Rxnna=: '(^|[^[:alnum:]_])'
Rxnnz=: '($|[^[:alnum:]_.:])'
Rxass=: '[[:space:]]*=[.:]'

ischar=: 2=3!:0

NB. =========================================================
NB. user compilation flags (0=off, 1=on)
RX_OPTIONS_MULTILINE=: 1  NB. enable newline support, default on
RX_OPTIONS_UTF8=: 1  NB. enable UTF-8 support

NB. =========================================================
NB. clear last values, not saved compiles
regclear=: 3 : 0
lastcomp=: lasthandle=: lastmatch=: lastnsub=: 0
lastpattern=: ''
EMPTY
)

NB. =========================================================
regcomp=: 3 : 0
if. -.ischar y do. reghandle y return. end.
if. (0<#y) *. y-:lastpattern do. return. end.
regfree''
lastpattern=: y
msg=. ,2
off=. ,2
flg=. (PCRE2_UTF*RX_OPTIONS_UTF8)+PCRE2_MULTILINE*RX_OPTIONS_MULTILINE
lastcomp=: 0 pick rc=. jpcre2_compile (,y);(#y);flg;msg;off;<<0
'msg off'=. 4 5{rc
if. 0=lastcomp do. regerror msg,off end.
lasthandle=: 0
lastmatch=: 0 pick jpcre2_match_data_create_from_pattern (<lastcomp);<<0
lastnsub=: 0 pick jpcre2_get_ovector_count <<lastmatch
EMPTY
)

NB. =========================================================
NB. regerror
regerror=: 3 : 0
m=. regerrormsg y
lasterror=: m
regfree''
m 13!:8[12
)

NB. =========================================================
regerrormsg=: 3 : 0
'msg off'=. 2 {. y,_1
m=. (0 >. >{.rc) {. 2{::rc=. jpcre2_get_error_message msg;(256#' ');256
if. off >: 0 do.
  m=. m,' at offset ',(":off),LF
  m=. m,lastpattern,LF,(off#' '),'^',LF
end.
)

NB. =========================================================
regfree=: 3 : 0
if. lasthandle=0 do.
  if. lastmatch do.
    jpcre2_match_data_free <<lastmatch
  end.
  if. lastcomp do.
    jpcre2_code_free <<lastcomp
  end.
end.
regclear''
)

NB. =========================================================
NB. set handle
reghandle=: 3 : 0
reghandlecheck y
ndx=. cmhandles i. y
'lastcomp lastmatch lastnsub'=: ndx{cmtable
lastpattern=: ndx pick cmpatterns
lasthandle=: ndx{cmhandles
EMPTY
)

NB. =========================================================
reghandlecheck=: 3 : 0
if. y e. cmhandles do. y return. end.
m=. 'handle not found: ',":y
m 13!:8[12
)

NB. =========================================================
regmatch1=: 3 : 0
regmatchtab 0 pick jpcre2_match (<lastcomp);(,y);(#y);0;0;(<lastmatch);<<0
)

NB. =========================================================
regmatch2=: 3 : 0
's p'=. y
regmatchtab 0 pick jpcre2_match (<lastcomp);(,s);(#s);p;PCRE2_NOTBOL;(<lastmatch);<<0
)

NB. =========================================================
NB. get match table
regmatchtab=: 3 : 0
if. y >: 0 do.
  p=. 0 pick jpcre2_get_ovector_pointer <<lastmatch
  'b e'=. |:_2 [\ memr p,0,(2*lastnsub),4
  _1 0 (I.b=_1) } b,.e-b
elseif. y=_1 do.
  ,:_1 0
elseif. do.
  regerror y
end.
)

NB. =========================================================
NB. show all matches
regshow=: 4 : 0
m=. x rxmatches y
r=. ,:y
if. 0 = # m do. return. end.
for_i. i. 1 { $ m do.
  a=. i {"2 m
  x=. ;({."1 a) (+i.) each {:"1 a
  r=. r, '^' x } (#y) # ' '
end.
)

NB. =========================================================
NB. for now just check if comp is a valid compiled pattern
regvalid=: 3 : 0
len=. 0 pick jpcre2_pattern_info (<y);PCRE2_INFO_SIZE;<<0
rc=. 0 pick jpcre2_pattern_info (<y);PCRE2_INFO_SIZE;<len$' '
if. rc>:0 do. 1 else. 0[echo (regerrormsg rc),': ',":y end.
)

NB. =========================================================
showhandles=: 3 : 0
cls=. ;:'pattern handle comp match nsub valid'
if. #cmpatterns do.
  val=. regvalid &> {."1 cmtable
  dat=. (>cmpatterns);<@,."1 |: cmhandles,.cmtable,.val
else.
  dat=. (#cls)#<EMPTY
end.
cls,:dat
)

NB. =========================================================
NB. utility to show rxmatches at top level
showmatches=: 4 : 0
m=. x rxmatches y
r=. ,:y
if. 0 = # m do. return. end.
'b e'=. |:{."2 m
p=. ;b (+ i.) each e
r, '^' p } (#y) # ' '
)
NB. lib

NB. =========================================================
NB. compile flags:
PCRE2_NOTBOL=: 16b1
PCRE2_NOTEOL=: 16b2
PCRE2_MULTILINE=: 16b400
PCRE2_UTF=: 16b80000

NB. info types:
PCRE2_INFO_SIZE=: 22

NB. =========================================================
NB. pcre2 library is in bin or tools/regex
3 : 0''
select. UNAME
case. 'Win' do. t=. 'jpcre2.dll'
case. 'Android' do. t=. 'libjpcre2.so'
case. 'Darwin' do. t=. 'libjpcre2.dylib'
case. 'Linux';'OpenBSD';'FreeBSD' do. t=. 'libjpcre2.so'
case. do. t=. 'libjpcre2.so'
end.

f=. BINPATH,'/',t
if. 0 = 1!:4 :: 0: <f do.
  f=. jpath '~tools/regex/',t
end.

NB. fall back one more time
if. ('Android'-:UNAME) *. 0 = 1!:4 :: 0: <f do.
  f=. (({.~i:&'/')LIBFILE),'/',t
elseif. ((<UNAME)e.'Linux';'OpenBSD';'FreeBSD';'Darwin') *. 0 = 1!:4 :: 0: <f do.
  f=. unxlib 'pcre2'
elseif. 0 = 1!:4 :: 0: <f do.
  f=. t
end.

pcre2dll=: f
)

NB. =========================================================
makefn=: 3 : 0
'name decl'=. y
('j',name)=: ('"',pcre2dll,'" ',name,'_8 ',(IFWIN#'+ '),decl)&(15!:0)
EMPTY
)

NB. void pcre2_code_free_8 (pcre2_code_8 *);
NB. pcre2_code_8 *pcre2_compile_8 (PCRE2_SPTR8, size_t, uint32_t, int *, size_t *, pcre2_compile_context_8 *);
NB. int pcre2_get_error_message_8 (int, PCRE2_UCHAR8 *, size_t);
NB. uint32_t pcre2_get_ovector_count_8 (pcre2_match_data_8 *);
NB. size_t *pcre2_get_ovector_pointer_8 (pcre2_match_data_8 *);
NB. int pcre2_match_8 (const pcre2_code_8 *, PCRE2_SPTR8, size_t, size_t, uint32_t, pcre2_match_data_8 *, pcre2_match_context_8 *);
NB. pcre2_match_data_8 *pcre2_match_data_create_from_pattern_8 (const pcre2_code_8 *, pcre2_general_context_8 *);
NB. void pcre2_match_data_free_8 (pcre2_match_data_8 *);
NB. int pcre2_pattern_info_8 (const pcre2_code_8 *, uint32_t, void *);

makefn 'pcre2_code_free';'n *'
makefn 'pcre2_compile';'* *c x i *i *x *'
makefn 'pcre2_get_error_message';'i i *c x'
makefn 'pcre2_get_ovector_count';'i *'
makefn 'pcre2_get_ovector_pointer';'*x *'
makefn 'pcre2_match';'i * *c x x i * *'
makefn 'pcre2_match_data_create_from_pattern';'* * *'
makefn 'pcre2_match_data_free';'n *'
makefn 'pcre2_pattern_info';'i * i *c'
NB. compile
NB.
NB. globals:
NB. cmhandles is a list of handles
NB. cmpatterns is a corresponding list of patterns
NB. cmtable is a corresponding table of compile,match,nsub

NB. =========================================================
NB. compile pattern, return handle
rxcomp=: 3 : 0
if. -.ischar y do. reghandlecheck y return. end.
ndx=. cmpatterns i. <y
if. ndx < #cmpatterns do. ndx{cmhandles return. end.
regcomp y
cmpatterns=: cmpatterns,<y
cmhandles=: cmhandles, cmseq=: cmseq + 1
cmtable=: cmtable,lastcomp,lastmatch,lastnsub
lasthandle=: ndx{cmhandles
)

NB. =========================================================
rxfree1=: 3 : 0
ndx=. cmhandles i. y
if. ndx=#cmhandles do. EMPTY return. end.
if. -. lastpattern -: ndx pick cmpatterns do.
  'comp match nsub'=. ndx{cmtable
  jpcre2_match_data_free <<match
  jpcre2_code_free <<comp
end.
ndx=. <<<ndx
cmtable=: ndx{cmtable
cmhandles=: ndx{cmhandles
cmpatterns=: ndx{cmpatterns
EMPTY
)

rxfree=: EMPTY [ rxfree1 &>

NB. =========================================================
rxinfo=: 3 : 0
ndx=. cmhandles i. y
if. ndx=#cmhandles do. 'handle not found: ',":y return. end.
((<ndx;2){cmtable);ndx{cmpatterns
)

NB. =========================================================
rxhandles=: 3 : 'cmhandles'
NB. main methods

rxfrom=: ,."1@[ <;.0 ]
rxeq=: {.@rxmatch -: 0 , #@]
rxin=: _1 ~: {.@{.@rxmatch
rxindex=: #@] [^:(<&0@]) {.@{.@rxmatch
rxE=: i.@#@] e. {.@{."2 @ rxmatches
rxfirst=: {.@rxmatch >@rxfrom ]
rxall=: {."2@rxmatches rxfrom ]

NB. =========================================================
rxapply=: 1 : 0
:
if. L. x do. 'pat ndx'=. x else. pat=. x [ ndx=. ,0 end.
if. 1 ~: #$ ndx do. 13!:8[3 end.
mat=. ({.ndx) {"2 pat rxmatches y
r=. u&.> mat rxfrom y
r mat rxmerge y
)

NB. =========================================================
rxcut=: 4 : 0
if. 0 e. #x do. <y return. end.
'beg len'=. |: ,. x
if. 1<#beg do.
  whilst. 0 e. d do.
    d=. 1,<:/\ (}:len) <: 2 -~/\ beg
    beg=. d#beg
    len=. d#len
  end.
end.
a=. 0, , beg ,. beg+len
b=. 2 -~/\ a, #y
f=. < @ (({. + i.@{:)@[ { ] )
(}: , {: -. a:"_) (a,.b) f"1 y
)

NB. =========================================================
rxerror=: 3 : 'lasterror'

NB. =========================================================
rxmatch=: 4 : 0
'p n'=. 2 {. boxopen x
regcomp p
r=. regmatch1 y
if. #n do. n{r end.
)

NB. =========================================================
rxmatches=: 4 : 0
'p n'=. 2 {. boxopen x
regcomp p
m=. regmatch1 y
if. _1 = {.{.m do. i.0 1 2 return. end.
s=. 1 >. +/{.m
r=. ,: m
while. s <#y do.
  if. _1 = {.{.m=. regmatch2 y;s do. break. end.
  s=. (s+1) >. +/ {.m
  r=. r, m
end.
if. #n do. n{"2 r end.
)

NB. =========================================================
rxmerge=: 1 : 0
:
p=. _2 ]\ m rxcut y
;, ({."1 p),.(#p){.(#m)$x
)

NB. =========================================================
rxrplc=: 4 : 0
pat=. >{.x
new=. {:x
if. L. pat do. 'pat ndx'=. pat else. ndx=. ,0 end.
if. 1 ~: #$ ndx do. 13!:8[3 end.
m=. pat rxmatches y
if. 0 e. $m do. y return. end.
mat=. ({.ndx) {"2 m
new mat rxmerge y
)

NB. =========================================================
rxutf8=: 3 : '(RX_OPTIONS_UTF8=: y) ] RX_OPTIONS_UTF8'
NB. nouns for applying regular expressions to J code
NB.
NB.   Jname        name
NB.   Jnumitem     numeric item
NB.   Jnum         number or blank
NB.   Jcharitem    character item
NB.   Jchar        character
NB.   Jconst       constant
NB.
NB.   Jlassign     local assign
NB.   Jgassign     global assign
NB.   Jassign      any assign
NB.
NB.   Jlpar        left paren
NB.   Jrpar        right paren
NB.
NB.   Jsol         start of line
NB.   Jeol         end of line

Jname=: '[[:alpha:]][[:alnum:]_]*|x\.|y\.|m\.|n\.|u\.|v\.'
Jnumitem=: '[[:digit:]_][[:alnum:]_.]*'
Jnum=: '([[:digit:]_][[:alnum:]_.]*|[[:blank:]])?'
Jcharitem=: '''(''''|[^''])'''
Jchar=: '''(''''|[^''])*'''
Jconst=: '([[:digit:]_][[:alnum:]_.]*|[[:blank:]])?|''(''''|[^''])*''|a:|a\.'
Jlassign=: '=\.'
Jgassign=: '=:'
Jassign=: '=[.:]'
Jlpar=: '\('
Jrpar=: '\)'
Jsol=: '^[[:blank:]]*'
Jeol=: '[[:blank:]]*(NB\..*)?$'
NB. fini

NB. =========================================================
3 : 0''
if. _1=nc <'cmhandles' do.
  cmhandles=: cmpatterns=: $0
  cmseq=: 0
  cmtable=: i.0 3
end.
lasterror=: ''
regclear''
)

NB. =========================================================
NB. define z locale names:
nms=. 0 : 0
rxmatch rxmatches rxcomp rxfree rxhandles rxinfo rxeq
rxin rxindex rxE rxfirst rxall rxrplc rxapply rxerror
rxcut rxfrom rxmerge rxutf8
)

nms=. (nms e.' ',LF) <;._2 nms
". > nms ,each (<'_z_=:') ,each nms ,each <'_jregex_'
cocurrent 'jwikiviz'

clear ''

load 'data/sqlite'
load 'web/gethttp'
load 'regex'
load 'gl2'
coinsert 'jgl2'
NB. A Items
NB. Can I force update of gethttp?  Raul's email...
NB. Bob's approach to Forums.
NB. Forum browsing really doesn't work on a small screen.
NB. Packaging an add-on

NB. B Items
NB. Fix use of sqlreadm__db
NB. Animated webview transition...?
NB. Support parallel download of forum and wiki documents.
NB. Add a "Search" label.
NB. Fix the extra "quotes in NuVoc
NB. Spider the Vocabulary--don't use the spreadsheet.

NB. ============= Database ===============
db =: ''
stageDbFile =: 'jwikiviz.stage.db'
stageDbPath =: jpath '~temp/' , stageDbFile
targetDbPath =: jpath '~temp/jwikiviz.db'
curlTracePath =: jpath '~temp/jwikiviz.trace'

clearTrace =: 3 : 0
'' (1!:2) < tracePath
)

trace =: 3 : 0
LF (1!:3) < tracePath
y (1!:3) < tracePath
)

dbError =: 3 : 0
sqlerror__db ''
)

dbOpenDb =: 3 : 0
try.
	db =: sqlopen_psqlite_ targetDbPath
catcht.
	smoutput 'Error opening database'
end.
)

log =: 3 : 0
if. -. LogFlag do. return. end.
sqlinsert__db 'log' ; (;: 'datetime msg') ; < ((6!:0) 'YYYY MM DD hh mm sssss') ; y
if. 0 = ? 200 do.
	max =. , > > {: sqlreadm__db 'select max(rowid) from log'
	sqlcmd__db 'delete from log where rowid < ' , ": 0 >. max - 1000
end.
)

clearLog =: 3 : 0
sqlcmd__db 'delete from log'
)

initAdmin =: 3 : 0
sqlupsert__db 'admin' ; 'key' ; (;: 'key value') ; < 'qscreen' ; wd 'qscreen'
sqlupsert__db 'admin' ; 'key' ; (;: 'key value') ; < 'JVERSION' ; JVERSION
)
NB. =======================================

NB. ==================== Form =====================
VocMouseXY =: 0 0
VocMouseClickXY =: 0 0

buildForm =: 3 : 0
log 'buildForm'
wd 'pc vizform;'
wd 'bin h;'
wd   'bin v;'
wd     'bin h;'
wd       'cc clearSearches button;cn Clear *Searches;'
wd       'cc searchBox edit;'
wd       'cc logcheck checkbox;cn Debug (Log);'
wd     'bin z'
wd     'cc vocContext isigraph;'
wd   'bin z;'
wd   'bin v;'
wd     'bin h;'
wd       'cc bookmark button; cn *Bookmark'
wd       'cc history combolist;'
wd       'cc launch button; cn Browser;'
wd     'bin z;'
wd     'cc browser webview;'
wd   'bin z;'
wd 'bin z;'
)

layoutForm =: 3 : 0
log 'layoutForm'
'w h' =. ". wd 'getp wh'
winW =. w - 40
winH =. h - 45
controlHeight =. 30
vocContextHeight =. winH >. 760
if. EmphasizeBrowserFlag do.
	vocContextWidth =. 175
	browserWidth =. winW - vocContextWidth
	wd 'set clearSearches maxwh ' , (": (vocContextWidth * 0.15) , controlHeight) , ';'
	wd 'set searchBox maxwh ' , (": (vocContextWidth * 0.65) , controlHeight) , ';'
	wd 'set logcheck maxwh ' , (": (vocContextWidth * 0.15) , controlHeight) , ';'
	wd 'set vocContext maxwh ' , (": <. vocContextWidth , vocContextHeight) , ';'
	wd 'set bookmark maxwh ' , (": <. (browserWidth * 0.15), controlHeight) , ';'
	wd 'set history maxwh ' , (": <. (browserWidth * 0.6) , controlHeight) , ';'
	wd 'set launch maxwh ' , (": <. (browserWidth * 0.15) , controlHeight) , ';'
	wd 'set browser maxwh ' , (": (<. browserWidth) , winH - controlHeight) , ';'
else.
	vocContextWidth =. <. 825 >. winW % 2
	browserWidth =. winW - vocContextWidth
	wd 'set clearSearches maxwh ' , (": <. (vocContextWidth * 0.15) , controlHeight) , ';'
	wd 'set searchBox maxwh ' , (": (vocContextWidth * 0.65) , controlHeight) , ';'
NB. 	wd 'set scrollConfig maxwh ' , (": (vocContextWidth * 0.35) , controlHeight) , ';'
	wd 'set logcheck maxwh ' , (": (vocContextWidth * 0.15) , controlHeight) , ';'
	wd 'set vocContext maxwh ' , (": <. vocContextWidth , vocContextHeight) , ';'
	wd 'set bookmark maxwh ' , (": <. (browserWidth * 0.15), controlHeight) , ';'
	wd 'set history maxwh ' , (": <. (browserWidth * 0.6) , controlHeight) , ';'
	wd 'set launch maxwh ' , (": <. (browserWidth * 0.15) , controlHeight) , ';'
	wd 'set browser maxwh ' , (": (<. browserWidth) , winH - controlHeight) , ';'
	wd 'set browser minwh 100 50;'
end.
wd 'timer 100'
)

emphasizeBrowser =: 3 : 0
'w h' =. ". wd 'getp wh'
if. w > 1500 do. return. end. 
EmphasizeBrowserFlag =: 1
layoutForm ''
)

deemphasizeBrowser =: 3 : 0
EmphasizeBrowserFlag =: 0
layoutForm ''
)

vizform_default =: 3 : 0
eventType =. > {: 5 { wdq
if. eventType -: 'close' do. wd 'pclose ;' end.
NB. (> {: 5 { wdq) (1!:2) 2
)

vizform_resize =: 3 : 0
layoutForm ''
)

vizform_close =: 3 : 0
log 'vizform_close'
wd 'timer 0'
wd 'pclose'
if. -. DBG do. 2!:55 [0 end.
)

vizform_bookmark_button =: 3 : 0
log 'vizform_bookmark_button'
bookmark ''
invalidateDisplay ''
)

vizform_clearSearches_button =: 3 : 0
log 'vizform_clearSearches_button'
clearSearches ''
invalidateDisplay ''
)

vizform_logcheck_button =: 3 : 0
LogFlag =: ". logcheck
smoutput LogFlag
)

vizform_vocContext_mmove =: 3 : 0
NB. Give the user the chance to get the mouse over to the webview without activating another link.
if. 1 > ((6!:1) '') - SuppressMouseHandlingStart do. return. end.
log 'vizform_vocContext_mmove'
if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do. return. end.
VocMouseXY =: 0 1 { ". > 1 { 13 { wdq
deemphasizeBrowser ''
invalidateDisplay ''
)

vizform_vocContext_mblup =: 3 : 0
log 'vizform_vocContext_mblup'
VocMouseClickXY =: 0 1 { ". > 1 { 13 { wdq
invalidateDisplay ''
)

vizform_vocContext_paint =: 3 : 0
trigger_paint ''
)

vizform_browser_curl =: 3 : 0
log 'vizform_browser_curl'
url =. > (1 {"1 wdq) {~ ({."1 wdq) i. < 'browser_curl'
topHistoryUrl =. > 0 { 0 { getHistoryMenu ''
if. -. +./ topHistoryUrl E. url do. addToHistoryMenu url ; url end.
resetBookmarkButton ''
)

vizform_mmove =: 3 : 0
deemphasizeBrowser ''
)

vizform_searchBox_button =: 3 : 0
log 'vizform_searchBox_button'
try.
	search searchBox
	wd 'set searchBox text ""'
	invalidateDisplay ''
catch.
	log (13!:12) ''
	log dbError ''
end.
)

vizform_history_select =: 3 : 0
log 'vizform_history_select'
loadPage (". history_select) { getHistoryMenu ''
)

vizform_launch_button =: 3 : 0
log 'vizform_launch_button ' , ": > 0 { 0 { getHistoryMenu ''
if. IFUNIX do. (2!:1) 'open -a Safari "' , (> 0 { 0 { getHistoryMenu '') , '"' end.
)

PerpetuateAnimationStartTime =: 0

sys_timer_z_ =: 3 : 0
log_jwikiviz_ 'sys_timer_z_'
try.
NB. 	checkQueuedUrlTime_base_ ''
	if. 4 > ((6!:1) '') - PerpetuateAnimationStartTime_jwikiviz_ do. invalidateDisplay_jwikiviz_ '' end.
catch.
	smoutput (13!:12) ''
	smoutput dbError ''
end.
)

perpetuateAnimation =: 3 : 0
PerpetuateAnimationStartTime =: (6!:1) ''
)

wd 'timer 0'

DisplayListRectTargetWidth =: 175
DisplayListRectSourceWidth =: 20
DisplayListRectAnimationStartTime =: 0

setDisplayRects =: 3 : 0
'w h' =. ". wd 'get vocContext wh'
DisplayListRect =: 0 0 175 , h
DisplayDetailRect =: 175 0 , (w - 175) , h
)

trigger_paint =: 3 : 0
log 'trigger_paint ' , (wd 'getp wh') , '   ' , (": getFrameRate '') , ' fps'
try.
glfill BackgroundColor , 255
'w h' =. ". wd 'getp wh'
if. (w < 200) +. h < 200 do.
	log 'trigger_paint--dimensions too small.  Aborting.'
	return.
end.
setDisplayRects ''
drawToc ''
drawPageLoadFreezeRect ''
VocMouseClickXY =: 0 0
glclip 0 0 10000 10000
catcht. catch. 
log (13!:12) ''
log dbError ''
smoutput (13!:12) ''
smoutput dbError ''
end.
)

invalidateDisplay =: 3 : 0
wd 'set vocContext invalid'
)
NB. ======================================================

NB. =================== Search ===========================
deleteCategoryIdAndDescendants =: 3 : 0
NB. y A category id whose descendants are to be deleted.
log 'deleteCategoryIdAndDescendants ' , ": y
if. y < 0 do. return. end.
childIds =. > {: sqlreadm__db 'select categoryid from categories where parentid = ' , ": y
deleteCategoryIdAndDescendants &. > childIds
sqlcmd__db 'delete from categories where categoryid = ' , ": y
sqlcmd__db 'delete from wiki where categoryid = ' , ": y
)

deleteCategoryIdDescendantsOnly =: 3 : 0
log 'deleteCategoryIdDescendantsOnly ' , ": y
if. y < 0 do. return. end.
childIds =. , > > {: sqlreadm__db 'select categoryid from categories where parentid = ' , ": y
deleteCategoryIdAndDescendants &. > childIds
)

clearSearches =: 3 : 0
NB. y A search string
NB. Remove the search records from the TOC.
log 'clearSearches'
terms1 =. > {: sqlreadm__db 'select category from categories where parentid = ' , ": getTopCategoryId SearchCatString
if. 0 < # terms1 do. clearSearch &. > terms1 end.
terms2 =. > {: sqlreadm__db 'select category from categories where parentid = ' , ": SearchHiddenCatId getCategoryId SearchCatString
if. 0 < # terms2 do. clearSearch &. > terms2 end.
clearCache ''
)

clearSearch =: 3 : 0
NB. y A search term
log 'clearSearch ' , y
termId =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '" AND parentid = ' , ": SearchHiddenCatId getCategoryId SearchCatString
deleteCategoryIdAndDescendants (SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y
deleteCategoryIdAndDescendants (getTopCategoryId SearchCatString) getCategoryId y
clearCache ''
)

addSearchToToc =: 3 : 0
NB. y A search string
NB. Save parent ; child.  
log 'addSearchToToc ' , ": y
term =.  y
clearSearch term
cols =. ;: 'level parentid categoryid category count parentseq link'
NB. sqlinsert__db 'categories' ; cols ; < 2 ; (getTopCategoryId SearchCatString) ; (nextUserCatId 1) ; (< term) ; _1 ; 0 ; 'https://www.jsoftware.com'
sqlinsert__db 'categories' ; cols ; < 1 ; (termParentId =. SearchHiddenCatId getCategoryId SearchCatString) ; (nextUserCatId 1) ; (< term) ; 0 ; 0 ; 'https://www.jsoftware.com'
sqlinsert__db 'categories' ; cols ; < 2 ; (termParentId getCategoryId term) ; (nextUserCatId 1) ; (< 'Wiki') ; _1 ; 0 ; 'https://code.jsoftware.com/wiki/Special:JwikiSearch'
NB. sqlinsert__db 'categories' ; cols ; < 2 ; (termParentId getCategoryId term) ; (< 'Forums') ; 0 ; 1 ; 'https://www.jsoftware.com/forumsearch.htm'
)

searchWiki =: 3 : 0
NB. y Search term
NB. Perform the search, parse the results, and update the "categories" and "wiki" tables.
NB. Return the number of hits.
NB. fname =. (jpath '~temp/S' , ": ? 100000) , '.txt'
NB.  ('-o ' , fname) gethttp 'https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=70&offset=0&profile=default&search=' , (urlencode y)
NB. smoutput (1!:1) < fname
log 'Searching wiki for ' , y , '...'
url =. 'https://code.jsoftware.com/mediawiki/index.php?title=Special:Search&limit=5000&offset=0&profile=default&search=' , urlencode y
html =. gethttp url
pat =. rxcomp 'mw-search-result-heading''><a href="([^"]+)" title="([^"]+)"'
offsetLengths =.  pat rxmatches html
wikiId =. ((SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Wiki'
log '...received ' , (": # html) , ' bytes with ' , (": # offsetLengths) , ' hits.'
if. 0 = # offsetLengths do.
	sqlupdate__db 'categories' ; ('categoryid = ' , ": wikiId) ; ('count' ; 'level') ; < 0 ; 2
else.
	ol =. 1 2 {"2 offsetLengths
	linkOffsets =. 0 {"(1) 0 {"2 ol
	titleOffsets =. 0 {"(1) 1 {"2 ol
	linkLengths =. 1 {"(1) 0 {"2 ol
	titleLengths =. 1 {"(1) 1 {"2 ol
	links =. 'https://code.jsoftware.com'&, &. > linkLengths <@{."0 1 linkOffsets }."0 1 html
	titles =. titleLengths <@{."0 1 titleOffsets }."0 1 html
	wikiCols =. ;: 'title categoryid link'
	data =. titles ; (wikiId #~ # titles) ; < links
	sqlinsert__db 'wiki';wikiCols;<data
	sqlupdate__db 'categories' ; ('categoryid = ' , ": wikiId) ; ('count' ; 'level') ; < (# titles) ; 3
end.
# offsetLengths
)

searchForums =: 3 : 0
NB. y Search term		
NB. Perform the search, parse the results, and update the "categories" and "wiki" tables.
try.
log 'Searching forums for ' , y , '...'
wikiCols =. ;: 'title categoryid link'
NB. html =. (2!:0) 'curl "https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2030"'
url =.'https://www.jsoftware.com/cgi-bin/forumsearch.cgi?all=' , (urlencode y) , '&exa=&one=&exc=&add=&sub=&fid=&tim=0&rng=0&dbgn=1&mbgn=1&ybgn=1998&dend=31&mend=12&yend=2100&blk=5000'
html =. gethttp url
pat =. rxcomp '(http://www.jsoftware.com/pipermail[^"]+)">\[([^\]]+)\] ([^<]+)</a>'
offsetLengths =. pat rxmatches html
termId =. (SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y
NB. forumsId =. ((SearchHiddenCatId getCategoryId SearchCatString) getCategoryId y) getCategoryId 'Forums'
log '...received ' , (": # html) , ' bytes with ' , (": # offsetLengths) , ' hits.'
if. 0 < # offsetLengths do.
	ol =. 1 2 3 {"2 offsetLengths
	linkOffsets =. 0 {"(1) 0 {"2 ol
	forumOffsets =. 0 {"(1) 1 {"2 ol
	titleOffsets =. 0 {"(1) 2 {"2 ol
	linkLengths =. 1 {"(1) 0 {"2 ol
	forumLengths =. 1 {"(1) 1 {"2 ol
	titleLengths =. 1 {"(1) 2 {"2 ol
	links =. linkLengths <@{."0 1 linkOffsets }."0 1 html
	links =. ('http://' ; 'https://')&rxrplc &. > links
	forums =. forumLengths <@{."0 1 forumOffsets }."0 1 html
	titles =. titleLengths <@{."0 1 titleOffsets }."0 1 html
	titleGroups =. forums </. titles
	linkGroups =. forums </. links
	for_index. i. # titleGroups do.
		fname =. > index { ~. forums
		forumLinks =. > index { linkGroups
		forumTitles =. > index { titleGroups
		cols =. (;: 'level parentid categoryid category parentseq count link')
		data =. 3 ; termId ; (nextUserCatId 1) ; fname ; (>: index) ; (# forumLinks) ; 'https://www.jsoftware.com/mailman/listinfo/' , }. fname
		sqlinsert__db 'categories' ; cols ; < data
		forumId =. termId getCategoryId fname
		data =. forumTitles ; (forumId #~ # forumLinks) ; < forumLinks
		sqlinsert__db 'wiki';wikiCols;<data
	end.
end.
count =. {. , > > {: sqlreadm__db 'select sum(count) from categories where parentid = ' , ": termId
otherTermId =. (getTopCategoryId SearchCatString) getCategoryId y
parms =. 'categories' ; ('categoryid = ' , ": otherTermId) ; (;: 'count level') ; < count ; 2
sqlupdate__db parms
catcht.
	log (13!:12) ''
	log 'Db Error (if any): ' , dbError ''
end.
)

search =: 3 : 0
NB. y A search term.
log 'search ' , y
try.
	log 'Searching for ' , y
	addSearchToToc y
	clearCache ''
	selectSearch ''
	invalidateDisplay ''
	wd 'msgs'
	searchWiki y
	searchForums y
	clearCache ''
	invalidateDisplay ''
catcht.
	log (13!:12) ''
	log 'Db Error (if any): ' , dbError ''
end.
)

selectSearch=: 3 : 0
log 'selectSearch'
NB. Select '*Search' in the Table of Contents (TOC).
index =. (< SearchCatString) i.~ 3 {"(1) 1 getTocOutlineRailEntries MaxTocDepth NB. Table of level ; parentid ; categoryid ; category ; parentseq ; count ; link
setTocOutlineRailSelectedIndex index
)

NB. ================== Drawing ====================
VocMinWidth =: 800
VocMinHeight =: 900
MaxCellWidth =: 100
MinColWidth =: 200
CellMargin =: 5
CellLineHeight =: 25
DocumentLineHeight =: 26
DocumentFont =: 'arial bold 18'
SectionFont =: 'arial bold 16'
DBG =: 1

BackgroundColor =: 255 255 255
SectionColor =: 0 0 0
LabelColor =: 0 102 204
ColumnGuideColor =: 245 253 198
SelectionColor =: 0 0 0
HoverColor =: 255 0 0 
BarColor =: 245 195 150

NB. BackgroundColor =: 148 210 189
NB. SectionColor =: 155 34 38
NB. LabelColor =: 0 18 25
NB. ColumnGuideColor =: 10 147 150
NB. SelectionColor =: 0 95 115
NB. BarColor =: 233 216 166

NB. BackgroundColor =: 255 255 255
NB. SectionColor =: 238 170 170
NB. LabelColor =: 0 0 0
NB. ColumnGuideColor =: 204 238 255
NB. SelectionColor =: 0 0 0
NB. BarColor =: 238 170 170

PageFreezeColor =: 0 18 25
VocSelectedGlyph =: ''
DocumentSelectedIsletIndex =: _1
DocumentSectionGeometry =: '' NB. index x y width height label sectionName columnId url
DocumentSectionSelectedIndex =: _1
VocTable =: '' NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
POSColors =: 221 204 255 , 204 238 255 , 238 255 204 , 255 204 238 , 221 221 221 ,: 238 170 170
POSNames =: ;: 'Verb Adverb Conjunction Noun Copula Control'
VocCellFont =: 'consolas 16 bold'
VocValenceFont =: 'arial 14'
CategoryIndex =: 0
CategoryTable =: ''
HighlightUrls =: '' NB. Holds the labels ; URLs to be used for highlighting the map. 
TocFont =: 'arial 13'
NB. TocBoldFont =: 'arial bold 14'
TocLineHeight =: 21
TocScrollIndex =: 0
MaxTocDepth =: 3
DisplayListRect =: 10 10 100 100
DisplayDetailRect =: 100 10 100 100
Months =: ;:'January February March April May June July August September October November December'
ShortMonths =: ;: 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'
ForumsCatString =: '*Forums'
BookmarkCatString =: '*Bookmarks'
SearchCatString =: '*Search'
SearchHiddenCatId =: 200000
TagCatString =: '*Tags'
TagHiddenCatId =: 500000
QueuedUrl =: ''
QueuedUrlTime =: 0
SuppressMouseHandlingStart =: 0
PageLoadFreezeTime =: 0
PageLoadFreezeRect =: ''
PageLoadFreezeDuration =: 3
MWheelOffset =: 0
EmphasizeBrowserFlag =: 0
LogFlag =: 0
ScrollConfig =: 2
UploadAcct =: '12a1yBS'

getTocFontForLevel =: 3 : 0
NB. y An integer level in an outline hierarchy.  _1 indicates a page; 0..n indicates a level.
NB. Return the string specification of the font to use.
if. y < 0 do. 'arial 13' return. end.
fonts =. 'arial bold 15' ; 'arial bold 13' ; 'arial 13'
> (y <. <: # fonts) { fonts
)

getTocColorForLevel =: 3 : 0
NB. y An integer level in an outline hierarchy.  _1 indicates a page; 9..n indicates a level.
NB. Return a color for the text.
if. 0 > y do. LabelColor else. SectionColor end.
)

getPosColor =: 3 : 0
NB. y The boxed name of a pos
NB. Return the corresponding color.
POSColors {~ POSNames i. y
)

drawStringAt =: 4 : 0
NB. x originX originY
NB. y A string
gltextxy x
gltext y
)

drawHighlight =: 4 : 0 
NB. x xx yy w h
NB. y color (r g b) but no (a)
NB. glrgb y
color =. y , 255 NB. <. 255 * | 1 o. 2 * {: (6!:0) ''
glrgba color
glpen 2
glrgba 0 0 0 0
glbrush ''
glrect x
)

pointInRect =: 4 : 0
NB. x A point
NB. y A rect (x y w h)
'px py' =. x
'rx ry rw rh' =. y
(rx < px) *. (px < rx + rw) *. (py > ry) *. (py < ry + rh)
)

isBookmarked =: 3 : 0
NB. y A url
NB. Return 1 if y is bookmarked
links =. , > {: sqlreadm__db 'select link from wiki where categoryId = ' , ": getTopCategoryId BookmarkCatString
(# links) > links i. < y
)

resetBookmarkButton =: 3 : 0
log 'resetBookmarkButton'
'url title' =. {. getHistoryMenu ''
links =. , > {: sqlreadm__db 'select link from wiki where categoryId = ' , ": getTopCategoryId BookmarkCatString
if. isBookmarked url do. wd 'set bookmark text "Un-bookmark";' else. wd 'set bookmark text "Bookmark";' end.
)

bookmark =: 3 : 0
log 'bookmark'
'url title' =. {. getHistoryMenu ''
id =. (getTopCategoryId BookmarkCatString)
if. isBookmarked url do.
	sqlcmd__db 'delete from wiki where categoryid = ' , (": id) , ' and link = "' , url , '"'
else.
	sqlinsert__db 'wiki' ; (;: 'title categoryid link') ; < title ; id ; url
end.
clearCache ''
invalidateDisplay ''
resetBookmarkButton ''
)

queueUrl =: 3 : 0
NB. y A url to queue for delayed loading ; A title
log 'queueUrl ' , (0 {:: y) , ' ' , 1 {:: y
NB. if. PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime do. return. end.
QueuedUrl =: y
QueuedUrlTime =: (6!:1) ''
loadPage QueuedUrl
)

addToHistoryMenu =: 3 : 0
NB. y Label ; Link
log 'addToHistoryMenu ' , (0 {:: y) , ' ' , 1 {:: y
if. y -: '' do. return. end.
loadHistoryMenu ''
if. HistoryMenu -: '' do. HistoryMenu =: ,: y else. HistoryMenu =: ~. y , HistoryMenu end.
s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
wd 'set history items *' , s
wd 'set history select 0'
HistoryMenu =: (30 <. # HistoryMenu) {. HistoryMenu
sqlcmd__db 'delete from history'
sqlinsert__db 'history' ; (;: 'label link') ; < ({:"1 HistoryMenu) ; < {."1 HistoryMenu
)

loadHistoryMenu =: 3 : 0
log 'loadHistoryMenu'
HistoryMenu =: > {: sqlreadm__db 'select link, label from history'
s =. }: ; ,&'" ' &. > '"'&, &. > ('^ *';'')&rxrplc &. > 1 {"1 HistoryMenu
wd 'set history items *' , s
wd 'set history select 0'
)

getHistoryMenu =: 3 : 0
if. HistoryMenu -: '' do. loadHistoryMenu '' end.
HistoryMenu
)

HistoryMenu =: '' NB. Table of Title ; Link
LastUrlLoaded =: ''

loadPage =: 3 : 0
NB. y A url, possibly unqualified ; A title
try.
if. 0 = # y do. return. end.
url =. > {. y
if. url -: '' do. return. end.
url =. ('User_' ; 'User:') rxrplc url
if. 'Category:' -: 9 {. url do.
	url =. 'https://code.jsoftware.com/wiki/' , url
elseif. -. 'http' -: 4 {. url do.
	url =. ('.html' ; '') rxrplc 'https://code.jsoftware.com/' , url
end.
if. url -: LastUrlLoaded do. return. end.
LastUrlLoaded =: url
log 'Loading url ' , url
wd 'set browser url *' , url
addToHistoryMenu (< url) , {: y
catch.
	smoutput (13!:12) ''
end.
)

NB. ======================== Mouse-Sensitive Areas ===========================
isFrozen =: 3 : 0
PageLoadFreezeDuration > ((6!:1) '') - PageLoadFreezeTime
)

registerRectLink =: 4 : 0
NB. x xx yy width height
NB. y A url or * to be evaluated ; a title ; loadMode (0 indicates hover, 1 indicates click)
NB. Record this for mouse processing: highlighting and loading urls.
NB. Note that since we're frame-based, we re-register rect/links on every frame.  So we 
NB. just check immediately to see whether the mouse is inside the rect and activate accordingly.
'urlCommand name loadMode' =. y
if. isFrozen '' do. 0 return. end.
if. -. VocMouseXY pointInRect x do. 0 return. end.
x drawReversibleSelection HoverColor
if. loadMode = 0 do.
	if. '*' = {. urlCommand do.
		". }. urlCommand
NB.		invalidateDisplay ''
	else. 
		queueUrl urlCommand ; name
	end.
elseif. VocMouseClickXY pointInRect x do.
	emphasizeBrowser ''
	if. '*' = {. urlCommand do.
		". }. urlCommand
NB.		invalidateDisplay ''
	else. 
		queueUrl urlCommand ; name
	end.
end.
if. VocMouseClickXY pointInRect x do.
	PageLoadFreezeTime =: (6!:1) ''
	SuppressMouseHandlingStart =: PageLoadFreezeTime
	PageLoadFreezeRect =: x
	emphasizeBrowser ''
end.
0
)

drawReversibleSelection =: 4 : 0
NB. x xx yy width height
NB. y color
NB. Draw an outline around xx yy width height.  Remember it so it can be erased later.
x drawHighlight y
NB. if. ReversibleSelections -: '' do. ReversibleSelections =: ,: x else. ReversibleSelections =: ReversibleSelections , x end.
)

drawPageLoadFreezeRect =: 3 : 0
if. isFrozen '' do.
	glrgb PageFreezeColor
	glpen 5
	glrgba 0 0 0 0
	glbrush ''
	glrect PageLoadFreezeRect
end.
)
NB. ============================== Scroller Field ===============================
drawScrollerField =: 4 : 0
NB. x xx yy width height
NB. y strings ; links ; ratios ; levels ; selectedIndex ; scrollIndex ; loadMode
NB. The "levels" indicate indention (0...n).  A level of _1 indicates that it's a page link, not a heading.
NB. Draw the strings and registerRectLink to highlight them and load pages.
NB. Use VocMouseXY to update scrollOffset and selectedIndex.
NB. Return the scrollIndex, which may have changed.
NB. Scroll/Select Configurations
NB.    (1) Simultaneous scroll/select, full width.
NB.    (2) Left mouse scroll, right select.
NB.    (3) Left mouse scroll, right numb.
NB.    (4) Two-finger scroll, mouse select, full width.
log 'drawScrollerField ' , (": x)
rect =. x
'strings links ratios levels selectedIndex scrollIndex loadMode' =. y
'xx yy w h' =. rect
window =. <. TocLineHeight %~ -: h
maxLineCount =. <. h % TocLineHeight
margin =. 5
NB. glfont TocFont
if. VocMouseXY pointInRect xx , yy , (-: w) , h do.
	scrollIndex =. 0 >. (window -~ # strings) <. <. (-: window) -~ (# strings) * (yy -~ {: VocMouseXY) % h
end.	
windowStartIndex =. scrollIndex NB. <. 0 >. (# strings) <. 0 >. scrollIndex - -: window
squishedLineHeight =. TocLineHeight <. (window -~ # strings) %~ h - window * TocLineHeight
heights =. (# strings) {. (windowStartIndex # squishedLineHeight) , (window # TocLineHeight) , 1000 # squishedLineHeight
ys =. <. }: +/\ 0 , heights
heights =. <. heights
origins =. <. (margin + xx) ,. margin + yy + ys
glrgb LabelColor
gltextcolor ''
glpen 1
glrgb BackgroundColor
glbrush ''
glrect rect
if. (ScrollConfig = 1) +. ScrollConfig = 2 do.
	glrgb ColumnGuideColor
	glbrush ''
	glpen 0
	glrect xx , yy , (<. -: w) , h
end.
scrollBarHeight =. <. h * window % # strings
scrollBarOffset =. <. h * scrollIndex % # strings
if. maxLineCount < # strings do.
	glrgb 3 # 200
	glbrush ''
	glpen 0
	glrect (xx + w - thickness) , scrollBarOffset , (thickness =. 10) , scrollBarHeight
end.
for_i. i. # strings do.
	lineHeight =. i { heights
	origin =. > i { origins
	glrgb BarColor
	glbrush ''
	glpen 0
	if. 0 < i { ratios do. glrect (origin - margin , 0) , (<. (w - margin) * i { ratios) , lineHeight - 4 end.
	glfont getTocFontForLevel i { levels
	glrgb getTocColorForLevel i { levels
	glbrush ''
	gltextcolor''
	glclip xx , yy ,  w , h
	if. lineHeight >: TocLineHeight do. (> i { origins) drawStringAt > i { strings end.
	if. i = selectedIndex do. ((origin - margin , 0) , w , lineHeight) drawHighlight SelectionColor end.
	if. VocMouseXY pointInRect xx , yy , (-: w) , h do. ((origin - margin , 0), w, lineHeight) registerRectLink (> i { links) ; (> i { strings) ; loadMode end.		
end.
glclip 0 0 10000 100000
scrollIndex
)
NB. ======================= Draw the TOC =========================
drawTocEntryChild =: 4 : 0
NB. x xx yy maxWidth height
NB. y Highlight Flag ; Name ; Link/Command ; Level
'xx yy maxWidth height' =. x
'highlightFlag name command level' =. y
glrgb getTocColorForLevel level
gltextcolor ''
glfont getTocFontForLevel level
(xx , yy) drawStringAt name
adjRect =. xx , yy , (maxWidth - 16) , height
if. highlightFlag do. adjRect drawHighlight SelectionColor end.
adjRect registerRectLink command ; name ; 0
)

drawTocEntryChildrenColumn =: 4 : 0
NB. x xx yy width height
NB. y Table of Name ; Link/Command ; Level
NB. Render the column in black, with headings in SectionColor
'xx yy width height' =. x
glclip xx , yy , (width - 10) , height
margin =. 5
rect =. (margin + xx) ,. (margin + yy + TocLineHeight * i. # y) ,"0 1 width , TocLineHeight
rect drawTocEntryChild"1 1 y
glclip 0 0 10000 10000
rect
)

setTocEntryForumMonthIndex =: 3 : 0
NB. y The month whose posts we'll display
TocEntryForumMonthIndex =: y
setTocEntryForumSubjectIndex 0
ForumSubjectScrollIndex =: 0
)

TocEntryForumYear =: 2023

setTocEntryForumYear =: 3 : 0
NB. y The year whose posts we'll display
TocEntryForumYear =: y
setTocEntryForumSubjectIndex 0
ForumSubjectScrollIndex =: 0
TocEntryForumMonthIndex =: 0
)

TocEntryForumSubjectIndex =: 0

setTocEntryForumSubjectIndex =: 3 : 0
NB. y The index of the subject that's currently highlighted
TocEntryForumSubjectIndex =: y
ForumAuthorScrollIndex =: 0
setTocEntryForumAuthorIndex 0
)

TocEntryForumAuthorIndex =: 0

setTocEntryForumAuthorIndex =: 3 : 0
NB. Ty he index of the author who's currently highlighted.
TocEntryForumAuthorIndex =: y
'year month subject author link' =. TocEntryForumAuthorIndex { ForumAuthorEntries
queueUrl ('https://www.jsoftware.com/pipermail/' , (}. ForumName) , '/' , (": year) , '-' , (> month { Months) , '/' , link , '.html') ; subject -. LF
)

ForumCacheTable =: '' NB. Year ; Month ; Subject ; Author ; Link
ForumCurrentName =: ''
ForumSubjectScrollIndex =: 0
ForumAuthorScrollIndex =: 0
ForumAuthorEntries =: ''  NB. Year ; Month ; Subject ; Author ; Link
ForumName =: ''
ForumYearBumpCount =: 0
ForumMonthBumpCount =: 0

drawTocEntryForum =: 4 : 0
NB. x The name of the forum
NB. y xx yy width height
NB. Display the contents of the forum
NB. x y width height drawScrollerField strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
log 'drawTocEntryForum ' , x
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
ForumName =: x
'xx yy width height' =. y
if. -. ForumCurrentName -: x do. 
	result =. > {: sqlreadm__db 'select year, month, subject, author, link from forums where forumname = "' , x , '" order by year desc, month desc'
	ForumCacheTable =: 0 1 2 3 4 {"1 result
	ForumCurrentName =: x
	TocEntryForumYear =: 2023
	TocEntryForumSubjectIndex =: 0
	TocEntryForumMonthIndex =: 0
	ForumAuthorEntries =: ''
end.
margin =. 5
glclip 0 0 10000 100000
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
colWidth =. <. -: width - +: margin
colHeight =. height
subjRect =. (xx + margin + 100) , yy , colWidth, colHeight
authRect =. subjRect + (colWidth + margin) , 0 0 0
years =. \:~ ~. > {."1 ForumCacheTable
if. 0 = # years do. return. end.
months =. > ~. 1 {"1 ForumCacheTable #~ TocEntryForumYear = yyyy =. > {."1 ForumCacheTable
TocEntryForumMonthIndex =: TocEntryForumMonthIndex <. <: # months
timeLineHeight =. 20
month =. TocEntryForumMonthIndex { months
if. (xx > {. VocMouseXY) +. ({. VocMouseXY) > {. subjRect do. 
	ForumYearBumpCount =: 0 >. <: <. (({: VocMouseXY) - yy) % timeLineHeight
	ForumMonthBumpCount =: ForumYearBumpCount
end.
if. (xx < {. VocMouseXY) *. ({. VocMouseXY) < xx + 40 do. ForumMonthBumpCount =: 0 >. <: <. (({: VocMouseXY) - yy) % timeLineHeight end.
yearBumpArray =. (ForumYearBumpCount # 0) , 30 # 3 * timeLineHeight
monthBumpArray =. (ForumMonthBumpCount # 0) , 12 # 3 * timeLineHeight
yearOrigins =. (xx + margin) ,. ((# years) {. yearBumpArray) + yy + margin + timeLineHeight * i. # years
yearStrings =: '`',. _2 {."1 ": ,.years
glrgb SectionColor
gltextcolor ''
glfont SectionFont
yearOrigins drawStringAt"1 1 > ": &. > <"0 yearStrings
monthStrings =. months { ShortMonths
monthOrigins =. (# months) {. <"1 (xx + margin + 45) ,. (12 {. monthBumpArray) + yy + margin + timeLineHeight * i. 12
monthOrigins drawStringAt &. > monthStrings
rects1 =. (<"1 yearRects =. (yearOrigins -"(1 1) _2 2) ,"(1 1) 30 , TocLineHeight) 
yearCommands =: '*setTocEntryForumYear '&, &. > ": &. > <"0 years
rects1 registerRectLink &. > <"1 yearCommands ,"0 1 ' ' ; 0
rects2 =. (<"1 monthRects =. (_2 + > monthOrigins) ,"(1 1) 40 , TocLineHeight) 
monthCommands =. '*setTocEntryForumMonthIndex '&, &. > ": &. > <"0 i. # months
rects2 registerRectLink &. > <"1 monthCommands ,"0 1 ' ' ; 0
((years i. TocEntryForumYear) { yearRects) drawHighlight SelectionColor
TocEntryForumMonthIndex =. TocEntryForumMonthIndex <. <: # months
(TocEntryForumMonthIndex { monthRects) drawHighlight SelectionColor
entries =. ForumCacheTable #~ (TocEntryForumYear = > {."1 ForumCacheTable) *. month = > 1 {"1 ForumCacheTable NB. entries: year ; month ; subject ; author ; link
if. 0 = # entries do. return. end.
subjects =: ~. 2 {"1 entries
ratios =. authorCounts % >./ authorCounts =. allSubjects #/. allSubjects =. 2 {"1 ForumCacheTable #~ (2 {"1 ForumCacheTable) e. subjects
NB. ratios =. authorCounts % >./ authorCounts =. > # &. > (2 {"1 entries) </. entries
subjects =. ~. allSubjects
subject =. TocEntryForumSubjectIndex { subjects 
ForumAuthorEntries =: e /: 4 {"1 e =. ForumCacheTable #~ (2 {"1 ForumCacheTable) = subject  NB. Check all posts since conversations may span months.
NB. smoutput '$ ForumAuthorEntries ; subject ; TocEntryForumAuthorIndex' ; ($ ForumAuthorEntries) ; subject ; TocEntryForumAuthorIndex
authors =. 3 {"1 ForumAuthorEntries
NB. links =.   4 {"1 ForumAuthorEntries
subjectCommands =. '*setTocEntryForumSubjectIndex '&, &. > ": &. > <"0 i. # subjects
NB. authorUrls =. ('https://www.jsoftware.com/pipermail/' , (}. x) , '/' , (": TocEntryForumYear) , '-' , (> month { Months) , '/')&, &. > links
authorCommands =. '*setTocEntryForumAuthorIndex '&, &. > ": &. > <"0 i. # authors
ForumSubjectScrollIndex =: subjRect drawScrollerField subjects ; subjectCommands ; ratios ; (2 #~ # subjects) ; TocEntryForumSubjectIndex ; ForumSubjectScrollIndex ; 0
ForumAuthorScrollIndex =: authRect drawScrollerField  authors ; authorCommands ; (0 #~ # authors) ; (_1 #~ # authors) ; TocEntryForumAuthorIndex ; ForumAuthorScrollIndex ; 0
if. TocEntryForumAuthorIndex = 0 do. setTocEntryForumAuthorIndex 0 end.
glclip 0 0 10000 100000
)

setTocEntryChildCategoryIndex =: 3 : 0
NB. y Index of the category whose children should be displayed.
TocEntryChildCategoryIndex =: y
queueUrl (> TocEntryChildCategoryIndex { 1 {"1 TocEntryChildCategoryEntries) ; > TocEntryChildCategoryIndex { 0 {"1 TocEntryChildCategoryEntries
)

TocEntryChildScrollIndex =: 0
TocEntryChildCategoryIndex =: 0 NB. The index of the currenty-selected child category in the tree.
TocEntryChildCategoryEntries =: '' NB. Table of Title ; Link

drawTocEntryChildrenWithTree =: 4 : 0
NB. x Category id
NB. y xx yy width height entryY
NB. Render the descendants of x (category id) in xx yy width height.
NB. This is used when the child count is too high.  It renders a tree in the first column (drawaScrollerField)
NB. and the children of each node in the subsequent columns.
NB. getTocOutlineRailEntries returns table of level ; parentid ; categoryid ; category ; parentseq ; count ; link
NB. x y width height drawScrollerField strings ; links ; ratios ; levels ; selectedIndex ; scrollIndex
log 'drawTocEntryChildrenWithTree ' , (": x) , ' ' , ": y
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
categoryId =. x
tocWikiDocs =. getTocWikiDocs categoryId NB. Table of (level parent category parentSeq count link) ; (table of title ; link)
if. 1 = # $ tocWikiDocs do. '' return. end.
ratios =. counts % maxCount =. >./ counts =. > # &. > 1 {"1 tocWikiDocs
margin =. 5
categoryEntries =. > {."1 tocWikiDocs  NB. categoryEntries: table of level parent categoryid category parentSeq count link
indents =. #&'  ' &. > <: &. > 0 {"1 categoryEntries
levels =. (] - <./) > {."1 categoryEntries
catTitles =. indents , &. > 3 {"1 categoryEntries
catLinks =. 6 {"1 categoryEntries
catHighlightFlags =. (-TocEntryChildCategoryIndex) |. 1 , 0 #~ <: # catTitles
cleanCategories =. ('''';'''''')&rxrplc &. > 1 {"1 catTitles
commandLinks =. ''''&, &. > ,&'''' &. > catLinks
commandCategories =. ,&'''' &. > ''''&, &. > cleanCategories
commands =. '*setTocEntryChildCategoryIndex '&, &. > <@":"0 i. # catLinks
categoryEntryList =. (<"0 catHighlightFlags) ,. catTitles ,. commands ,. <1 NB. Table of Highlight Flag ; Category ; Command ; Heading Flag
TocEntryChildCategoryIndex =: TocEntryChildCategoryIndex <. <: # catLinks
displayChildTable =. > TocEntryChildCategoryIndex { 1 {"1 tocWikiDocs  NB. Table of Title ; Link
TocEntryChildCategoryEntries =: catTitles ,. catLinks
entryList =. (< 0) ,. displayChildTable ,. <_1
rowCount =. <. height % TocLineHeight
columnGroups =. (< categoryEntryList) , (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - xx) % width) * # columnGroups
fullSizeColCount =. <. width % MinColWidth
colWidth =. <. width % fullSizeColCount
compressedColWidth =. <. (width - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =: <"1 <. (xx + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
if. fullSizeColCount < # columnRects do.
	glrgb ColumnGuideColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
headerColumn =. > {. columnGroups
parms =. (1 {"1 headerColumn) ; (2 {"1 headerColumn) ; ratios ; levels ; TocEntryChildCategoryIndex ; TocEntryChildScrollIndex ; 0
TocEntryChildScrollIndex =: (> {. columnRects) drawScrollerField parms
(}. columnRects) drawTocEntryChildrenColumn &. > }. columnGroups
''
)

TocEntryTagScrollIndex =: 0
TocEntryTagSubcatIndex =: 0

setTocEntryTagSubcatIndex =: 3 : 0
TocEntryTagSubcatIndex =: y
)

drawTocEntryTags =: 3 : 0
NB. y xx yy width height
NB. Render the immediate subcategories of *Tags in a scrollerField.  
NB. Render the sub-subcategories of the selected subcategory to the right with their pages.
NB. x y width height drawScrollerField strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
log 'drawTocEntryTags ' , ": y
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
margin =. 5
subcatEntries =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link, categoryid from categories where parentid = ' , ": TagHiddenCatId getCategoryId TagCatString
subcats =. 3 {"1 subcatEntries
subcatColWidth =. <. width % 3
detailX =. xx + subcatColWidth + margin
detailWidth =. width - subcatColWidth + margin
commandLinks =. '*setTocEntryTagSubcatIndex '&, &. > ": &. > <"0 i. # subcats
scrollEntries =. subcats ; commandLinks ; (0 #~ # subcats) ; (2 #~ # subcats) ; TocEntryTagSubcatIndex ; TocEntryTagScrollIndex ; 0
TocEntryTagScrollIndex =: ((xx + margin) , (yy + margin) , subcatColWidth , height - +: margin) drawScrollerField scrollEntries
parentId =. > 7 { TocEntryTagSubcatIndex { subcatEntries
tocWikiDocs =. getTocWikiDocs parentId  NB. (level parentid categoryid category parentSeq count link) ; table of title ; link
if. 0 = # tocWikiDocs do. '' return. end.
categoryEntries =. > {."1 tocWikiDocs
catLinkFlag =. (3 6 {"1 categoryEntries) ,. <1 NB. Category ; Link ; Heading Flag
documentTables =. {:"1 tocWikiDocs
titleLinkLevel =. ,.&(<_1) &. > documentTables NB. Title ; Link ; Level
entryList =. (<0) ,. ; (<"1 catLinkFlag) , &. > titleLinkLevel
rowCount =. <. height % TocLineHeight
columnGroups =. (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - detailX) % detailWidth) * # columnGroups
fullSizeColCount =. <. (width - subcatColWidth) % MinColWidth
colWidth =. <. detailWidth % fullSizeColCount
compressedColWidth =. <. (detailWidth - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =. <"1 <. (detailX + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
if. fullSizeColCount < # columnRects do.
	glrgb ColumnGuideColor
	glbrush ''
	glpen 0
	w =. <. detailWidth % # columnRects
	glrect <. (detailX + selectedColumnIndex * w) , yy , w , height
end.
columnRects drawTocEntryChildrenColumn &. > columnGroups
)

drawTocEntryChildren =: 4 : 0
NB. x Category id
NB. y xx yy width height
NB. Render the descendants of the TocOutlineRailSelectedIndex category in xx yy width height.
NB. Use multiple columns if necessary.  If there are too many columns, invoke drawTocEntryChildrenWithTree.
NB. getTocOutlineRailEntries returns table of level ; parentid ; categoryid ; category ; parentseq ; count ; link
log 'drawTocEntryChildren ' , (": x) , ' ' , ": y
'xx yy width height' =. y
if. VocMouseXY pointInRect y do. glcursor IDC_ARROW end.
margin =. 5
glrgb 0 0 0
glpen 1
glrgb BackgroundColor
glbrush ''
glrect xx , yy , width , height
tocWikiDocs =. getTocWikiDocs x NB. Table of (level parentid categoryid category parentSeq count link) ; table of title ; link
if. 0 = # tocWikiDocs do. '' return. end.
categoryEntries =. > {."1 tocWikiDocs
catLinkFlag =. (3 6 {"1 categoryEntries) ,. <1 NB. Category ; Link ; Heading Flag
documentTables =. {:"1 tocWikiDocs
titleLinkLevel =. ,.&(<_1) &. > documentTables NB. Title ; Link ; Level
entryList =. (<0) ,. ; (<"1 catLinkFlag) , &. > titleLinkLevel
rowCount =. <. height % TocLineHeight
columnGroups =. (-rowCount) <\ entryList
selectedColumnIndex =. 0 >. (<: # columnGroups) <. <. ((({. VocMouseXY) - xx) % width) * # columnGroups
fullSizeColCount =. <. width % MinColWidth
colWidth =. <. width % fullSizeColCount
compressedColWidth =. <. (width - colWidth) % <: # columnGroups
columnWidths =. (-selectedColumnIndex) |. colWidth <. colWidth , (<: # columnGroups) # compressedColWidth
columnRects =. <"1 <. (xx + }: +/\ 0 , columnWidths) ,. yy ,. columnWidths ,. height
if. (1 < # categoryEntries) *. (# columnRects) > 2 * fullSizeColCount do. 
	x drawTocEntryChildrenWithTree xx , yy , width , height
	''
	return.
end.
if. fullSizeColCount < # columnRects do.
	glrgb ColumnGuideColor
	glbrush ''
	glpen 0
	w =. width % # columnRects
	glrect <. (xx + selectedColumnIndex * w) , yy , w , height
end.
columnRects drawTocEntryChildrenColumn &. > columnGroups
''
)

TocOutlineRailSelectedIndex =: 0
TocOutlineRailScrollIndex =: 0

setTocOutlineRailSelectedIndex =: 3 : 0
NB. y The new value of the index
TocOutlineRailSelectedIndex =: y
entry =. y { 1 getTocOutlineRailEntries MaxTocDepth  NB. level ; parentid ; categoryid ; category ; parentseq ; count ; link
queueUrl (> 6 { entry) ; > 3 { entry
)

drawTocRail =: 4 : 0
NB. x xx yy w h
NB. y A level of the Toc hierarchy to which to display
NB. (x y width height) drawScrollerField strings ; links ; ratios ; headingFlags ; selectedIndex ; scrollIndex
log 'drawTocRail ' , (": x) , ', ' , ": y
'xx yy width height' =. x
entries =. 1 getTocOutlineRailEntries y NB. Table of level ; parentId ; categoryid ; category ; parentseq ; count ; link
levels =. (] - <./) > 0 {"1 entries
maxCount =. >./ > 4 {"1 entries
indentStrings =. (#&'  ' &. > <: &. > 0 {"1 entries) , &. > 3 {"1 entries
linkCommands =. '*setTocOutlineRailSelectedIndex '&, &. > ": &. > <"0 i. # entries
parms =. indentStrings ; linkCommands ; (maxCount %~ > 5 {"1 entries) ; levels ; TocOutlineRailSelectedIndex ; TocOutlineRailScrollIndex ; 0
TocOutlineRailScrollIndex =: x drawScrollerField parms
if. EmphasizeBrowserFlag do. return. end.
entry =. TocOutlineRailSelectedIndex { entries
if.  +./ '*NuVoc' E. > 3 { entry do.
	drawVoc ''
elseif. (getTopCategoryId ForumsCatString) = > 1 { entry do. NB. level ; parent ; categoryid ; category ; parentseq ; count ; link
	(> 3 { entry) drawTocEntryForum DisplayDetailRect
elseif. TagCatString -: > 3 { entry do.
	drawTocEntryTags DisplayDetailRect
elseif. (< SearchCatString) = 3 { entry do.
	(SearchHiddenCatId getCategoryId SearchCatString) drawTocEntryChildrenWithTree DisplayDetailRect
else.
	categoryId =. (> 1 { entry) getCategoryId > 3 { entry
	categoryId drawTocEntryChildren DisplayDetailRect
end.
)

drawToc =: 3 : 0
log 'drawToc'
DisplayListRect drawTocRail MaxTocDepth
)

NB. ======================= Table of Contents Data Management =====================
TocOutlineRailEntriesCache =: ,: a: , a:
WikiDocsCache =: ,: a: , a:

TocWikiDocsCategory =: ''
TocWikiDocsEntries =: ''

visitedRailEntries =: '' NB. Boxed IDs.

recurseGetTocOutlineRailEntries =: 4 : 0
NB. x A parent id
NB. y A depth
NB. Terminate cycles.
if. y = 0 do. '' return. end.
if. (# visitedRailEntries) > visitedRailEntries i. (< x) do. '' return. end.  NB. Terminate cycles.
visitedRailEntries =: visitedRailEntries , < x
parentId =. x
entries =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link from categories where parentid = ' , (": parentId) , ' order by parentseq'
NB. childIds =. parentId&getCategoryId &. > 2 {"1 entries
childIds =. 2 {"1 entries
NB. entries =. ({."1 entries) ,. parents ,. 2 3 4 5 {"1 entries
; (<"0<"1 entries) , &. > recurseGetTocOutlineRailEntries&(<: y) &. > childIds
)

getTocOutlineRailEntries =: 4 : 0
NB. x A parent category id
NB. y Depth to which to go in the TOC hierarchy
NB. Return level ; parentid ; category ; parentseq ; count ; link
NB. Take account of the parentseq number when ordering the entries.
NB. Terminate cycles.
log 'getTocOutlineRailEntries ' , (": x) , ', ' , ": y
key =. < (": x) , 'DDD' , ": y
if. (# TocOutlineRailEntriesCache) > index =. (0 {"1 TocOutlineRailEntriesCache) i. key do.
	result =. > index { 1 {"1 TocOutlineRailEntriesCache
else.
	visitedRailEntries =: ''
	result =: > x recurseGetTocOutlineRailEntries y
NB. 	if. x = 0 do. result =. }. result end.
	if. 0 = # result do.
		result =. ''
	else.
NB. 		result =. (> tagCatId&~: &. > 1 {"1 rawResult) # rawResult  NB. Drop the child categories of *Tags.
		TocOutlineRailEntriesCache =: TocOutlineRailEntriesCache , key , < result
	end.
end.
result
)

getTocWikiDocs =: 3 : 0
NB. y A category id
NB. Return the subtree TOC from the categories table with a set of wiki documents for each entry.
NB. Return table of (level parentid categoryid category parentSeq count link) ; table of title ; link
log 'getTocWikiDocs ' , ": y
key =. < y
if. (# WikiDocsCache) > index =. (0 {"1 WikiDocsCache) i. key do.
	result =. > index { 1 {"1 WikiDocsCache
else.
	entries =. y getTocOutlineRailEntries 100
	if. 0 = # entries do.
		NB. The category is not a parent.
		entry =. > {: sqlreadm__db 'select level, parentid, categoryid, category, parentseq, count, link from categories where categoryid = ' , ": y
		wikiDocs =. > {: sqlreadm__db 'select title, link from wiki where categoryid = ' , ": y
		result =. (< entry) , < wikiDocs
	else.
		categories =. 3 {"1 entries
		parentIds =. 1 {"1 entries
		categoryIds =. parentIds getCategoryId &. > categories
		result =. (<"1 entries) ,. >@{: &. > sqlreadm__db &. > 'select title, link from wiki where categoryid = '&, &. > ": &. > categoryIds
	end.
	WikiDocsCache =: WikiDocsCache , key , < result
end.
result
)

clearCache =: 3 : 0
log 'clearCache'
TocOutlineRailEntriesCache =: ,: a: , a:
WikiDocsCache =: ,: a: , a:
)

NextUserCatId =: 0

nextUserCatId =: 3 : 0
NB. y Number of ids needed
log 'nextUserCatId ' , ": y
if. NextUserCatId = 0 do.
	result =. , > > {: sqlreadm__db 'select max(categoryid) from categories where categoryid >= 1000000' 
	if. 'NULL' -: result do. base =: 1000000 else. base =: >: {. result end.
else.
	base =: NextUserCatId
end.
ids =. base + i. y
NextUserCatId =: base + y
ids
)

getCategory =: 3 : 0
NB. y Category Id
NB. Return the category string, empty string if none.
log 'getCategory ' , ": y
result =. > {: sqlreadm__db 'select category from categories where categoryid = ' , ": y
if. 0 = # result do. '' else. > , > result end.
)

getCategoryIdNoParent =: 3 : 0
NB. y Category string
NB. Return the id or _1.
log 'getCategoryIdNoParent ' , y
result =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '"'
if. 0 = # result do. _1 else. > , > result end.
)

getCategoryId =: 4 : 0
NB. x Parent id
NB. y Category name (category names are guaranteed to be unique)
NB. Return the categoryid of the category
log 'getCategoryId ' , (": x) , ', ' , y
if. x < 0 do. _1 return. end.
result =. > {: sqlreadm__db 'select categoryid from categories where category = "' , y , '" and parentid = ' , ": x
if. 0 = # result do. 
NB. 	smoutput 'getCategoryId _1 for' ; x ; y
	_1
else. 
	{. , > result 
end.  NB. {. to force it to a scalar shape.
)

getTopCategoryId =: 3 : 0
NB. y Category name
log 'getTopCategoryId ' , y
1 getCategoryId y
)

getParentId =: 3 : 0
NB. y Category id
NB. Return the categoryid of the category's parent.
log 'getParentId ' , ": y
, > , > {: sqlreadm__db 'select parentid from categories where categoryid = ' , ": y
)
NB. ==================== End Table of Contents ====================

NB. ====================== NuVoc ========================
loadVoc =: 3 : 0
log 'loadVoc'
try. VocTable =: > 1 { sqlreadm__db 'select * from vocabulary' catch. end.
)

calcCellDimensions =: 3 : 0
NB. y A space-separated list of tokens inside a cell.
NB. Return the width and height of the cell.  Create extra lines if necessary.
glfont VocCellFont
tokens =. < ;._2 (> y) , ' '
tokenWidths =: (2 * CellMargin) + > {.@:glqextent &. > tokens
lineWidths =. ''
while. 0 < # tokenWidths do.
	sieve =. MaxCellWidth >: +/\tokenWidths
	if. 0 = +/ sieve do. NB. Throw up our hands--not enough horizontal area for the next token.
		lineWidths =. lineWidths , {. tokenWidths
		tokenWidths =. }. tokenWidths
	else.
		lineWidths =. lineWidths , +/ sieve # tokenWidths
		tokenWidths =. tokenWidths #~ -. sieve
	end.
end.
(>./ lineWidths) , CellLineHeight * # lineWidths
)

calcRowDimensions =: 3 : 0
NB. y A row of boxed tokens
NB. Return the height and column widths of the row.
dimensions =. > calcCellDimensions &. > y
(>./ {:"1 dimensions) , {."1 dimensions
)

drawVocEntry =: 4 : 0
NB. x An entry from VocTable: Group POS Row Glyph MonadicRank Label DyadicRank Link
NB. y centerOrigin (x and y)
'xx yy' =. y
'monadic label dyadic link' =. 4 5 6 7 { x
s =. monadic , ' ' , label , ' ' , dyadic
width =. {. glqextent s
leftX =. <. xx - -: width
glfont VocValenceFont
glrgb 0 0 255
gltextcolor ''
(leftX , yy) drawStringAt s
((leftX - 4) , (yy - 1) , (width + 8) , 20) registerRectLink link ; label ; 0
NB. end.
0
)

drawVocCell =: 4 : 0
NB. x POS ; Glyph ; Selected
NB. y xStart ; yStart ; width ; height
NB. Return the height
'pos glyph selected' =. x
'xStart yStart width height' =. y
glfont VocCellFont
glrgb 0 0 0
gltextcolor ''
tokens =. < ;.2 glyph , ' ' 
tokens =. (}: tokens) , }: &. > {: tokens
tokenWidths =. > {.@:glqextent &. > tokens
lineWidths =. ''
lineTokens =. ''
yStarts =. ''
while. 0 < # tokenWidths do.
	sieve =. MaxCellWidth >: +/\tokenWidths
	if. 0 = +./ sieve do. sieve =. 1 , (<: # tokenWidths) # 0 end. NB. Take a token even if it doesn't fit.
	lineWidths =. lineWidths , +/ sieve # tokenWidths
	tokenWidths =. tokenWidths #~ -. sieve
	lineTokens =. lineTokens , < sieve # tokens
	tokens =. tokens #~ -. sieve
	yStarts =. yStarts , (yStart + CellLineHeight * # lineWidths) - CellLineHeight
end.
xOffsets =. xStart + <. 0.5 * width - lineWidths
coords =. <"1 xOffsets ,. 2 + yStarts
glrgb getPosColor < pos
glbrush ''
glrgb 162 169 177
glpen 1
glrect xStart , yStart , width , height
if. selected do.
	(xStart, yStart, width, height) drawHighlight SelectionColor
end.
coords drawStringAt &. > ; &. > lineTokens
(xStart , yStart , width , height) registerRectLink ('*selectVocGlyph ''' , glyph , '''') ; glyph ; 0
''
)

drawVocLine =: 4 : 0
NB. x Table of POS Glyph
NB. y Origin ; height ; column widths
NB. Return new y start.
'origin height colWidths' =. y
'xx yStart' =. origin
selected =. VocSelectedGlyph&-: &. > 1 {"1 x
adjustedColWidths =. (# x) {. colWidths NB. We may not need all of the column widths.
xStarts =. <"0 xx + +/\ 0 , }: adjustedColWidths
(x ,. selected) drawVocCell"1 1 xStarts ,. (< yStart) ,. (<"0 adjustedColWidths) ,. < height
selectionPadding =. 0
availableWidth =. +/ colWidths
entryLineHeight =. 20
if. 0 < +/ > selected do. 
	entries =. VocTable #~ > VocSelectedGlyph&-: &. > 3 {"1 VocTable  NB. Group POS Row Glyph MonadicRank Label DyadicRank Link
	coords =. (xx + <. -: availableWidth) ,. yStart + height + 10 + entryLineHeight * i. # entries
	entries drawVocEntry"1 1 coords
	selectionPadding =. entryLineHeight * >: # entries
end.
yStart + selectionPadding + height
)

drawVocSections =: 4 : 0
NB. x Origin
NB. y Section numbers
'xx runningY' =. x
rows =. VocTable #~ (, > {."1 VocTable) e. y
cells =. ~. 1 2 3 {"1 rows NB. POS Line Glyph
dimensions =. > calcCellDimensions &. > (2 {"1 cells)
lineNumbers =. 1 {"1 cells
cellWidths =. {."1 dimensions
columnWidths =. >./ > lineNumbers < /. cellWidths
lineHeights =. > >./ &. > lineNumbers < /. {:"1 dimensions
lines =. ({. , {:)"1 &. > lineNumbers < /. cells NB. POS Glyph
spacings =. 3 * ~: lineNumbers
glfont 'consolas bold 12'
glrgb 0 0 0
gltextcolor ''
for_line. lines do.
	rowHeight =. line_index { lineHeights
	runningY =. (> line) drawVocLine (xx , runningY) ; rowHeight ; columnWidths
	runningY =. runningY + line_index { spacings
end.
runningY
)

selectVocGlyph =: 3 : 0
NB. y A glyph
log 'selectVocGlyph ' , y
VocSelectedGlyph =: , y
entry =. VocTable {~ (3 {"1 VocTable) i. < VocSelectedGlyph
queueUrl n =: (> 7 { entry) ; > 5 { entry
)

drawVoc =: 3 : 0
log 'drawVoc'
glrgb 255 255 255
glbrush ''
glrect DisplayDetailRect
((20 + {. DisplayDetailRect) , 5) drawVocSections 0 1 2 3 4 5 6
((300 + {. DisplayDetailRect) , 5) drawVocSections 7 8 9 10 11
)
NB. ============================= End Voc ===============================

NB. ============================ Database Management ====================
uploadAcct =: '12a1yBS'

checkForNewerDatabase =: 3 : 0
NB. Return 1 if a newer database is available.  
NB. Return 2 is a newer database is required.
NB. Return 0 if the local database is up to date.
if. -. fexist targetDbPath do. 
	2 
	return. 
end.
try. 
	dbOpenDb ''
	localHash =. , > > {: sqlreadm__db 'select value from admin where key = "Hash"' 
	if. 0 = # localHash do. 
		2
	return. 
	end.
catcht.
	2
	return.
end.
head =. ('--head') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
remoteHash =. n {.~ LF i.~ n =. (13 + I. 'x-file-hash: ' E. head) }. head
-. localHash -: remoteHash
)

downloadLatestStageDatabase =: 3 : 0
('-o "' , stageDbPath , '"') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
)

downloadAndTransferDatabase =: 3 : 0
NB. Open the target db (tdb) and read all of the user records.  
NB. Write them to the staging db (db).
NB. Delete the target db, then rename the staging db
downloadLatestStageDatabase ''
if. fexist stageDbPath do.
	if. fexist targetDbPath do.
		sdb =. sqlopen_psqlite_ stageDbPath
		tdb =. sqlopen_psqlite_ targetDbPath
		cats =. > {: sqlreadm__tdb 'select level, parentid, categoryid, category, parentseq, count, link from categories where categoryid > 1000000'
		historyMenu =. > {: sqlreadm__tdb 'select label, link from history'
		wiki =. > {: sqlreadm__tdb 'select title, categoryid, link from wiki where categoryid >= 1000000'
		catCols =. ;: 'level parentid categoryid category parentseq count link'
		wikiCols =. ;: 'title categoryid link'
		sqlinsert__sdb 'categories' ; catCols ; < (> 0 {"1 cats) ; (> 1 {"1 cats) ; (> 2 {"1 cats) ; (3 {"1 cats) ; (> 4 {"1 cats) ; (> 5 {"1 cats) ; < (6 {"1 cats)
		sqlinsert__sdb 'wiki' ; wikiCols ; < (0 {"1 wiki) ; (> 1 {"1 wiki) ; < (2 {"1 wiki)
		sqlinsert__sdb 'history' ; ('label' ; 'link') ; < (0 {"1 historyMenu) ; < (1 {"1 historyMenu)
		sqlclose__sdb ''
		sqlclose__tdb ''
		(1!:55) < targetDbPath 
	end.
	targetDbPath frename stageDbPath
	'rw-rw-rw-' (1!:7) < targetDbPath
	try. (1!:22) < targetDbPath catch. end.
end.
head =. ('--head') gethttp 'https://upcdn.io/' , uploadAcct , '/raw/uploads/' , stageDbFile , '?cache=false'
hash =: n {.~ LF i.~ n =. (13 + I. 'x-file-hash: ' E. head) }. head
try. (1!:22) < targetDbPath catch. end.
dbOpenDb ''
sqlclose__db ''
dbOpenDb ''
sqlinsert__db 'admin' ; (;: 'key value') ; < 'Hash' ;  hash
)

downloadDialog =: 3 : 0
status =. {. , checkForNewerDatabase ''
select. status
case. 0 do.
	wdinfo 'Local Database Status' ; 'Your local database is up to date.'
	1
case. 1 do.
	result =. wd 'mb query mb_yes =mb_no "Local Database Status" "A new database is available.  Download (to ~temp)?"'
	if. result -: 'yes' do. downloadAndTransferDatabase'' end.
	1
case. 2 do.
	result =. wd 'mb query mb_yes =mb_no "Local Database Status" "A new database is required.  Yes to download (to ~temp); No to quit."'
	if. result -: 'yes' do. 
		downloadAndTransferDatabase ''
		1
	else.
		0
	end.
end.
)
NB. ====================================================================

FrameTimeStamps =: ''

getFrameRate =: 3 : 0
FrameTimeStamps =: (t =. (6!:1) '' ) , FrameTimeStamps
fps =. # FrameTimeStamps =: FrameTimeStamps #~ (t - 1) < FrameTimeStamps
)

manageLoad =: 3 : 0
try. wd 'pclose' catch. end.
)

manageLoad ''

showide=: 3 : 0
if. IDE do.
  IDE=: 0
  wd'ide hide'
else.
  IDE=: 1
  wd'ide show'
  wd'psel view;pactive'
end.
empty''
)

view_wctrlshift_fkey=: showide

go =: 3 : 0
if. -. downloadDialog '' do. return. end.
initAdmin ''
loadVoc ''
clearLog ''
buildForm ''
layoutForm ''
loadHistoryMenu ''
wd 'pshow'
)

view_run_z_ =: 3 : 0
IDE =: 1
NB. showHide ''

go_jwikiviz_ ''
)
view_run''
