-- ============================================
-- FITUR 1: Menampilkan total order setiap bulan
-- ============================================

-- Query 1A: Detail lengkap per bulan
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') AS bulan_tahun,
    TO_CHAR(order_date, 'Month YYYY') AS nama_bulan,
    COUNT(*) AS total_order,
    COUNT(CASE WHEN order_status = 'completed' THEN 1 END) AS order_selesai,
    COUNT(CASE WHEN order_status = 'cancelled' THEN 1 END) AS order_dibatalkan,
    COUNT(CASE WHEN order_status = 'pending' THEN 1 END) AS order_pending,
    COUNT(CASE WHEN order_status = 'ongoing' THEN 1 END) AS order_berjalan,
    COUNT(CASE WHEN order_status = 'accepted' THEN 1 END) AS order_diterima,
    SUM(CASE WHEN order_status = 'completed' THEN fare_amount ELSE 0 END) AS total_pendapatan,
    ROUND(AVG(CASE WHEN order_status = 'completed' THEN fare_amount END), 2) AS rata_rata_fare,
    ROUND(100.0 * COUNT(CASE WHEN order_status = 'completed' THEN 1 END) / COUNT(*), 2) AS persentase_selesai
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM'), TO_CHAR(order_date, 'Month YYYY'), DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date) DESC;

-- Query 1B: Ringkasan per bulan (untuk dashboard)
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') AS bulan,
    COUNT(*) AS total_order,
    SUM(CASE WHEN order_status = 'completed' THEN fare_amount ELSE 0 END) AS pendapatan,
    ROUND(100.0 * COUNT(CASE WHEN order_status = 'completed' THEN 1 END) / COUNT(*), 1) AS success_rate
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM'), DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date) DESC
LIMIT 12;  -- 12 bulan terakhir

-- Query 1C: Trend bulanan (untuk chart)
WITH monthly_data AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS bulan,
        COUNT(*) AS total_order,
        SUM(CASE WHEN order_status = 'completed' THEN fare_amount ELSE 0 END) AS pendapatan
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    TO_CHAR(bulan, 'Mon YY') AS bulan_pendek,
    total_order,
    pendapatan,
    LAG(total_order) OVER (ORDER BY bulan) AS prev_month_orders,
    ROUND(100.0 * (total_order - LAG(total_order) OVER (ORDER BY bulan)) / 
          NULLIF(LAG(total_order) OVER (ORDER BY bulan), 0), 2) AS growth_percent
FROM monthly_data
ORDER BY bulan DESC
LIMIT 6;

-- ============================================
-- FITUR 2: Nama customer yang paling sering order tiap bulan
-- ============================================

-- Query 2A: Top customer per bulan
WITH customer_monthly_stats AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS bulan,
        c.customer_id,
        c.full_name AS nama_customer,
        COUNT(o.order_id) AS jumlah_order,
        SUM(o.fare_amount) AS total_pengeluaran,
        ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('month', o.order_date) 
                          ORDER BY COUNT(o.order_id) DESC, SUM(o.fare_amount) DESC) AS ranking
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'completed'  -- Hanya order yang selesai
    GROUP BY DATE_TRUNC('month', o.order_date), c.customer_id, c.full_name
)
SELECT 
    TO_CHAR(bulan, 'YYYY-MM') AS bulan,
    nama_customer,
    jumlah_order,
    total_pengeluaran,
    CASE 
        WHEN ranking = 1 THEN 'CUSTOMER TERATAS'
        WHEN ranking = 2 THEN 'RUNNER UP'
        WHEN ranking = 3 THEN 'THIRD PLACE'
        ELSE 'TOP 10'
    END AS pencapaian
FROM customer_monthly_stats
WHERE ranking <= 5  -- Top 5 per bulan
ORDER BY bulan DESC, ranking;

-- Query 2B: Customer loyal (order tiap bulan)
SELECT 
    c.customer_id,
    c.full_name AS nama_customer,
    COUNT(DISTINCT DATE_TRUNC('month', o.order_date)) AS bulan_aktif,
    COUNT(o.order_id) AS total_order,
    SUM(o.fare_amount) AS total_pengeluaran,
    ROUND(AVG(o.fare_amount), 2) AS rata_rata_per_order,
    MAX(o.order_date) AS order_terakhir
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'completed'
GROUP BY c.customer_id, c.full_name
HAVING COUNT(DISTINCT DATE_TRUNC('month', o.order_date)) >= 2  -- Aktif minimal 2 bulan
ORDER BY bulan_aktif DESC, total_order DESC
LIMIT 10;

-- Query 2C: Detail customer teraktif bulan ini
WITH current_month_top AS (
    SELECT 
        c.customer_id,
        c.full_name,
        c.phone_number,
        COUNT(o.order_id) AS order_bulan_ini,
        SUM(o.fare_amount) AS pengeluaran_bulan_ini,
        ROUND(AVG(o.fare_amount), 2) AS avg_fare_bulan_ini,
        MAX(o.order_date) AS order_terakhir
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'completed'
    AND DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY c.customer_id, c.full_name, c.phone_number
    ORDER BY order_bulan_ini DESC
    LIMIT 1
)
SELECT 
    'CUSTOMER TERAKTIF BULAN INI' AS judul,
    full_name AS nama,
    phone_number AS telepon,
    order_bulan_ini AS jumlah_order,
    pengeluaran_bulan_ini AS total_pengeluaran,
    avg_fare_bulan_ini AS rata_rata_per_order,
    order_terakhir AS terakhir_order
FROM current_month_top;

-- ============================================
-- FITUR 3: Daerah/lokasi dengan jumlah order terbanyak
-- ============================================

-- Query 3A: Top 10 lokasi paling populer
SELECT 
    l.location_id,
    l.location_name AS nama_lokasi,
    l.city AS kota,
    l.area_type AS tipe_lokasi,
    COUNT(o.order_id) AS total_order,
    COUNT(DISTINCT o.customer_id) AS jumlah_customer_unik,
    COUNT(DISTINCT o.driver_id) AS jumlah_driver_unik,
    ROUND(AVG(o.distance_km), 2) AS rata_rata_jarak,
    ROUND(AVG(o.fare_amount), 2) AS rata_rata_fare,
    RANK() OVER (ORDER BY COUNT(o.order_id) DESC) AS peringkat_popularitas
FROM locations l
LEFT JOIN orders o ON l.location_id = o.pickup_location_id
WHERE o.order_status = 'completed' OR o.order_id IS NULL
GROUP BY l.location_id, l.location_name, l.city, l.area_type
ORDER BY total_order DESC NULLS LAST, nama_lokasi
LIMIT 10;

-- Query 3B: Hotspot area (lokasi dengan order > threshold)
SELECT 
    l.location_name AS hotspot_area,
    l.city AS kota,
    COUNT(o.order_id) AS total_order,
    ROUND(100.0 * COUNT(o.order_id) / SUM(COUNT(o.order_id)) OVER (), 2) AS persentase_total,
    CASE 
        WHEN COUNT(o.order_id) >= 20 THEN 'HOTSPOT TINGGI'
        WHEN COUNT(o.order_id) >= 10 THEN 'HOTSPOT SEDANG'
        WHEN COUNT(o.order_id) >= 5 THEN 'HOTSPOT RENDAH'
        ELSE '📌 AREA BIASA'
    END AS kategori_hotspot
FROM locations l
JOIN orders o ON l.location_id = o.pickup_location_id
WHERE o.order_status = 'completed'
GROUP BY l.location_id, l.location_name, l.city
HAVING COUNT(o.order_id) >= 5  -- Minimal 5 order
ORDER BY total_order DESC;

-- Query 3C: Pair lokasi favorit (pickup -> destination)
WITH location_pairs AS (
    SELECT 
        pl.location_name AS lokasi_penjemputan,
        dl.location_name AS lokasi_tujuan,
        COUNT(*) AS frekuensi,
        ROUND(AVG(o.distance_km), 2) AS rata_rata_jarak,
        ROUND(AVG(o.fare_amount), 2) AS rata_rata_fare
    FROM orders o
    JOIN locations pl ON o.pickup_location_id = pl.location_id
    JOIN locations dl ON o.destination_location_id = dl.location_id
    WHERE o.order_status = 'completed'
    GROUP BY pl.location_name, dl.location_name
)
SELECT 
    lokasi_penjemputan,
    lokasi_tujuan,
    frekuensi,
    rata_rata_jarak || ' km' AS jarak_rata_rata,
    'Rp ' || rata_rata_fare AS fare_rata_rata,
    RANK() OVER (ORDER BY frekuensi DESC) AS ranking_popularitas
FROM location_pairs
WHERE frekuensi >= 3  -- Minimal 3 kali terjadi
ORDER BY frekuensi DESC
LIMIT 15;

-- ============================================
-- FITUR 4: Waktu (jam) order ramai dan sepi
-- ============================================

-- Query 4A: Distribusi order per jam (24 jam)
WITH hourly_stats AS (
    SELECT 
        EXTRACT(HOUR FROM order_date)::INTEGER AS jam,
        TO_CHAR(order_date, 'Day') AS hari,
        COUNT(*) AS jumlah_order,
        ROUND(AVG(fare_amount), 2) AS rata_rata_fare,
        SUM(fare_amount) AS total_pendapatan,
        ROUND(AVG(distance_km), 2) AS rata_rata_jarak
    FROM orders
    WHERE order_status = 'completed'
    AND order_date >= CURRENT_DATE - INTERVAL '30 days'  -- 30 hari terakhir
    GROUP BY EXTRACT(HOUR FROM order_date), TO_CHAR(order_date, 'Day')
)
SELECT 
    jam,
    TRIM(hari) AS hari,
    jumlah_order,
    rata_rata_fare,
    total_pendapatan,
    rata_rata_jarak,
    RANK() OVER (ORDER BY jumlah_order DESC) AS ranking_ramai,
    RANK() OVER (ORDER BY jumlah_order ASC) AS ranking_sepi,
    CASE 
        WHEN RANK() OVER (ORDER BY jumlah_order DESC) = 1 THEN 'PUNCAK RAMAI'
        WHEN RANK() OVER (ORDER BY jumlah_order DESC) <= 3 THEN 'JAM SIBUK'
        WHEN RANK() OVER (ORDER BY jumlah_order ASC) = 1 THEN 'JAM SEPI'
        WHEN RANK() OVER (ORDER BY jumlah_order ASC) <= 3 THEN 'JAM TENANG'
        ELSE 'JAM NORMAL'
    END AS kategori_waktu
FROM hourly_stats
ORDER BY jam, 
    CASE TRIM(hari)
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- Query 4B: Peak hours analysis (per hari kerja vs weekend)
SELECT 
    CASE 
        WHEN TRIM(TO_CHAR(order_date, 'Day')) IN ('Saturday', 'Sunday') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS tipe_hari,
    EXTRACT(HOUR FROM order_date)::INTEGER AS jam,
    COUNT(*) AS jumlah_order,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY 
        CASE 
            WHEN TRIM(TO_CHAR(order_date, 'Day')) IN ('Saturday', 'Sunday') THEN 'WEEKEND'
            ELSE 'WEEKDAY'
        END
    ), 2) AS persentase
FROM orders
WHERE order_status = 'completed'
AND order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY 
    CASE 
        WHEN TRIM(TO_CHAR(order_date, 'Day')) IN ('Saturday', 'Sunday') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END,
    EXTRACT(HOUR FROM order_date)
ORDER BY tipe_hari, jumlah_order DESC;

-- Query 4C: Rekomendasi waktu untuk driver
WITH hour_recommendation AS (
    SELECT 
        EXTRACT(HOUR FROM order_date)::INTEGER AS jam,
        COUNT(*) AS permintaan,
        COUNT(DISTINCT driver_id) AS driver_available,
        ROUND(AVG(fare_amount), 2) AS avg_fare,
        ROUND(CAST(COUNT(*) AS DECIMAL) / NULLIF(COUNT(DISTINCT driver_id), 0), 2) AS order_per_driver
    FROM orders
    WHERE order_status = 'completed'
    AND order_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY EXTRACT(HOUR FROM order_date)
)
SELECT 
    jam || ':00 - ' || jam || ':59' AS waktu,
    permintaan,
    driver_available,
    avg_fare,
    order_per_driver,
    CASE 
        WHEN order_per_driver >= 3 THEN 'WAKTU TERBAIK (High Demand)'
        WHEN order_per_driver >= 2 THEN 'WAKTU BAIK (Moderate Demand)'
        WHEN order_per_driver >= 1 THEN 'WAKTU STANDAR'
        ELSE 'WAKTU SEPI'
    END AS rekomendasi_untuk_driver
FROM hour_recommendation
ORDER BY order_per_driver DESC;

-- ============================================
-- FITUR 5: Jumlah customer yang sedang login dan logout
-- ============================================

-- Query 5A: Status login real-time
WITH latest_sessions AS (
    SELECT 
        u.user_id,
        u.username,
        u.user_type,
        us.session_status,
        us.login_time,
        us.logout_time,
        ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY us.login_time DESC) AS rn
    FROM users u
    LEFT JOIN user_sessions us ON u.user_id = us.user_id
    WHERE u.user_type IN ('customer', 'driver')  -- Hanya customer & driver
)
SELECT 
    user_type AS tipe_pengguna,
    COUNT(*) AS total_pengguna,
    COUNT(CASE WHEN session_status = 'active' AND logout_time IS NULL THEN 1 END) AS sedang_login,
    COUNT(CASE WHEN session_status = 'inactive' OR logout_time IS NOT NULL THEN 1 END) AS sudah_logout,
    COUNT(CASE WHEN session_status IS NULL THEN 1 END) AS belum_pernah_login,
    ROUND(100.0 * COUNT(CASE WHEN session_status = 'active' AND logout_time IS NULL THEN 1 END) / COUNT(*), 2) AS persentase_online
FROM latest_sessions
WHERE rn = 1 OR rn IS NULL
GROUP BY user_type
UNION ALL
SELECT 
    'TOTAL' AS tipe_pengguna,
    SUM(COUNT(*)) OVER () AS total_pengguna,
    SUM(COUNT(CASE WHEN session_status = 'active' AND logout_time IS NULL THEN 1 END)) OVER () AS sedang_login,
    SUM(COUNT(CASE WHEN session_status = 'inactive' OR logout_time IS NOT NULL THEN 1 END)) OVER () AS sudah_logout,
    SUM(COUNT(CASE WHEN session_status IS NULL THEN 1 END)) OVER () AS belum_pernah_login,
    ROUND(100.0 * SUM(COUNT(CASE WHEN session_status = 'active' AND logout_time IS NULL THEN 1 END)) OVER () / 
          SUM(COUNT(*)) OVER (), 2) AS persentase_online
FROM latest_sessions
WHERE rn = 1 OR rn IS NULL
GROUP BY 1
ORDER BY 
    CASE user_type 
        WHEN 'TOTAL' THEN 3
        WHEN 'customer' THEN 1
        WHEN 'driver' THEN 2
    END;

-- Query 5B: Detail user online sekarang
SELECT 
    u.user_id,
    u.username,
    u.user_type,
    CASE 
        WHEN u.user_type = 'customer' THEN c.full_name
        WHEN u.user_type = 'driver' THEN d.full_name
        ELSE 'Admin'
    END AS nama_lengkap,
    us.login_time AS waktu_login,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - us.login_time)) / 60 AS menit_online,
    us.device_info AS perangkat,
    us.ip_address AS alamat_ip
FROM users u
LEFT JOIN user_sessions us ON u.user_id = us.user_id
    AND us.session_id = (
        SELECT MAX(session_id) 
        FROM user_sessions 
        WHERE user_id = u.user_id
    )
LEFT JOIN customers c ON u.user_id = c.user_id
LEFT JOIN drivers d ON u.user_id = d.user_id
WHERE us.session_status = 'active'
AND us.logout_time IS NULL
AND u.user_type IN ('customer', 'driver')
ORDER BY us.login_time DESC;

-- Query 5C: Login activity patterns
SELECT 
    TO_CHAR(login_time, 'HH24:00') AS jam_login,
    TO_CHAR(login_time, 'Day') AS hari,
    COUNT(*) AS jumlah_login,
    ROUND(AVG(EXTRACT(EPOCH FROM (logout_time - login_time)) / 60), 2) AS rata_rata_durasi_menit
FROM user_sessions
WHERE logout_time IS NOT NULL
AND login_time >= CURRENT_DATE - INTERVAL '7 days'  -- 7 hari terakhir
GROUP BY TO_CHAR(login_time, 'HH24:00'), TO_CHAR(login_time, 'Day')
ORDER BY 
    CASE TO_CHAR(login_time, 'Day')
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,
    TO_CHAR(login_time, 'HH24:00');

-- ============================================
-- FITUR 6: Driver paling rajin (paling banyak order sampai selesai) tiap bulan
-- ============================================

-- Query 6A: Top drivers per bulan
WITH driver_monthly_performance AS (
    SELECT 
        DATE_TRUNC('month', o.completion_time) AS bulan,
        d.driver_id,
        d.full_name AS nama_driver,
        d.vehicle_type AS tipe_kendaraan,
        d.vehicle_number AS plat_nomor,
        COUNT(o.order_id) AS jumlah_order_selesai,
        SUM(o.fare_amount) AS total_pendapatan,
        ROUND(AVG(o.distance_km), 2) AS rata_rata_jarak,
        ROUND(AVG(o.fare_amount), 2) AS rata_rata_fare,
        ROUND(AVG(r.rating), 2) AS rata_rata_rating,
        SUM(o.distance_km) AS total_jarak_tempuh,
        ROW_NUMBER() OVER (PARTITION BY DATE_TRUNC('month', o.completion_time) 
                          ORDER BY COUNT(o.order_id) DESC, SUM(o.fare_amount) DESC) AS ranking
    FROM orders o
    JOIN drivers d ON o.driver_id = d.driver_id
    LEFT JOIN reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'completed'
    AND o.completion_time IS NOT NULL
    GROUP BY DATE_TRUNC('month', o.completion_time), d.driver_id, d.full_name, 
             d.vehicle_type, d.vehicle_number
)
SELECT 
    TO_CHAR(bulan, 'YYYY-MM') AS bulan,
    ranking AS peringkat,
    nama_driver,
    tipe_kendaraan,
    plat_nomor,
    jumlah_order_selesai,
    total_pendapatan,
    rata_rata_rating || '/5' AS rating,
    total_jarak_tempuh || ' km' AS jarak_tempuh,
    CASE 
        WHEN ranking = 1 THEN 'DRIVER OF THE MONTH'
        WHEN ranking <= 3 THEN 'TOP PERFORMER'
        WHEN ranking <= 5 THEN 'EXCELLENT'
        WHEN ranking <= 10 THEN 'GOOD'
        ELSE 'AVERAGE'
    END AS kategori_prestasi
FROM driver_monthly_performance
WHERE ranking <= 15  -- Top 15 driver per bulan
ORDER BY bulan DESC, ranking;

-- Query 6B: Driver consistency (perform baik tiap bulan)
WITH driver_monthly_rank AS (
    SELECT 
        d.driver_id,
        d.full_name,
        DATE_TRUNC('month', o.completion_time) AS bulan,
        COUNT(o.order_id) AS monthly_orders,
        RANK() OVER (PARTITION BY DATE_TRUNC('month', o.completion_time) 
                    ORDER BY COUNT(o.order_id) DESC) AS monthly_rank
    FROM orders o
    JOIN drivers d ON o.driver_id = d.driver_id
    WHERE o.order_status = 'completed'
    GROUP BY d.driver_id, d.full_name, DATE_TRUNC('month', o.completion_time)
)
SELECT 
    driver_id,
    full_name AS nama_driver,
    COUNT(DISTINCT bulan) AS total_bulan_aktif,
    MIN(monthly_rank) AS peringkat_terbaik,
    MAX(monthly_rank) AS peringkat_terburuk,
    ROUND(AVG(monthly_rank), 2) AS rata_rata_peringkat,
    SUM(CASE WHEN monthly_rank <= 5 THEN 1 ELSE 0 END) AS kali_top_5,
    SUM(CASE WHEN monthly_rank <= 10 THEN 1 ELSE 0 END) AS kali_top_10,
    CASE 
        WHEN AVG(monthly_rank) <= 3 THEN 'CONSISTENT TOP PERFORMER'
        WHEN AVG(monthly_rank) <= 5 THEN 'REGULAR PERFORMER'
        WHEN AVG(monthly_rank) <= 10 THEN 'STEADY PERFORMER'
        ELSE 'OCCASIONAL PERFORMER'
    END AS kategori_konsistensi
FROM driver_monthly_rank
GROUP BY driver_id, full_name
HAVING COUNT(DISTINCT bulan) >= 2  -- Minimal aktif 2 bulan
ORDER BY rata_rata_peringkat, total_bulan_aktif DESC
LIMIT 20;

-- Query 6C: Driver stats bulan ini (real-time)
WITH current_month_stats AS (
    SELECT 
        d.driver_id,
        d.full_name,
        d.vehicle_type,
        d.vehicle_number,
        d.is_active,
        COUNT(o.order_id) AS order_bulan_ini,
        SUM(CASE WHEN o.order_status = 'completed' THEN 1 ELSE 0 END) AS selesai_bulan_ini,
        SUM(CASE WHEN o.order_status = 'completed' THEN o.fare_amount ELSE 0 END) AS pendapatan_bulan_ini,
        ROUND(AVG(CASE WHEN o.order_status = 'completed' THEN r.rating END), 2) AS rating_bulan_ini
    FROM drivers d
    LEFT JOIN orders o ON d.driver_id = o.driver_id
        AND DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', CURRENT_DATE)
    LEFT JOIN reviews r ON o.order_id = r.order_id
    WHERE d.is_active = TRUE
    GROUP BY d.driver_id, d.full_name, d.vehicle_type, d.vehicle_number, d.is_active
)
SELECT 
    '🚀 PERFORMANCE DRIVER BULAN INI' AS judul_laporan,
    full_name AS nama_driver,
    vehicle_type || ' (' || vehicle_number || ')' AS kendaraan,
    order_bulan_ini AS total_order,
    selesai_bulan_ini AS order_selesai,
    pendapatan_bulan_ini AS total_pendapatan,
    rating_bulan_ini || '/5' AS rating_rata_rata,
    CASE 
        WHEN selesai_bulan_ini >= 15 THEN 'SUPER AKTIF'
        WHEN selesai_bulan_ini >= 10 THEN 'SANGAT AKTIF'
        WHEN selesai_bulan_ini >= 5 THEN 'AKTIF'
        WHEN selesai_bulan_ini >= 1 THEN 'STANDAR'
        ELSE 'BELUM ADA ORDER'
    END AS status_aktivitas
FROM current_month_stats
ORDER BY selesai_bulan_ini DESC, pendapatan_bulan_ini DESC
LIMIT 10;

-- ============================================
-- BONUS QUERIES: Untuk dashboard admin
-- ============================================

-- Bonus 1: Executive summary (dashboard utama)
SELECT 
    '📊 EXECUTIVE SUMMARY - ' || TO_CHAR(CURRENT_DATE, 'DD Mon YYYY') AS judul,
    (SELECT COUNT(*) FROM users WHERE user_type = 'customer') AS total_customer,
    (SELECT COUNT(*) FROM users WHERE user_type = 'driver') AS total_driver,
    (SELECT COUNT(*) FROM drivers WHERE is_active = TRUE) AS driver_aktif,
    (SELECT COUNT(*) FROM orders WHERE DATE(order_date) = CURRENT_DATE) AS order_hari_ini,
    (SELECT COUNT(*) FROM orders WHERE order_status = 'ongoing') AS order_berjalan,
    (SELECT SUM(fare_amount) FROM orders WHERE order_status = 'completed' AND DATE(order_date) = CURRENT_DATE) AS pendapatan_hari_ini,
    (SELECT COUNT(*) FROM user_sessions WHERE session_status = 'active' AND logout_time IS NULL) AS user_online,
    (SELECT ROUND(AVG(rating), 2) FROM reviews) AS rating_rata_rata
FROM (SELECT 1) AS dummy;

-- Bonus 2: Recent activities
SELECT 
    'AKTIVITAS TERAKHIR' AS kategori,
    CASE 
        WHEN o.order_id IS NOT NULL THEN 'Order #' || o.order_id || ' - ' || o.order_status
        WHEN r.review_id IS NOT NULL THEN 'Review oleh ' || c.full_name
        WHEN us.session_id IS NOT NULL THEN u.username || ' - ' || us.session_status
        ELSE 'Aktivitas lain'
    END AS aktivitas,
    COALESCE(o.order_date, r.created_at, us.login_time) AS waktu,
    CASE 
        WHEN o.order_id IS NOT NULL THEN 'orders'
        WHEN r.review_id IS NOT NULL THEN 'reviews'
        WHEN us.session_id IS NOT NULL THEN 'sessions'
        ELSE 'other'
    END AS tipe
FROM (
    SELECT order_id, order_date, order_status FROM orders ORDER BY order_date DESC LIMIT 5
) o
FULL OUTER JOIN (
    SELECT r.review_id, r.created_at, c.full_name 
    FROM reviews r 
    JOIN customers c ON r.customer_id = c.customer_id 
    ORDER BY r.created_at DESC LIMIT 3
) r ON 1=0
FULL OUTER JOIN (
    SELECT us.session_id, us.login_time, u.username, us.session_status
    FROM user_sessions us
    JOIN users u ON us.user_id = u.user_id
    ORDER BY us.login_time DESC LIMIT 3
) us ON 1=0
ORDER BY waktu DESC
LIMIT 10;

-- ============================================
-- TEST EXECUTION
-- ============================================

-- Test run semua fitur utama
DO $$
DECLARE
    fitur1_count INTEGER;
    fitur2_count INTEGER;
    fitur3_count INTEGER;
    fitur4_count INTEGER;
    fitur5_count INTEGER;
    fitur6_count INTEGER;
BEGIN
    -- Test Fitur 1
    SELECT COUNT(*) INTO fitur1_count FROM (
        SELECT TO_CHAR(order_date, 'YYYY-MM') FROM orders GROUP BY TO_CHAR(order_date, 'YYYY-MM')
    ) AS f1;
    RAISE NOTICE 'Fitur 1: Total % bulan dengan data order', fitur1_count;
    
    -- Test Fitur 2
    SELECT COUNT(*) INTO fitur2_count FROM (
        SELECT c.full_name FROM orders o 
        JOIN customers c ON o.customer_id = c.customer_id 
        WHERE o.order_status = 'completed'
        GROUP BY c.customer_id, c.full_name 
        HAVING COUNT(*) > 0
        LIMIT 5
    ) AS f2;
    RAISE NOTICE 'Fitur 2: % customer ditemukan dengan order selesai', fitur2_count;
    
    -- Test Fitur 3
    SELECT COUNT(*) INTO fitur3_count FROM (
        SELECT l.location_name FROM locations l 
        JOIN orders o ON l.location_id = o.pickup_location_id 
        GROUP BY l.location_id, l.location_name 
        HAVING COUNT(*) > 0
        LIMIT 5
    ) AS f3;
    RAISE NOTICE 'Fitur 3: % lokasi populer ditemukan', fitur3_count;
    
    -- Test Fitur 4
    SELECT COUNT(*) INTO fitur4_count FROM (
        SELECT EXTRACT(HOUR FROM order_date) FROM orders 
        WHERE order_status = 'completed'
        GROUP BY EXTRACT(HOUR FROM order_date)
        LIMIT 5
    ) AS f4;
    RAISE NOTICE 'Fitur 4: % jam berbeda dengan aktivitas order', fitur4_count;
    
    -- Test Fitur 5
    SELECT COUNT(*) INTO fitur5_count FROM (
        SELECT DISTINCT u.user_type FROM users u
        LEFT JOIN user_sessions us ON u.user_id = us.user_id
        WHERE u.user_type IN ('customer', 'driver')
        LIMIT 2
    ) AS f5;
    RAISE NOTICE 'Fitur 5: % tipe user ditemukan (customer/driver)', fitur5_count;
    
    -- Test Fitur 6
    SELECT COUNT(*) INTO fitur6_count FROM (
        SELECT d.full_name FROM drivers d
        JOIN orders o ON d.driver_id = o.driver_id
        WHERE o.order_status = 'completed'
        GROUP BY d.driver_id, d.full_name
        HAVING COUNT(*) > 0
        LIMIT 5
    ) AS f6;
    RAISE NOTICE 'Fitur 6: % driver dengan order selesai ditemukan', fitur6_count;
    
    RAISE NOTICE 'SEMUA 6 FITUR BERHASIL DITEST!';
END $$;

-- ============================================
-- END OF QUERIES FILE
-- ============================================