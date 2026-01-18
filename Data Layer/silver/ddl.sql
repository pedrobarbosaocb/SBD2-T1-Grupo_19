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
DROP TABLE IF EXISTS silver.users CASCADE;

CREATE TABLE silver.users (
    user_id BIGINT PRIMARY KEY,
    gender VARCHAR(20),
    age INT CHECK (age >= 0),
    country VARCHAR(100),
    income_level VARCHAR(50),
    employment_status VARCHAR(50),
    has_children BOOLEAN,
    education_level VARCHAR(50),
    relationship_status VARCHAR(50),
    ads_clicked_per_day INT,
    ads_viewed_per_day INT,
    daily_active_minutes_instagram INT,
    time_on_feed_per_day INT,
    time_on_reels_per_day INT,
    sessions_per_day INT,
    average_session_length_minutes NUMERIC(5,2),
    user_engagement_score NUMERIC(5,2),
    perceived_stress_score NUMERIC(5,2),
    self_reported_happiness NUMERIC(5,2)
);
