CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    stock INT
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_id INT,
    quantity INT
);

CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE id = NEW.product_id;
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE products
        SET stock = stock + OLD.quantity - NEW.quantity
        WHERE id = NEW.product_id;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE id = OLD.product_id;
        RETURN OLD;
    END IF;
END;
$$;

CREATE TRIGGER trg_orders_insert
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();

CREATE TRIGGER trg_orders_update
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();

CREATE TRIGGER trg_orders_delete
AFTER DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();

INSERT INTO products (name, stock) VALUES
('Laptop Dell', 10),
('Chuột Logitech', 50);

INSERT INTO orders (product_id, quantity)
VALUES (1, 3);

UPDATE orders
SET quantity = 5
WHERE id = 1;

DELETE FROM orders
WHERE id = 1;

SELECT * FROM products;
SELECT * FROM orders;
