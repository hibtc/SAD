      subroutine tfsetparam
      use tfstk
      use ffs
      use tffitcode
      implicit none
      integer*4 ix
      real*8 rgetgl1,df
      emx   =rgetgl1('EMITX')
      emy   =rgetgl1('EMITY')
      if(emx .le. 1.d-30)then
        emx=1.d-12
      endif
      if(emy .le. 1.d-30)then
        emy=1.d-12
      endif
      dpmax =rfromd(kxsymbolv('DP',2))
      if(idtype(ilist(1,ilattp+1)) .eq. icMARK)then
        ix=ilist(2,ilattp+1)
        rlist(ix+kytbl(kwEMIX,icMARK))=emx
        rlist(ix+kytbl(kwEMIY,icMARK))=emy
        rlist(ix+kytbl(kwDP,icMARK))=dpmax
        rlist(ix+kytbl(kwSIGZ,icMARK))=rgetgl1('SIGZ')
        dp0=rlist(ix+kytbl(kwDDP,icMARK))
      else
        dp0=0.d0
      endif
      np0   =int(rgetgl1('NP'))
      nturn =int(rgetgl1('TURNS'))
      charge=rgetgl1('CHARGE')
      amass =rgetgl1('MASS')
      pgev  =rgetgl1('MOMENTUM')
      pbunch=rgetgl1('PBUNCH')
      anbunch=rgetgl1('NBUNCH')
      coumin=rgetgl1('MINCOUP')
      emidiv=rgetgl1('EMITDIV')
      emidib=rgetgl1('EMITDIVB')
      emidiq=rgetgl1('EMITDIVQ')
      emidis=rgetgl1('EMITDIVS')
      fridiv=rgetgl1('FRINGDIV')
      alost =rgetgl1('LOSSAMPL')
      zlost =rgetgl1('LOSSDZ')
      df    =rgetgl1('FSHIFT')
      dleng =rlist(ilist(2,ilattp)+1)*df
      pspac_nx =max(1,int(rgetgl1('PSPACNX')))
      pspac_ny =max(1,int(rgetgl1('PSPACNY')))
      pspac_nz =max(1,int(rgetgl1('PSPACNZ')))
      pspac_dx =rgetgl1('PSPACDX')
      pspac_dy =rgetgl1('PSPACDY')
      pspac_dz =rgetgl1('PSPACDZ')
      pspac_nturn =max(1,int(rgetgl1('PSPACNTURN')))
      pspac_nturncalc =max(0,int(rgetgl1('PSPACNTURNCALC')))
      call tphyzp
      call tsetgcut
      xixf  =rfromd(kxsymbolv('XIX',3))*pi2
      xiyf  =rfromd(kxsymbolv('XIY',3))*pi2
      nparallel=max(1,int(rgetgl1('NPARA')))
      iwakepold=ifwakep
      return
      end

      subroutine tphyzp
      use tfstk
      implicit none
      include 'inc/TMACRO1.inc'
      brhoz =pgev/c
      brho  =brhoz/abs(charge)
      p0    =pgev/amass
      h0    =p2h(p0)
c      h0    =p0*sqrt(1.d0+1.d0/p0**2)
      re0   =e/amass/4/pi/ep0
      rclassic=charge**2*re0
      crad  =sign(rclassic*(c/amass)**2/p0/1.5d0,charge)
      urad  =sign(1.5d0*hp*c/p0/amass/e,charge)
      erad  =55.d0/24.d0/sqrt(3.d0)*urad
      rcratio=rclassic/(hp*c/amass/e)
      anrad =5.d0/2.d0/sqrt(3.d0)*rcratio
      ccintr=(rclassic/h0**2)**2/8.d0/pi
      if(rlist(ilist(2,ilattp)+1) .ne. 0.d0)then
        omega0=pi2*c*p0/h0/rlist(ilist(2,ilattp)+1)
      else
        omega0=0.d0
      endif
      call rsetgl1('OMEGA0',omega0)
      return
      end