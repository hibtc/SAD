      subroutine tsgeo(latt,gammab,k,ke,ke1,geo,pos,sol)
      use tfstk
      use ffs
      use tffitcode
      implicit none
      real*8 conv
      parameter (conv=3.d-16)
      integer*4 latt(2,nlat),i,kg,k1,k2,lp,le,idir,i0,i1,lt,
     $     led,mfr,ll,j,l1,lenw,l2,kbz
      real*8 geo(3,4,nlat),geo1(3,3),geos(3,4),pos(nlat),
     $     pzf,trans(6,12),cod(6),beam(42),gammab(nlat),
     $     db,bzs,bzs0,psi1,psi2,phi,apsi1,apsi2,
     $     chi1,chi2,cschi1,snchi1,cschi2,snchi2,chi3,
     $     cschi3,snchi3,g1,xi,yi,pxi,pyi,al,pzi,fb1,fb2,
     $     ak,sinphi,a22,a12,a14,a24,dx,pxf,dy,pyf,zf,
     $     theta,akk,f1,f2,gf,dvf,dl,f,dir,tfbzs,pos0,
     $     chi2i,cchi2i,schi2i,chi1i,cchi1i,schi1i,ds,
     $     s1,s2,s3,u,v,w,phix,phiy,xf,yf,g2,tfchi,gi,
     $     chi1m,chi2m
      integer*4 k,ke,ke1
      logical*4 sol,dirf
      sol=.true.
      l1=latt(2,k)
      kg=0
      if(rlist(latt(2,k)+8) .eq. 0.d0)then
        go to 12
      endif
      if(rlist(latt(2,k)+12) .ne. 0.d0)then
        kg=k
      endif
      do 10 i=k+1,nlat-1
        if(idtype(latt(1,i)) .eq. icSOL)then
          if(rlist(latt(2,i)+8) .ne. 0.d0)then
            if(rlist(latt(2,i)+12) .ne. 0.d0)then
              kg=i
            endif
            ke=i
            go to 20
          endif
        endif
10    continue
12    write(*,*)' Missing BOUND of Solenoid ',
     $     pname(latt(1,k))(1:lenw(pname(latt(1,k))))
      sol=.false.
      return
20    if(kg .eq. 0)then
        write(*,*)' Missing GEO of Solenoid ',
     $     pname(latt(1,k))(1:lenw(pname(latt(1,k))))
        sol=.false.
        return
      endif
      l2=latt(2,ke)
      if(kg .eq. k)then
        k1=k
        k2=ke
        lp=l1
        le=l2
        dir=1.d0
        idir=1
        ke1=ke+1
      else
        k1=ke
        k2=k
        lp=l2
        le=l1
        dir=-1.d0
        idir=-1
        ke1=ke+1
      endif
      rlist(lp+kytbl(kwDZ,icSOL))=0.d0
      chi1=rlist(lp+kytbl(kwDPX,icSOL))
      chi2=rlist(lp+kytbl(kwDPY,icSOL))
      cschi1=cos(chi1)
      snchi1=sin(chi1)
      cschi2=cos(chi2)
      snchi2=sin(chi2)
      if(idir .gt. 0)then
        bzs=tfbzs(k1,kbz)
        chi3=tfchi(geo(1,1,k),3)
        cschi3=cos(chi3)
        snchi3=sin(chi3)
        do 110 i=1,3
          geo1(i,1)= geo(i,1,k)*cschi3+geo(i,2,k)*snchi3
          geo1(i,2)=-geo(i,1,k)*snchi3+geo(i,2,k)*cschi3
          geo(i,1,k+1)=geo1(i,1)
          geo(i,2,k+1)=geo1(i,2)
          geo(i,3,k+1)=geo(i,3,k)
          geo(i,4,k+1)=geo(i,4,k)
          g1       = geo1(i,2)*snchi2+geo(i,3,k)*cschi2
          geo1(i,2)= geo1(i,2)*cschi2-geo(i,3,k)*snchi2
          geo1(i,3)= g1*cschi1+geo1(i,1)*snchi1
          geo1(i,1)=-g1*snchi1+geo1(i,1)*cschi1
110     continue
        call tgrot(rlist(l1+kytbl(kwCHI1,icSOL)),geo(1,1,k),geo1)
        pos0=0
        pos(k+1)=pos(k)
      else
        bzs=tfbzs(k1-1,kbz)
        call tclr(geo1,9)
        geo1(2,1)=-1.d0
        geo1(3,2)=-1.d0
        geo1(1,3)=1.d0
        call tmov(geo(1,1,k),geos,12)
        geo(1,1,ke)= snchi1
        geo(2,1,ke)=-cschi1
        geo(3,1,ke)=0.d0
        geo(1,2,ke)= snchi2*cschi1
        geo(2,2,ke)= snchi2*snchi1
        geo(3,2,ke)=-cschi2
        geo(1,3,ke)= cschi2*cschi1
        geo(2,3,ke)= cschi2*snchi1
        geo(3,3,ke)= snchi2
        geo(1,4,ke)= 0.d0
        geo(2,4,ke)= 0.d0
        geo(3,4,ke)= 0.d0
        call tgrot(rlist(l2+kytbl(kwCHI1,icSOL)),geo1,geo(1,1,ke))
        pos0=pos(k)
        pos(k1)=0.d0
      endif
      xi=rlist(latt(2,k1)+kytbl(kwDX,icSOL))
      yi=rlist(latt(2,k1)+kytbl(kwDY,icSOL))
      pxi=-snchi1*cschi2
      pyi=-snchi2
      led=idval(latt(1,k2))
      ds=0.d0
      gi=0.d0
      if(rlist(latt(2,k1)+kytbl(kwFRIN,icSOL)) .eq. 0.d0)then
        call tsfrin(1,xi,pxi,yi,pyi,ds,gi,bzs)
        ds=-ds*dir
      endif
      pxi=pxi+yi*bzs*.5d0
      pyi=pyi-xi*bzs*.5d0
      do 1010 i=k1+idir,k2,idir
        i0=i+(1-idir)/2
        i1=2*i+1-i0
        lt=idtype(latt(1,i))
        if(lt .eq. icDRFT)then
          al=rlist(latt(2,i)+1)
          pzi=1.d0
     1       -(pxi**2+pyi**2)/(1.d0+sqrt((1.d0-pyi)*(1.d0+pyi)-pxi**2))
          phi=al*bzs/pzi*dir
          ak=bzs
          sinphi=sin(phi)
          a22= cos(phi)
          if(ak .eq. 0.d0)then
            a12=al/pzi*dir
            a14=0.d0
          else
            a12= sinphi/ak
            if(a22 .ge. 0.d0)then
              a14=a12*sinphi/(1.d0+a22)
            else
              a14=(1.d0-a22)/ak
            endif
c            a14= 2.d0*sin(phi*.5d0)**2/ak
          endif
          a24= sinphi
          dx = a12*pxi+a14*pyi
          pxf= a22*pxi+a24*pyi
          dy =-a14*pxi+a12*pyi
          pyf=-a24*pxi+a22*pyi
          dl=(pxi**2+pyi**2)/pzi/(1.d0+pzi)*al
          xi=xi+dx
          yi=yi+dy
        elseif(lt .eq. icBEND)then
          ll=latt(2,i)
          al=rlist(ll+1)
          phi=rlist(ll+2)
          theta=rlist(ll+kytbl(kwROT,icBEND))
          phiy=phi*cos(theta)
          phix=phi*sin(theta)
          f=.5d0*bzs
          xf=xi
          pxf=(pxi-f*yi)*dir
          yf=yi
          pyf=(pyi+f*xi)*dir
          zf=0.d0
          gf=0.d0
          dvf=0.d0
          call tdrift(1,xf,pxf,yf,pyf,zf,gf,dvf,pzf,al,bzs*dir,
     $         phiy,phix)
          pxf=pxf*dir+f*yf
          pyf=pyf*dir-f*xf
          dl=-zf
          dx=xf-xi
          dy=yf-yi
          xi=xf
          yi=yf
        elseif(lt .eq. icQUAD)then
          ll=latt(2,i)
          al=rlist(ll+1)
          xf=xi
          f=.5d0*bzs
          pxf=(pxi-f*yi)*dir
          yf=yi
          pyf=(pyi+f*xi)*dir
          zf=0.d0
          theta=rlist(ll+4)
          akk=rlist(ll+2)/al
          f1=-akk*rlist(ll+10)*abs(rlist(ll+10))/24.d0
          f2=akk*rlist(ll+11)
          rlist(ll+ilist(1,ll))=rlist(ll+ilist(1,ll))*dir
          dirf=rlist(ll+ilist(1,ll)) .gt. 0.d0
          if(dirf)then
            mfr=nint(rlist(ll+12))
          else
            mfr=nint(rlist(ll+12))
            mfr=mfr*(11+mfr*(2*mfr-9))/2
          endif
          gf=0.d0
          dvf=0.d0
          call tquads(1,xf,pxf,yf,pyf,zf,gf,dvf,pzf,
     $         al,rlist(ll+2),bzs*dir,
     $         rlist(ll+5),rlist(ll+6),theta,
     1         cos(theta),sin(theta),
     1         1.d0,rlist(ll+9) .eq. 0.d0,
     $         f1,f2,mfr,rlist(ll+kytbl(kwF1,icQuad)),
     $         rlist(ll+13),i,dirf)
          rlist(ll+ilist(1,ll))=rlist(ll+ilist(1,ll))*dir
          pxf=pxf*dir+f*yf
          pyf=pyf*dir-f*xf
          dl=-zf
          dx=xf-xi
          dy=yf-yi
          xi=xf
          yi=yf
        elseif(lt .eq. icMULT)then
          ll=latt(2,i)
          al=rlist(ll+1)
          f=bzs*.5d0
          cod(1)=xi
          cod(2)=(pxi-f*yi)*dir
          cod(3)=yi
          cod(4)=(pyi+f*xi)*dir
          cod(5)=0.d0
          cod(6)=0.d0
          rlist(ll+ilist(1,ll))=rlist(ll+ilist(1,ll))*dir
          dirf=rlist(ll+ilist(1,ll)) .gt. 0.d0
          phi=rlist(ll+kytbl(kwANGL,icMULT))
          mfr=nint(rlist(ll+kytbl(kwFRMD,icMULT)))
          if(dirf)then
            psi1=rlist(ll+kytbl(kwE1,icMULT))
            psi2=rlist(ll+kytbl(kwE2,icMULT))
            apsi1=rlist(ll+kytbl(kwAE1,icMULT))
            apsi2=rlist(ll+kytbl(kwAE2,icMULT))
            fb1=rlist(ll+kytbl(kwFB1,icMULT))
            fb2=rlist(ll+kytbl(kwFB2,icMULT))
            chi1m=rlist(ll+kytbl(kwCHI1,icMULT))
            chi2m=rlist(ll+kytbl(kwCHI2,icMULT))
          else
            mfr=mfr*(11+mfr*(2*mfr-9))/2
            psi1=rlist(ll+kytbl(kwE2,icMULT))
            psi2=rlist(ll+kytbl(kwE1,icMULT))
            apsi1=rlist(ll+kytbl(kwAE2,icMULT))
            apsi2=rlist(ll+kytbl(kwAE1,icMULT))
            fb2=rlist(ll+kytbl(kwFB1,icMULT))
            fb1=rlist(ll+kytbl(kwFB2,icMULT))
            chi1m=-rlist(ll+kytbl(kwCHI1,icMULT))
            chi2m=-rlist(ll+kytbl(kwCHI2,icMULT))
          endif
c          if(chi1m .ne. 0.d0)then
c            write(*,*)'tsgeo ',i,chi1m,dirf,dir
c          endif
          call tclr(beam,21)
          call tclr(trans,36)
          bzs=bzs*dir
          call tmulte(trans,cod,beam,gammab,i,
     $         al,rlist(ll+kytbl(kwK0,icMULT)),bzs,
     $         phi,psi1,psi2,apsi1,apsi2,
     $         rlist(ll+3),rlist(ll+4),rlist(ll+5)*dir,
     $         chi1m,chi2m,rlist(ll+8),
     $         0.d0,
     1         rlist(ll+9),.false.,rlist(ll+11) .eq. 0.d0,
     $         rlist(ll+12),rlist(ll+13),mfr,fb1,fb2,
     $         rlist(lp+kytbl(kwK0FR,icMULT)) .eq. 0.d0,
     $         rlist(ll+15),rlist(ll+16),
     $         rlist(ll+17),rlist(ll+18),0.d0,1.d0,
     $         0)
          rlist(ll+ilist(1,ll))=rlist(ll+ilist(1,ll))*dir
          xf=cod(1)
          yf=cod(3)
          pxf=cod(2)*dir+f*yf
          pyf=cod(4)*dir-f*xf
          bzs=bzs*dir
          dl=-cod(5)
          dx=xf-xi
          dy=yf-yi
          xi=xf
          yi=yf
        elseif(lt .eq. icSOL)then
          al=0.d0
          dx=0.d0
          dy=0.d0
          dl=0.d0
          ll=latt(2,i)
          if(rlist(ll+8) .eq. 0.d0)then
            bzs0=bzs
            if(idir .lt. 0)then
              bzs=tfbzs(i-1,kbz)
            else
              bzs=tfbzs(i,kbz)
            endif
            db=bzs-bzs0
            if(rlist(ll+kytbl(kwFRIN,icSOL)) .eq. 0.d0)then
              pxf=pxi-yi*bzs0*.5d0
              pyf=pyi+xi*bzs0*.5d0
              gi=0.d0
              xf=xi
              yf=yi
              call tsfrin(1,xf,pxf,yf,pyf,dl,gi,db)
              dx=xf-xi
              dy=yf-yi
              xi=xf
              yi=yf
              dl=-dl
              pxf=pxf+yi*bzs*.5d0
              pyf=pyf-xi*bzs*.5d0
            else
              pxf=pxi+yi*db*.5d0
              pyf=pyi-xi*db*.5d0
            endif
            call tclr(rlist(ll+3),10)
          else
            pxf=pxi-yi*bzs*.5d0
            pyf=pyi+xi*bzs*.5d0
            if(rlist(ll+kytbl(kwFRIN,icSOL)) .eq. 0.d0)then
              gi=0.d0
              xf=xi
              yf=yi
              call tsfrin(1,xf,pxf,yf,pyf,dl,gi,-bzs)
              dx=xf-xi
              dy=yf-yi
              xi=xf
              yi=yf
              dl=-dl
            endif
          endif
        else
          al=0.d0
          dx=0.d0
          pxf=pxi
          dy=0.d0
          pyf=pyi
          dl=0.d0
        endif
        chi2i =-asin(min(1.d0,max(-1.d0,pyf)))
        cchi2i=cos(chi2i)
        schi2i=sin(chi2i)
        chi1i =-asin(min(1.d0,max(-1.d0,pxf/cchi2i)))
        cchi1i=cos(chi1i)
        schi1i=sin(chi1i)
        do 1020 j=1,3
          geo(j,4,i1)=geo(j,4,i0)+geo1(j,3)*al*dir
     1               +geo1(j,1)*dx+geo1(j,2)*dy
          geo(j,1,i1)= cchi1i*geo1(j,1)+schi1i*geo1(j,3)
          g1         =-schi1i*geo1(j,1)+cchi1i*geo1(j,3)
          geo(j,3,i1)= cchi2i*g1-schi2i*geo1(j,2)
          geo(j,2,i1)= schi2i*g1+cchi2i*geo1(j,2)
1020    continue
        pxi=pxf
        pyi=pyf
        pos(i1)=pos(i0)+(al+dl)*dir
        ds=ds+dl
1010  continue
      rlist(led+3)=xi
      rlist(led+4)=yi
      rlist(led+5)=ds
      rlist(le+3)=xi
      rlist(le+4)=yi
      rlist(le+5)=ds
      if(idir .gt. 0)then
        chi3=tfchi(geo(1,1,ke1),3)
        cschi3= cos(chi3)
        snchi3= sin(chi3)
        call trotg(geo(1,1,ke1),geo(1,3,ke1),cschi3,snchi3)
        call tgrot(rlist(l2+kytbl(kwCHI1,icSOL)),geo1,geo(1,1,ke1))
      else
        s1=geo(1,1,ke)*geo(1,1,k)+geo(2,1,ke)*geo(2,1,k)
     1       +geo(3,1,ke)*geo(3,1,k)
        s2=geo(1,1,ke)*geo(1,2,k)+geo(2,1,ke)*geo(2,2,k)
     1       +geo(3,1,ke)*geo(3,2,k)
        s3=geo(1,1,ke)*geo(1,3,k)+geo(2,1,ke)*geo(2,3,k)
     1       +geo(3,1,ke)*geo(3,3,k)
        u=s1*geos(3,1)+s2*geos(3,2)
        v=s1*geos(3,2)-s2*geos(3,1)
        w=s3*geos(3,3)
        if(u .eq. 0.d0)then
          if(v .eq. 0.d0)then
            snchi3=0.d0
          else
            snchi3=-w/v
          endif
          cschi3=sqrt(1.d0-snchi3**2)
        else
          if(v .ge. 0.d0)then
            snchi3=(-v*w-u*sqrt(u**2+(v-w)*(v+w)))/(u**2+v**2)
            cschi3=(-u*w+v*sqrt(u**2+(v-w)*(v+w)))/(u**2+v**2)
          else
            snchi3=(-v*w+u*sqrt(u**2+(v-w)*(v+w)))/(u**2+v**2)
            cschi3=(-u*w-v*sqrt(u**2+(v-w)*(v+w)))/(u**2+v**2)
          endif
        endif
c         write(*,*)'tsgeo ',u,v,w,cschi3,snchi3
c        chi3=tfchi(geos,3)
c        cschi3=cos(chi3)
c        snchi3=sin(chi3)
        do 230 j=1,3
          geo1(j,1)= cschi3*geos(j,1)+snchi3*geos(j,2)
          geo1(j,2)=-snchi3*geos(j,1)+cschi3*geos(j,2)
          geo1(j,3)=geos(j,3)
230     continue
        do 210 i=k+1,ke
          pos(i)=pos0+(pos(i)-pos(k))
          geo(1,4,i)=geo(1,4,i)-geo(1,4,k)
          geo(2,4,i)=geo(2,4,i)-geo(2,4,k)
          geo(3,4,i)=geo(3,4,i)-geo(3,4,k)
          do 220 j=1,4
            s1=geo(1,j,i)*geo(1,1,k)+geo(2,j,i)*geo(2,1,k)
     1        +geo(3,j,i)*geo(3,1,k)
            s2=geo(1,j,i)*geo(1,2,k)+geo(2,j,i)*geo(2,2,k)
     1        +geo(3,j,i)*geo(3,2,k)
            s3=geo(1,j,i)*geo(1,3,k)+geo(2,j,i)*geo(2,3,k)
     1        +geo(3,j,i)*geo(3,3,k)
            geo(1,j,i)=s1*geo1(1,1)+s2*geo1(1,2)+s3*geo1(1,3)
            geo(2,j,i)=s1*geo1(2,1)+s2*geo1(2,2)+s3*geo1(2,3)
            geo(3,j,i)=s1*geo1(3,1)+s2*geo1(3,2)+s3*geo1(3,3)
220       continue
          geo(1,4,i)=geo(1,4,i)+geos(1,4)
          geo(2,4,i)=geo(2,4,i)+geos(2,4)
          geo(3,4,i)=geo(3,4,i)+geos(3,4)
210     continue
        pos(k)=pos0
        pos(ke+1)=pos(ke)
        do 240 j=1,3
          g1=geo1(j,1)
          g2=geo1(j,2)
          geo1(j,1)=-geo(2,1,k)*g1-geo(2,2,k)*g2
     1              -geo(2,3,k)*geo1(j,3)
          geo1(j,2)=-geo(3,1,k)*g1-geo(3,2,k)*g2
     1              -geo(3,3,k)*geo1(j,3)
          geo1(j,3)= geo(1,1,k)*g1+geo(1,2,k)*g2
     1              +geo(1,3,k)*geo1(j,3)
240     continue
        call tmov(geos,geo(1,1,k),12)
        call tgrot(rlist(l1+kytbl(kwCHI1,icSOL)),geos,geo1)
        call tmov(geo(1,1,ke),geo(1,1,ke+1),12)
      endif
      return
      end