-- Ship 2 part A: add the client 5-min WhatsApp reminder enum value.
-- Same pattern as Ship 1: enum changes must commit before any function
-- can reference the new value as an enum constant.

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
    RETURN;
  END IF;

  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'booking_reminder_5min');
END $$;
