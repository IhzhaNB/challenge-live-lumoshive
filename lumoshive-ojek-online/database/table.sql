-- 1. TABLE: users (untuk admin, customer, driver)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('admin', 'customer', 'driver')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TABLE: customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    registration_date DATE DEFAULT CURRENT_DATE
);

-- 3. TABLE: drivers
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    vehicle_type VARCHAR(100) CHECK (vehicle_type IN ('motor', 'mobil', 'minivan')),
    vehicle_number VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    registration_date DATE DEFAULT CURRENT_DATE,
    driver_license_number VARCHAR(50)
);

-- 4. TABLE: locations
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(255) NOT NULL,
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    area_type VARCHAR(20) DEFAULT 'both' CHECK (area_type IN ('pickup', 'destination', 'both')),
    city VARCHAR(100)
);

-- 5. TABLE: orders (CORE TABLE)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    driver_id INTEGER REFERENCES drivers(driver_id),
    pickup_location_id INTEGER NOT NULL REFERENCES locations(location_id),
    destination_location_id INTEGER NOT NULL REFERENCES locations(location_id),
    order_status VARCHAR(20) DEFAULT 'pending' 
        CHECK (order_status IN ('pending', 'accepted', 'ongoing', 'completed', 'cancelled')),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pickup_time TIMESTAMP,
    completion_time TIMESTAMP,
    distance_km DECIMAL(5,2) CHECK (distance_km > 0),
    fare_amount DECIMAL(10,2) CHECK (fare_amount >= 0),
    payment_method VARCHAR(50) CHECK (payment_method IN ('cash', 'gopay', 'ovo', 'dana', 'credit_card')),
    payment_status VARCHAR(20) DEFAULT 'pending' 
        CHECK (payment_status IN ('pending', 'paid', 'failed')),
    notes TEXT
);

-- 6. TABLE: user_sessions
CREATE TABLE user_sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP,
    session_status VARCHAR(20) DEFAULT 'active' 
        CHECK (session_status IN ('active', 'inactive')),
    device_info TEXT,
    ip_address VARCHAR(45)
);

-- 7. TABLE: reviews (+1 untuk rating driver)
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    order_id INTEGER UNIQUE NOT NULL REFERENCES orders(order_id),
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id),
    rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CREATE INDEXES (OPTIMAL UNTUK 7 TABEL)
-- ============================================

-- Indexes untuk users
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_email ON users(email);

-- Indexes untuk customers
CREATE INDEX idx_customers_user_id ON customers(user_id);
CREATE INDEX idx_customers_phone ON customers(phone_number);

-- Indexes untuk drivers
CREATE INDEX idx_drivers_is_active ON drivers(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_drivers_user_id ON drivers(user_id);

-- Indexes untuk locations
CREATE INDEX idx_locations_city ON locations(city);
CREATE INDEX idx_locations_area_type ON locations(area_type);

-- Indexes untuk orders (PENTING UNTUK PERFORMANCE)
CREATE INDEX idx_orders_order_date ON orders(order_date DESC);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_driver_id ON orders(driver_id);
CREATE INDEX idx_orders_order_status ON orders(order_status);
CREATE INDEX idx_orders_pickup_location ON orders(pickup_location_id);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);

-- Composite indexes untuk query yang sering digunakan
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date DESC);
CREATE INDEX idx_orders_driver_date ON orders(driver_id, order_date DESC);
CREATE INDEX idx_orders_status_date ON orders(order_status, order_date);

-- Indexes untuk user_sessions
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_active ON user_sessions(session_status) WHERE session_status = 'active';
CREATE INDEX idx_user_sessions_login_time ON user_sessions(login_time DESC);

-- Indexes untuk reviews
CREATE INDEX idx_reviews_driver_id ON reviews(driver_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- ============================================
-- CREATE VIEWS UNTUK REPORTING
-- ============================================

-- View 1: Monthly order summary (FITUR 1)
CREATE VIEW monthly_order_summary AS
SELECT 
    DATE_TRUNC('month', order_date)::DATE AS bulan,
    EXTRACT(YEAR FROM order_date) AS tahun,
    EXTRACT(MONTH FROM order_date) AS bulan_angka,
    COUNT(*) AS total_order,
    COUNT(CASE WHEN order_status = 'completed' THEN 1 END) AS order_selesai,
    COUNT(CASE WHEN order_status = 'cancelled' THEN 1 END) AS order_dibatalkan,
    SUM(CASE WHEN order_status = 'completed' THEN fare_amount ELSE 0 END) AS total_pendapatan
FROM orders
GROUP BY DATE_TRUNC('month', order_date), EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY DATE_TRUNC('month', order_date) DESC;

-- View 2: Top customers monthly (FITUR 2)
CREATE VIEW top_customers_monthly AS
SELECT 
    DATE_TRUNC('month', o.order_date)::DATE AS bulan,
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS jumlah_order,
    ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('month', o.order_date) 
                      ORDER BY COUNT(o.order_id) DESC) AS ranking
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'completed'
GROUP BY DATE_TRUNC('month', o.order_date), c.customer_id, c.full_name;

-- View 3: Popular locations (FITUR 3)
CREATE VIEW popular_locations AS
SELECT 
    l.location_id,
    l.location_name,
    l.city,
    l.area_type,
    COUNT(o.order_id) AS total_order,
    RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS ranking_popularity
FROM locations l
LEFT JOIN orders o ON l.location_id = o.pickup_location_id
GROUP BY l.location_id, l.location_name, l.city, l.area_type;

-- View 4: Driver performance (FITUR 6)
CREATE VIEW driver_performance_monthly AS
SELECT 
    DATE_TRUNC('month', o.completion_time)::DATE AS bulan,
    d.driver_id,
    d.full_name,
    d.vehicle_type,
    COUNT(o.order_id) AS jumlah_order_selesai,
    ROUND(AVG(r.rating), 2) AS rata_rata_rating,
    SUM(o.fare_amount) AS total_pendapatan,
    ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('month', o.completion_time) 
                      ORDER BY COUNT(o.order_id) DESC) AS ranking_rajin
FROM orders o
JOIN drivers d ON o.driver_id = d.driver_id
LEFT JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'completed'
GROUP BY DATE_TRUNC('month', o.completion_time), d.driver_id, d.full_name, d.vehicle_type;

-- View 5: User login status (FITUR 5)
CREATE VIEW user_login_status AS
SELECT 
    u.user_id,
    u.username,
    u.user_type,
    CASE 
        WHEN u.user_type = 'customer' THEN c.full_name
        WHEN u.user_type = 'driver' THEN d.full_name
        ELSE 'Admin'
    END AS full_name,
    us.login_time,
    us.logout_time,
    us.session_status,
    CASE 
        WHEN us.session_status = 'active' AND us.logout_time IS NULL THEN 'Online'
        ELSE 'Offline'
    END AS online_status
FROM users u
LEFT JOIN user_sessions us ON u.user_id = us.user_id
    AND us.session_id = (
        SELECT MAX(session_id) 
        FROM user_sessions 
        WHERE user_id = u.user_id
    )
LEFT JOIN customers c ON u.user_id = c.user_id
LEFT JOIN drivers d ON u.user_id = d.user_id;

-- ============================================
-- CREATE FUNCTIONS
-- ============================================

-- Function 1: Update driver average rating
CREATE OR REPLACE FUNCTION update_driver_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE drivers d
    SET 
        -- Update average rating
        -- This is a simplified version, in reality you might want to store this in a separate column
        -- For now, we'll just note that rating is available in reviews table
        driver_license_number = driver_license_number -- dummy update to trigger
    WHERE d.driver_id = NEW.driver_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function 2: Calculate fare (basic calculation)
CREATE OR REPLACE FUNCTION calculate_fare(distance_km DECIMAL)
RETURNS DECIMAL AS $$
DECLARE
    base_fare DECIMAL := 10000;
    per_km DECIMAL := 3000;
    total_fare DECIMAL;
BEGIN
    total_fare := base_fare + (distance_km * per_km);
    -- Round to nearest 500
    total_fare := ROUND(total_fare / 500) * 500;
    
    RETURN total_fare;
END;
$$ LANGUAGE plpgsql;

-- Function 3: Get order statistics for a date range
CREATE OR REPLACE FUNCTION get_order_statistics(
    start_date DATE,
    end_date DATE
) RETURNS TABLE (
    total_orders BIGINT,
    completed_orders BIGINT,
    cancelled_orders BIGINT,
    total_revenue DECIMAL,
    avg_fare DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) AS total_orders,
        COUNT(CASE WHEN order_status = 'completed' THEN 1 END) AS completed_orders,
        COUNT(CASE WHEN order_status = 'cancelled' THEN 1 END) AS cancelled_orders,
        SUM(CASE WHEN order_status = 'completed' THEN fare_amount ELSE 0 END) AS total_revenue,
        ROUND(AVG(CASE WHEN order_status = 'completed' THEN fare_amount END), 2) AS avg_fare
    FROM orders
    WHERE DATE(order_date) BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CREATE TRIGGERS
-- ============================================

-- Trigger 1: Auto-update updated_at in users table
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_users_timestamp
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();

-- Trigger 2: Auto-set completion time when order is completed
CREATE OR REPLACE FUNCTION set_completion_time()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_status = 'completed' AND OLD.order_status != 'completed' THEN
        NEW.completion_time := CURRENT_TIMESTAMP;
        NEW.payment_status := 'paid'; -- Auto-set payment as paid when completed
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_completion_time
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION set_completion_time();

-- Trigger 3: Auto-calculate fare when distance is set
CREATE OR REPLACE FUNCTION auto_calculate_order_fare()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.distance_km IS NOT NULL AND NEW.fare_amount IS NULL THEN
        NEW.fare_amount := calculate_fare(NEW.distance_km);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_calculate_fare
    BEFORE INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION auto_calculate_order_fare();

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================

COMMENT ON TABLE users IS 'Tabel utama untuk semua jenis pengguna: admin, customer, driver';
COMMENT ON TABLE customers IS 'Profil dan informasi customer';
COMMENT ON TABLE drivers IS 'Profil driver dan informasi kendaraan';
COMMENT ON TABLE locations IS 'Data master lokasi penjemputan dan tujuan';
COMMENT ON TABLE orders IS 'Tabel transaksi utama untuk pemesanan ojek';
COMMENT ON TABLE user_sessions IS 'Melacak status login/logout pengguna';
COMMENT ON TABLE reviews IS 'Rating dan review customer untuk driver';

COMMENT ON COLUMN orders.order_status IS 'Status order: pending, accepted, ongoing, completed, cancelled';
COMMENT ON COLUMN orders.payment_status IS 'Status pembayaran: pending, paid, failed';
COMMENT ON COLUMN drivers.is_active IS 'Status aktif/tidak aktif driver';
COMMENT ON COLUMN locations.area_type IS 'Jenis lokasi: pickup, destination, both';
