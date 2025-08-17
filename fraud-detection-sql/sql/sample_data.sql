USE FraudDetectionDB;

-- Users
INSERT INTO Users (name, email, phone, address, user_home_location) VALUES
('Pranathi', 'pranathi@example.com', '9000000001', 'Hyderabad, IN', 'Hyderabad'),
('Sudhesha', 'sudhesha@example.com', '9000000002', 'Bengaluru, IN', 'Bengaluru'),
('Thanmayee', 'thanmayee@example.com', '9000000003', 'Vijayawada, IN', 'Vijayawada'),
('Abhilash Sharma', 'abhilash@example.com', '9000000004', 'Pune, IN', 'Pune'),
('Aadhya Sharma', 'aadhya@example.com', '9000000005', 'Mumbai, IN', 'Mumbai'),
('Rohit', 'rohit@example.com', '9000000006', 'Delhi, IN', 'Delhi'),
('Meera', 'meera@example.com', '9000000007', 'Chennai, IN', 'Chennai');

-- Transactions (synthetic)
-- Times chosen to trigger off-hours and frequency rules; amounts to trigger high-value and average-deviation
INSERT INTO Transactions (user_id, amount, transaction_date, transaction_type, status, merchant_name, location, device_ip) VALUES
-- High value & average deviation
(1, 7000.00, '2025-04-10 19:40:00', 'debit', 'approved', 'BookMyShow', 'Hyderabad', '10.0.0.1'),
-- Off-hours
(3, 2000.00, '2025-04-11 23:50:00', 'debit', 'approved', 'Big Bazaar', 'Vijayawada', '10.0.0.3'),
(1, 1000.00, '2025-04-12 00:30:00', 'debit', 'approved', 'Swiggy', 'Hyderabad', '10.0.0.1'),
(4, 4500.00, '2025-04-12 23:10:00', 'debit', 'approved', 'Amazon', 'Pune', '10.0.0.4'),
(5, 2500.00, '2025-04-13 01:10:00', 'debit', 'approved', 'Big Bazaar', 'Mumbai', '10.0.0.5'),
-- High value
(2, 5500.00, '2025-04-14 18:15:00', 'debit', 'approved', 'Flipkart', 'Bengaluru', '10.0.0.2'),
-- Repeated to same merchant
(6, 300.00, '2025-04-15 10:00:00', 'debit', 'approved', 'Café Coffee Day', 'Delhi', '10.0.0.6'),
(6, 320.00, '2025-04-15 12:00:00', 'debit', 'approved', 'Café Coffee Day', 'Delhi', '10.0.0.6'),
(6, 290.00, '2025-04-15 14:00:00', 'debit', 'approved', 'Café Coffee Day', 'Delhi', '10.0.0.6'),
(6, 310.00, '2025-04-15 16:00:00', 'debit', 'approved', 'Café Coffee Day', 'Delhi', '10.0.0.6'),
-- Frequency burst (>5 in 24h) for user 7
(7, 150.00, '2025-04-16 09:00:00', 'debit', 'approved', 'Uber', 'Chennai', '10.0.0.7'),
(7, 160.00, '2025-04-16 09:20:00', 'debit', 'approved', 'Uber', 'Chennai', '10.0.0.7'),
(7, 170.00, '2025-04-16 09:40:00', 'debit', 'approved', 'Uber', 'Chennai', '10.0.0.7'),
(7, 180.00, '2025-04-16 10:00:00', 'debit', 'approved', 'Uber', 'Chennai', '10.0.0.7'),
(7, 190.00, '2025-04-16 10:20:00', 'debit', 'approved', 'Uber', 'Chennai', '10.0.0.7'),
(7, 200.00, '2025-04-16 10:40:00', 'debit', 'approved', 'Uber', 'Chennai', '10.0.0.7'),
-- Consecutive declined attempts for user 2
(2, 100.00, '2025-04-17 11:00:00', 'debit', 'declined', 'Paytm', 'Bengaluru', '10.0.0.2'),
(2, 120.00, '2025-04-17 11:05:00', 'debit', 'declined', 'Paytm', 'Bengaluru', '10.0.0.2'),
(2, 130.00, '2025-04-17 11:10:00', 'debit', 'declined', 'Paytm', 'Bengaluru', '10.0.0.2'),
-- Location mismatch vs home (user 1: home=Hyderabad, tx in Mumbai)
(1, 450.00, '2025-04-18 15:30:00', 'debit', 'approved', 'Metro', 'Mumbai', '10.0.0.8');
