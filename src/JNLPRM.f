      subroutine JNLPRM(buf,LLEN,pbuf)
      use tfrbuf, only:modemapped
      use macfile, only:MAXLLEN
c
c     JNLPRM is a HITAC library funcion to get command argumen.
c     n:not used
c     buf:return command aruguments.
c     LLEN: input= size of buf,output: size of returned string.
c     pbuf: buf(pbuf) is the last character in argument string.
c
      implicit NONE
      integer*4 LLEN,pbuf,irtc
      character*(1) buf(LLEN)
c
      integer i,j,argc,slen
      character*(MAXLLEN) argv,file
      logical*4 ex
c
C*DEC added by Y.Tange 9-Jan-1995
      integer iargc
      integer ll
C*DEC End
      integer*4 ifd
      integer*8 ksize,kfile,mapallocfd
c
      argc=iargc()
      if(argc .le. 0) then
         pbuf=0
         return
      end if
      pbuf=0
      ex=.false.
      do i=1,argc
C     *DEC / on HP-UX use +U77 option.
        call getarg( i, argv )
        ll = len_trim(argv)
        if ( ll .le. 0 .or. ll .gt. MAXLLEN) then
          stop
        endif
        slen=min(LLEN,ll)
cccccccccccccK. Oide 9/1/2000
        if(i .eq. 1)then
          if(argv .eq. '*' .or. argv .eq. '-c')then
            call getarg(2,file)
            open(77,FILE=file,STATUS='OLD')
            ifd=fnum(77)
            kfile=mapallocfd(ifd,ksize,irtc)
            if(irtc .eq. 0)then
              call irbopen1(77,kfile/8,ksize+modemapped,ifd)
            else
              write(*,*)'???-Initial input file open error: ',
     $             file(1:len_trim(file))
            endif
            if(argv .eq. '*')then
              call readstr(77,file,irtc)
              if(irtc .ne. 0)then
                file=' '
              endif
            endif
            argv='OFF LOG ECHO;READ 77'
            slen=20
            ex=.true.
          endif
        endif
ccccccccccccc
        do j=1,slen
          buf(pbuf+j)=argv(j:j)
        end do
        pbuf=min(pbuf+slen,LLEN-1)+1
        buf(pbuf)=' '
        if(ex)then
          exit
        endif
      end do
c     
      if( pbuf .lt. LLEN) then
        pbuf=pbuf+1
        buf(pbuf)=";"
      endif
c     
      print *,(buf(i),i=1,pbuf),i
      llen=pbuf
c     
      return
c     
      end
