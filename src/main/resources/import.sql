-- This file is executed automatically by Hibernate on startup to create initial data/schema
-- Ensure outboxevent table exists with proper structure
CREATE TABLE IF NOT EXISTS outboxevent (
    id UUID PRIMARY KEY,
    aggregatetype VARCHAR(255) NOT NULL,
    aggregateid VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    payload TEXT,
    tracingspancontext VARCHAR(255)
);