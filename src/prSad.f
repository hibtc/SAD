      Subroutine prSad(idx)
      use maccbk
      implicit real*8 (a-h,o-z)
      integer idx
c
      include 'inc/MACCODE.inc'
      include 'inc/MACFILE.inc'
      integer*4 plist,len,idxl,oldfl
c for debug
c     call ptrace('prSad',1)
c end debug
      oldfl=outfl
      outfl=21
      call sprlin(idx)
      idxl=idval(idx)
      plist=mkplst(idxl)
      len=ilist(1,plist)-1
c     print *,'prsad',plist,len
      do 1100 i=plist+1,plist+len
        ival=idtype(ilist(2,i))
        if(ival .eq. icLINE) then
           call sprlin(ilist(2,i))
        else if (ival .lt. icMXEL) then
           call prelem(ilist(2,i),' ')
        else
          call errmsg('prSad','Invalid element'//pname(ilist(2,i))
     &               ,0,0)
        endif
 1100 continue
      call freeme(plist,ilist(1,plist))
      do 2110 i=1,HTMAX
        if((idtype(i) .ge. icGLI) .and.
     &       (idtype(i) .le. icGLR)) then
           call iprglb(i)
        else if(idtype(i) .eq. icFLAG) then
           call prnflg(pname(i))
        endif
 2110 continue
c     write(outfl,*)'! End of print '//pname(idx)//' sad'
      outfl=oldfl
c for debug
c     call ptrace('prSad',1)
c end debug
      return
      end