-- Run in MySQL Workbench against database `event` if logins fail after an old seed.
-- (Updates bcrypt hashes for admin123 / user123)

USE event;

UPDATE users SET password = '$2a$10$Ypck7s964bsJjMtgnjHh9uOLvPo4dWk9bXlJ/yh5p7ij/hBkYCWCO' WHERE username = 'admin';
UPDATE users SET password = '$2a$10$3oIRmyi7FbRccBkjRo1DpuKtt9HMY5YKG3hmlCNje7AX8j7TMEmhi' WHERE username IN ('user', 'jsmith');
