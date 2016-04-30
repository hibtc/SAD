      module temw
      implicit none
      private

      real(8), public :: r(6, 6) = RESHAPE((/
     $     1.d0, 0.d0, 0.d0, 0.d0, 0.d0, 0.d0,
     $     0.d0, 1.d0, 0.d0, 0.d0, 0.d0, 0.d0,
     $     0.d0, 0.d0, 1.d0, 0.d0, 0.d0, 0.d0,
     $     0.d0, 0.d0, 0.d0, 1.d0, 0.d0, 0.d0,
     $     0.d0, 0.d0, 0.d0, 0.d0, 1.d0, 0.d0,
     $     0.d0, 0.d0, 0.d0, 0.d0, 0.d0, 1.d0/),
     $     (/6, 6/))

c     Inverse matrix of r
      real(8), public :: ri(6, 7) = RESHAPE((/
     $     1.d0, 0.d0, 0.d0, 0.d0, 0.d0, 0.d0,
     $     0.d0, 1.d0, 0.d0, 0.d0, 0.d0, 0.d0,
     $     0.d0, 0.d0, 1.d0, 0.d0, 0.d0, 0.d0,
     $     0.d0, 0.d0, 0.d0, 1.d0, 0.d0, 0.d0,
     $     0.d0, 0.d0, 0.d0, 0.d0, 1.d0, 0.d0,
     $     0.d0, 0.d0, 0.d0, 0.d0, 0.d0, 1.d0,
     $     0.d0, 0.d0, 0.d0, 0.d0, 0.d0, 0.d0/),
     $     (/6, 7/))

      real(8), public :: emx, emy, emz

      end module temw

      module touschek_table
      implicit none
      private

      public :: initialize_tampl

      integer(8), public:: itoul = 0
      integer, public :: id = 0

      integer, public, parameter :: ntouckx = 34, ntouckz = 25
      integer, public, parameter :: ntouckl = 120

c     ntouckx > ntouckz

c     Table of amplitude(index, axis[1->x, 2->y, 3->z])
      real(8), public :: tampl(ntouckx, 3)

c     Table of loss-rate
      real(8), public :: touckl(ntouckl)
      real(8), public :: touckm(ntouckz, ntouckx, 3)
      real(8), public, allocatable :: toucke(:,:)

      contains

      subroutine initialize_tampl()
      implicit none
      integer :: i

      tampl(:,:) = 0.d0

      tampl( 1,1)=1.d0
      tampl( 2,1)=2.d0
      tampl( 3,1)=3.d0
      tampl( 4,1)=4.d0

      tampl( 1+4,1)=5.d0
      tampl( 2+4,1)=6.d0
      tampl( 3+4,1)=7.d0
      tampl( 4+4,1)=8.d0
      tampl( 5+4,1)=9.d0

      tampl( 1+5+4,1)=10.d0
      tampl( 2+5+4,1)=11.d0
      tampl( 3+5+4,1)=13.d0
      tampl( 4+5+4,1)=15.d0
      tampl( 5+5+4,1)=17.d0
      tampl( 6+5+4,1)=19.d0
      tampl( 7+5+4,1)=21.d0
      tampl( 8+5+4,1)=24.d0
      tampl( 9+5+4,1)=28.d0
      tampl(10+5+4,1)=32.d0
      tampl(11+5+4,1)=36.d0
      tampl(12+5+4,1)=41.d0
      tampl(13+5+4,1)=46.d0
      tampl(14+5+4,1)=53.d0
      tampl(15+5+4,1)=60.d0
      tampl(16+5+4,1)=68.d0
      tampl(17+5+4,1)=77.d0
      tampl(18+5+4,1)=88.d0

      do i = 28, ntouckx
        tampl(i, 1) = tampl(i-18, 1) * 10.d0
      enddo

      tampl(1:ntouckx,2) = tampl(1:ntouckx,1)

      tampl(7:ntouckx-3,3) = tampl(10:ntouckx,1)
      tampl( 1,3)= 4.6d0
      tampl( 2,3)= 5.3d0
      tampl( 3,3)= 6.d0
      tampl( 4,3)= 6.8d0
      tampl( 5,3)= 7.7d0
      tampl( 6,3)= 8.8d0

      return
      end subroutine initialize_tampl

      end module touschek_table

      subroutine temit(latt,trans,cod,beam,btr,
     $     twiss,size,gammab,calem,
     $     iatr,iacod,iabmi,iamat,
     $     ndim,plot,params,stab,lfni,lfno)
      use tfstk
      use temw
      implicit none
      include 'inc/TMACRO1.inc'
      integer*4 npara
      real*8 conv
      parameter (npara=59)
      parameter (conv=1.d-12)
      integer*8 iatr,iacod,iamat,iabmi
      integer*4 latt(2,nlat),lfni,lfno,ndim,ia,it,i,j,k,
     $k1,k2,k3,m,n, iret,l,italoc
      real*8 trans(6,12),cod(6),beam(42),emx0,emy0,emz0,dl,
     $     heff,orf,phirf,alphap,omegaz,bh,so,s,
     $     sr,sqr2,bb,sige,
     $     emxr,emyr,emzr,xxs,yys,btilt,
     $     sig1,sig2,sigx,sigy,tune,sigz,
     $     emxmin,emymin,emzmin,emxmax,emymax,emzmax,
     $     emxe,emye,emze,dc,
     $     transs(6,12),beams(21)
      complex*16 cc(6),cd(6),ceig(6),ceig0(6),dceig(6)
      real*8 btr(21,21),emit(21),emit1(42),beam1(42),
     1       beam2(21),params(npara),codold(6),ab(6)
      real*8 twiss(nlat,-ndim:ndim,*),size(21,nlat),
     $     polsca(7),demin,rgetgl1
      real*8 gammab(nlat)
      character*10 label1(6),label2(6)
      character*11 autofg,vout(9)
      logical*4 plot,pri,fndcod,synchm,intend,stab,calem,
     $     epi,calcodr
      data label1/'        X ','       Px ','        Y ',
     1            '       Py ','        Z ','       Pz '/
      data label2/'        x ','    px/p0 ','        y ',
     1            '    py/p0 ','        z ','    dp/p0 '/
      ia(m,n)=((m+n+abs(m-n))**2+2*(m+n)-6*abs(m-n))/8
      it=0
      trf0=0.d0
      vcphic=0.d0
      vcalpha=1.d0
      epsrad=1.d-6
      demin=1.d100
      calint=.false.
      intend=.false.
      epi=.false.
      cod=codin
      call tmov(beamin,beam,21)
c      call tclr(beam,21)
      call tclr(beam(22),21)
      call tfill(codold,10.d0,6)
      call tclr(params,npara)
      call tclr(ceig0,12)
      emxe=rgetgl1('EMITXE')
      emye=rgetgl1('EMITYE')
      emze=rgetgl1('EMITZE')
      call tsetdvfs
      emx0=0.d0
      emy0=0.d0
      emz0=0.d0
      emxmin=1.d-100
      emymin=1.d-100
      emzmin=1.d-100
      emxmax=1.d100
      emymax=1.d100
      emzmax=1.d100
      irad=6
      caltouck=.false.
      calcodr=.not. trpt .and. calcod
      pri=lfno .gt. 0
      if(calcodr)then
c
c zero clear initial cod (comment out by Y.O, 2010/10/28)
c
c        call tclr(cod,6)
        call tcod(latt,trans,cod,beam,twiss,gammab,ndim,fndcod)
        codin=cod
c        write(*,*)'temit-tcod ',trf0
        if(pri)then
          write(lfno,*)
          write(lfno,*)'   Closed orbit:'
          write(lfno,'(10X,6A)')label2
          call tput(cod,label2,' Entrance ','9.6',1,lfno)
        endif
      elseif(calem)then
        if(pri)then
          write(lfno,*)
          write(lfno,*)'   Closed orbit:'
          write(lfno,'(10X,6A)')label2
          call tput(codin,label2,' Entrance ','9.6',1,lfno)
        endif
      else
        if(pri)then
          write(lfno,*)
          write(lfno,*)'   Closed orbit:'
          write(lfno,'(10X,6A)')label2
          call tput(cod,label2,' Entrance ','9.6',1,lfno)
        endif
        call tinitr(trans)
        call tclr(trans(1,7),36)
        call tturne(latt,trans,cod,beam,0.d0,0.d0,gammab,0,0,0,
     1       0,.false.,.false.,.true.)
      endif
      if(calpol .and. irad .eq. 6)then
        ipoltr=italoc(npelm*36)
        ipolb=italoc(npelm*21)
        ipolo=italoc(npelm*6)
        ipoll=italoc(npelm)
        ipolid=italoc(npelm)
      endif
      irad=12
 4001 if(calem)then
        cod=codin
        beam(1:21)=beamin
c        call tclr(beam,21)
        call tinitr(trans)
        call tclr(trans(1,7),36)
c        write(*,*)'temit ',trf0,cod
        call tturne(latt,trans,cod,beam,twiss,size,gammab,0,0,0,
     1       ndim,.false.,.false.,.true.)
      endif
c     call tsymp(trans)
      params(1:6)=cod
      if(pri)then
        call tput(cod,label2,'     Exit ','9.6',1,lfno)
        write(lfno,*)
      endif
      transs=trans
      if(trpt)then
        beams=beamin(1:21)
      else
        beams=beam(1:21)
      endif
 3101 r=trans(:,1:6)
      if(pri .and. emiout)then
        write(lfno,*)'   Symplectic part of the transfer matrix:'
        call tput(trans,label2,label2,'9.6',6,lfno)
        call tinv(r,ri,6,6)
        call tmultr(ri,trans,6)
        call tput(ri,label2,label2,'9.6',6,lfno)
      endif
      if(.not. rfsw)then
        r(6,1)=0.d0
        r(6,2)=0.d0
        r(6,3)=0.d0
        r(6,4)=0.d0
        r(6,5)=0.d0
        r(6,6)=1.d0
      endif
      call teigen(r,ri,ceig,6,6)
      call tnorm(r,ceig,lfno)
      call tsub(ceig,ceig0,dceig,12)
      ceig0=ceig
      call tinv(r,ri,6,6)
      call tmultr(trans,ri,6)
      call tmov(r,btr,36)
      call tmultr(btr,trans,6)
      if(pri .and. emiout)then
        call tput(btr,label1,label1,'9.6',6,lfno)
      endif
      if(iamat .gt. 0)then
        dlist(iamat+4)=
     $       dtfcopy1(kxm2l(ri,6,6,6,.false.))
        dlist(iamat+1)=
     $       dtfcopy1(kxm2l(codin,0,6,1,.false.))
      endif
      dl=btr(14,2)
      do i=1,3
        cc(i*2-1)=ceig(i*2-1)
        cc(i*2  )=conjg(cc(i*2-1))
        cd(i+3)=log(cc(i*2-1))
      enddo
      if(vceff .ne. 0.d0)then
        heff=wrfeff*c/omega0
      else
        heff=0.d0
      endif
      orf=wrfeff
      phirf=abs(trf0*orf/c/p0*h0)
      synchm=rfsw .and. imag(cd(6)) .ne. 0.d0
      if(synchm)then
        if(wrfeff .ne. 0.d0)then
c          alphap=imag(cd(6))**2/pi2/hvc0*pgev/cos(phirf)*p0/h0
c          alphap=-imag(cd(6))*abs(imag(cd(6)))
c     $          /pi2/abs(hvc0)/vcalpha*pgev/cos(phirf)*p0/h0
          alphap=-imag(cd(6))*abs(imag(cd(6)))/(c*pi2/omega0)
     $         /(dvcacc/pgev)
        else
          alphap=0.d0
        endif
        omegaz=abs(imag(cd(6)))*omega0/pi2
      else
        alphap=-dl/pi2/c/p0*h0*omega0
        omegaz=sqrt(abs(alphap*pi2*heff*vceff/pgev*cos(phirf)))
     $       *omega0/pi2
      endif
      if(vceff .ne. 0.d0)then
        bh=sqrt(abs(vceff/pi/abs(alphap)/heff/pgev*
     1        (2.d0*cos(phirf)-(pi-2.d0*phirf)*u0*pgev/vceff)))
      else
        bh=0.d0
      endif
      stab=(abs(dble(cd(4))) .lt. 1.d-6
     $     .and. abs(dble(cd(5))) .lt. 1.d-6
     1     .and. abs(dble(cd(6))) .lt. 1.d-6) .and. fndcod
      params(7)=imag(cd(4))/pi2
      params(8)=imag(cd(5))/pi2
      params(9)=imag(cd(6))/pi2
      params(10)=u0*pgev
      params(11)=vceff
      params(12)=trf0
      params(13)=alphap
      params(14)=dleng
      params(15)=bh
      params(27)=heff
      call tfetwiss(ri,cod,params(31),lfno,pri)
      if(pri)then
        vout(1)=autofg(pgev/1.d9       ,'10.7')
        vout(2)=autofg(omega0/pi2      ,'10.7')
        vout(3)=autofg(u0*pgev/1.d6    ,'10.7')
        vout(4)=autofg(vceff/1.d6      ,'10.7')
        vout(5)=autofg(trf0*1.d3       ,'10.7')
        vout(6)=autofg(alphap          ,'10.7')
        vout(7)=autofg(-dleng*1.d3     ,'10.7')
        vout(8)=autofg(heff            ,'10.7')
        vout(9)=autofg(bh              ,'10.7')
        write(lfno,9101)(vout(i)(1:10),i=1,9)
9101    format(   'Design momentum      P0 =',a,' GeV',
     1         1x,'Revolution freq.     f0 =',a,' Hz '/
     1            'Energy loss per turn U0 =',a,' MV ',
     1         1x,'Effective voltage    Vc =',a,' MV '/
     1            'Equilibrium position dz =',a,' mm ',
     1         1x,'Momentum compact. alpha =',a/
     1            'Orbit dilation       dl =',a,' mm ',
     1         1x,'Effective harmonic #  h =',a,/
     1            'Bucket height     dV/P0 =',a/)
        if(emiout)then
          write(lfno,*)'   Eigen values and eigen vectors:'
          write(lfno,*)
          write(lfno,9011)'     Real:',(dble(ceig(j)),j=1,6)
          write(lfno,9011)'Imaginary:',(imag(ceig(j)),j=1,6)
        endif
        write(lfno,9012)'Imag.tune:',(dble(cd(j))/pi2,j=4,6)
        write(lfno,9012)'Real tune:',(imag(cd(j))/pi2,j=4,6)
        write(lfno,*)
9011    format(2x,a,6f10.7)
9012    format(2x,a,3(f10.7,10x))
        so=0.d0
        do i=1,6
          do j=1,6
            s=0.d0
            do k=1,6
              s=s+ri(j,k)*r(k,i)
            enddo
            trans(j,i)=s
            if(i .eq. j)then
              so=so+abs(s-1.d0)
            else
              so=so+abs(s)
            endif
          enddo
        enddo
        if(so .gt. 1.d-8)then
          write(lfno,*)' *** Deviation from symplectic matrix = ',so
        endif
        if(emiout)then
          call tput(r ,label1,label2,'9.6',6,lfno)
          call tput(ri,label2,label1,'9.6',6,lfno)
          call tput(trans,label2,label2,'9.6',6,lfno)
        endif
      endif
      if(.not. calem)then
        go to 7010
      endif
      do i=1,6
        do j=1,6
          s=0.d0
          do k=1,6
            s=s+trans(j,k+6)*r(k,i)
          enddo
          trans(j,i)=s
        enddo
      enddo
      call tmultr(trans,ri,6)
      do i=1,5,2
        cd(i/2+1)=dcmplx((trans(i,i)+trans(i+1,i+1))*.5d0,
     1                   (trans(i,i+1)-trans(i+1,i))*.5d0)/cc(i)
      enddo
      if(trpt)then
        taurdx=1.d3
        taurdy=1.d3
        taurdz=1.d3
      else
        if(dble(cd(1)) .ne. 0.d0)then
          taurdx=-pi2/omega0/dble(cd(1))
        else
          taurdx=0.d0
        endif
        if(dble(cd(2)) .ne. 0.d0)then
          taurdy=-pi2/omega0/dble(cd(2))
        else
          taurdy=0.d0
        endif
        if(dble(cd(3)) .ne. 0.d0)then
          taurdz=-pi2/omega0/dble(cd(3))
        else
          taurdz=0.d0
        endif
      endif
      params(16)=dble(cd(1))
      params(17)=dble(cd(2))
      params(18)=dble(cd(3))
      params(28)=imag(cd(1))
      params(29)=imag(cd(2))
      params(30)=imag(cd(3))
      sr=(dble(cd(1))+dble(cd(2))+dble(cd(3)))
      if(sr .ne. 0.d0)then
        sr=4.d0/sr
        params(19)=params(16)*sr
        params(20)=params(17)*sr
        params(21)=params(18)*sr
      else
        sr=0.d0
        params(19)=0.d0
        params(20)=0.d0
        params(21)=0.d0
      endif
      if(pri)then
        if(emiout)then
          write(lfno,*)'   Radiation part of the transfer matrix:'
          call tput(trans(1,7),label2,label2,'9.6',6,lfno)
          call tput(trans     ,label1,label1,'9.6',6,lfno)
        endif
        write(lfno,*)'   Damping per one revolution:'
        write(lfno,9013)
     1        'X :',dble(cd(1)),'Y :',dble(cd(2)),'Z :',dble(cd(3))
        write(lfno,*)'   Damping time (sec):'
        write(lfno,9013)
     1       'X :',-pi2/omega0/dble(cd(1)),
     $       'Y :',-pi2/omega0/dble(cd(2)),
     $       'Z :',-pi2/omega0/dble(cd(3))
        write(lfno,*)'   Tune shift due to radiation:'
        write(lfno,9013)
     1        'X :',imag(cd(1))/pi2,
     $       'Y :',imag(cd(2))/pi2,'Z :',imag(cd(3))/pi2
9013    format(10x,3(a,1p,g14.6,3x))
        write(lfno,*)'   Damping partition number:'
        write(lfno,9014)
     1  'X :',dble(cd(1))*sr,'Y :',dble(cd(2))*sr,'Z :',dble(cd(3))*sr
9014    format(10x,3(a,f10.4,7x))
        write(lfno,*)
      endif
      call tmov(beam,beam1,21)
      call tmulbs(beam,ri,.false.,.false.)
      call tmov(beam,beam2,21)
      if(.not. synchm)then
        do i=1,6
          beam(ia(5,i))=0.d0
          trans(i,5)=0.d0
          trans(5,i)=0.d0
        enddo
      endif
      call tclr(btr,441)
      call tclr(trans(1,7),36)
      do i=1,5,2
        tune=imag(cd(i/2+4))
        trans(i  ,i+6)= cos(tune)
        trans(i  ,i+7)= sin(tune)
        trans(i+1,i+6)=-sin(tune)
        trans(i+1,i+7)= cos(tune)
      enddo
      do i=1,6
        do j=1,i
          k=ia(i  ,j  )
          do m=1,6
            do n=1,6
              l=ia(m,n)
              btr(k,l)=btr(k,l)-(trans(i,m)+trans(i,m+6))*
     1                          (trans(j,n)+trans(j,n+6))
            enddo
          enddo
        enddo
      enddo
      sqr2=sqrt(.5d0)
      do i=1,5,2
        k1=ia(i  ,i  )
        k2=ia(i+1,i+1)
        k3=ia(i  ,i+1)
        do j=1,21
          bb=btr(k1,j)
          btr(k1,j)=( bb+btr(k2,j))*sqr2
          btr(k2,j)=(-bb+btr(k2,j))*sqr2
          btr(k3,j)=btr(k3,j)/sqr2
        enddo
        bb=beam(k1)
        beam(k1)=( bb+beam(k2))*sqr2
        beam(k2)=(-bb+beam(k2))*sqr2
        beam(k3)=beam(k3)/sqr2
        do j=1,21
          bb=btr(j,k1)
          btr(j,k1)=( bb+btr(j,k2))*sqr2
          btr(j,k2)=(-bb+btr(j,k2))*sqr2
          btr(j,k3)=btr(j,k3)*sqr2
        enddo
      enddo
      do  i=1,21
        btr(i,i)=btr(i,i)+1.d0
        emit(i)=0.d0
      enddo
      do i=1,5,2
        k=ia(i,i)
        btr(k,k)=-(trans(i  ,i)**2+trans(i  ,i+1)**2+
     1             trans(i+1,i)**2+trans(i+1,i+1)**2)*.5d0-
     1            trans(i,i+6)*(trans(i,i)+trans(i+1,i+1))-
     1            trans(i,i+7)*(trans(i,i+1)-trans(i+1,i))
      enddo
      if(.not. synchm)then
        btr(15,21)=0.d0
        btr(15,15)=btr(15,15)*2.d0
        btr(21,15)=-btr(21,21)
        beam(21)=0.d0
      endif
      do i=1,5,2
        k1=ia(i,i)
        k2=ia(i+1,i+1)
        if(btr(k2,k2) .ne. 0.d0 .and. btr(k1,k1) .ne. 0.d0)then
          ab(i)=sqrt(abs(btr(k1,k1)/btr(k2,k2)))
          do j=1,21
            btr(k1,j)=btr(k1,j)/ab(i)
            btr(k2,j)=btr(k2,j)*ab(i)
          enddo
          beam(k1)=beam(k1)/ab(i)
          beam(k2)=beam(k2)*ab(i)
        else
          ab(i)=1.d0
        endif
      enddo
      call tsolva(btr,beam,emit,21,21,21,1d-8)
      do i=1,5,2
        k1=ia(i,i)
        k2=ia(i+1,i+1)
        bb=emit(k1)
        emit(k1          )=(bb-emit(k2))*sqr2
        emit(k2          )=(bb+emit(k2))*sqr2
        emit(ia(i  ,i+1))=emit(ia(i  ,i+1))*sqr2
      enddo
      emit(ia(1,1))=sign(max(abs(emit(ia(1,1))),emxe),
     $     emit(ia(1,1)))
      emit(ia(2,2))=sign(max(abs(emit(ia(2,2))),emxe),
     $     emit(ia(2,2)))
      emit(ia(3,3))=sign(max(abs(emit(ia(3,3))),emye),
     $     emit(ia(3,3)))
      emit(ia(4,4))=sign(max(abs(emit(ia(4,4))),emye),
     $     emit(ia(4,4)))
      emit(ia(5,5))=sign(max(abs(emit(ia(5,5))),emze),
     $     emit(ia(5,5)))
      emit(ia(6,6))=sign(max(abs(emit(ia(6,6))),emze),
     $     emit(ia(6,6)))
      if(.not. epi)then
        emx= sign(sqrt(abs(emit(ia(1,1))*emit(ia(2,2))
     $       -emit(ia(1,2))**2)),emit(ia(2,2))*charge)
        emy= sign(sqrt(abs(emit(ia(3,3))*emit(ia(4,4))
     $       -emit(ia(3,4))**2)),emit(ia(4,4))*charge)
        emz= sign(sqrt(abs(emit(ia(5,5))*emit(ia(6,6))
     $       -emit(ia(5,6))**2)),emit(ia(6,6))*charge)
      endif
      emit1(1:21)=emit
      call tmulbs(emit1,r,.false.,.false.)
      sige=sqrt(abs(emit1(21)))
      if(synchm)then
        sigz=sqrt(abs(emit1(15)))
      else
        if(omegaz .ne. 0.d0)then
          sigz=abs(alphap)*sige*c*p0/h0/omegaz
        else
          sigz=0.d0
        endif
        emz=sigz*sige
      endif
      params(22)=emx
      params(23)=emy
      params(24)=emz
      params(25)=sige
      params(26)=sigz
      call rsetgl1('EMITX',emx)
      call rsetgl1('EMITY',emy)
      call rsetgl1('EMITZ',emz)
      call rsetgl1('SIGE',sige)
      call rsetgl1('SIGZ',sigz)
 3001 if(pri)then
        if(emiout)then
          if(calint)then
            if(intra)then
              write(lfno,*)
     1             '   Beam matrix by radiation+intrabeam fluctuation:'
            endif
            if(wspac)then
              write(lfno,*)
     1             '   Beam matrix with space charge:'
            endif
          else
            write(lfno,*)'   Beam matrix by radiation fluctuation:'
          endif
          call tputbs(beam1,label2,lfno)
          call tputbs(beam2,label1,lfno)
          write(lfno,*)'   Equiliblium beam matrix:'
          call tputbs(emit,label1,lfno)
          call tputbs(emit1,label2,lfno)
        endif
        vout(1)=autofg(emx             ,'11.8')
        vout(2)=autofg(emy             ,'11.8')
        vout(3)=autofg(emz             ,'11.8')
        vout(4)=autofg(sige            ,'11.8')
        vout(5)=autofg(sigz*1.d3       ,'11.8')
ckiku <------------------
        xxs=emit1(1)-emit1(6)
        yys=-2.d0*emit1(4)
        if(xxs .ne. 0.d0 .and. yys .ne. 0.d0)then
          btilt= atan2(yys,xxs) /2d0
        else
          btilt=0.d0
        endif
        sig1 = abs(emit1(1)+emit1(6))/2d0
        sig2 = 0.5d0* sqrt(abs((emit1(1)-emit1(6))**2+4d0*emit1(4)**2))
        sigx = max(sqrt(sig1+sig2),sqrt(abs(sig1-sig2)))
        sigy = min(sqrt(sig1+sig2),sqrt(abs(sig1-sig2)))
        vout(6)=autofg(btilt,'11.8')
        vout(7)=autofg(sigx*1.d3  ,'11.8')
        vout(8)=autofg(sigy*1.d3  ,'11.8')
        write(lfno,9102)(vout(i)     ,i=1,8)
9102    format(   'Emittance X            =',a,' m  ',
     1         1x,'Emittance Y            =',a,' m'/
     1            'Emittance Z            =',a,' m  ',
     1         1x,'Energy spread          =',a,/
     1            'Bunch Length           =',a,' mm ',
     1         1X,'Beam tilt              =',a,' rad'/
     1            'Beam size xi           =',a,' mm ',
     1         1X,'Beam size eta          =',a,' mm'/)
c9103   format(3X,'Beam dimension along principal axis:'/
        call putsti(emx,emy,emz,sige,sigz,btilt,sigx,sigy,
     1              calint,fndcod)
ckiku ------------------>
      endif
      if(calcodr .and. .not. stab .and. intra)then
        write(lfno,*)'Skip intrabeam because of unstable.'
        intend=.true.
      endif
      if(intend)then
        go to 7010
      endif
      if(intra .or. wspac)then
        dc=0.d0
        do i=1,6
          dc=dc+abs(dceig(i))
        enddo
        call tintraconv(lfno,it,emit,transs,trans,r,
     $     beams,beam,
     $     emxr,emyr,emzr,
     $     emx,emy,emz,
     $     emxmax,emymax,emzmax,
     $     emxmin,emymin,emzmin,
     $     emx0,emy0,emz0,demin,sigz,sige,dc,
     $     vout,pri,intend,epi,synchm,iret)
c        write(*,*)'temit-intraconv ',iret,beam(27)
        go to (7010,4001,3101,3001),iret
      else
        beam(22:42)=emit1(1:21)
      endif
7010  if(plot .and. calem)then
        if(iamat .gt. 0)then
          dlist(iamat+5)=
     $         dtfcopy1(kxm2l(beam1,0,21,1,.false.))
          dlist(iamat+6)=
     $         dtfcopy1(kxm2l(emit1,0,21,1,.false.))
        endif
        call tinitr(trans)
        call tclr(trans(1,7),36)
        cod=codin
        call tmov(r,btr,78)
        if(trpt)then
          emit1(1:21)=beamin
        else
          emit1(1:21)=beam(22:42)
        endif
        emit1(22:42)=beam(22:42)
c        write(*,*)'temit-7101: ',emit1(6),emit1(27)
        call tturne(latt,trans,cod,emit1,twiss,size,gammab,
     $       iatr,iacod,iabmi,ndim,.true.,.false.,.true.)
        if(iamat .gt. 0)then
          dlist(iamat+2)=
     $         dtfcopy1(kxm2l(trans,6,6,6,.false.))
          dlist(iamat+3)=
     $         dtfcopy1(kxm2l(trans(1,7),6,6,6,.false.))
        endif
        call tmov(btr,r,78)
        if(iamat .eq. 0)then
          if(charge .lt. 0.d0)then
            do i=1,nlat
              do j=1,21
                size(j,i)=-size(j,i)
              enddo
            enddo
          endif
        endif
      endif
      if(.not. calpol)then
        return
      endif
      polsca(1)=imag(cd(4))/pi2
      polsca(2)=imag(cd(5))/pi2
      polsca(3)=imag(cd(6))/pi2
      polsca(4)=emx
      polsca(5)=emy
      polsca(6)=emz
      polsca(7)=pgev
      call pol(npelm,rlist(ipolid),rlist(ipoll),rlist(ipolo),
     1         rlist(ipoltr),rlist(ipolb),polsca,r,pname,lfni,lfno)
      call tfree(ipoltr)
      call tfree(ipolb)
      call tfree(ipolo)
      call tfree(ipoll)
      call tfree(ipolid)
      return
      end

      subroutine tintraconv(lfno,it,emit,transs,trans,r,
     $     beams,beam,
     $     emxr,emyr,emzr,
     $     emx,emy,emz,
     $     emxmax,emymax,emzmax,
     $     emxmin,emymin,emzmin,
     $     emx0,emy0,emz0,demin,sigz,sige,dc,
     $     vout,pri,intend,epi,synchm,iret)
      use tfstk
      use touschek_table
      implicit none
      type (sad_list), pointer :: klx,klx1,klx2,klx1d,klx1l
      include 'inc/TMACRO1.inc'
      integer*4 itmax,ia,m,n
      real*8 resib,dcmin
      parameter (itmax=100,resib=3.d-6,dcmin=0.06d0)
      integer*8 kax,kax1,kax1d,kax1l,kax2
      integer*4 lfno,it,i,iii,k,iret,j
      real*8 emit(21),beams(21),beam(42),transs(6,12),
     $     trans(6,12),trans1(6,6),r(6,6),
     $     rx,ry,rz,emxr,emyr,emzr,
     $     emx,emy,emz,emx1,emy1,emz1,emmin,
     $     emxmax,emymax,emzmax,
     $     emxmin,emymin,emzmin,
     $     de,emx0,emy0,emz0,demin,tf,tt,eintrb,
     $     rr,sigz,sige,dc
      logical*4 pri,intend,epi,synchm
      character*11 autofg,vout(*)
      ia(m,n)=((m+n+abs(m-n))**2+2*(m+n)-6*abs(m-n))/8
      emx1=emx
      emy1=emy
      emz1=emz
      if(.not. trpt)then
        emmin=(emx+emy)*coumin
        emx=max(emmin,emx)
        emy=max(emmin,emy)
        emz=max(emz0*0.1d0,emz)
        if(emx .le. 0.d0 .or. emy .le. 0.d0 .or. emz .le. 0.d0)then
          write(lfno,*)
     $         ' Negative emittance, ',
     $         'No intrabeam/space charge calculation. emx,y,z =',
     $         emx,emy,emz
          it=itmax+1
        endif
        if(it .ge. 20)then
          emx=min(emxmax,max(emxmin,emx))
          emy=min(emymax,max(emymin,emy))
          emz=min(emzmax,max(emzmin,emz))
        endif
        de=(1.d0-emx0/emx)**2+
     1       (1.d0-emy0/emy)**2+(1.d0-emz0/emz)**2
        demin=min(de,demin)
        if(it .ge. 20)then
          if(it .eq. 20)then
            write(*,*)' Poor convergence... '
            write(*,*)
     $'     EMITX          EMITY          EMITZ           conv'
          endif
          write(*,'(1P,4G15.7)')emx,emy,emz,de
        endif
      endif
 7301 if(it .gt. 1 .and. dc .lt. dcmin
     $     .and. de .lt. resib .or. it .gt. itmax)then
        if(.not. trpt)then
          if(de .ge. resib .or. dc .ge. dcmin)then
            write(*,*)' Intrabeam/space charge convergence failed.'
          elseif(intra .and. .not. caltouck)then
            de=resib*1.01d0
            go to 7301
          endif
          if(itoul .eq. 0)then
            itoul=ktfsymbolz('TouschekTable',13)-4
          endif
          intend=.true.
          tf=rclassic**2*c*pbunch*sqrt(pi)/h0*omega0/2.d0/pi/c/p0*h0
          if(caltouck)then
            id=id+1
            kax=ktadaloc(0,4,klx)
            kax1=ktadaloc(0,2,klx1)
            kax1d=ktavaloc(0,ntouckl,klx1d)
            kax1l=ktavaloc(0,ntouckl,klx1l)
            do i=1,ntouckl
              klx1d%rbody(i)=(i+1)*2.d-3
              klx1l%rbody(i)=touckl(i)*tf
              do j=1,nlat
c factor: tf for toucke(#dp/p0,#element) 
                toucke(i,j)=toucke(i,j)*tf
              enddo
            enddo
            klx1%body(1)=ktflist+kax1d
            klx1%body(2)=ktflist+kax1l
            kax2=ktadaloc(0,3,klx2)
            klx2%dbody(1)=
     $           dtfcopy1(kxm2l(tampl,ntouckx,3,ntouckx,.true.))
            do i=1,ntouckx
              do j=1,ntouckz
                touckm(j,i,1)=touckm(j,i,1)*tf
                touckm(j,i,2)=touckm(j,i,2)*tf
              enddo
            enddo
            klx2%dbody(2)=dtfcopy1(kxm2l(touckm(1,1,1),
     $           ntouckz,ntouckx,ntouckz,.true.))
            klx2%dbody(3)=dtfcopy1(kxm2l(touckm(1,1,2),
     $           ntouckz,ntouckx,ntouckz,.true.))
c set list for toucke
            klx%rbody(1)=id
            klx%body(2)=ktflist+kax1
            klx%body(3)=ktflist+kax2
            klx%dbody(4)=dtfcopy1(
     $           kxm2l(toucke,ntouckl,nlat,ntouckl,.true.))
            call tflocal(klist(itoul))
            klist(itoul)=ktflist+kax
c            if(tfcheckelement(ktflist+kax,.true.))then
c              write(*,*)'itoul: ',itoul
c            endif
          endif
          pri=lfno .gt. 0
          if(pri)then
            if(caltouck)then
              write(lfno,*)
              do iii=0,(ntouckl-1)/5
                write(lfno,9104)((5*iii+i+1)*0.2d0,i=1,5)
 9104           format(
     1               ' Momentum acceptance:  ',5(f8.1,2x),'  %')
                do i=1,5
                  if(5*iii+i .le. ntouckl)then
                    tt=touckl(5*iii+i)*tf
                  else
                    tt=0.d0
                  endif
                  if(tt .ne. 0.d0)then
                    vout(i)=autofg(1.d0/tt,'9.6')
                  else
                    vout(i)='   ---'
                  endif
                enddo
                write(lfno,9105)(vout(i)(1:9),i=1,5)
 9105           format(
     1               ' Touschek lifetime:    ',5(a,1x),' sec')
              enddo
              write(lfno,*)
              write(lfno,'(a)')
     1             ' Touschek lifetime/100s for aperture '//
     1             '2Jx/(Nx**2 emitx'') + 2Jz/(Nz**2 emitz) < 1:'
              write(lfno,9131)'Nx',(int(tampl(k,1)),
     1             (max(0,min(999,
     $             nint(.01d0/touckm(m,k,1)))),m=1,ntouckz),
     1             k=1,ntouckx)
 9131         format(
     1             '  ',
     1             'Nz: 4.6 5.3   6 6.8 7.7 8.8  10  11  13  15',
     $             '  17  19  21  24  28  32  36  41  46  53',
     $             '  60  68  77  88 100'/
     1             '  ',a,
     1   '!---1---1---1---1---1---1---1---1---1---1---1---1',
     1   '---1---1---1---1---1---1---1---1---1---1---1---1---1'/,
     1             34(i4,'!',25(i4)/))
              write(lfno,'(a)')
     1             ' Touschek lifetime/100s for aperture '//
     1             '2Jy/(Ny**2 emitx'') + 2Jz/(Nz**2 emitz) < 1:'
              write(lfno,9131)'Ny',(int(tampl(k,2)),
     1             (max(0,min(999,
     $             nint(0.01d0/touckm(m,k,2)))),m=1,ntouckz),
     1             k=1,ntouckx)
            endif
          endif
        else
          intend=.true.
        endif
        if(intra)then
          write(lfno,*)'   Parameters with intrabeam scattering:'
        endif
        if(wspac)then
          write(lfno,*)'   Parameters with space charge:'
        endif
        vout(1)=autofg(pbunch ,'11.8')
        vout(2)=autofg(coumin*1.d2,'11.8')
        write(lfno,9103)(vout(i)(1:11),i=1,2)
 9103   format(  'Particles/bunch        =',a,'    ',
     $       1x,'Minimum coupling       =',a,' %  ')
        if(wspac)then
          write(lfno,*)
          trans=transs
          beam(1:21)=beams
          epi=.true.
          iret=3
        else
          iret=4
        endif
        return
      else
        caltouck=intra .and. de .lt. resib*10.d0 .and. .not. trpt
        pri=.false.
        if(calint)then
          if(intra)then
            rx=eintrb(emx0,emx,emxr)/emx
            ry=eintrb(emy0,emy,emyr)/emy
            rz=eintrb(emz0,emz,emzr)/emz
            rr=min(100.d0,max(0.01d0,(rx*ry*rz)**(1.d0/3.d0)))
            emx=emx*rr
            emy=emy*rr
            emz=emz*rr
          elseif(emx0 .ne. 0.d0)then
            if(it .ge. 20)then
              emxmax=min(max(emx,emx0),emxmax)
              emxmin=max(min(emx,emx0),emxmin)
              emx=sqrt(emxmax*emxmin)
            else
              emx=sqrt(emx*emx0)
            endif
            if(it .gt. 30)then
              emymax=min(max(emy,emy0),emymax)
              emymin=max(min(emy,emy0),emymin)
              emy=sqrt(emymax*emymin)
            else
              emy=sqrt(emy*emy0)
            endif
            emzmax=min(max(emz,emz0),emzmax)
            emzmin=max(min(emz,emz0),emzmin)
            emz=sqrt(emzmax*emzmin)
          endif
        else
          emxr=emx
          emyr=emy
          emzr=emz
        endif
        emx0=emx
        emy0=emy
        emz0=emz
        calint=.true.
c     ccintr=(rclassic/h0**2)**2/8.d0/pi
c     cintrb=ccintr*pbunch/emx/emy/emz
c     
c     cintrb=rclassic**2/8.d0/pi
c     1           *pbunch/(emx*h0)/(emy*h0)/(emz*h0)/h0
c     Here was the factor 2 difference from B-M paper.
c     Pointed out by K. Kubo on 6/18/2001.
c     
        cintrb=rclassic**2/4.d0/pi*pbunch
c     write(*,*)cintrb,emx,emy,emz
c        if(trpt)then
c          write(*,*)'tintraconv @ src/temit.f: ',
c     $          'Reference uninitialized emx1/emy1/emz1',
c     $          '(FIXME)'
c          stop
c        endif
        if(.not. trpt)then
          if(emx1 .gt. 0.01d0*emx)then
            rx=sqrt(emx/emx1)
          else
            emit(ia(1,1))=emx
            emit(ia(2,2))=emx
            rx=1.d0
          endif
          if(emy1 .gt. 0.01d0*emy)then
            ry=sqrt(emy/emy1)
          else
            emit(ia(3,3))=emy
            emit(ia(4,4))=emy
            ry=1.d0
          endif
          if(emz1 .gt. 0.01d0*emz)then
            rz=sqrt(emz/emz1)
          else
            emit(ia(5,5))=emz
            emit(ia(6,6))=emz
            rz=1.d0
          endif
          call tinitr(trans1)
          trans1(1,1)=rx
          trans1(2,2)=rx
          trans1(3,3)=ry
          trans1(4,4)=ry
          trans1(5,5)=rz
          trans1(6,6)=rz
c     write(*,*)'temit ',rx,ry,rx
c     write(*,*)'temit ',emy,emy1
          call tmulbs(emit,trans1,.false.,.false.)
          if(.not. synchm)then
            emit(ia(5,1))=0.d0
            emit(ia(5,2))=0.d0
            emit(ia(5,3))=0.d0
            emit(ia(5,4))=0.d0
            emit(ia(5,5))=sigz**2
            emit(ia(5,6))=0.d0
            emit(ia(6,6))=sige**2
            r(1,5)=0.d0
            r(2,5)=0.d0
            r(3,5)=0.d0
            r(4,5)=0.d0
            r(5,5)=1.d0
            r(6,5)=0.d0
            r(6,1)=0.d0
            r(6,2)=0.d0
            r(6,3)=0.d0
            r(6,4)=0.d0
            r(6,5)=0.d0
            r(6,6)=1.d0
            r(5,1)=0.d0
            r(5,2)=0.d0
            r(5,3)=0.d0
            r(5,4)=0.d0
            r(5,5)=1.d0
            r(5,6)=0.d0
          endif
          call tmulbs(emit,r,.false.,.false.)
          beam(22:42)=emit
          it=it+1
        else
          beam(22:42)=0.d0
          beam(1:21)=beamin
          it=itmax+1
        endif
        iret=2
        return
      endif
      iret=1
      return
      end

      subroutine tfetwiss(r,cod,twiss,lfno,pri)
      implicit none
      integer*4 lfno,i
      real*8 r(6,6),twiss(28),h(6,6),hi(6,6),cod(6)
      real*8 ax,ay,az,axy,f,
     $     uz11,uz12,uz21,uz22,
     $     hx11,hx12,hx21,hx22,
     $     hy11,hy12,hy21,hy22,
     $     r11,r12,r21,r22,
     $     crx,cry,crz,cx,cy,cz,sx,sy,sz,
     $     bx21,bx22,by21,by22,bz21,bz22
      character*9 autofg,vout(28)
      logical*4 pri
      az=sqrt(r(5,5)*r(6,6)-r(6,5)*r(5,6))
      uz11=r(5,5)/az
      uz12=r(5,6)/az
      uz21=r(6,5)/az
      uz22=r(6,6)/az
      hx11= r(6,2)*uz11-r(5,2)*uz21
      hx12= r(6,2)*uz12-r(5,2)*uz22
      hx21=-r(6,1)*uz11+r(5,1)*uz21
      hx22=-r(6,1)*uz12+r(5,1)*uz22
      hy11= r(6,4)*uz11-r(5,4)*uz21
      hy12= r(6,4)*uz12-r(5,4)*uz22
      hy21=-r(6,3)*uz11+r(5,3)*uz21
      hy22=-r(6,3)*uz12+r(5,3)*uz22
      f=1.d0/(1.d0+az)
      ax=1.d0-(hx11*hx22-hx21*hx12)*f
      ay=1.d0-(hy11*hy22-hy21*hy12)*f
      h(1,1)=ax
      h(1,2)=0.d0
      h(1,3)= (hx12*hy21-hx11*hy22)*f
      h(1,4)=(-hx12*hy11+hx11*hy12)*f
      h(1,5)=-hx11
      h(1,6)=-hx12
      h(2,1)= 0.d0
      h(2,2)= ax
      h(2,3)= (hx22*hy21-hx21*hy22)*f
      h(2,4)=(-hx22*hy11+hx21*hy12)*f
      h(2,5)=-hx21
      h(2,6)=-hx22
      h(3,1)= h(2,4)
      h(3,2)=-h(1,4)
      h(3,3)= ay
      h(3,4)= 0.d0
      h(3,5)=-hy11
      h(3,6)=-hy12
      h(4,1)=-h(2,3)
      h(4,2)= h(1,3)
      h(4,3)= 0.d0
      h(4,4)= ay
      h(4,5)=-hy21
      h(4,6)=-hy22
      h(5,1)= hx22
      h(5,2)=-hx21
      h(5,3)= hy22
      h(5,4)=-hy21
      h(5,5)= az
      h(5,6)= 0.d0
      h(6,1)=-hx12
      h(6,2)= hx11
      h(6,3)=-hy12
      h(6,4)= hy11
      h(6,5)= 0.d0
      h(6,6)= az
      call tinv(h,hi,6,6)
      call tmultr(hi,r,6)
      axy=sqrt(hi(1,1)*hi(2,2)-hi(2,1)*hi(1,2))
      r11=( hi(4,4)*hi(3,1)-hi(3,4)*hi(4,1))/axy
      r12=( hi(4,4)*hi(3,2)-hi(3,4)*hi(4,2))/axy
      r21=(-hi(4,3)*hi(3,1)+hi(3,3)*hi(4,1))/axy
      r22=(-hi(4,3)*hi(3,2)+hi(3,3)*hi(4,2))/axy
      crx=sqrt(hi(1,2)**2+hi(2,2)**2)
      cx= hi(2,2)/crx
      sx=-hi(1,2)/crx
      bx21=(-sx*hi(1,1)+cx*hi(2,1))/axy
      bx22=(-sx*hi(2,1)+cx*hi(2,2))/axy
      cry=sqrt(hi(3,4)**2+hi(4,4)**2)
      cy= hi(4,4)/cry
      sy=-hi(3,4)/cry
      by21=(-sy*hi(3,3)+cy*hi(4,3))/axy
      by22=(-sy*hi(4,3)+cy*hi(4,4))/axy
      crz=sqrt(uz12**2+uz22**2)
      cz= uz22/crz
      sz=-uz12/crz
      bz21=-sz*uz11+cz*uz21
      bz22=-sz*uz21+cz*uz22
      twiss(1)= bx21*bx22
      twiss(2)= bx22**2
      twiss(3)= atan2(sx,cx)
      twiss(4)= by21*by22
      twiss(5)= by22**2
      twiss(6)= atan2(sy,cy)
      twiss(7)= axy*hx12-r22*hy12+r12*hy22
      twiss(8)= axy*hx22+r21*hy12-r11*hy22
      twiss(9)= axy*hy12+r11*hx12+r12*hx22
      twiss(10)=axy*hy22+r21*hx12+r22*hx22
      twiss(11)=r11
      twiss(12)=r12
      twiss(13)=r21
      twiss(14)=r22
      twiss(15)=r11*r22-r12*r21
      twiss(16)=cod(1)
      twiss(17)=cod(2)
      twiss(18)=cod(3)
      twiss(19)=cod(4)
      twiss(20)=cod(5)
      twiss(21)=cod(6)
      twiss(22)=bz21*bz22
      twiss(23)=bz22**2
      twiss(24)=atan2(sz,cz)
      twiss(25)=axy*hx11-r22*hy11+r12*hy21
      twiss(26)=axy*hx21+r21*hy11-r11*hy21
      twiss(27)=axy*hy11+r11*hx11+r12*hx21
      twiss(28)=axy*hy21+r21*hx11+r22*hx21
      if(lfno .gt. 0 .and. pri)then
        do i=1,28
          vout(i)=autofg(twiss(i),'9.6')
        enddo
        write(lfno,9001)
     $       vout(1),vout(2),vout(25),vout(7),
     $       vout(3),vout(26),vout(8),
     $       vout(11),vout(12),vout(4),vout(5),vout(27),vout(9),
     $       vout(13),vout(14),vout(6),vout(28),vout(10),
     $       vout(22),vout(23),vout(24)
 9001   format('    Extended Twiss Parameters:',/,
     $       'AX:',a,' BX:',a,              26x,'  ZX:',a,'  EX:',a,/
     $          11x,'PSIX:',a,              26x,' ZPX:',a,' EPX:',a,/
     $       'R1:',a,' R2:',a,' AY:',a,' BY:',a,'  ZY:',a,'  EY:',a,/
     $       'R3:',a,' R4:',a,    12x,'PSIY:',a,' ZPY:',a,' EPY:',a,/
     $                                      51x,'  AZ:',a,'  BZ:',a,/
     $                                                65x,'PSIZ:',a,/
     $       '    Units: B(X,Y,Z), E(X,Y), R2: m ',
     $       '| PSI(X,Y,Z): radian | ZP(X,Y), R3: 1/m',/)
      endif
      return
      end

      subroutine tsymp(trans)
      implicit none
      integer*4 i,j
      real*8 trans(6,6),ri(6,7)
      call tinv(trans,ri,6,6)
      call tmultr(ri,trans,6)
      do 10 i=1,6
        do 20 j=1,6
          ri(j,i)=-ri(j,i)*.5d0
20      continue
        ri(i,i)=ri(i,i)+1.5d0
10    continue
      call tmultr(trans,ri,6)
      return
      end

      real*8 function eintrb(em0,y,emr)
      implicit none
      real*8 em0,y,emr,eps

      integer itmax
      parameter (eps=1.d-10,itmax=30)
      real*8 em,a,y1
      integer it

      em=em0
      a=(y-emr)*em0**2
      y1=y
      it=0
1     em=em+(y1-em)/(em**3+2.d0*a)*em**3
      y1=emr+a/em**2
      if(abs(y1-em) .lt. eps*em)then
        eintrb=min(100.d0*em0,max(emr,y1,0.01d0*em0))
        return
      endif
      it=it+1
      if(it .gt. itmax)then
        eintrb=min(100.d0*em0,max(0.01d0*em0,em))
        return
      endif
      go to 1
      end

      subroutine tinv(r,ri,n,ndim)
      implicit none
      integer*4 i,j,n,ndim
      real*8 r(ndim,n),ri(ndim,n)
      do 10 i=1,n-1,2
        do 20 j=1,n-1,2
          ri(i  ,j  )= r(j+1,i+1)
          ri(i  ,j+1)=-r(j  ,i+1)
          ri(i+1,j  )=-r(j+1,i  )
          ri(i+1,j+1)= r(j  ,i  )
20      continue
10    continue
      return
      end