     H NoMain

      /Include commons

     P ChangeDirectory...
     P                 B                   EXPORT
     D ChangeDirectory...
     D                 PI              N
     D  IN_Directory               5000A   VARYING
      /Free
       Return Exec('CD DIR(''' + IN_Directory + ''')');
      /End-Free
     P ChangeDirectory...
     P                 E

     P GetFilesList    B                   EXPORT
     D GetFilesList    PI              A   Len(1000000) VARYING
     D  IN_Directory               2000A   CONST VARYING
     D  IN_Extension                 10A   CONST VARYING
     D  IN_Separator                  1A   CONST VARYING
      
     D w_list          S               A   Len(1000000) VARYING
     D w_file          S            133A   VARYING
     D w_statement     S            300A   Varying
      /Free
       Exec('CRTPF FILE(QTEMP/LISTFILES) RCDLEN(133)');
       Exec('DSPLNK OBJ(''' + IN_Directory + '/*'') OUTPUT(*PRINT) +
             DETAIL(*NAME) DSPOPT(*USER)');
       Exec('CPYSPLF FILE(QSYSPRT) CRTDATE(*LAST) TOFILE(QTEMP/LISTFILES)');
       Exec('DLTSPLF FILE(QSYSPRT) SELECT(*CURRENT *ALL *ALL DSPLNK)');

       w_statement = 'Select Trim(LISTFILES) +
                      From QTEMP/LISTFILES +
                      Where Lower(Trim(LISTFILES)) Like ''%' + IN_Extension +
                      ''' For Read Only';

       Exec SQL Prepare S_ListFiles  From :w_statement;
       Exec Sql Declare C_LISTFILES Cursor For S_ListFiles;

       Exec Sql Open C_LISTFILES;
       Exec Sql Fetch From C_LISTFILES Into :w_file;
       DoW SQLCOD = 0;
          w_list += IN_Separator + IN_Directory + '/' + w_file;
          Exec Sql Fetch From C_LISTFILES Into :w_file;
       EndDo;
       Exec Sql Close C_LISTFILES;

       Exec('DLTF FILE(QTEMP/LISTFILES)');

       Return w_list;
      /End-Free
     P GetFilesList    E

     P Exec            B                   EXPORT
     D Exec            PI              N
     D   IN_COMMAND               32000A   CONST VARYING
      
     D QCMDEXC         PR                  EXTPGM('QCMDEXC')
     D  IN_CMD                    32000A   CONST
     D  IN_LEN                       15P 5 CONST
      /Free
       CallP(e) QCMDEXC(IN_COMMAND:%Len(IN_COMMAND));
       Return Not %Error;
      /End-Free
     P Exec            E

      * Check IFS file existence
     P CheckIFS        B                   EXPORT
     D CheckIFS        PI              N
     D   IN_IFSPATH               16000A   CONST Options(*VarSize)
      
     D slash           S             10I 0
     D prev_slash      S             10I 0
     D w_filename      S           2000A   VARYING
     D w_IFSPATH       S          16000A   VARYING
      /Free
       w_IFSPATH = %Trim(IN_IFSPATH);

       slash = %Scan('/':w_IFSPATH);
       If slash > 0;
          //Until we can use %ScanR...
          DoW slash > 0 And slash + 1 < %Len(w_IFSPATH);
             prev_slash = slash;
             slash = %Scan('/':w_IFSPATH:slash + 1);
          EndDo;
          w_filename = %Subst(w_IFSPATH:prev_slash + 1);
          Return Exec('REN OBJ(''' + w_IFSPATH + ''') +
                           NEWOBJ(''' + w_filename + ''')');
       Else;
          Return *Off;
       EndIf;
      /End-Free
     P CheckIFS        E 