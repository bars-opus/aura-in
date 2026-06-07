-- Ship 1 part A: add notification_type enum values for shop-owner reminders.
-- Must commit before the helper / trigger update can reference them.

DO $$
DECLARE
  v_typname text;
BEGIN
  SELECT t.typname INTO v_typname
  FROM pg_attribute a
  JOIN pg_type t ON t.oid = a.atttypid
  JOIN pg_class c ON c.oid = a.attrelid
  WHERE c.relname = 'scheduled_notifications'
    AND a.attname = 'notification_type'
    AND a.attnum > 0
    AND NOT a.attisdropped;

  IF v_typname IS NULL OR v_typname IN ('text', 'varchar') THEN
    RAISE NOTICE 'notification_type is not an enum — nothing to add';
    RETURN;
  END IF;

  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'booking_owner_30min');
  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'booking_owner_5min');
END $$;
