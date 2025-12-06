-- Admin users
INSERT INTO users (username, password_hash, email, user_type) VALUES
('admin1', '$2a$10$H8fZ4hV7nT8kL9mN2bV3cE', 'admin1@lumoshive.com', 'admin'),
('admin2', '$2a$10$J9gA5kL6mN7oP8qR0sT1uV', 'admin2@lumoshive.com', 'admin');

-- Customer users (10 customers)
INSERT INTO users (username, password_hash, email, user_type) VALUES
('budi_s', '$2a$10$A1b2C3d4E5f6G7h8I9j0K', 'budi.santoso@email.com', 'customer'),
('siti_n', '$2a$10$L1m2N3o4P5q6R7s8T9u0V', 'siti.nurhaliza@email.com', 'customer'),
('ahmad_r', '$2a$10$W1x2Y3z4A5b6C7d8E9f0G', 'ahmad.rizki@email.com', 'customer'),
('dewi_l', '$2a$10$H1i2J3k4L5m6N7o8P9q0R', 'dewi.lestari@email.com', 'customer'),
('joko_p', '$2a$10$S1t2U3v4W5x6Y7z8A9b0C', 'joko.prasetyo@email.com', 'customer'),
('anin_s', '$2a$10$D1e2F3g4H5i6J7k8L9m0N', 'anin.susanti@email.com', 'customer'),
('rifki_m', '$2a$10$O1p2Q3r4S5t6U7v8W9x0Y', 'rifki.maulana@email.com', 'customer'),
('lina_w', '$2a$10$Z1a2B3c4D5e6F7g8H9i0J', 'lina.wati@email.com', 'customer'),
('tono_w', '$2a$10$K1l2M3n4O5p6Q7r8S9t0U', 'tono.wijaya@email.com', 'customer'),
('maya_s', '$2a$10$V1w2X3y4Z5a6B7c8D9e0F', 'maya.sari@email.com', 'customer');

-- Driver users (8 drivers)
INSERT INTO users (username, password_hash, email, user_type) VALUES
('joko_s', '$2a$10$G1h2I3j4K5l6M7n8O9p0Q', 'joko.susilo@driver.com', 'driver'),
('rina_d', '$2a$10$R1s2T3u4V5w6X7y8Z9a0B', 'rina.dewi@driver.com', 'driver'),
('herman_s', '$2a$10$C1d2E3f4G5h6I7j8K9l0M', 'herman.setiawan@driver.com', 'driver'),
('agus_p', '$2a$10$N1o2P3q4R5s6T7u8V9w0X', 'agus.pratama@driver.com', 'driver'),
('sari_m', '$2a$10$Y1z2A3b4C5d6E7f8G9h0I', 'sari.melati@driver.com', 'driver'),
('bambang_s', '$2a$10$J1k2L3m4N5o6P7q8R9s0T', 'bambang.saputra@driver.com', 'driver'),
('eko_p', '$2a$10$F1g2H3i4J5k6L7m8N9o0P', 'eko.purnomo@driver.com', 'driver'),
('fajar_a', '$2a$10$Q1r2S3t4U5v6W7x8Y9z0A', 'fajar.adi@driver.com', 'driver');

-- ============================================
-- 2. INSERT CUSTOMERS (10 customers)
-- ============================================

INSERT INTO customers (user_id, full_name, phone_number, date_of_birth, registration_date) VALUES
(3, 'Budi Santoso', '081234567890', '1990-05-15', '2024-01-15'),
(4, 'Siti Nurhaliza', '081298765432', '1992-08-20', '2024-01-20'),
(5, 'Ahmad Rizki', '081377788899', '1988-11-30', '2024-02-01'),
(6, 'Dewi Lestari', '081466677788', '1995-03-25', '2024-02-05'),
(7, 'Joko Prasetyo', '081555566677', '1985-07-12', '2024-02-10'),
(8, 'Anin Susanti', '081644455566', '1993-09-18', '2024-02-15'),
(9, 'Rifki Maulana', '081733344455', '1991-12-05', '2024-02-20'),
(10, 'Lina Wati', '081822233344', '1994-06-30', '2024-03-01'),
(11, 'Tono Wijaya', '081911122233', '1987-04-22', '2024-03-05'),
(12, 'Maya Sari', '082100011122', '1996-10-08', '2024-03-10');

-- ============================================
-- 3. INSERT DRIVERS (8 drivers)
-- ============================================

INSERT INTO drivers (user_id, full_name, phone_number, vehicle_type, vehicle_number, is_active, driver_license_number) VALUES
(13, 'Joko Susilo', '081512345678', 'motor', 'B 1234 ABC', TRUE, 'SIM C 1234567890'),
(14, 'Rina Dewi', '081523456789', 'motor', 'B 5678 DEF', TRUE, 'SIM C 2345678901'),
(15, 'Herman Setiawan', '081534567890', 'mobil', 'B 9012 GHI', TRUE, 'SIM A 3456789012'),
(16, 'Agus Pratama', '081545678901', 'motor', 'B 3456 JKL', TRUE, 'SIM C 4567890123'),
(17, 'Sari Melati', '081556789012', 'motor', 'B 7890 MNO', TRUE, 'SIM C 5678901234'),
(18, 'Bambang Saputra', '081567890123', 'mobil', 'B 2468 PQR', TRUE, 'SIM A 6789012345'),
(19, 'Eko Purnomo', '081589012345', 'mobil', 'B 8024 VWX', TRUE, 'SIM A 8901234567'),
(20, 'Fajar Adi', '081590123456', 'motor', 'B 9753 YZA', TRUE, 'SIM C 9012345678');

-- ============================================
-- 4. INSERT LOCATIONS (15 popular locations)
-- ============================================

INSERT INTO locations (location_name, address, city, area_type) VALUES
('Mall Grand Indonesia', 'Jl. MH Thamrin No.1', 'Jakarta Pusat', 'both'),
('Stasiun Gambir', 'Jl. Medan Merdeka Timur No.1', 'Jakarta Pusat', 'both'),
('Bandara Soekarno-Hatta', 'Tangerang', 'Tangerang', 'both'),
('Kemang', 'Jl. Kemang Raya', 'Jakarta Selatan', 'both'),
('Plaza Senayan', 'Jl. Asia Afrika No.8', 'Jakarta Pusat', 'both'),
('SCBD Sudirman', 'Jl. Jend. Sudirman', 'Jakarta Selatan', 'both'),
('Kota Tua', 'Jl. Kali Besar Barat', 'Jakarta Barat', 'both'),
('Ancol Dreamland', 'Jl. Lodan Timur No.7', 'Jakarta Utara', 'both'),
('Universitas Indonesia', 'Depok', 'Depok', 'both'),
('BSD City', 'Jl. Pagedangan', 'Tangerang Selatan', 'both'),
('Pondok Indah Mall', 'Jl. Metro Pondok Indah', 'Jakarta Selatan', 'both'),
('Kelapa Gading', 'Jl. Boulevard Kelapa Gading', 'Jakarta Utara', 'both'),
('Cilandak Town Square', 'Jl. TB Simatupang', 'Jakarta Selatan', 'both'),
('Tanjung Priok', 'Jl. Enggano No.1', 'Jakarta Utara', 'both'),
('Kampung Rambutan', 'Terminal Kampung Rambutan', 'Jakarta Timur', 'both');

-- ============================================
-- 5. INSERT ORDERS (80 orders for 3 months)
-- ============================================

-- March 2024 orders (30 orders)
INSERT INTO orders (customer_id, driver_id, pickup_location_id, destination_location_id, 
                   order_status, order_date, pickup_time, completion_time, 
                   distance_km, fare_amount, payment_method, payment_status) VALUES
-- Day 1
(1, 1, 1, 2, 'completed', '2024-03-01 08:30:00', '2024-03-01 08:35:00', '2024-03-01 09:00:00', 5.2, 25600, 'gopay', 'paid'),
(2, 2, 3, 4, 'completed', '2024-03-01 09:15:00', '2024-03-01 09:20:00', '2024-03-01 09:50:00', 12.5, 47500, 'ovo', 'paid'),
(3, 3, 5, 6, 'completed', '2024-03-01 10:30:00', '2024-03-01 10:35:00', '2024-03-01 11:05:00', 8.7, 36100, 'cash', 'paid'),
(4, 4, 7, 8, 'completed', '2024-03-01 11:45:00', '2024-03-01 11:50:00', '2024-03-01 12:20:00', 6.3, 28900, 'gopay', 'paid'),
(5, 5, 9, 10, 'completed', '2024-03-01 13:00:00', '2024-03-01 13:05:00', '2024-03-01 13:40:00', 15.2, 55600, 'dana', 'paid'),

-- Day 2
(1, 6, 11, 12, 'completed', '2024-03-02 08:45:00', '2024-03-02 08:50:00', '2024-03-02 09:15:00', 7.1, 31300, 'ovo', 'paid'),
(2, 7, 13, 14, 'completed', '2024-03-02 10:00:00', '2024-03-02 10:05:00', '2024-03-02 10:35:00', 9.5, 38500, 'cash', 'paid'),
(3, 8, 1, 3, 'completed', '2024-03-02 11:30:00', '2024-03-02 11:35:00', '2024-03-02 12:15:00', 18.3, 64900, 'gopay', 'paid'),
(4, 1, 4, 5, 'completed', '2024-03-02 14:00:00', '2024-03-02 14:05:00', '2024-03-02 14:30:00', 5.8, 27400, 'ovo', 'paid'),
(5, 2, 6, 7, 'completed', '2024-03-02 15:30:00', '2024-03-02 15:35:00', '2024-03-02 16:05:00', 11.2, 43600, 'cash', 'paid'),

-- Day 3
(6, 3, 8, 9, 'completed', '2024-03-03 09:00:00', '2024-03-03 09:05:00', '2024-03-03 09:40:00', 14.5, 53500, 'gopay', 'paid'),
(7, 4, 10, 11, 'completed', '2024-03-03 10:30:00', '2024-03-03 10:35:00', '2024-03-03 11:10:00', 16.8, 60400, 'ovo', 'paid'),
(8, 5, 12, 13, 'completed', '2024-03-03 12:00:00', '2024-03-03 12:05:00', '2024-03-03 12:40:00', 13.2, 49600, 'cash', 'paid'),
(9, 6, 14, 15, 'completed', '2024-03-03 13:30:00', '2024-03-03 13:35:00', '2024-03-03 14:10:00', 10.7, 42100, 'gopay', 'paid'),
(10, 7, 2, 4, 'completed', '2024-03-03 15:00:00', '2024-03-03 15:05:00', '2024-03-03 15:40:00', 11.9, 45700, 'ovo', 'paid'),

-- More March orders (15 more)
(1, 8, 3, 5, 'completed', '2024-03-04 08:15:00', '2024-03-04 08:20:00', '2024-03-04 08:50:00', 9.3, 37900, 'cash', 'paid'),
(2, 1, 6, 8, 'completed', '2024-03-04 09:45:00', '2024-03-04 09:50:00', '2024-03-04 10:25:00', 12.1, 46300, 'gopay', 'paid'),
(3, 2, 9, 11, 'completed', '2024-03-04 11:00:00', '2024-03-04 11:05:00', '2024-03-04 11:45:00', 17.5, 62500, 'ovo', 'paid'),
(4, 3, 12, 14, 'completed', '2024-03-04 13:30:00', '2024-03-04 13:35:00', '2024-03-04 14:15:00', 14.8, 54400, 'cash', 'paid'),
(5, 4, 15, 1, 'completed', '2024-03-04 15:00:00', '2024-03-04 15:05:00', '2024-03-04 15:50:00', 20.3, 70900, 'gopay', 'paid'),
(6, 5, 2, 6, 'completed', '2024-03-05 08:30:00', '2024-03-05 08:35:00', '2024-03-05 09:10:00', 13.7, 51100, 'ovo', 'paid'),
(7, 6, 4, 9, 'completed', '2024-03-05 10:00:00', '2024-03-05 10:05:00', '2024-03-05 10:50:00', 15.9, 57700, 'cash', 'paid'),
(8, 7, 7, 12, 'completed', '2024-03-05 11:30:00', '2024-03-05 11:35:00', '2024-03-05 12:20:00', 16.2, 58600, 'gopay', 'paid'),
(9, 8, 10, 13, 'completed', '2024-03-05 14:00:00', '2024-03-05 14:05:00', '2024-03-05 14:45:00', 12.4, 47200, 'ovo', 'paid'),
(10, 1, 11, 14, 'completed', '2024-03-05 16:00:00', '2024-03-05 16:05:00', '2024-03-05 16:40:00', 9.8, 39400, 'cash', 'paid'),
(1, 2, 13, 15, 'completed', '2024-03-06 09:00:00', '2024-03-06 09:05:00', '2024-03-06 09:35:00', 8.2, 34600, 'gopay', 'paid'),
(2, 3, 3, 7, 'completed', '2024-03-06 10:30:00', '2024-03-06 10:35:00', '2024-03-06 11:15:00', 14.1, 52300, 'ovo', 'paid'),
(3, 4, 5, 10, 'completed', '2024-03-06 12:00:00', '2024-03-06 12:05:00', '2024-03-06 12:50:00', 18.7, 66100, 'cash', 'paid'),
(4, 5, 8, 11, 'completed', '2024-03-06 14:30:00', '2024-03-06 14:35:00', '2024-03-06 15:20:00', 16.4, 59200, 'gopay', 'paid'),
(5, 6, 12, 1, 'completed', '2024-03-06 16:30:00', '2024-03-06 16:35:00', '2024-03-06 17:20:00', 19.5, 68500, 'ovo', 'paid');

-- April 2024 orders (25 orders)
INSERT INTO orders (customer_id, driver_id, pickup_location_id, destination_location_id, 
                   order_status, order_date, pickup_time, completion_time, 
                   distance_km, fare_amount, payment_method, payment_status) VALUES
-- April orders
(6, 7, 2, 5, 'completed', '2024-04-01 08:15:00', '2024-04-01 08:20:00', '2024-04-01 08:55:00', 11.3, 43900, 'cash', 'paid'),
(7, 8, 4, 8, 'completed', '2024-04-01 10:00:00', '2024-04-01 10:05:00', '2024-04-01 10:45:00', 13.7, 51100, 'gopay', 'paid'),
(8, 1, 6, 9, 'completed', '2024-04-01 11:30:00', '2024-04-01 11:35:00', '2024-04-01 12:20:00', 15.9, 57700, 'ovo', 'paid'),
(9, 2, 8, 11, 'completed', '2024-04-01 13:00:00', '2024-04-01 13:05:00', '2024-04-01 13:50:00', 17.2, 61600, 'cash', 'paid'),
(10, 3, 10, 13, 'completed', '2024-04-01 14:30:00', '2024-04-01 14:35:00', '2024-04-01 15:20:00', 14.5, 53500, 'gopay', 'paid'),

(1, 4, 12, 15, 'completed', '2024-04-02 09:00:00', '2024-04-02 09:05:00', '2024-04-02 09:40:00', 9.8, 39400, 'ovo', 'paid'),
(2, 5, 1, 4, 'completed', '2024-04-02 10:30:00', '2024-04-02 10:35:00', '2024-04-02 11:15:00', 12.6, 47800, 'cash', 'paid'),
(3, 6, 3, 7, 'completed', '2024-04-02 12:00:00', '2024-04-02 12:05:00', '2024-04-02 12:50:00', 15.3, 55900, 'gopay', 'paid'),
(4, 7, 5, 10, 'completed', '2024-04-02 14:00:00', '2024-04-02 14:05:00', '2024-04-02 14:55:00', 18.9, 66700, 'ovo', 'paid'),
(5, 8, 7, 12, 'completed', '2024-04-02 16:00:00', '2024-04-02 16:05:00', '2024-04-02 16:50:00', 16.1, 58300, 'cash', 'paid'),

-- More April orders (15 more)
(6, 1, 9, 14, 'completed', '2024-04-03 08:45:00', '2024-04-03 08:50:00', '2024-04-03 09:30:00', 13.4, 50200, 'gopay', 'paid'),
(7, 2, 11, 2, 'completed', '2024-04-03 10:15:00', '2024-04-03 10:20:00', '2024-04-03 11:05:00', 17.8, 63400, 'ovo', 'paid'),
(8, 3, 13, 5, 'completed', '2024-04-03 11:45:00', '2024-04-03 11:50:00', '2024-04-03 12:35:00', 14.2, 52600, 'cash', 'paid'),
(9, 4, 15, 8, 'completed', '2024-04-03 13:15:00', '2024-04-03 13:20:00', '2024-04-03 14:05:00', 16.7, 60100, 'gopay', 'paid'),
(10, 5, 2, 11, 'completed', '2024-04-03 15:00:00', '2024-04-03 15:05:00', '2024-04-03 15:50:00', 19.3, 67900, 'ovo', 'paid'),
(1, 6, 4, 13, 'completed', '2024-04-04 09:30:00', '2024-04-04 09:35:00', '2024-04-04 10:20:00', 15.6, 56800, 'cash', 'paid'),
(2, 7, 6, 15, 'completed', '2024-04-04 11:00:00', '2024-04-04 11:05:00', '2024-04-04 11:50:00', 17.9, 63700, 'gopay', 'paid'),
(3, 8, 8, 1, 'completed', '2024-04-04 12:30:00', '2024-04-04 12:35:00', '2024-04-04 13:25:00', 20.1, 70300, 'ovo', 'paid'),
(4, 1, 10, 3, 'completed', '2024-04-04 14:00:00', '2024-04-04 14:05:00', '2024-04-04 14:55:00', 18.4, 65200, 'cash', 'paid'),
(5, 2, 12, 6, 'completed', '2024-04-04 15:30:00', '2024-04-04 15:35:00', '2024-04-04 16:25:00', 19.7, 69100, 'gopay', 'paid'),
(6, 3, 14, 9, 'completed', '2024-04-05 08:20:00', '2024-04-05 08:25:00', '2024-04-05 09:10:00', 15.1, 55300, 'ovo', 'paid'),
(7, 4, 1, 12, 'completed', '2024-04-05 09:45:00', '2024-04-05 09:50:00', '2024-04-05 10:40:00', 18.6, 65800, 'cash', 'paid'),
(8, 5, 3, 14, 'completed', '2024-04-05 11:15:00', '2024-04-05 11:20:00', '2024-04-05 12:10:00', 17.3, 61900, 'gopay', 'paid'),
(9, 6, 5, 2, 'completed', '2024-04-05 13:00:00', '2024-04-05 13:05:00', '2024-04-05 13:55:00', 19.8, 69400, 'ovo', 'paid'),
(10, 7, 7, 5, 'completed', '2024-04-05 14:30:00', '2024-04-05 14:35:00', '2024-04-05 15:25:00', 16.5, 59500, 'cash', 'paid');

-- May 2024 orders (25 orders - current month with various statuses)
INSERT INTO orders (customer_id, driver_id, pickup_location_id, destination_location_id, 
                   order_status, order_date, pickup_time, completion_time, 
                   distance_km, fare_amount, payment_method, payment_status) VALUES
-- May completed orders
(1, 8, 2, 7, 'completed', '2024-05-01 08:30:00', '2024-05-01 08:35:00', '2024-05-01 09:15:00', 13.8, 51400, 'gopay', 'paid'),
(2, 1, 4, 9, 'completed', '2024-05-01 10:00:00', '2024-05-01 10:05:00', '2024-05-01 10:50:00', 16.2, 58600, 'ovo', 'paid'),
(3, 2, 6, 11, 'completed', '2024-05-01 11:30:00', '2024-05-01 11:35:00', '2024-05-01 12:25:00', 18.7, 66100, 'cash', 'paid'),
(4, 3, 8, 13, 'completed', '2024-05-01 13:00:00', '2024-05-01 13:05:00', '2024-05-01 13:55:00', 17.4, 62200, 'gopay', 'paid'),
(5, 4, 10, 15, 'completed', '2024-05-01 14:30:00', '2024-05-01 14:35:00', '2024-05-01 15:25:00', 19.1, 67300, 'ovo', 'paid'),

-- May ongoing and pending orders (for real-time testing)
(6, 5, 12, 1, 'ongoing', '2024-05-02 09:00:00', '2024-05-02 09:05:00', NULL, 14.5, 53500, 'cash', 'pending'),
(7, 6, 14, 3, 'accepted', '2024-05-02 10:30:00', NULL, NULL, 11.8, 45400, 'gopay', 'pending'),
(8, 7, 1, 5, 'pending', '2024-05-02 12:00:00', NULL, NULL, 9.3, 37900, 'ovo', 'pending'),
(9, 8, 3, 7, 'completed', '2024-05-02 14:00:00', '2024-05-02 14:05:00', '2024-05-02 14:45:00', 15.7, 57100, 'cash', 'paid'),
(10, 1, 5, 9, 'cancelled', '2024-05-02 16:00:00', NULL, NULL, 12.4, 47200, 'gopay', 'failed'),

-- More May orders with mixed status
(1, 2, 7, 11, 'completed', '2024-05-03 08:15:00', '2024-05-03 08:20:00', '2024-05-03 09:00:00', 13.1, 49300, 'ovo', 'paid'),
(2, 3, 9, 13, 'ongoing', '2024-05-03 09:45:00', '2024-05-03 09:50:00', NULL, 16.8, 60400, 'cash', 'pending'),
(3, 4, 11, 15, 'pending', '2024-05-03 11:15:00', NULL, NULL, 10.2, 40600, 'gopay', 'pending'),
(4, 5, 13, 2, 'completed', '2024-05-03 13:00:00', '2024-05-03 13:05:00', '2024-05-03 13:50:00', 18.3, 64900, 'ovo', 'paid'),
(5, 6, 15, 4, 'accepted', '2024-05-03 14:30:00', NULL, NULL, 14.9, 54700, 'cash', 'pending'),

-- Last May orders for testing peak hours
(6, 7, 2, 6, 'completed', '2024-05-04 07:30:00', '2024-05-04 07:35:00', '2024-05-04 08:10:00', 8.7, 36100, 'gopay', 'paid'),
(7, 8, 4, 8, 'completed', '2024-05-04 08:00:00', '2024-05-04 08:05:00', '2024-05-04 08:40:00', 7.5, 32500, 'ovo', 'paid'),
(8, 1, 6, 10, 'completed', '2024-05-04 08:30:00', '2024-05-04 08:35:00', '2024-05-04 09:15:00', 12.3, 46900, 'cash', 'paid'),
(9, 2, 8, 12, 'completed', '2024-05-04 09:00:00', '2024-05-04 09:05:00', '2024-05-04 09:50:00', 15.6, 56800, 'gopay', 'paid'),
(10, 3, 10, 14, 'completed', '2024-05-04 17:30:00', '2024-05-04 17:35:00', '2024-05-04 18:20:00', 16.4, 59200, 'ovo', 'paid'),
(1, 4, 12, 1, 'completed', '2024-05-04 18:00:00', '2024-05-04 18:05:00', '2024-05-04 18:50:00', 19.2, 67600, 'cash', 'paid'),
(2, 5, 14, 3, 'completed', '2024-05-04 18:30:00', '2024-05-04 18:35:00', '2024-05-04 19:20:00', 17.8, 63400, 'gopay', 'paid'),
(3, 6, 1, 5, 'completed', '2024-05-04 19:00:00', '2024-05-04 19:05:00', '2024-05-04 19:45:00', 11.6, 44800, 'ovo', 'paid'),
(4, 7, 3, 7, 'completed', '2024-05-04 20:00:00', '2024-05-04 20:05:00', '2024-05-04 20:45:00', 13.4, 50200, 'cash', 'paid'),
(5, 8, 5, 9, 'completed', '2024-05-04 21:00:00', '2024-05-04 21:05:00', '2024-05-04 21:40:00', 10.8, 42400, 'gopay', 'paid');

-- ============================================
-- 6. INSERT USER_SESSIONS (login/logout data)
-- ============================================

-- Active sessions (current online users)
INSERT INTO user_sessions (user_id, login_time, logout_time, session_status, device_info) VALUES
(3, CURRENT_TIMESTAMP - INTERVAL '30 minutes', NULL, 'active', 'Android 13, Samsung Galaxy S23'),
(4, CURRENT_TIMESTAMP - INTERVAL '1 hour', NULL, 'active', 'iOS 16, iPhone 14 Pro'),
(13, CURRENT_TIMESTAMP - INTERVAL '2 hours', NULL, 'active', 'Android 12, Xiaomi Redmi Note 11'),
(14, CURRENT_TIMESTAMP - INTERVAL '45 minutes', NULL, 'active', 'Android 13, Oppo Reno 8'),
(1, CURRENT_TIMESTAMP - INTERVAL '15 minutes', NULL, 'active', 'Windows 11, Chrome Browser');

-- Inactive sessions (recently logged out)
INSERT INTO user_sessions (user_id, login_time, logout_time, session_status, device_info) VALUES
(5, CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'inactive', 'Android 11, Vivo Y21'),
(6, CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP - INTERVAL '3 hours', 'inactive', 'iOS 15, iPhone 13'),
(15, CURRENT_TIMESTAMP - INTERVAL '5 hours', CURRENT_TIMESTAMP - INTERVAL '1 hour', 'inactive', 'Android 13, Realme 9 Pro'),
(16, CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '4 hours', 'inactive', 'Android 12, Samsung A53'),
(2, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '30 minutes', 'inactive', 'MacOS, Safari Browser');

-- Historical sessions (older logins)
INSERT INTO user_sessions (user_id, login_time, logout_time, session_status, device_info) VALUES
(7, '2024-05-01 08:30:00', '2024-05-01 12:00:00', 'inactive', 'Android 12, Pixel 6'),
(8, '2024-05-01 09:15:00', '2024-05-01 13:30:00', 'inactive', 'iOS 16, iPhone 12'),
(17, '2024-05-01 07:00:00', '2024-05-01 15:00:00', 'inactive', 'Android 13, Motorola Edge 30'),
(18, '2024-05-02 08:00:00', '2024-05-02 16:00:00', 'inactive', 'Android 12, Samsung S21'),
(9, '2024-05-02 10:30:00', '2024-05-02 14:45:00', 'inactive', 'Windows 10, Firefox Browser');

-- ============================================
-- 7. INSERT REVIEWS (customer reviews for drivers)
-- ============================================

INSERT INTO reviews (order_id, customer_id, driver_id, rating, review_text) VALUES
-- Reviews for driver 1 (Joko Susilo)
(1, 1, 1, 5, 'Driver sangat ramah dan tepat waktu. Motor bersih dan nyaman.'),
(10, 4, 1, 4, 'Baik, sedikit terlambat tapi masih dalam toleransi.'),
(26, 1, 1, 5, 'Sempurna! Selalu order dengan driver ini.'),
(41, 6, 1, 4, 'Pengemudi hati-hati, aman untuk keluarga.'),

-- Reviews for driver 2 (Rina Dewi)
(2, 2, 2, 5, 'Driver perempuan yang sangat profesional. Safety first!'),
(11, 7, 2, 5, 'Sangat recommended untuk perempuan yang sendirian.'),
(27, 2, 2, 4, 'Baik, komunikatif.'),
(42, 7, 2, 5, 'Terima kasih sudah antar sampai depan pintu.'),

-- Reviews for driver 3 (Herman Setiawan)
(3, 3, 3, 5, 'Mobil sangat bersih dan nyaman. AC dingin.'),
(12, 8, 3, 4, 'Nyaman untuk perjalanan jauh.'),
(28, 3, 3, 5, 'Professional seperti taksi bandara.'),
(43, 8, 3, 5, 'Sempurna untuk meeting penting.'),

-- Reviews for driver 4 (Agus Pratama)
(4, 4, 4, 4, 'Motor lumayan nyaman. Oke lah.'),
(13, 9, 4, 3, 'Biasa aja, tidak spesial.'),
(29, 4, 4, 4, 'Cukup baik, harga sesuai.'),
(44, 9, 4, 5, 'Hari ini sangat baik, tepat waktu.'),

-- Reviews for driver 5 (Sari Melati)
(5, 5, 5, 5, 'Sangat ramah dan pengertian.'),
(14, 10, 5, 4, 'Baik, membantu bawa barang.'),
(30, 5, 5, 5, 'Super! Sangat membantu.'),
(45, 10, 5, 5, 'Driver terbaik sejauh ini.'),

-- Reviews for driver 6 (Bambang Saputra)
(6, 1, 6, 4, 'Mobil bersih, supir sopan.'),
(15, 6, 6, 3, 'Agak lambat, tapi aman.'),
(31, 1, 6, 4, 'Cukup memuaskan.'),
(46, 6, 6, 5, 'Hari ini sangat cepat, terima kasih.'),

-- Reviews for driver 7 (Eko Purnomo)
(7, 2, 7, 5, 'Sangat profesional, seperti sopir pribadi.'),
(16, 7, 7, 4, 'Mobil mewah, harga standar. Worth it.'),
(32, 2, 7, 5, 'Selalu memuaskan.'),
(47, 7, 7, 4, 'Baik, tapi agak mahal.'),

-- Reviews for driver 8 (Fajar Adi)
(8, 3, 8, 4, 'Muda tapi berpengalaman.'),
(17, 8, 8, 5, 'Very good driver, English speaking.'),
(33, 3, 8, 4, 'Cukup baik untuk driver muda.'),
(48, 8, 8, 5, 'Excellent service!');

-- ============================================
-- DATA VERIFICATION QUERIES
-- ============================================

-- Check total counts
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'locations', COUNT(*) FROM locations
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'user_sessions', COUNT(*) FROM user_sessions
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
ORDER BY table_name;

-- Check orders by month (Fitur 1 preview)
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') as bulan,
    COUNT(*) as total_order,
    COUNT(CASE WHEN order_status = 'completed' THEN 1 END) as completed,
    COUNT(CASE WHEN order_status = 'cancelled' THEN 1 END) as cancelled
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY bulan;

-- Check top customers (Fitur 2 preview)
SELECT 
    c.full_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.fare_amount) as total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'completed'
GROUP BY c.customer_id, c.full_name
ORDER BY total_orders DESC
LIMIT 5;

-- ============================================
-- END OF DUMMY DATA
-- ============================================