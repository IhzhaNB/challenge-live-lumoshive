-- ============================================
-- 1. CREATE APPLICATION ROLES
-- ============================================

-- Buat roles untuk aplikasi
CREATE ROLE lumoshive_admin;
CREATE ROLE lumoshive_customer;
CREATE ROLE lumoshive_driver;

-- ============================================
-- 2. CREATE APPLICATION USER
-- ============================================

-- User untuk aplikasi backend (akan connect sebagai ini)
DROP USER IF EXISTS lumoshive_app;
CREATE USER lumoshive_app WITH PASSWORD 'SecurePass123!';

-- ============================================
-- 3. GRANT BASIC PERMISSIONS
-- ============================================

-- Grant connect ke database
GRANT CONNECT ON DATABASE lumoshive_ojek_online TO 
    lumoshive_admin, lumoshive_customer, lumoshive_driver, lumoshive_app;

-- Grant usage pada schema public
GRANT USAGE ON SCHEMA public TO 
    lumoshive_admin, lumoshive_customer, lumoshive_driver, lumoshive_app;

-- ============================================
-- 4. ADMIN PERMISSIONS (FULL ACCESS)
-- ============================================

-- Admin bisa semua: CREATE, READ, UPDATE, DELETE semua tabel
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO lumoshive_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO lumoshive_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO lumoshive_admin;

-- Admin bisa akses semua views
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lumoshive_admin;

-- ============================================
-- 5. CUSTOMER PERMISSIONS (LIMITED ACCESS)
-- ============================================

-- Customers table: hanya bisa CRUD data sendiri
GRANT SELECT, INSERT, UPDATE ON customers TO lumoshive_customer;

-- Drivers table: hanya bisa lihat driver aktif
GRANT SELECT ON drivers TO lumoshive_customer;

-- Locations table: hanya bisa lihat
GRANT SELECT ON locations TO lumoshive_customer;

-- Orders table: hanya bisa CRUD order milik sendiri
GRANT SELECT, INSERT ON orders TO lumoshive_customer;
GRANT UPDATE ON orders TO lumoshive_customer 
    WHERE (customer_id IN (SELECT customer_id FROM customers WHERE user_id = current_user_id()));

-- User_sessions table: hanya bisa akses session sendiri
GRANT SELECT, INSERT, UPDATE ON user_sessions TO lumoshive_customer;

-- Reviews table: hanya bisa CRUD review milik sendiri
GRANT SELECT, INSERT ON reviews TO lumoshive_customer;
GRANT UPDATE ON reviews TO lumoshive_customer 
    WHERE (customer_id IN (SELECT customer_id FROM customers WHERE user_id = current_user_id()));

-- Sequences untuk customer activities
GRANT USAGE ON SEQUENCE orders_order_id_seq TO lumoshive_customer;
GRANT USAGE ON SEQUENCE reviews_review_id_seq TO lumoshive_customer;
GRANT USAGE ON SEQUENCE user_sessions_session_id_seq TO lumoshive_customer;

-- ============================================
-- 6. DRIVER PERMISSIONS (SPECIFIC ACCESS)
-- ============================================

-- Drivers table: hanya bisa update data sendiri
GRANT SELECT, UPDATE ON drivers TO lumoshive_driver;

-- Customers table: hanya bisa lihat nama & phone (untuk order)
GRANT SELECT (customer_id, full_name, phone_number) ON customers TO lumoshive_driver;

-- Locations table: hanya bisa lihat
GRANT SELECT ON locations TO lumoshive_driver;

-- Orders table: hanya bisa update order yang ditugaskan
GRANT SELECT ON orders TO lumoshive_driver;
GRANT UPDATE ON orders TO lumoshive_driver 
    WHERE (driver_id IN (SELECT driver_id FROM drivers WHERE user_id = current_user_id()));

-- User_sessions table: hanya bisa akses session sendiri
GRANT SELECT, INSERT, UPDATE ON user_sessions TO lumoshive_driver;

-- Reviews table: hanya bisa lihat review untuk dirinya
GRANT SELECT ON reviews TO lumoshive_driver 
    WHERE (driver_id IN (SELECT driver_id FROM drivers WHERE user_id = current_user_id()));

-- Sequences untuk driver activities
GRANT USAGE ON SEQUENCE user_sessions_session_id_seq TO lumoshive_driver;

-- ============================================
-- 7. VIEWS PERMISSIONS
-- ============================================

-- Semua role bisa akses views (read-only)
GRANT SELECT ON monthly_order_summary TO lumoshive_admin, lumoshive_customer, lumoshive_driver;
GRANT SELECT ON top_customers_monthly TO lumoshive_admin, lumoshive_driver;
GRANT SELECT ON popular_locations TO lumoshive_admin, lumoshive_customer, lumoshive_driver;
GRANT SELECT ON driver_performance_monthly TO lumoshive_admin, lumoshive_driver;
GRANT SELECT ON user_login_status TO lumoshive_admin;

-- Views khusus customer (hanya data sendiri)
CREATE VIEW customer_my_orders AS
SELECT * FROM orders 
WHERE customer_id IN (SELECT customer_id FROM customers WHERE user_id = current_user_id());

GRANT SELECT ON customer_my_orders TO lumoshive_customer;

-- Views khusus driver (hanya data sendiri)
CREATE VIEW driver_my_orders AS
SELECT * FROM orders 
WHERE driver_id IN (SELECT driver_id FROM drivers WHERE user_id = current_user_id());

GRANT SELECT ON driver_my_orders TO lumoshive_driver;

-- ============================================
-- 8. FUNCTIONS PERMISSIONS
-- ============================================

-- Functions untuk semua role
GRANT EXECUTE ON FUNCTION calculate_fare(DECIMAL) TO 
    lumoshive_admin, lumoshive_customer, lumoshive_driver;

-- Functions khusus admin
GRANT EXECUTE ON FUNCTION get_order_statistics(DATE, DATE) TO lumoshive_admin;

-- Functions khusus customer
GRANT EXECUTE ON FUNCTION calculate_fare(DECIMAL) TO lumoshive_customer;

-- Functions khusus driver  
GRANT EXECUTE ON FUNCTION calculate_fare(DECIMAL) TO lumoshive_driver;

-- ============================================
-- 9. APPLICATION USER SETUP
-- ============================================

-- App user inherit dari semua roles
GRANT lumoshive_admin TO lumoshive_app;
GRANT lumoshive_customer TO lumoshive_app;
GRANT lumoshive_driver TO lumoshive_app;

-- App user punya hak untuk switch roles
ALTER USER lumoshive_app WITH SUPERUSER;  -- Atau sesuaikan dengan kebutuhan security

-- ============================================
-- 10. ROW LEVEL SECURITY (OPTIONAL - ADVANCED)
-- ============================================

-- Enable RLS pada tabel sensitive
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- Policies untuk customers (hanya lihat data sendiri)
CREATE POLICY customer_self_policy ON customers
    FOR ALL USING (
        user_id = current_user_id() OR 
        current_user IN ('lumoshive_admin', 'lumoshive_app')
    );

-- Policies untuk orders
CREATE POLICY customer_orders_policy ON orders
    FOR SELECT USING (
        customer_id IN (SELECT customer_id FROM customers WHERE user_id = current_user_id()) OR
        driver_id IN (SELECT driver_id FROM drivers WHERE user_id = current_user_id()) OR
        current_user IN ('lumoshive_admin', 'lumoshive_app')
    );

CREATE POLICY customer_insert_orders_policy ON orders
    FOR INSERT WITH CHECK (
        customer_id IN (SELECT customer_id FROM customers WHERE user_id = current_user_id())
    );

-- Policies untuk reviews
CREATE POLICY customer_reviews_policy ON reviews
    FOR ALL USING (
        customer_id IN (SELECT customer_id FROM customers WHERE user_id = current_user_id()) OR
        driver_id IN (SELECT driver_id FROM drivers WHERE user_id = current_user_id()) OR
        current_user IN ('lumoshive_admin', 'lumoshive_app')
    );

-- Policies untuk user_sessions
CREATE POLICY user_sessions_policy ON user_sessions
    FOR ALL USING (
        user_id = current_user_id() OR
        current_user IN ('lumoshive_admin', 'lumoshive_app')
    );

-- ============================================
-- 11. CREATE HELPER FUNCTIONS FOR SECURITY
-- ============================================

-- Function untuk mendapatkan current user's customer_id
CREATE OR REPLACE FUNCTION current_customer_id()
RETURNS INTEGER AS $$
DECLARE
    cid INTEGER;
BEGIN
    SELECT customer_id INTO cid
    FROM customers 
    WHERE user_id = current_user_id();
    
    RETURN cid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function untuk mendapatkan current user's driver_id
CREATE OR REPLACE FUNCTION current_driver_id()
RETURNS INTEGER AS $$
DECLARE
    did INTEGER;
BEGIN
    SELECT driver_id INTO did
    FROM drivers 
    WHERE user_id = current_user_id();
    
    RETURN did;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function untuk check jika user adalah admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users 
        WHERE user_id = current_user_id() 
        AND user_type = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 12. CREATE SECURITY VIEWS
-- ============================================

-- View untuk admin melihat semua data dengan security context
CREATE VIEW admin_secure_users AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    u.user_type,
    u.created_at,
    CASE 
        WHEN u.user_type = 'customer' THEN c.full_name
        WHEN u.user_type = 'driver' THEN d.full_name
        ELSE 'Admin'
    END AS full_name,
    CASE 
        WHEN u.user_type = 'customer' THEN c.phone_number
        WHEN u.user_type = 'driver' THEN d.phone_number
        ELSE NULL
    END AS phone_number
FROM users u
LEFT JOIN customers c ON u.user_id = c.user_id
LEFT JOIN drivers d ON u.user_id = d.user_id
WHERE is_admin()  -- Hanya tampil jika user adalah admin
ORDER BY u.created_at DESC;

GRANT SELECT ON admin_secure_users TO lumoshive_admin;

-- View untuk driver melihat order available (dengan security)
CREATE VIEW driver_available_orders_secure AS
SELECT 
    o.order_id,
    o.order_date,
    c.full_name as customer_name,
    c.phone_number as customer_phone,
    pl.location_name as pickup_location,
    dl.location_name as destination_location,
    o.distance_km,
    o.fare_amount,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - o.order_date))/60 as minutes_waiting
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN locations pl ON o.pickup_location_id = pl.location_id
JOIN locations dl ON o.destination_location_id = dl.location_id
WHERE o.order_status = 'pending'
AND o.order_date >= CURRENT_TIMESTAMP - INTERVAL '30 minutes'
AND EXISTS (SELECT 1 FROM drivers WHERE user_id = current_user_id() AND is_active = TRUE)  -- Hanya driver aktif
ORDER BY o.order_date;

GRANT SELECT ON driver_available_orders_secure TO lumoshive_driver;

-- ============================================
-- 13. AUDIT LOGGING TABLE (OPTIONAL)
-- ============================================

-- Tabel untuk audit log (track semua perubahan penting)
CREATE TABLE IF NOT EXISTS audit_logs (
    audit_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    action_type VARCHAR(50) NOT NULL,  -- INSERT, UPDATE, DELETE
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);

GRANT INSERT ON audit_logs TO lumoshive_app;
GRANT SELECT ON audit_logs TO lumoshive_admin;

-- Function untuk log audit otomatis
CREATE OR REPLACE FUNCTION log_audit()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (
        user_id,
        action_type,
        table_name,
        record_id,
        old_values,
        new_values
    ) VALUES (
        current_user_id(),
        TG_OP,
        TG_TABLE_NAME,
        CASE 
            WHEN TG_OP = 'DELETE' THEN OLD.order_id
            ELSE NEW.order_id
        END,
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger audit untuk orders (contoh)
CREATE TRIGGER audit_orders
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION log_audit();

-- ============================================
-- 14. TEST PERMISSIONS
-- ============================================

-- Query untuk test permissions (run sebagai admin)
/*
-- Test 1: Cek semua permissions yang diberikan
SELECT 
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee LIKE 'lumoshive_%'
ORDER BY grantee, table_name;

-- Test 2: Cek role assignments
SELECT 
    rolname,
    rolsuper,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
WHERE rolname LIKE 'lumoshive_%';

-- Test 3: Cek jika RLS aktif
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('customers', 'orders', 'reviews', 'user_sessions');
*/