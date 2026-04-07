-- =============================================================================
-- Event Management + marketplace (full schema, seed data, demo password repair)
-- From repo root:  mysql -u root -p < database/init.sql
-- =============================================================================

CREATE DATABASE IF NOT EXISTS event;
USE event;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(120) NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'vendor', 'user') NOT NULL
);

CREATE TABLE vendors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  business_name VARCHAR(120) NOT NULL,
  category VARCHAR(80),
  contact_details TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE memberships (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  duration VARCHAR(20) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status VARCHAR(20) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  date DATE NOT NULL,
  location VARCHAR(100) NOT NULL
);

CREATE TABLE transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  event_id INT NOT NULL,
  date DATE NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (event_id) REFERENCES events(id)
);

CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  image_url VARCHAR(500),
  status VARCHAR(40) NOT NULL DEFAULT 'active',
  FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

CREATE TABLE cart_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  UNIQUE KEY uq_cart_user_product (user_id, product_id)
);

CREATE TABLE orders (
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

CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE item_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  vendor_id INT NULL,
  description TEXT NOT NULL,
  status VARCHAR(40) NOT NULL DEFAULT 'open',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

CREATE TABLE guest_list (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- demo passwords: admin123, user123, vendor123
INSERT INTO users (username, email, password, role) VALUES
('admin', 'admin@example.com', '$2a$10$Ypck7s964bsJjMtgnjHh9uOLvPo4dWk9bXlJ/yh5p7ij/hBkYCWCO', 'admin'),
('user', 'user@example.com', '$2a$10$3oIRmyi7FbRccBkjRo1DpuKtt9HMY5YKG3hmlCNje7AX8j7TMEmhi', 'user'),
('jsmith', 'jsmith@example.com', '$2a$10$3oIRmyi7FbRccBkjRo1DpuKtt9HMY5YKG3hmlCNje7AX8j7TMEmhi', 'user'),
('vendor1', 'vendor@example.com', '$2a$10$wOVyPFPcxUyYAl/cBlHl.uTPdizJ3QUUvGjsbHBGOhjbfFzyHfRuu', 'vendor');

INSERT INTO vendors (user_id, business_name, category, contact_details) VALUES
(4, 'Demo Catering Co', 'Catering', 'Call 555-0101 or email vendor@example.com');

INSERT INTO products (vendor_id, name, price, image_url, status) VALUES
(1, 'Coffee Service', 150.00, '/img/placeholder-product.svg', 'active'),
(1, 'Lunch Buffet', 450.00, '/img/placeholder-product.svg', 'active');

INSERT INTO memberships (user_id, duration, start_date, end_date, status) VALUES
(2, '6 months', '2025-10-01', '2026-04-01', 'active'),
(3, '1 year', '2024-06-15', '2025-06-15', 'expired');

INSERT INTO events (name, date, location) VALUES
('Annual Gala', '2026-05-20', 'Grand Hall Downtown'),
('Tech Meetup', '2026-04-12', 'Room 3B City Library'),
('Charity Run', '2026-06-01', 'Riverside Park');

INSERT INTO transactions (user_id, event_id, date) VALUES
(2, 1, '2026-03-01'),
(2, 2, '2026-03-15');

-- -----------------------------------------------------------------------------
-- Demo password repair (idempotent; use if hashes drift or import was partial)
-- -----------------------------------------------------------------------------
UPDATE users SET password = '$2a$10$Ypck7s964bsJjMtgnjHh9uOLvPo4dWk9bXlJ/yh5p7ij/hBkYCWCO' WHERE username = 'admin';
UPDATE users SET password = '$2a$10$3oIRmyi7FbRccBkjRo1DpuKtt9HMY5YKG3hmlCNje7AX8j7TMEmhi' WHERE username IN ('user', 'jsmith');
UPDATE users SET password = '$2a$10$wOVyPFPcxUyYAl/cBlHl.uTPdizJ3QUUvGjsbHBGOhjbfFzyHfRuu' WHERE username = 'vendor1';
