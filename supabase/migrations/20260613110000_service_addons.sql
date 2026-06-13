-- Migration: service add-ons
--
-- service_addons        — owner-defined optional extras per appointment slot
-- service_template_addons — add-ons seeded alongside service templates

-- ── service_addons ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS service_addons (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id          UUID NOT NULL REFERENCES appointment_slots(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,
  price            INT  NOT NULL DEFAULT 0,   -- minor units (kobo / cents)
  duration_minutes INT,                        -- null = no extra time added
  is_active        BOOLEAN NOT NULL DEFAULT true,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_service_addons_slot_id ON service_addons (slot_id);

ALTER TABLE service_addons ENABLE ROW LEVEL SECURITY;

-- Public read — any authenticated user can see add-ons for a slot they can see.
CREATE POLICY "service_addons_read" ON service_addons
  FOR SELECT USING (true);

-- Write access — only the shop owner can manage add-ons.
CREATE POLICY "service_addons_owner_write" ON service_addons
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM appointment_slots s
      JOIN shops sh ON sh.id = s.shop_id
      WHERE s.id = service_addons.slot_id
        AND sh.owner_id = auth.uid()
    )
  );

-- ── service_template_addons ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS service_template_addons (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id           UUID NOT NULL REFERENCES service_templates(id) ON DELETE CASCADE,
  name                  TEXT NOT NULL,
  suggested_price_minor INT,
  duration_minutes      INT
);

CREATE INDEX IF NOT EXISTS idx_template_addons_template_id
  ON service_template_addons (template_id);

ALTER TABLE service_template_addons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "template_addons_read" ON service_template_addons
  FOR SELECT USING (true);

-- ── Seed template add-ons ────────────────────────────────────────────────────
-- Uses a CTE to resolve template UUIDs by (shop_type, service_name, service_type).

WITH t AS (SELECT id, shop_type, service_name, service_type FROM service_templates)
INSERT INTO service_template_addons (template_id, name, suggested_price_minor, duration_minutes)
SELECT t.id, a.name, a.price, a.dur
FROM t
JOIN (VALUES
  -- Barbershop
  ('Barbershop', 'Haircut',         'Fade',            'Hot towel finish',       NULL, 5),
  ('Barbershop', 'Haircut',         'Fade',            'Beard line-up',          NULL, 10),
  ('Barbershop', 'Haircut',         'Skin Fade',       'Scalp treatment',        NULL, 10),
  ('Barbershop', 'Beard Trim',      'Beard Trim',      'Hot towel shave',        NULL, 15),
  ('Barbershop', 'Hot Towel Shave', 'Hot Towel Shave', 'Moisturising treatment', NULL, 5),
  ('Barbershop', 'Design Cut',      'Design Cut',      'Hair colouring',         NULL, 30),

  -- Salon
  ('Salon', 'Haircut',        'Haircut',         'Blowout finish',        NULL, 20),
  ('Salon', 'Haircut',        'Haircut',         'Deep conditioning',     NULL, 15),
  ('Salon', 'Hair Colour',    'Full Colour',     'Gloss treatment',       NULL, 20),
  ('Salon', 'Hair Colour',    'Highlights',      'Toner',                 NULL, 15),
  ('Salon', 'Braids',         'Box Braids',      'Scalp oil treatment',   NULL, 10),
  ('Salon', 'Weave',          'Weave Install',   'Closure install',       NULL, 30),
  ('Salon', 'Wig Install',    'Wig Install',     'Custom wig cut',        NULL, 20),
  ('Salon', 'Natural Styling','Afro',            'Moisturising treatment',NULL, 10),

  -- Spa
  ('Spa', 'Swedish Massage',     'Swedish Massage', 'Aromatherapy oils',   NULL, 0),
  ('Spa', 'Swedish Massage',     'Swedish Massage', 'Hot stones add-on',   NULL, 15),
  ('Spa', 'Deep Tissue Massage', 'Deep Tissue',     'CBD oil upgrade',     NULL, 0),
  ('Spa', 'Facial',              'Classic Facial',  'Eye treatment',       NULL, 10),
  ('Spa', 'Facial',              'Hydrafacial',     'Lip peel add-on',     NULL, 10),
  ('Spa', 'Waxing',              'Eyebrow Wax',     'Tint add-on',         NULL, 10),
  ('Spa', 'Eyelash Extensions',  'Classic Lashes',  'Lash lift add-on',    NULL, 20),
  ('Spa', 'Foot Treatment',      'Foot Massage',    'Exfoliation scrub',   NULL, 10),

  -- Nail Salon
  ('Nail Salon', 'Manicure',  'Classic Manicure',  'Gel upgrade',        NULL, 10),
  ('Nail Salon', 'Manicure',  'Classic Manicure',  'Nail art (2 nails)', NULL, 10),
  ('Nail Salon', 'Pedicure',  'Classic Pedicure',  'Gel upgrade',        NULL, 10),
  ('Nail Salon', 'Pedicure',  'Classic Pedicure',  'Callus removal',     NULL, 10),
  ('Nail Salon', 'Gel Nails', 'Gel Manicure',      'Nail art (2 nails)', NULL, 10),
  ('Nail Salon', 'Acrylic Nails', 'Full Set Acrylics', 'Ombre effect',   NULL, 15),
  ('Nail Salon', 'Nail Art',  'Nail Art',           '3D gems add-on',    NULL, 10)
) AS a(shop_type, svc_name, svc_type, name, price, dur)
  ON t.shop_type = a.shop_type
 AND t.service_name = a.svc_name
 AND t.service_type = a.svc_type
ON CONFLICT DO NOTHING;
