      subroutine tqfrie(trans,cod,beam,ak,al,ld,bz)
      use tfstk
      implicit none
      include 'inc/TMACRO1.inc'
      integer*4 ld,i
      real*8 trans(6,12),cod(6),beam(42),ak,al,bz,akk,pr
      real*8 trans1(6,6),xmax
      real*8 xi,yi,aki,a,b,d,ab,t,dx1,dy1,xx,yy,h,f,bzh,pxi,pyi,
     $     px1,py1,dz1,dddx,dddy,dddp,dxxdx,dxxdy,dxxdp,
     $     dyydx,dyydy,dyydp,dhdx,dhdy,dhdp,dfdx,dfdy,dfdp,
     $     y,py
      parameter (xmax=1.d10)
      akk=ak/al/4.d0
      pr=1.d0+cod(6)
      if(irad .gt. 6)then
        trans1(1,2)=0.d0
        trans1(1,4)=0.d0
        trans1(1,5)=0.d0
        trans1(2,5)=0.d0
        trans1(3,2)=0.d0
        trans1(3,4)=0.d0
        trans1(3,5)=0.d0
        trans1(4,5)=0.d0
        trans1(5,5)=1.d0
        trans1(6,1)=0.d0
        trans1(6,2)=0.d0
        trans1(6,3)=0.d0
        trans1(6,4)=0.d0
        trans1(6,5)=0.d0
        trans1(6,6)=1.d0
      endif
      xi=min(xmax,max(-xmax,cod(1)))
      yi=min(xmax,max(-xmax,cod(3)))
      aki=akk/pr
      a=aki*xi**2
      b=aki*yi**2
      d=a+b
      ab=aki*(xi-yi)*(xi+yi)
      t=ab**2/6.d0
      dx1= xi*(a/3.d0+b+t)
      dy1=-yi*(a+b/3.d0-t)
      cod(1)=xi+dx1
      cod(3)=yi+dy1
      xx=1.d0+d+ab*(5.d0*a-b)/6.d0
      yy=1.d0-d+ab*(a-5.d0*b)/6.d0
      h=2.d0*aki*xi*yi*(1.d0-ab/3.d0)
      f=xx*yy+h**2
      bzh=.5d0*bz
      pxi=cod(2)+bzh*cod(3)
      pyi=cod(4)-bzh*cod(1)
      px1=(pxi*yy+pyi*h)/f
      py1=(pyi*xx-pxi*h)/f
      cod(2)=px1-bzh*yi
      cod(4)=py1+bzh*xi
      dz1=-(cod(2)*(dx1+t*xi)+cod(4)*(dy1+t*yi))/pr
      cod(5)=cod(5)+dz1
      dddx=2.d0*aki*xi
      dddy=2.d0*aki*yi
      dddp=-d/pr
      dxxdx=dddx+dddx*(5.d0*a/3.d0-b)
      dxxdy=dddy-dddy*(a-b/3.d0)
      dxxdp=dddp-ab*(5.d0*a-b)/3.d0/pr
      dyydx=-dddx+dddx*(a/3.d0-b)
      dyydy=-dddy-dddy*(a-5.d0*b/3.d0)
      dyydp=-dddp-ab*(a-5.d0*b)/3.d0/pr
      dhdx=dxxdy
      dhdy=-dyydx
      dhdp=-2.d0*aki*xi*yi*(1.d0-2.d0*ab/3.d0)/pr
      dfdx=dxxdx*yy+xx*dyydx+2.d0*h*dhdx
      dfdy=dxxdy*yy+xx*dyydy+2.d0*h*dhdy
      dfdp=dxxdp*yy+xx*dyydp+2.d0*h*dhdp
      trans1(1,1)=xx
      trans1(1,3)=h
      trans1(1,6)=-(dx1+xi*t)/pr
      trans1(3,1)=-h
      trans1(3,3)=yy
      trans1(3,6)=-(dy1+yi*t)/pr
      trans1(2,1)=(-px1*dfdx+pxi*dyydx+pyi*dhdx
     $     -bzh*h*(yy+xx))/f
      trans1(2,2)=yy/f
      trans1(2,3)=(-px1*dfdy+pxi*dyydy+pyi*dhdy
     $     +bzh*(yy-h)*(yy+h))/f-bzh
      trans1(2,4)=h/f
      trans1(2,6)=(-px1*dfdp+pxi*dyydp+pyi*dhdp
     $     +bzh*(yy*trans1(3,6)-h*trans1(1,6)))/f
      trans1(4,1)=(-py1*dfdx+pyi*dxxdx-pxi*dhdx
     $     -bzh*(xx-h)*(xx+h))/f+bzh
      trans1(4,2)=-h/f
      trans1(4,3)=(-py1*dfdy+pyi*dxxdy-pxi*dhdy
     $     -bzh*h*(xx+yy))/f
      trans1(4,4)=xx/f
      trans1(4,6)=(-py1*dfdp+pyi*dxxdp-pxi*dhdp
     $     -bzh*(xx*trans1(1,6)+h*trans1(3,6)))/f
      trans1(5,1)=-trans1(1,1)*trans1(2,6)+trans1(2,1)*trans1(1,6)
     $     -trans1(3,1)*trans1(4,6)+trans1(4,1)*trans1(3,6)
      trans1(5,2)=trans1(2,2)*trans1(1,6)+trans1(4,2)*trans1(3,6)
      trans1(5,3)=-trans1(1,3)*trans1(2,6)+trans1(2,3)*trans1(1,6)
     $     -trans1(3,3)*trans1(4,6)+trans1(4,3)*trans1(3,6)
      trans1(5,4)=trans1(2,4)*trans1(1,6)+trans1(4,4)*trans1(3,6)
      trans1(5,6)=-2.d0*(dz1-(cod(2)*xi+cod(4)*yi)*t/pr)/pr
      do i=1,irad
        y=trans(3,i)
        py=trans(4,i)
        trans(5,i)=trans(5,i)
     $       +trans1(5,1)*trans(1,i)+trans1(5,2)*trans(2,i)
     $       +trans1(5,3)*y+trans1(5,4)*py+trans1(5,6)*trans(6,i)
        trans(4,i)=trans1(4,1)*trans(1,i)+trans1(4,2)*trans(2,i)
     $       +trans1(4,3)*y+trans1(4,4)*py+trans1(4,6)*trans(6,i)
        trans(2,i)=trans1(2,1)*trans(1,i)+trans1(2,2)*trans(2,i)
     $       +trans1(2,3)*y+trans1(2,4)*py+trans1(2,6)*trans(6,i)
        trans(3,i)=trans1(3,1)*trans(1,i)+trans1(3,3)*y
     $       +trans1(3,6)*trans(6,i)
        trans(1,i)=trans1(1,1)*trans(1,i)+trans1(1,3)*y
     $       +trans1(1,6)*trans(6,i)
      enddo
      if(irad .gt. 6 .or. calpol)then
        call tmulbs(beam,trans1,.true.,.true.)
      endif
      if(calpol)then
        call polpar(0,ld,0.d0,0.d0,0.d0,0.d0,0.d0,cod)
      endif
      return
      end