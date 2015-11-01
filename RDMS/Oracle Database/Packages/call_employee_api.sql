DECLARE
  v_employees_rec employees%ROWTYPE;
  
BEGIN
  
  -- Initialize record
  v_employees_rec.employee_id := 998;
  v_employees_rec.first_name := 'Ganesh';
  v_employees_rec.last_name := 'babu';
  v_employees_rec.email := 'Ganeshc@yahoo.com';
  v_employees_rec.phone_number := '937372833';
  v_employees_rec.hire_date := sysdate;
  v_employees_rec.job_id := 'IT_PROG';
  v_employees_rec.salary := 50000;
  v_employees_rec.commission_pct := 0;
  v_employees_rec.manager_id := 100;
  v_employees_rec.department_id := 60;
  
  -- Called record based API
  employee_api.emp_insert( v_employees_rec );
  
  -- Call parameterized api
  employee_api.emp_insert(
   p_employee_id => 9991,
   p_first_name => 'ganesh',
   p_last_name => 'babu',
   p_email => 'ganeshc@yahoo.com',
   p_phone_number => '937372833',
   p_hire_date => sysdate,
   p_job_id => 'IT_PROG',
   p_salary => 50000,
   p_commission_pct => 0,
   p_manager_id => 100,
   p_department_id => 60 );
  
  -- call update api
  employee_api.emp_update(
   p_employee_id => 99911,
   p_email => 'ganesh@testit.com' );
  
  -- call delete api
  employee_api.emp_delete(
   p_employee_id => 999111 );
  
END;
/
