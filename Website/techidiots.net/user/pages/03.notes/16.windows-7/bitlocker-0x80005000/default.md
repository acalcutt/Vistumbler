---
title: 'Bitlocker 0x80005000'
date: '2010-06-07 16:24'
---

I had a machine that just did not want to encrypt. It would get a 0x80005000 Active Directory Error. After a day of trying to get it to work I ended up formatting the machine and it encrypted fine.

 Today I got another machine with this error so I researched it a little more. I came across this article of vbscript getting the 0x80005000 error (http://www.tek-tips.com/viewthread.cfm?qid=775481). From this i realized what the problem was.

 Like the person using vbscript, my computer was in an OU that contained a forward slash ("/"). This forward slash was causing the error. As soon as this computer was moved from this OU it encrypted without a problem.