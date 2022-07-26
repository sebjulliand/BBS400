**FREE
/TITLE List all Access Levels and allow to add/edit/delete
Ctl-Opt COPYRIGHT('(C) 2020 David Asta under MIT License');
// SYSTEM      : V4R5
// PROGRAMMER  : David Asta
// DATE-WRITTEN: 20/NOV/2020
//
// This program shows the list of Access Levels, and allows to edit or
//   delete them, as well as add new ones
//*********************************************************************
/Include CBKOPTIMIZ
//*********************************************************************
// INDICATORS USED:
// 25 - Roll key
// 40 - SFLDSP
// 41 - SFLCLR
// 42 - SFLEND(*MORE)
//*********************************************************************
Dcl-F BBSAACCLVD WORKSTN
                         SFILE(SF:wRRN);
Dcl-F PACCLVS    Usage(*Update:*Delete:*Output) Keyed;
//*********************************************************************
// Data structures
/Include CBKDTAARA
// Constants
Dcl-C wErrDuplAccLvl  CONST('Access Level already exists');
Dcl-C wOptsLin1       CONST(' 4=Delete   7=Rename    8=Cha-
nge Expire days     9=Change Expire -
to Lvl');
Dcl-C wOptsLin2       CONST('10=Switch List Users   11=Swi-
tch System Info.   12=Switch Post...-
');
Dcl-C wOptsLin3       CONST('13=Switch Message Users      -
        14=Switch See Who''s Online.-
..');
// Variables
Dcl-S wRRN            Packed(4:0);
Dcl-S wOptions        Ind             INZ(*ON);
Dcl-S wPtr            Pointer;
Dcl-S wYesNo          Char(1)         BASED(wPtr);
Dcl-S wWinMode        Char(1);
Dcl-S wWinText        Char(30);
Dcl-S wWinNumber      Packed(3:0);
Dcl-S wWinF3          Ind;
Dcl-S wAccLvlD        Packed(2:0);
// Prototype for BBSWINASKR
Dcl-Pr Pgm_BBSWINASKR ExtPgm('BBSWINASKR');
  wWinMode        Char(1);
  wWinText        Char(30);
  wWinNumber      Packed(3:0);
  wWinF3          Ind;
End-Pr;
//*********************************************************************
Write FOOTER;
Exfmt SFLCTL;
Clear MSGLIN;
Exsr ChkFkeys;
If *In40;
  Exsr ChkOptions;
Endif;
//*********************************************************************
// Subroutine called automatically at startup
//*********************************************************************
BegSr *INZSR;
  // Get values from DATAARA and show them on screen
/Include CBKHEADER
  // Initialise variables and load subfile
  SCRSCR = 'BBSAACCLV';
  OPTSL1 = wOptsLin1;
  OPTSL2 = wOptsLin2;
  wRRN = 0;
  Exsr LoadSFL;
EndSr;
//*********************************************************************
// Check Function keys pressed by the user
//*********************************************************************
BegSr ChkFkeys;
  // F5=Refresh
  If *IN05 = *ON;
    Exsr ReLoadSFL;
  EndIf;
  // F6=Create
  If *IN06 = *ON;
    Exsr AddNewAccLvl;
  EndIf;
  // F12=Go back
  If *IN12 = *ON;
    *INLR = *ON;
    Return;
  EndIf;
  // F23=More options
  If *IN23 = *ON;
    If wOptions = *ON;
      wOptions = *OFF;
      OPTSL1 = wOptsLin3;
      OPTSL2 = *BLANKS;
    Else;
      wOptions = *ON;
      OPTSL1 = wOptsLin1;
      OPTSL2 = wOptsLin2;
    EndIf;
  EndIf;
EndSr;
//*********************************************************************
// Check Options entered by the user
//*********************************************************************
BegSr ChkOptions;
  ReadC SF;
  *IN91 = %Eof;
  DoW *IN91 = *OFF;
    Select;
      When SCROPT = '4';
        // Delete an Access Level
        Chain SCRLVL PACCLVS;
        If %FOUND;
          Delete RACCLV;
        EndIf;
      When SCROPT = '7';
        // Rename
        wWinMode = 'T';
        wWinText = SCRLVD;
        wWinNumber = 0;
        wWinF3 = *OFF;
        Pgm_BBSWINASKR(wWinMode : wWinText : wWinNumber : wWinF3);
        If wWinF3 = *OFF;
          SCRLVD = wWinText;
          Exsr UpdateDB;
        EndIf;
      When SCROPT = '8';
        // Change Expire days
        wWinMode = 'N';
        wWinText = *BLANKS;
        wWinNumber = SCREXP;
        wWinF3 = *OFF;
        Pgm_BBSWINASKR(wWinMode : wWinText : wWinNumber : wWinF3);
        If wWinF3 = *OFF;
          SCREXP = wWinNumber;
          Exsr UpdateDB;
        EndIf;
      When SCROPT = '9';
        // Change Expire to Lvl
        wWinMode = 'N';
        wWinText = *BLANKS;
        wWinNumber = SCREXL;
        wWinF3 = *OFF;
        Pgm_BBSWINASKR(wWinMode : wWinText : wWinNumber : wWinF3);
        If wWinF3 = *OFF;
          SCREXL = wWinNumber;
          Exsr UpdateDB;
        EndIf;
      When SCROPT = '10';
        // Switch List Users
        wPtr = %ADDR(SCRALU);
        Exsr SwitchYesNo;
        Exsr UpdateDB;
      When SCROPT = '11';
        // Switch System Info.
        wPtr = %ADDR(SCRASI);
        Exsr SwitchYesNo;
        Exsr UpdateDB;
      When SCROPT = '12';
        // Switch Post
        wPtr = %ADDR(SCRAPM);
        Exsr SwitchYesNo;
        Exsr UpdateDB;
      When SCROPT = '13';
        // Switch Message Users
        wPtr = %ADDR(SCRAMU);
        Exsr SwitchYesNo;
        Exsr UpdateDB;
      When SCROPT = '14';
        // Switch See Who's Online
        wPtr = %ADDR(SCRAWO);
        Exsr SwitchYesNo;
        Exsr UpdateDB;
    EndSl;
    SCROPT = *BLANKS;
    ReadC SF;
    *IN91 = %Eof;
  EndDo;
  Exsr ReLoadSFL;
EndSr;
//*********************************************************************
// If we want to reload the subfile, we need to clear it up first
//*********************************************************************
BegSr ReLoadSFL;
  *IN41 = *ON;
  Write SFLCTL;
  *IN41 = *OFF;
  wRRN = 0;
  Exsr LoadSFL;
EndSr;
//*********************************************************************
// Load all records from PACCLVS
// All records are loaded (load-all SFL) until the end of the file or
//  until SFLSIZ is reached
//*********************************************************************
BegSr LoadSFL;
  Setll *START PACCLVS;
  DoU %EOF;
    Read PACCLVS;
    If %EOF;
      Leave;
    EndIf;
    Exsr Data2SFL;
    wRRN += 1;
    Write SF;
    // If we have loaded 9999 records, we cannot add more. Stop loop
    If wRRN = 9999;
      Leave;
    EndIf;
  EndDo;
  // If we loaded at least 1 record, enable SFL
  If wRRN > 0;
    *IN40  = *ON;
  EndIf;
  *IN42  = *ON;
EndSr;
//*********************************************************************
// Put data into a SFL record
//*********************************************************************
BegSr Data2SFL;
  SCRLVL = LVLLVL;
  SCRLVD = LVLDSC;
  SCREXP = LVLEXP;
  SCREXL = LVLEXL;
  SCRALU = LVLALU;
  SCRASI = LVLASI;
  SCRAPM = LVLAPM;
  SCRAMU = LVLAMU;
  SCRAWO = LVLAWO;
EndSr;
//*********************************************************************
// Switches the value pointed by the wYesNo pointer
//  from Y to N and viceversa
//*********************************************************************
BegSr SwitchYesNo;
  If wYesNo = 'Y';
    wYesNo = 'N';
  Else;
    wYesNo = 'Y';
  EndIf;
EndSr;
//*********************************************************************
// Updates an Access Level in PACCLVS with values changed by the user
//*********************************************************************
BegSr UpdateDB;
  Chain SCRLVL PACCLVS;
  If %FOUND;
    LVLDSC = SCRLVD;
    LVLEXP = SCREXP;
    LVLEXL = SCREXL;
    LVLALU = SCRALU;
    LVLASI = SCRASI;
    LVLAPM = SCRAPM;
    LVLAMU = SCRAMU;
    LVLAWO = SCRAWO;
    Update RACCLV;
  EndIf;
EndSr;
//*********************************************************************
// Add a new Access Level tp PACCLVS
//  The user will be ask to enter the Access Level number,
//  and the rest of fields will be default
//*********************************************************************
BegSr AddNewAccLvl;
  wWinMode = 'N';
  wWinText = *BLANKS;
  wWinNumber = 0;
  wWinF3 = *OFF;
  Pgm_BBSWINASKR(wWinMode : wWinText : wWinNumber : wWinF3);
  If wWinF3 = *OFF;
    // Check that the Access Lvl entered by the user doesn't already exist
    wAccLvlD = wWinNumber;
    Chain wAccLvlD PACCLVS;
    If %FOUND;
      MSGLIN = wErrDuplAccLvl;
    Else;
      // Add to DB
      LVLLVL = wWinNumber;
      LVLDSC = 'NEW ACCESS LEVL';
      LVLEXP = 0;
      LVLEXL = 0;
      LVLALU = 'N';
      LVLASI = 'N';
      LVLAPM = 'N';
      LVLAMU = 'N';
      LVLAWO = 'N';
      Write RACCLV;
    EndIf;
  EndIf;
EndSr;