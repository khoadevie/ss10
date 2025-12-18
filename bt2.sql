CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    credit_limit NUMERIC(10,2)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT,
    order_amount NUMERIC(10,2)
);

CREATE OR REPLACE FUNCTION check_credit_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    total_order NUMERIC;
    limit_amount NUMERIC;
BEGIN
    SELECT credit_limit
    INTO limit_amount
    FROM customers
    WHERE id = NEW.customer_id;

    IF limit_amount IS NULL THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

    SELECT COALESCE(SUM(order_amount), 0)
    INTO total_order
    FROM orders
    WHERE customer_id = NEW.customer_id;

    IF total_order + NEW.order_amount > limit_amount THEN
        RAISE EXCEPTION 'Credit limit exceeded';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_credit
BEFORE INSERT
ON orders
FOR EACH ROW
EXECUTE FUNCTION check_credit_limit();

INSERT INTO customers (name, credit_limit) VALUES
('Nguyen Van A', 5000),
('Tran Thi B', 3000);

INSERT INTO orders (customer_id, order_amount) VALUES
(1, 2000),
(1, 2500);

INSERT INTO orders (customer_id, order_amount) VALUES
(1, 1000);

INSERT INTO orders (customer_id, order_amount) VALUES
(2, 1500),
(2, 1200);

INSERT INTO orders (customer_id, order_amount) VALUES
(2, 500);

SELECT * FROM customers;
SELECT * FROM orders;
