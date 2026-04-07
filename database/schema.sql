-- Event Management System - MySQL setup
-- Run: mysql -u root -p < schema.sql

CREATE DATABASE IF NOT EXISTS event;
USE event;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'user') NOT NULL
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

-- demo logins (plain text password -> bcrypt below):
--   admin  /  admin123
--   user   /  user123
--   jsmith /  user123
INSERT INTO users (username, password, role) VALUES
('admin', '$2a$10$Ypck7s964bsJjMtgnjHh9uOLvPo4dWk9bXlJ/yh5p7ij/hBkYCWCO', 'admin'),
('user', '$2a$10$3oIRmyi7FbRccBkjRo1DpuKtt9HMY5YKG3hmlCNje7AX8j7TMEmhi', 'user'),
('jsmith', '$2a$10$3oIRmyi7FbRccBkjRo1DpuKtt9HMY5YKG3hmlCNje7AX8j7TMEmhi', 'user');

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
