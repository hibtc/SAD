      subroutine tfattr(word,latt,
     $         iele,iele1,ival,couple,vlim,errk,
     $         klp,mult,lfno,exist,kx,irtc,ret)
      use tfstk
      use ffs
      use tffitcode
      implicit none
      type (sad_descriptor) kx
      type (sad_list), pointer :: klxi
      integer*4 lfno,i,j
      integer*4 latt(2,nlat),iele(nlat),iele1(nlat),mult(nlat)
      integer*4 ival(nele),klp(nele),irtc,isp1,lenw
      real*8 errk(2,nlat),couple(nlat),vlim(nele,2),v
      character*(*) word
      character*(MAXPNAME+16) namc,name
      character*10 autofg
      character*8 tfkwrd,key
      logical*4 exist,exist1,all,temat,ret
      write(lfno,'(a)')
     $     'Element     Keyword    Value     Mimimum  Maximum'
     1           //'  Couple         Coefficient'
      all=.false.
      exist=.false.
      isp1=isp
 1    exist1=.false.
      call getwdl(word)
      if(word .eq. ' ')then
        if(exist)then
          go to 9000
        else
          all=.true.
        endif
      endif
 2    LOOP_J: do j=1,nlat-1
        if(all)then
          call elname(latt,j,mult,name)
        elseif(temat(latt,j,mult,name,word))then
        else
          cycle LOOP_J
        endif
        exist1=.true.
        i=iele1(iele(j))
        if(iele(j) .eq. j .or. klp(iele1(j)) .eq. j .or.
     $       iele(j) .ne. klp(iele1(j)) .and.
     $       iele(j) .ne. iele(klp(iele1(j))))then
          call elname(latt,iele(j),mult,namc)
          if(ival(i) .eq. 0)then
            v=0.d0
          else
            v=rlist(latt(2,j)+ival(i))/errk(1,j)
          endif
          key=tfkwrd(idtype(latt(1,j)),ival(i))
          if(ret)then
            dtastk(isp)=kxadaloc(-1,7,klxi)
            klxi%dbody(1)=kxsalocb(0,name,lenw(name))
            klxi%dbody(2)=kxsalocb(0,key,lenw(key))
            klxi%rbody(3)=v
            klxi%rbody(4)=vlim(1,1)
            klxi%rbody(5)=vlim(1,2)
            klxi%dbody(6)=kxsalocb(0,namc,lenw(namc))
            klxi%rbody(7)=couple(j)
            isp=isp+1
          endif
          if(klp(i) .eq. j)then
            namc='<--'
          endif
          write(lfno,'(5a,1x,2a)')name(1:12),
     $         key,autofg(v,'10.6'),
     $         autofg(vlim(i,1),'10.6'),autofg(vlim(i,2),'10.6'),
     1         namc(1:12),autofg(couple(j),'10.6')
        endif
      enddo LOOP_J
      if(.not. all)then
        if(exist)then
          if(exist1)then
            go to 1
          else
            exist=.false.
          endif
        else
          if(exist1)then
            exist=.true.
          else
            all=.true.
            go to 2
          endif
          go to 1
        endif
      endif
 9000 if(ret)then
        kx=kxmakelist(isp1)
        isp=isp1
        irtc=0
      endif
      return
      end