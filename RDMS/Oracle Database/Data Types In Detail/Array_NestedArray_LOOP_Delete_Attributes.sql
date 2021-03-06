declare
 type t_array is table of varchar2(30);
 
 v_array t_array;
 
 v_index BINARY_INTEGER;
begin
  v_array :=t_array();
  
  v_array.extend;
  v_array(1) :='Hello world';
  
  v_array.extend;
  v_array(2) := 'Hello again';
  
  v_array.extend;
  v_array(3) := 'New Row';
  
  v_array.delete(2);
  
  v_index :=v_array.FIRST;
 
  loop
    exit when v_index is null;
    dbms_output.put_line(v_array(v_index));
    
    v_index :=v_array.next(v_index);
  end loop;
end;
/