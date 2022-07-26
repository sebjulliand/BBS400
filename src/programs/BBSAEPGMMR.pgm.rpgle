**FREE
/TITLE Add/View External Program
Ctl-Opt COPYRIGHT('(C) 2020 David Asta under MIT License');
// SYSTEM      : V4R5
// PROGRAMMER  : David Asta
// DATE-WRITTEN: 10/DEC/2020
//
// This program allows the SysOp to Add a new External Program or Edit
//   an existing one
//*********************************************************************
/Include CBKOPTIMIZ
//*********************************************************************
// INDICATORS USED:
// 89 - *OFF = Check of newly entered data was OK
// 90 - CHAIN not found
// 91 - UPDATE/WRITE error
//*********************************************************************
Dcl-F BBSAEPGMMD WORKSTN;
Dcl-F PEXTPGMS   Usage(*Update:*Delete:*Output) Keyed;
//*********************************************************************
// Data structures
/Include CBKDTAARA
// Constants
Dcl-C cTitleAdd       CONST('BBS400 - Add a new External P-
rogram');
Dcl-C cTitleEdit      CONST('BBS400 - Edit an External Pro-
gram');
Dcl-C cAddOK          CONST('New External Program successf-
ully added.');
Dcl-C cModifOK        CONST('External Program successfully-
 modified.');
Dcl-C cSaveKO         CONST('There was an error when tryin-
g to save the data.');
Dcl-C cOrdExists      CONST('The entered Menu Order is alr-
eady assigned to another External Pr-
ogram.');
Dcl-C cOptExists      CONST('The entered Menu Option is al-
ready assigned to another External P-
Program.');
// Variables
Dcl-S wPrevOrd        Packed(2:0);
// Prototype for BBSAEPGMMR
Dcl-Pr Pgm_BBSAEPGMMR ExtPgm('BBSAEPGMMR');
  pMode           Char(1);
  pOrder          Packed(2:0);
End-Pr;
// Procedure interface for BBSAEPGMMR
Dcl-Pi Pgm_BBSAEPGMMR;
  pMode           Char(1);
  pOrder          Packed(2:0);
End-Pi;
//*********************************************************************
Write HEADER;
Write FOOTER;
Exfmt BODY;
Clear MSGLIN;
Exsr CheckFkeys;
//*********************************************************************
// Subroutine called automatically at startup
//*********************************************************************
BegSr *INZSR;
  SCRSCR = 'BBSAEPGMM';
  // Receive parameters
  Select;
    When pMode = 'A';
      SCRNAM = cTitleAdd;
    When pMode = 'E';
      SCRNAM = cTitleEdit;
      Exsr LoadData;
  EndSl;
  // Get values from DATAARA and show them on screen
/Include CBKHEADER
  // Check User Level, to prevent that this program is called directly
  //   by somebody else
  //    wUserLvl      IFNE      '99'
  //                  EVAL      *INLR = *ON
  //                  RETURN
  //                  ENDIF
EndSr;
//*********************************************************************
// Check Function keys pressed by the user
//*********************************************************************
BegSr CheckFkeys;
  // F10=Save changes
  If *IN10 = *ON;
    Select;
      When pMode = 'A';
        // Add a new External Program
        Exsr AddEPGM;
      When pMode = 'E';
        // Edit an existing External Program
        Exsr ModifyEPGM;
    EndSl;
  EndIf;
  // F12=Go back
  If *IN12 = *ON;
    *INLR = *ON;
    Return;
  EndIf;
EndSr;
//*********************************************************************
// Load data and show it on screen
//*********************************************************************
BegSr LoadData;
  Chain pOrder PEXTPGMS;
  If %FOUND;
    SCRPNM = EXTPGM;
    SCROBJ = EXTOBJ;
    SCRLIB = EXTLIB;
    SCRORD = EXTORD;
    SCRALV = EXTALV;
    If pMode  = 'E';
      wPrevOrd = SCRORD;
    EndIf;
  Else;
    Dsply 'LOAD ERROR';
  EndIf;
EndSr;
//*********************************************************************
// Add a new External Program
//*********************************************************************
BegSr AddEPGM;
  Chain SCRORD PEXTPGMS;
  *IN81 = not %Found;
  If not *In81;
    MSGLIN = cOrdExists;
  Endif;
  If not *In81;
    LeaveSr;
  Endif;
  EXTORD = SCRORD;
  EXTPGM = SCRPNM;
  EXTOBJ = SCROBJ;
  EXTLIB = SCRLIB;
  EXTALV = SCRALV;
  Write(e) RETPGM;
  *IN91 = %Error;
  If *In91;
    MSGLIN = cSaveKO;
  Endif;
  If not *In91;
    MSGLIN = cAddOK;
  Endif;
EndSr;
//*********************************************************************
// Edit an existing External Program
//*********************************************************************
BegSr ModifyEPGM;
  Chain SCRORD PEXTPGMS;
  *IN81 = not %Found;
  If SCRORD = wPrevOrd;
    *IN81 = *ON;
  EndIf;
  If not *In81;
    MSGLIN = cOrdExists;
  Endif;
  If not *In81;
    LeaveSr;
  Endif;
  EXTORD = SCRORD;
  EXTPGM = SCRPNM;
  EXTOBJ = SCROBJ;
  EXTLIB = SCRLIB;
  EXTALV = SCRALV;
  Update(e) RETPGM;
  *IN91 = %Error;
  If *In91;
    MSGLIN = cSaveKO;
  Endif;
  If not *In91;
    MSGLIN = cModifOK;
  Endif;
EndSr;