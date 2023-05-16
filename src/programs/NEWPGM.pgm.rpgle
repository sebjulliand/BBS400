**free
ctl-opt Main(NEWPGM);

dcl-c my_constant 'test';

///
// APPERRC template
// Used for error capturing
///
dcl-ds APIERRC_T Qualified Template;
  bytesProvided Int(10:0) Inz(%size(ApiErrC));
  bytesAvailable Int(10:0);
  exceptionID Char(7);
  reserved Char(1);
  exceptionData Char(3000);
end-ds;

dcl-pr QRCVDTAQ EXTPGM('QRCVDTAQ');
  Object CHAR(10);
  Library CHAR(10);
  DataLen PACKED(5);
  Data CHAR(DQ_LEN);
  WaitTime PACKED(5);
  KeyOrder CHAR(2) OPTIONS(*NOPASS);
  KeyLen PACKED(3) OPTIONS(*NOPASS);
  Key POINTER OPTIONS(*NOPASS);
end-pr;

dcl-pr NEWPGM;

end-pr;