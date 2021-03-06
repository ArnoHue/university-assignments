MODULE BinMat;

CONST DIM*=5;

TYPE Index*=ARRAY DIM OF LONGINT;
     Element*=BOOLEAN;
     
VAR matrix: POINTER TO ARRAY OF SET;
    upperBoundary, lowerBoundary, dope: Index;


PROCEDURE GetAddress(inx: Index): LONGINT;
  
VAR address, i: LONGINT;
    err: BOOLEAN;
    
BEGIN
  address:=0;
  i:=0;
  err:=FALSE;
  
  WHILE (i<DIM) & (~err) DO
    err:=(inx[i]<lowerBoundary[i]) OR (inx[i]>upperBoundary[i]);
    IF ~err THEN
      address:=address+dope[i]*(inx[i]-lowerBoundary[i]);
    END;
    INC(i);
  END;
  
  IF err THEN
    RETURN 0;
  ELSE
    RETURN address;
  END; 
END GetAddress;  


PROCEDURE MatrixSize*(): LONGINT;

(* MatrixSize wird exportiert, um die Ausgabe der Matrix im Testmodul
   zu ermöglichen - siehe dort *)
   
BEGIN
  RETURN GetAddress(upperBoundary)+1;
END MatrixSize;


PROCEDURE GetIndex*(addr: LONGINT; VAR inx: Index);

(* GetIndex wird exportiert, um die Ausgabe der Matrix im Testmodul
   zu ermöglichen - siehe dort *)

VAR address, i: LONGINT;

BEGIN
  IF (matrix#NIL) & (addr<=MatrixSize())THEN
    address:=addr;
    FOR i:=0 TO DIM-1 DO
      inx[i]:=address DIV dope[i] + lowerBoundary[i];
      address:=address MOD dope[i];
    END;
  END;
END GetIndex;

  
PROCEDURE CleanUp*();

VAR i: LONGINT;

BEGIN
  DISPOSE(matrix);
  FOR i:=0 TO DIM-1 DO
    upperBoundary[i]:=0;
    lowerBoundary[i]:=0;
  END;
END CleanUp;


PROCEDURE Init*(upBnd,loBnd: Index; VAR err: BOOLEAN);

VAR i: LONGINT;

BEGIN
  IF matrix#NIL THEN
    CleanUp();
  END;
  
  err:=FALSE;
  i:=DIM-1;
  dope[DIM-1]:=1;
  
  REPEAT
    IF upBnd[i]>=loBnd[i] THEN
      upperBoundary[i]:=upBnd[i];
      lowerBoundary[i]:=loBnd[i];
      IF i>0 THEN
        dope[i-1]:=dope[i]*(upperBoundary[i]-lowerBoundary[i]+1);
      END;
    ELSE
      err:=TRUE
    END;
    DEC(i);
  UNTIL (i<0) OR (err);
  
  IF ~err THEN
    NEW(matrix,MatrixSize() DIV (MAX(SET)+1)+1);
    err:=(matrix=NIL);
  END;
END Init;
  

PROCEDURE Get*(inx: Index): BOOLEAN;

VAR address: LONGINT;

BEGIN
  IF matrix#NIL THEN
    address:=GetAddress(inx);
    RETURN (address MOD (MAX(SET)+1) IN matrix^[address DIV (MAX(SET)+1)]);
  ELSE
    RETURN FALSE;
  END;
END Get;


PROCEDURE Put*(inx: Index; ele: BOOLEAN);

VAR address: LONGINT;

BEGIN
  IF matrix#NIL THEN
    address:=GetAddress(inx);
    IF ele THEN
      matrix^[address DIV (MAX(SET)+1)]:=matrix^[address DIV (MAX(SET)+1)]+{(address MOD (MAX(SET)+1))};
    ELSE
      matrix^[address DIV (MAX(SET)+1)]:=matrix^[address DIV (MAX(SET)+1)]-{(address MOD (MAX(SET)+1))};
    END;
  END
END Put;


END BinMat.