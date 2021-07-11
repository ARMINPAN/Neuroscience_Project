2009-Nov-10

A new version of scripts "tview.m" and "fretrieve_log.m" has been
supplied which should fix the problem described below.  The old
version of these scripts were moved to the "old" directory.

So now tview should work on all the files.
 

------------------------
Original note:

At some point when the experiments were being done, the data format
for the *tune.log files was modified.  The version of tview.m in this
directory works with the newer format and not the older format.

We are trying to obtain the version that works with the earlier format.

Below are the files that fail and work with currently available
version of tview.m:

Fail:
tview('000412.a01atune.log')
tview('000412.a01ftune.log')
tview('000413.b03atune.log')
tview('000413.b04atune.log')
tview('000413.b04gtune.log')
tview('000413.b05atune.log')
tview('000418.a01atune.log')
tview('000418.a01gtune.log')
tview('000419.a06gtune.log')
tview('000419.a07atune.log')
tview('000419.a09itune.log')
tview('000420.b02atune.log')
tview('000503.a03atune.log')
tview('000511.b09ntune.log')
tview('000511.b09tune.log')
tview('000511.b10otune.log')
tview('000513.d11atune.log')
tview('000524.c01atune.log')
tview('000525.d05atune.log')
tview('000601.c05atune.log')
tview('000601.c07atune.log')
tview('000620.a02atune.log')
tview('000622.f03atune.log')
tview('000622.f04atune.log')
tview('000622.f05atune.log')
tview('000712.b03atune.log')
tview('000712.b04atune.log')
tview('000720.c06atune.log')
tview('000802.c07atune.log')
tview('000804.i01atune.log')
tview('000823.d04atune.log')
tview('000824.g04atune.log')
tview('000907.f07atune.log')
tview('000914.c06atune.log')
tview('000914.c07atune.log')
tview('000926.a04atune.log')

tview('010718.B.c01atune.log')  ** out of sequence
tview('010718.B.c02atune.log')


Work:
tview('010125.A.c02atune.log')
tview('010125.A.c03atune.log') - only one plot, has arrows
tview('010208.A.h01atune.log')
tview('010322.A.f06atune.log')
tview('010524.A.f01atune.log')
tview('010612.B.b02atune.log')
tview('010614.B.e08atune.log')
tview('010628.A.c03atune.log')
tview('010628.A.c04atune.log')

tview('010801.A.b01dtune.log')
tview('011019.A.c09atune.log')
tview('011024.A.b04atune.log')
tview('011025.A.d07atune.log')
tview('011101.A.d02atune.log')
tview('011101.A.d03atune.log')
tview('011121.A.d02atune.log')
tview('020109.A.b01atune.log')
tview('020109.A.b02atune.log')
tview('020213.A.i01atune.log')
tview('020214.A.j01atune.log')
tview('020306.A.a01atune.log')
tview('020306.A.a02atune.log')
tview('020308.A.d01atune.log')
tview('020321.A.i01atune.log')
tview('020321.A.i02atune.log')
