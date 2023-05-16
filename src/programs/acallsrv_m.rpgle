**FREE
// %METADATA
//   %TEXT Call services
// %EMETADATA
Ctl-Opt Main(ACALLSRV);

/include commons

Dcl-Pr ACALLSRV EXTPGM('ACALLSRV');
End-Pr;

Dcl-Proc ACALLSRV;
	GetFilesList('/tmp':'.txt':',');
	GetFilesList('/tmp':'.txt2':',');
	return;	
End-Proc ACALLSRV;