-- Create DB & use it
CREATE DATABASE IF NOT EXISTS FraudDetectionDB;
USE FraudDetectionDB;

-- Users Table
CREATE TABLE IF NOT EXISTS Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(20),
  address TEXT,
  user_home_location VARCHAR(100)
);

-- Transactions Table
CREATE TABLE IF NOT EXISTS Transactions (
  transaction_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
  transaction_date DATETIME NOT NULL,
  transaction_type ENUM('debit','credit') NOT NULL,
  status ENUM('approved','declined') NOT NULL DEFAULT 'approved',
  merchant_name VARCHAR(100),
  location VARCHAR(100),
  device_ip VARCHAR(45),
  CONSTRAINT fk_tx_user FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Flags Table
CREATE TABLE IF NOT EXISTS Flags (
  flag_id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_id INT NOT NULL,
  flag_reason VARCHAR(255) NOT NULL,
  flag_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_flag_tx FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id)
);

-- Helpful Indexes
CREATE INDEX IF NOT EXISTS idx_amount ON Transactions (amount);
CREATE INDEX IF NOT EXISTS idx_transaction_date ON Transactions (transaction_date);
CREATE INDEX IF NOT EXISTS idx_user_merchant ON Transactions (user_id, merchant_name);
CREATE INDEX IF NOT EXISTS idx_flag_reason ON Flags (flag_reason);
