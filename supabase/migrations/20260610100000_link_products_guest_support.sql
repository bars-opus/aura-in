-- Link-products feature, schema layer (mirrors 20260528120000 for bookings).
--
-- What this enables:
--   * Public shareable URL https://aurain.barsopus.com/m/<slug> resolves to a
--     shop's product list, with a guest checkout that flows into the existing
--     orders/order_items tables (no payment — pay on delivery).
--   * shops.products_slug is the fast lookup column synced from short_links.
--   * orders gains guest_profile_id (nullable) so guests can place orders
--     without auth; CHECK enforces exactly one of user_id / guest_profile_id.
--
-- Checklist alignment (v3.1):
--   * 1.4 — guest path documented + scope-tagged in the new RPCs.
--   * 1.11 — guest PII (name, phone, address) flows into existing columns
--            (delivery_address, customer_phone) plus guest_profile_id.
--            No new PII storage; retention follows the orders table.
--   * 2.18 — orders.idempotency_key already enforced (NOT NULL via existing
--            schema); guest path will use (guest_profile_id, idem_key).

-- ────────────────────────────────────────────────────────────────────────────
-- ORDERS: allow guests
-- ────────────────────────────────────────────────────────────────────────────

ALTER TABLE orders
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS guest_profile_id UUID
    REFERENCES guest_profiles(id) ON DELETE SET NULL;

-- Exactly one of user_id or guest_profile_id must be set. Both null = no
-- accountable customer; both set = ambiguous who placed it.
ALTER TABLE orders
  DROP CONSTRAINT IF EXISTS orders_user_or_guest_chk;
ALTER TABLE orders
  ADD CONSTRAINT orders_user_or_guest_chk
  CHECK (
    (user_id IS NOT NULL AND guest_profile_id IS NULL) OR
    (user_id IS NULL     AND guest_profile_id IS NOT NULL)
  );

CREATE INDEX IF NOT EXISTS orders_guest_profile_idx
  ON orders (guest_profile_id, created_at DESC)
  WHERE guest_profile_id IS NOT NULL;

-- ────────────────────────────────────────────────────────────────────────────
-- SHOPS: cached products_slug
-- ────────────────────────────────────────────────────────────────────────────

ALTER TABLE shops
  ADD COLUMN IF NOT EXISTS products_slug TEXT UNIQUE;

-- ────────────────────────────────────────────────────────────────────────────
-- TRIGGER: keep shops.products_slug in sync with short_links rows where
-- link_type = 'shop_products'. Mirror of sync_booking_slug_to_shop.
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION sync_products_slug_to_shop()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Clear cache if the link was previously an active shop_products link AND
  -- it's now deactivated, retargeted, retyped, or re-slugged.
  IF TG_OP = 'UPDATE'
     AND OLD.link_type = 'shop_products'
     AND OLD.is_active = true
     AND (
          NEW.is_active = false
       OR NEW.link_type <> 'shop_products'
       OR NEW.target_id <> OLD.target_id
       OR NEW.slug      <> OLD.slug
     ) THEN
    UPDATE shops
       SET products_slug = NULL
     WHERE id = OLD.target_id::uuid
       AND products_slug = OLD.slug;
  END IF;

  IF NEW.link_type = 'shop_products' AND NEW.is_active = true THEN
    UPDATE shops SET products_slug = NEW.slug WHERE id = NEW.target_id::uuid;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS short_links_sync_products_slug_ins ON short_links;
CREATE TRIGGER short_links_sync_products_slug_ins
  AFTER INSERT ON short_links
  FOR EACH ROW
  EXECUTE FUNCTION sync_products_slug_to_shop();

DROP TRIGGER IF EXISTS short_links_sync_products_slug_upd ON short_links;
CREATE TRIGGER short_links_sync_products_slug_upd
  AFTER UPDATE OF slug, target_id, link_type, is_active ON short_links
  FOR EACH ROW
  EXECUTE FUNCTION sync_products_slug_to_shop();

-- One-time backfill for any existing shop_products short_links.
DO $$
DECLARE
  link RECORD;
BEGIN
  FOR link IN
    SELECT slug, target_id FROM short_links
    WHERE link_type = 'shop_products' AND is_active = true
  LOOP
    UPDATE shops SET products_slug = link.slug WHERE id = link.target_id::uuid;
  END LOOP;
END $$;
