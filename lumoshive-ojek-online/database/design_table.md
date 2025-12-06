```mermaid
erDiagram
    users {
        int user_id PK
        varchar username
        varchar password_hash
        varchar email
        varchar user_type
        timestamp created_at
        timestamp updated_at
    }
    
    customers {
        int customer_id PK
        int user_id FK
        varchar full_name
        varchar phone_number
        date date_of_birth
        date registration_date
        timestamp last_login
    }
    
    drivers {
        int driver_id PK
        int user_id FK
        varchar full_name
        varchar phone_number
        varchar vehicle_type
        varchar vehicle_number
        boolean is_active
        date registration_date
        varchar driver_license_number
        decimal average_rating
        int total_completed_orders
    }
    
    locations {
        int location_id PK
        varchar location_name
        text address
        decimal latitude
        decimal longitude
        varchar area_type
        varchar city
        varchar district
        varchar postcode
    }
    
    orders {
        int order_id PK
        int customer_id FK
        int driver_id FK
        int pickup_location_id FK
        int destination_location_id FK
        varchar order_status
        timestamp order_date
        timestamp pickup_time
        timestamp completion_time
        decimal distance_km
        decimal fare_amount
        varchar payment_method
        varchar payment_status
        text notes
        int estimated_duration_minutes
    }
    
    user_sessions {
        int session_id PK
        int user_id FK
        timestamp login_time
        timestamp logout_time
        varchar session_status
        text device_info
        varchar ip_address
        text user_agent
    }
    
    reviews {
        int review_id PK
        int order_id FK
        int customer_id FK
        int driver_id FK
        smallint rating
        text review_text
        timestamp created_at
        timestamp updated_at
    }

    users ||--o{ customers : "has"
    users ||--o{ drivers : "has"
    users ||--o{ user_sessions : "creates"
    customers ||--o{ orders : "places"
    drivers ||--o{ orders : "accepts"
    locations ||--o{ orders : "as_pickup"
    locations ||--o{ orders : "as_destination"
    orders ||--|| reviews : "has"
