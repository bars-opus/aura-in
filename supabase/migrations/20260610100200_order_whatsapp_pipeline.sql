-- Order WhatsApp pipeline.
--
-- Two pieces:
--   1. enqueue_order_message(order_id, type) — writes a scheduled_notifications
--      row that the existing process-scheduled-notifications worker drains.
--      Branches on logged-in user vs guest the same way enqueue_booking_reminder
--      does (push for users, WhatsApp template for guests). For guests the
--      template name is <type>_v1 by default.
--
--   2. AFTER UPDATE trigger on orders.status — fires the right message
--      on each status transition. NO-OP if the buyer is logged-in (we keep
--      them on push only) for now; can be extended later.
--
-- Template name convention (must match Meta-approved names):
--   order_received_v1, order_confirmed_v1, order_out_for_delivery_v1,
--   order_delivered_v1.
--
-- Params shape for every order_* template (single builder reused):
--   {1: shop_name, 2: total, 3: order_detail_url}
--
-- Checklist alignment:
--   * 2.18 — status-transition trigger is idempotent: same row already
--            in target status produces no second notification (handled by
--            the WHEN clause).
--   * 2.21 — webhook idempotency unchanged (orders never re-fire on replay).
--   * 4.4  — phone is not logged here (we only read it and pass through).

-- Add the new enum values that go on scheduled_notifications.notification_type.
DO $$
DECLARE v_typname text;
BEGIN
  SELECT t.typname INTO v_typname
  FROM pg_attribute a
  JOIN pg_type t ON t.oid = a.atttypid
  JOIN pg_class c ON c.oid = a.attrelid
  WHERE c.relname = 'scheduled_notifications'
    AND a.attname = 'notification_type'
    AND a.attnum > 0
    AND NOT a.attisdropped;

  IF v_typname IS NULL OR v_typname IN ('text','varchar') THEN
    RETURN;
  END IF;

  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'order_received');
  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'order_confirmed');
  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'order_out_for_delivery');
  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'order_delivered');
  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'order_cancelled');
END $$;
