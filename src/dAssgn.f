      Subroutine dAssgn(token,slen,status)
      use maccbk
      implicit none
      include 'inc/MACCODE.inc'
      include 'inc/MACTTYP.inc'
      include 'inc/MACVAR.inc'
      include 'inc/MACMISC.inc'
c     
      character*(MAXSTR) token
      integer slen,status

      real*8 rval, val
      logical skipch,skiped
      integer*4 idx,i,ival,ttype,newblk,allmem,membas,memptr,memuse
      integer*4 mfalloc
c     macro functions
      logical issign
      character char
      issign(char)=(char .eq. '+') .or. (char .eq. '-')
C     implementation
      status=0
      call defglb(token(:slen),icNULL,idx)
      if ((idtype(idx) .ne. icGLR) .and.
     &     (idtype(idx) .ne. icGLI) .and.
     &     (idtype(idx) .ne. icGLL) .and.
     &     (idtype(idx) .ne. icNULL))then
         status=-1
         return
      endif
c     
      call gettok(token,slen,ttype,rval,ival)
      skiped = skipch('=',token,slen,ttype,rval,ival)
      if(ttype .eq. ttypNM .or. ttype .eq. ttypID
     $     .or. issign(token(:slen)) ) then
         call rdterm(token,slen,ttype,rval,status)
         if (status .ne. 0) return
         if (idtype(idx) .eq. icGLI) then
            idval(idx)=INT(rval)
         else if ((idtype(idx) .eq. icGLR) .or.
     &           (idtype(idx) .eq. icNULL)) then
            if(idval(idx) .le. 0) idval(idx)=mfalloc(1)
            idtype(idx)=icGLR
            rlist(idval(idx))=rval
         else if (idtype(idx) .eq. icGLL) then
            call freeme(idval(idx),ilist(1,idval(idx)))
            idval(idx)=mfalloc(2)
            ilist(1,idval(idx))=1
            if(ilist(2,idval(idx)) .eq. icNULL)
     &           ilist(2,idval(idx))=icGLR
            rlist(idval(idx)+1)=rval
         endif
      else if(skipch(LPAR,token,slen,ttype,rval,ival)) then
         if(idtype(idx) .ne. icGLL .and. idtype(idx) .ne.icNULL) then
            status=-1
            call errmsg('dasgn', 'type mismatch',0,4)
            return
         endif
         if(idtype(idx) .eq. icGLL)
     &        call freeme(idval(idx),ilist(1,idval(idx)))
         call defglb(pname(idx),icGLL,idx)
         allmem=pagesz/4
         membas=mfalloc(allmem)
         if(membas .eq. 0) then
            call errmsg('dAssgn',' cannot allocate memory',0,0)
            stop
         end if
c     Note
c     ilist(1,membas): size
c     ilist(2,membas): data type
c     See ilist(*,ptr)@src/LgetGL.f
         memptr=membas+1
 2000    if(skipch(COMMA,token,slen,ttype,rval,ival)) go to 2000
         if(skipch(RPAR,token,slen,ttype,rval,ival)) go to 3000
         if(token(:slen) .eq. SEMIC) go to 3000
         call rdterm(token,slen,ttype,val,status)
         if(status .ne. 0) then
            call errmsg('dAssgn',
     &           'sytax error.',0,4)
            return
         endif
         rlist(memptr)=val
         memptr=memptr+1
         if(memptr-membas .ge. allmem) then
               newblk=mfalloc(2*allmem)
               if (newblk .eq. 0) then
                  call errmsg('dAssgn',
     &                 ' cannot extend working area.',32,0)
                  stop
               end if
               do i=1,memptr-membas-1
                  ilist(1,newblk+i)=ilist(1,membas+i)
                  ilist(2,newblk+i)=ilist(2,membas+i)
               end do
               memptr=newblk+(memptr-membas)
               call freeme(membas,allmem)
               allmem=2*allmem
               membas=newblk
         endif
         go to 2000
c     End of List.
 3000    continue
         if (token(:slen) .ne. SEMIC) then
            call errmsg('dAssgn',' Illegal delimiter ',0,4)
         endif
         memuse=memptr-membas
         if(allmem .lt. memuse) then
            call errmsg('dassgn',
     &           ' broken memory area.',0,16)
            stop 9999
         endif
         call freeme(memptr,allmem-memuse)
         call LsetGL(pname(idx),idx,membas,memuse-1,icGLR)
      endif
c     for debug
c     call ptrace('dAssgn',-1)
c     end debug
      return
      end