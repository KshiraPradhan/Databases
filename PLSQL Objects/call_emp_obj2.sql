DECLARE  
  v_emp_obj emp_obj;
BEGIN

  v_emp_obj := emp_obj(
    last_name => 'ganesh',
    first_name => 'babu',
    email => 'ganesh@gmail.com',
    phone_number => '34343',
    hire_date => sysdate,
    salary => 5000);
  
END;  
/


