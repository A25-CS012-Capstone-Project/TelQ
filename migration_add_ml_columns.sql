-- Migration: Add ML columns to existing database
-- Run this after importing telq_backup_fixed.sql

-- Add behavior_segment to user_features if not exists
ALTER TABLE user_features ADD COLUMN IF NOT EXISTS behavior_segment INTEGER DEFAULT 0;

-- Add pop_score to products if not exists
ALTER TABLE products ADD COLUMN IF NOT EXISTS pop_score FLOAT DEFAULT 0.0;

-- Compute pop_score from purchase history (proportion of total purchases)
UPDATE products p SET pop_score = (
    SELECT COUNT(*)::FLOAT / NULLIF((SELECT COUNT(*) FROM purchase_history), 0)
    FROM purchase_history ph WHERE ph.product_id = p.product_id
);

-- Confirm the changes
SELECT 'Migration completed successfully' AS status;
