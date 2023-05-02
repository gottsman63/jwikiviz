NB. about.ijs
NB. about dialog

NB. require'gl2'
NB. require' graphics/bmp'

coclass 'about'
NB. coinsert'jgl2'

ABOUT=: 0 : 0
pc about escclose dialog nosize;pn "About Viewer";
bin vh;
cc l1 static sunken center;set l1 wh 280 112; 
bin zh;
cc l2 static sunken;
bin z;
bin h s2;
minwh 80 1;cc ok button;cn "&OK";
)

NB. cc pic image;

vinfo=: 0 : 0
A sample standalone application
)

cinfo=: 0 : 0
Copyright (c) 2023
)

open=: 3 : 0
wd ABOUT
if. DARK__ do. wd'ptheme dark' else. wd'ptheme' end.
wd 'set l1 text ','Viewer ',VERSION__,' (',VERSIONDATE__,')',LF,vinfo
wd 'set l2 text ',cinfo
NB. wd'set pic image *',TBP__,'toucan.bmp'
wd 'pshow;'
empty''
)

about_close=: 3 : 'wd''pclose'''

about_ok_button=: about_cancel=: about_close
