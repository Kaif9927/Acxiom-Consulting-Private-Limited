-- =============================================================================
-- Migration: legacy event DB (admin/user only) → full marketplace schema
-- Run ONLY if you already have data and lack marketplace tables.
-- Do NOT run on a DB created with database/init.sql
--   mysql -u root -p event < database/upgrade_legacy.sql
-- =============================================================================

USE event;

ALTER TABLE users
  MODIFY COLUMN role ENUM('admin', 'vendor', 'user') NOT NULL;

ALTER TABLE users
  ADD COLUMN email VARCHAR(120) NULL AFTER username;

CREATE TABLE IF NOT EXISTS vendors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  business_name VARCHAR(120) NOT NULL,
  category VARCHAR(80),
  contact_details TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  image_url VARCHAR(500),
  status VARCHAR(40) NOT NULL DEFAULT 'active',
  FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

CREATE TABLE IF NOT EXISTS cart_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY uq_cart_user_product (user_id, product_id)
);

CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  grand_total DECIMAL(12, 2) NOT NULL,
  fulfillment_status VARCHAR(50) NOT NULL DEFAULT 'pending',
  customer_name VARCHAR(120),
  customer_email VARCHAR(120),
  customer_phone VARCHAR(40),
  customer_address TEXT,
  customer_city VARCHAR(80),
  customer_state VARCHAR(80),
  customer_pin VARCHAR(20),
  payment_method VARCHAR(40),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS item_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  vendor_id INT NULL,
  description TEXT NOT NULL,
  status VARCHAR(40) NOT NULL DEFAULT 'open',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

CREATE TABLE IF NOT EXISTS guest_list (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT IGNORE INTO users (username, email, password, role) VALUES
('vendor1', 'vendor@example.com', '$2a$10$wOVyPFPcxUyYAl/cBlHl.uTPdizJ3QUUvGjsbHBGOhjbfFzyHfRuu', 'vendor');

INSERT INTO vendors (user_id, business_name, category, contact_details)
SELECT id, 'Demo Catering Co', 'Catering', '555-0101'
FROM users WHERE username = 'vendor1' AND NOT EXISTS (SELECT 1 FROM vendors v WHERE v.user_id = users.id);

INSERT INTO products (vendor_id, name, price, image_url, status)
SELECT v.id, 'Coffee Service', 150.00, '/img/placeholder-product.svg', 'active'
FROM vendors v JOIN users u ON u.id = v.user_id WHERE u.username = 'vendor1'
AND NOT EXISTS (SELECT 1 FROM products p WHERE p.vendor_id = v.id AND p.name = 'Coffee Service');

INSERT INTO products (vendor_id, name, price, image_url, status)
SELECT v.id, 'Lunch Buffet', 450.00, '/img/placeholder-product.svg', 'active'
FROM vendors v JOIN users u ON u.id = v.user_id WHERE u.username = 'vendor1'
AND NOT EXISTS (SELECT 1 FROM products p WHERE p.vendor_id = v.id AND p.name = 'Lunch Buffet');
