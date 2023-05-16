**FREE
ctl-opt MAIN(ADDLOTFILE);

DCL-PR ADDLOTFILE EXTPGM('ADDLOTFILE');
    dcl-parm in_lib char(10) const;
END-PR;

DCL-PROC ADDLOTFILE;
    DCL-PI *N;
    dcl-parm in_lib char(10) const;
    END-PI;

    Dcl-s I INT(10);
    Dcl-s J INT(10);
    Dcl-s P Like(j);
    Dcl-s requete Varchar(30000);

    Exec SQl Set Option COMMIT=*NONE;

    for J = 0 To 500;
    requete = 'Create table ' + %Trim(in_lib) +
                '/TABLE' + %Char(j) +
                ' (id integer as identity, value varchar(500))';
    Exec SQL Execute immediate :requete;

    for i = 0 To 500;
        requete = 'Insert into ' + %Trim(in_lib) +
                    '/TABLE' +  %Char(j) +
                    ' values (default, ''value' +  %Char(i) + ''')';
        Exec SQL Execute immediate :requete;
        If SQLCOD <> 0;
            dsply 'nok';
        ENDIF;

        Exec SQL Execute immediate :requete;
        dow sqlstt <> 0;
            dsply 'nok';
        ENDdo;

        Exec SQL Execute immediate :requete;

        select;
        when 0 <> 0;
            dsply 'nok';
        ENDSL;
    endFor;
    EndFor;
END-PROC; 