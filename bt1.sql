CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC(10,2),
    last_modified TIMESTAMP
);

CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.last_modified := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_last_modified
BEFORE UPDATE
ON products
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

INSERT INTO products (name, price, last_modified) VALUES
('Laptop Dell', 2000, CURRENT_TIMESTAMP),
('Chuột Logitech', 50, CURRENT_TIMESTAMP);

UPDATE products
SET price = 2100
WHERE name = 'Laptop Dell';

SELECT * FROM products;
