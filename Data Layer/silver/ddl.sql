-- ============================================================================
-- SILVER LAYER: TABELA USER
-- Camada Silver - Dados limpos e validados do Instagram
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS silver;

-- Comentário no schema
COMMENT ON SCHEMA silver IS 'Camada Silver - Dados limpos e validados';

-- ============================================================================
-- TABELA: USER
-- ============================================================================
DROP TABLE IF EXISTS silver.USER CASCADE;

CREATE TABLE silver.USER (
    user_id INT,
    app_name VARCHAR(50),
    age INT,
    gender VARCHAR(20),
    country VARCHAR(50),
    urban_rural VARCHAR(20),
    income_level VARCHAR(20),
    employment_status VARCHAR(30),
    education_level VARCHAR(50),
    relationship_status VARCHAR(30),
    has_children BOOLEAN,
    exercise_hours_per_week DECIMAL(4,1),
    sleep_hours_per_night DECIMAL(3,1),
    diet_quality VARCHAR(20),
    smoking BOOLEAN,
    alcohol_frequency VARCHAR(20),
    perceived_stress_score INT,
    self_reported_happiness INT,
    body_mass_index DECIMAL(4,1),
    blood_pressure_systolic INT,
    blood_pressure_diastolic INT,
    daily_steps_count INT,
    weekly_work_hours DECIMAL(4,1),
    hobbies_count INT,
    social_events_per_month INT,
    books_read_per_year INT,
    volunteer_hours_per_month DECIMAL(4,1),
    travel_frequency_per_year INT,
    daily_active_minutes_instagram DECIMAL(5,1),
    sessions_per_day INT,
    posts_created_per_week INT,
    reels_watched_per_day INT,
    stories_viewed_per_day INT,
    likes_given_per_day INT,
    comments_written_per_day INT,
    dms_sent_per_week INT,
    dms_received_per_week INT,
    ads_viewed_per_day INT,
    ads_clicked_per_day INT,
    time_on_feed_per_day DECIMAL(5,1),
    time_on_explore_per_day DECIMAL(5,1),
    time_on_messages_per_day DECIMAL(5,1),
    time_on_reels_per_day DECIMAL(5,1),
    followers_count INT,
    following_count INT,
    uses_premium_features BOOLEAN,
    notification_response_rate DECIMAL(4,2),
    account_creation_year INT,
    last_login_date DATE,
    average_session_length_minutes DECIMAL(4,1),
    content_type_preference VARCHAR(30),
    preferred_content_theme VARCHAR(30),
    privacy_setting_level VARCHAR(20),
    two_factor_auth_enabled BOOLEAN,
    biometric_login_used BOOLEAN,
    linked_accounts_count INT,
    subscription_status VARCHAR(20),
    user_engagement_score DECIMAL(5,2)
);


