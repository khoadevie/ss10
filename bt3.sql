CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    position VARCHAR(50),
    salary NUMERIC(10,2)
);

CREATE TABLE employees_log (
    log_id SERIAL PRIMARY KEY,
    employee_id INT,
    operation VARCHAR(10),
    old_data JSONB,
    new_data JSONB,
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_employee_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO employees_log (employee_id, operation, old_data, new_data)
        VALUES (NEW.id, 'INSERT', NULL, to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO employees_log (employee_id, operation, old_data, new_data)
        VALUES (NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO employees_log (employee_id, operation, old_data, new_data)
        VALUES (OLD.id, 'DELETE', to_jsonb(OLD), NULL);
        RETURN OLD;
    END IF;
END;
$$;

CREATE TRIGGER trg_employees_insert
AFTER INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

CREATE TRIGGER trg_employees_update
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

CREATE TRIGGER trg_employees_delete
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

INSERT INTO employees (name, position, salary)
VALUES ('Nguyen Van A', 'Developer', 1500);

UPDATE employees
SET salary = 1800
WHERE name = 'Nguyen Van A';

DELETE FROM employees
WHERE name = 'Nguyen Van A';

SELECT * FROM employees_log;
