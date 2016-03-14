      subroutine BEDGE(EANG)
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON /TMATR/TM(4,4),VM(4),TO(4,4),VO(4),TU(4,4),VU(4)
      COMMON /DELEM/DL,DKL0,DKL1,DKL2,CKL0X,CKL0Y,CKL1X,CKL1Y
c
      save
c
      CURV=DKL0/DL
      CALL ZEROV4(VM)
      CALL UNITM4(TM,1.)
      TM(2,1)=CURV*DTAN(EANG)
      TM(4,3)=-CURV*DTAN(EANG)
      CALL TROT(TM,VM,TETA,TO,VO)
         CKL0X=DCOS(TETA)*DKL0
         CKL0Y=-DSIN(TETA)*DKL0
         CKL1X=0.
         CKL1Y=0.
      RETURN
      END