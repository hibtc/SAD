      subroutine ptrim(word,latt,twiss,imon,emon,nmon,lfno)
      use tfstk
      use ffs
c      trim data greater than cut*sigma
      use tffitcode
      implicit real*8(a-h,o-z)
      integer*8 latt(nlat)
      dimension twiss(nlat,-ndim:ndim,ntwissfun),
     1          imon(nmona,4),emon(nmona,4),rms(2)
      external pack
      logical exist
      character*(*) word
      include 'inc/common.inc'
c
      call getwdl(word)
      if(word.eq.'S') then
      elseif(word.eq.'O') then
      elseif(word.eq.'M') then
        cut=getva(exist)
        if(.not.exist) then
          call getwdl(word)
          return
        endif
        ia=italoc(2*nmon)
        ia1=ia-1
        ia2=ia1+nmon
        if(simulate) then
          do 10 i=1,nmon
            j=imon(i,2)
            nq=imon(j,4)
            rlist(ia1+i)=twiss(imon(j,1),0,mfitdx)
     1           -twiss(imon(j,1),ndim,mfitdx)-rlist(latt(nq)+5)
     1           -emon(j,1)
            rlist(ia2+i)=twiss(imon(j,1),0,mfitdy)
     1           -twiss(imon(j,1),ndim,mfitdy)-rlist(latt(nq)+6)
     1           -emon(j,2)
 10       continue
        else
          do 11 i=1,nmon
            j=imon(i,2)
            rlist(ia1+i)=twiss(imon(j,1),0,mfitdx)
            rlist(ia2+i)=twiss(imon(j,1),0,mfitdy)
 11     continue
        endif
        rms(1)=0d0
        rms(2)=0d0
        nm=0
        do 20 i=1,nmon
          nm=nm+1
          rms(1)=rms(1)+rlist(ia1+i)**2
          rms(2)=rms(2)+rlist(ia2+i)**2
   20   continue
        rms(1)=sqrt(rms(1)/max(nm,1))
        rms(2)=sqrt(rms(2)/max(nm,1))
        fcut1=cut*rms(1)
        fcut2=cut*rms(2)
        do 30 i=1,nmon
          j=imon(i,2)
          if(abs(rlist(ia1+i)).gt.fcut1.or.
     1       abs(rlist(ia2+i)).gt.fcut2) then
            imon(j,3)=1
          endif
   30   continue
        call pack(imon(1,2),imon(1,3),nmon,nmon)
        write(lfno,'(2(A,I4))') '  BPM available :',nmon,' in ',nmonact
        nmonact=nmon
        call tfree(int8(ia))
        call getwdl(word)
      else
        return
      endif
      return
      end
