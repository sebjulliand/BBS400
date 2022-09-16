**FREE
/TITLE Administration Menu
Ctl-Opt COPYRIGHT('(C) 2020 David Asta under MIT License');
// SYSTEM      : V4R5
// PROGRAMMER  : David Asta
// DATE-WRITTEN: 26/NOV/2020
//
// This program shows the Administration Menu to a logged in SysOp
//*********************************************************************
// INDICATORS USED:
// 33 - *ON = BBS is in Maintenance Mode
//*********************************************************************
/Include CBKOPTIMIZ
//*********************************************************************
Dcl-F BBSADMMNUD WORKSTN;
Dcl-F PCONFIG    Usage(*Update:*Delete) Keyed;
//*********************************************************************
// Data structures
/Copy CBKDTAARA
// Variables
Dcl-S wCfgKey         Char(6);
Dcl-S wMode           Char(1);
// Prototype for BBSAACCLVR
Dcl-Pr Pgm_BBSAACCLVR ExtPgm('BBSAACCLVR') End-Pr;
// Prototype for BBSADGCR
Dcl-Pr Pgm_BBSADGCR ExtPgm('BBSADGCR') End-Pr;
// Prototype for BBSADNUDFR
Dcl-Pr Pgm_BBSADNUDFR ExtPgm('BBSADNUDFR') End-Pr;
// Prototype for BBSBRDLR
Dcl-Pr Pgm_BBSBRDLR ExtPgm('BBSBRDLR');
  wMode           Char(1);
End-Pr;
// Prototype for BBSETPGMSR
Dcl-Pr Pgm_BBSETPGMSR ExtPgm('BBSETPGMSR');
  wMode           Char(1);
End-Pr;
// Prototype for BBSIFSFILR
Dcl-Pr Pgm_BBSIFSFILR ExtPgm('BBSIFSFILR');
  wMode           Char(1);
End-Pr;
// Prototype for BBSLSTUSRR
Dcl-Pr Pgm_BBSLSTUSRR ExtPgm('BBSLSTUSRR');
  wMode           Char(1);
End-Pr;
// Prototype for BBSPOLLSLR
Dcl-Pr Pgm_BBSPOLLSLR ExtPgm('BBSPOLLSLR');
  wMode           Char(1);
End-Pr;
//*********************************************************************
Write HEADER;
Write FOOTER;
Exfmt MNUADM;
Exsr CheckFkeys;
//*********************************************************************
// Subroutine called automatically at startup
//*********************************************************************
BegSr *INZSR;
  SCRSCR = 'BBSADMMNU';
  // Get values from DTAARA and show them on the screen
/Include CBKHEADER
  Exsr UpdMaintOnScr;
EndSr;
//*********************************************************************
// Check Functions keys pressed by user
//*********************************************************************
BegSr CheckFkeys;
  Select;
    When *IN12 = *ON;
      // F12=Go back
      *INLR = *ON;
      Return;
    When *IN13 = *ON;
      // F13=General configuration
      Pgm_BBSADGCR();
    When *IN14 = *ON;
      // F14=Boards & Sub-Boards
      wMode = 'A';
      Pgm_BBSBRDLR(wMode);
    When *IN15 = *ON;
      // F15=Users Management
      wMode = 'M';
      Pgm_BBSLSTUSRR(wMode);
    When *IN16 = *ON;
      // F16=Access Levels
      Pgm_BBSAACCLVR();
    When *IN17 = *ON;
      // F17=Polls
      wMode = 'A';
      Pgm_BBSPOLLSLR(wMode);
    When *IN18 = *ON;
      // F18=New User default values
      Pgm_BBSADNUDFR();
    When *IN19 = *ON;
      // F19=Text Files (IFS)
      wMode = 'A';
      Pgm_BBSIFSFILR(wMode);
    When *IN20 = *ON;
      // F20=External Programs
      wMode = 'A';
      Pgm_BBSETPGMSR(wMode);
    When *IN24 = *ON;
      // F24=Set Maintenance Mode ON/OFF
      wCfgKey = 'MAINTM';
      Chain wCfgKey PCONFIG;
      *IN41 = not %Found;
      If *In41;
        Dsply 'ERROR 41';
      Endif;
      If *In41;
        LeaveSr;
      Endif;
      If *In33;
        CNFVAL = 'N';
      Endif;
      If *In33;
        wMAINTM = 'N';
      Endif;
      If not *In33;
        CNFVAL = 'Y';
      Endif;
      If not *In33;
        wMAINTM = 'Y';
      Endif;
      Update(e) CONFIG;
      *IN41 = %Error;
      If not *In41;
        Exsr UpdMaintOnScr;
      Endif;
  EndSl;
EndSr;
//*********************************************************************
// Update Maintenance Mode on Screen
//*********************************************************************
BegSr UpdMaintOnScr;
  If wMAINTM = 'Y';
    *IN33 = *ON;
  Else;
    *IN33 = *OFF;
  EndIf;
EndSr;