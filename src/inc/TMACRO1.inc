c     Don't confuse, Emacs. This is -*- fortran -*- mode!
      integer*8 iwakepold
      integer*4 nflag,nlat,np0,nturn,isynch,lspect,nspect,
     $     lplot,nplot,nuse,nclas,irad,novfl,
     $     npelm,ipelm,ipoltr,ipolb,ipoll,ipolid,ipolo,
     $     ilattp,nparallel,pspac_nx,pspac_ny,pspac_nz,
     $     pspac_nturn,pspac_nturncalc
      include 'inc/MACPHYS.inc'
      real*8 c,hp,e
      parameter (c=cveloc,hp=plankr,e=elemch)
      parameter (nflag=64)
      include 'inc/MACCODE.inc'
      include 'inc/MACKW.inc'
      include 'inc/MACFILE.inc'
      logical*4
     $     rad,rfsw,radcod,calcod      ,trpt,emiout,gauss,
     $     bipol,cell,flags,fseed,dapert,ideal,intra,calint,codplt,
     $     convgo,calpol,rfluct,cmplot,fourie,ffsprmpt,trsize,
     $     simulate,absweit,jitter,trgauss,lwake,twake,smearp,
     $     bunchsta,caltouck,canon,cellstab,spac,tparaed,radlight,
     $     oldflagsdummy,geocal,photons,wspac,selfcod,pspac,
     $     convcase,preservecase,lossmap,orbitcal,radtaper,sorg
      real*8
     $     amass,charge,h0,p0,omega0,trf0,crad,erad,epsrad,
     $     codin(6),dleng,anrad,urad,u0,vc0,hvc0,dp0,brho,
     $     ccintr,cintrb,pbunch,coumin,re0,pgev,emidiv,
     $     emidib,emidiq,emidis,ctouck,dvemit,h1emit,
     $     anbunch,tdummy(6),zlost,alost,
     $     taurdx,taurdy,taurdz,fridiv,beamin(21),
     $     vccos,vcsin,vcphic,vcalpha,vceff,
     $     pspac_dx,pspac_dy,pspac_dz,dvfs,rcratio,rclassic,brhoz,
     $     dummycom(114)
      common /tparm/
     $     amass,charge,h0,p0,omega0,trf0,crad,erad,epsrad,
     $     codin,dleng,anrad,urad,u0,vc0,hvc0,dp0,brho,
     $     ccintr,cintrb,pbunch,coumin,re0,pgev,emidiv,
     $     emidib,emidiq,emidis,ctouck,dvemit,h1emit,
     $     anbunch,tdummy,zlost,alost,
     $     taurdx,taurdy,taurdz,fridiv,beamin,
     $     vccos,vcsin,vcphic,vcalpha,vceff,
     $     pspac_dx,pspac_dy,pspac_dz,dvfs,rcratio,rclassic,brhoz,
     $     dummycom
c      integer*4 ntouckl,ntouckx,ntouckz
c      parameter (ntouckl=120,ntouckx=34,ntouckz=25)
c      real*8
c     $     touckm(ntouckz,ntouckx,3),tampl(ntouckx,3),touckl(ntouckl),
c     $     toucke(ntouckl,6000)
c      common /intr/ touckm,tampl,touckl,toucke
      common /itparm/ iwakepold,
     $     nlat,np0,nturn,isynch,lspect,nspect,lplot,nplot,
     $     nuse,nclas,irad,oldflagsdummy(32),
     $     novfl,calint,
     $     npelm,ipelm,ipoltr,ipolb,ipoll,ipolid,ipolo,
     $     caltouck,ilattp,tparaed,nparallel,
     $     pspac_nx,pspac_ny,pspac_nz,pspac_nturn,pspac_nturncalc
      common /tflagscom/flags(nflag)
      character*8 fname(nflag),sino(nflag)
      common /tfnamecom/ fname,sino
      equivalence
     $     (flags(1),rad),(flags(2),rfsw),(flags(3),radcod),
     $     (flags(4),calcod),(flags(5),intra),(flags(6),trpt),
     $     (flags(7),emiout),(flags(8),gauss),(flags(9),bipol),
     $     (flags(10),cell),(flags(11),ffsprmpt),(flags(12),dapert),
     $     (flags(13),fseed),(flags(14),ideal),(flags(15),codplt),
     $     (flags(16),canon),(flags(17),calpol),(flags(18),rfluct),
     $     (flags(19),cmplot),(flags(20),fourie),(flags(21),trsize),
     $     (flags(22),simulate),(flags(23),absweit),(flags(24),jitter),
     $     (flags(25),trgauss),(flags(26),lwake),(flags(27),twake),
     $     (flags(28),smearp),(flags(29),bunchsta),(flags(30),convgo),
     $     (flags(31),cellstab),(flags(32),spac),(flags(33),radlight),
     $     (flags(34),geocal),(flags(35),photons),(flags(36),wspac),
     $     (flags(37),selfcod),(flags(38),pspac),(flags(39),convcase),
     $     (flags(40),preservecase),(flags(41),lossmap),
     $     (flags(42),orbitcal),(flags(43),radtaper),(flags(44),sorg)