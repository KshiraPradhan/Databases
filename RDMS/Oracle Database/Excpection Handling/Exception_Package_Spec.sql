--spec
CREATE OR REPLACE PACKAGE MY_EXCEPTIONS AS  
  weird_error EXCEPTION;
  pragma EXCEPTION_INIT(WEIRD_ERROR, -20001);
END MY_EXCEPTIONS;
/

CREATE OR REPLACE PACKAGE MY_EXCEPTIONS AS 
  weird_error EXCEPTION;
  pragma EXCEPTION_INIT(WEIRD_ERROR, -20001);
  strange_error EXCEPTION;
  pragma EXCEPTION_INIT(STRANGE_ERROR, -20002);
END MY_EXCEPTIONS;
/