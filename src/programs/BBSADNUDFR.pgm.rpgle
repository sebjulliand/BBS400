**FREE
/TITLE Administration - New User default values
Ctl-Opt COPYRIGHT('(C) 2020 David Asta under MIT License');
// SYSTEM      : V4R5
// PROGRAMMER  : David Asta
// DATE-WRITTEN: 25/NOV/2020
//
// This program allows an Administrator user to display/change the
//   New User default values
//*********************************************************************
/Include CBKOPTIMIZ
//*********************************************************************
// INDICATORS USED:
// 80 - *ON turns DSPATR(PR), which protects fields from being changed
// 81 - CBKPCFGREA CHAIN Not Found
//*********************************************************************
Dcl-F BBSADNUDFD WORKSTN;
Dcl-F PCONFIG    Usage(*Update:*Delete) Keyed;
//*********************************************************************
// Data structures
/Include CBKDTAARA
// Constants
Dcl-C cKeysDft        CONST('F10=Edit   F12=Go back');
Dcl-C cKeysEdit       CONST('F10=Confirm Changes   F12=Can-
cel');
Dcl-C cSavedOK        CONST('Configuration was changed suc-
cessfully.');
Dcl-C cSavedKO        CONST('There was an error while writ-
ting to PCONFIG.');
// Variables
/Include CBKPCFGDCL
Dcl-S wCfgKey         Char(6);
Dcl-S ATag            Char(14);
//*********************************************************************
Write HEADER;
If *In80;
  KEYSLS = cKeysDft;
Endif;
If not *In80;
  KEYSLS = cKeysEdit;
Endif;
Write FOOTER;
Exfmt BODY;
Clear MSGLIN;
Exsr CheckFkeys;
//*********************************************************************
// Subroutine called automatically at startup
//*********************************************************************
BegSr *INZSR;
  SCRSCR = 'BBSADNUDF';
  // Protect fields from being modified
  *IN80 = *ON;
  // Get values from PCONFIG and show them on screen
  Exsr GetConfig;
  SCRNUL = wCfgNUSLVL;
  SCRRNA = wCfgSvyRName;
  SCRGND = wCfgSvyGendr;
  SCRLOC = wCfgSvyLocat;
  SCREML = wCfgSvyEmail;
  SCRSVY = wCfgSurvey;
  // Get values from DATAARA and show them on screen
/Include CBKHEADER
EndSr;
//*********************************************************************
// Check Function keys pressed by the user
//*********************************************************************
BegSr CheckFkeys;
  // F10=Edit
  If *IN10 = *ON;
    // N80              EXSR      SavePCONFIG
    //  80              EVAL      *IN80 = *OFF
    If *IN80 = *ON;
      *IN80 = *OFF;
    Else;
      Exsr SavePCONFIG;
    EndIf;
  EndIf;
  // F12=Go back or F12=Cancel
  If *IN12 = *ON;
    If *In80;
      *INLR = *ON;
    Endif;
    If *In80;
      Return;
    Endif;
    If not *In80;
      *IN80 = *ON;
    Endif;
  EndIf;
EndSr;
//*********************************************************************
// Save changed values to PCONFIG
//*********************************************************************
BegSr SavePCONFIG;
  // Default Level
  If SCRNUL <> wCfgNUSLVL;
    wCfgKey = 'NUSLVL';
    Chain wCfgKey PCONFIG;
    *IN81 = not %Found;
    If not *In81;
      %Subst(CNFVAL:1:2) = %EditC(SCRNUL:'X');
    Endif;
    If not *In81;
      Update(e) CONFIG;
      *IN81 = %Error;
    Endif;
    If *In81;
      ATag = 'UPDKO';
    Endif;
  EndIf;
  If ATag = *Blanks;
    // Survey questions
    wCfgSvyRName = SCRRNA;
    wCfgSvyGendr = SCRGND;
    wCfgSvyLocat = SCRLOC;
    wCfgSvyEmail = SCREML;
    If SCRSVY <> wCfgSurvey;
      wCfgKey = 'NUSSVY';
      Chain wCfgKey PCONFIG;
      *IN81 = not %Found;
      If not *In81;
        CNFVAL = wCfgSurvey;
      Endif;
      If not *In81;
        Update(e) CONFIG;
        *IN81 = %Error;
      Endif;
      If *In81;
        ATag = 'UPDKO';
      Endif;
    EndIf;
  EndIf;
  If ATag = *Blanks;
    MSGLIN = cSavedOK;
    ATag = 'UPDEND';
  EndIf;
  If ATag = 'UPDKO' or ATag = *Blanks;
    ATag = *Blanks;
    MSGLIN = cSavedKO;
  EndIf;
  // branch when ATag = 'UPDEND'
  ATag = *Blanks;
  *IN80 = *ON;
EndSr;
//*********************************************************************
/Include CBKPCFGREA