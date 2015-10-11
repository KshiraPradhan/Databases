DECLARE
  TYPE r_emps IS RECORD
  (
    last_name VARCHAR2(25),
    first_name VARCHAR2(20),
    email VARCHAR2(25),
    phone_number VARCHAR2(20),
    hire_date DATE,
    salary NUMBER(8,2)
  ) ;
  
  v_emps r_emps;
  
  v_emp_obj emp_obj;
BEGIN
  v_emps.last_name := 'gg';
  v_emps.first_name := 'bb';
  
  v_emp_obj := emp_obj(
    last_name => 'gg',
    first_name => 'bb',
    email => 'gg@databasewisdom.com',
    phone_number => '34343',
    hire_date => sysdate,
    salary => 5000);
  
END; 
/

