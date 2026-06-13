-- Creates service_templates table and seeds templates for all 4 shop types.
-- Run this in Supabase Dashboard → SQL Editor.
-- Verify with: SELECT shop_type, COUNT(*) FROM service_templates GROUP BY shop_type;

CREATE TABLE IF NOT EXISTS service_templates (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_type             TEXT NOT NULL,          -- 'Salon' | 'Barbershop' | 'Spa' | 'Nail Salon'
  service_name          TEXT NOT NULL,
  service_type          TEXT NOT NULL,          -- sub-type label
  duration_minutes      INTEGER NOT NULL DEFAULT 30,
  suggested_price_minor INTEGER,               -- minor units (kobo/cents), nullable = no suggestion
  description           TEXT,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE service_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "templates_read" ON service_templates FOR SELECT USING (true);

CREATE INDEX idx_service_templates_shop_type ON service_templates(shop_type);

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO service_templates (shop_type, service_name, service_type, duration_minutes, suggested_price_minor, description) VALUES
-- Barbershop
('Barbershop', 'Haircut', 'Fade', 30, NULL, 'Classic fade haircut'),
('Barbershop', 'Haircut', 'Low Fade', 30, NULL, 'Low fade haircut'),
('Barbershop', 'Haircut', 'High Fade', 30, NULL, 'High fade haircut'),
('Barbershop', 'Haircut', 'Skin Fade', 45, NULL, 'Skin/bald fade haircut'),
('Barbershop', 'Haircut', 'Taper', 30, NULL, 'Classic taper cut'),
('Barbershop', 'Beard Trim', 'Beard Trim', 20, NULL, 'Beard shaping and trim'),
('Barbershop', 'Lineup', 'Edge-Up', 15, NULL, 'Hairline and edge-up shaping'),
('Barbershop', 'Hot Towel Shave', 'Hot Towel Shave', 45, NULL, 'Traditional hot towel straight razor shave'),
('Barbershop', 'Kids Cut', 'Kids Cut', 20, NULL, 'Haircut for children under 12'),
('Barbershop', 'Design Cut', 'Design Cut', 60, NULL, 'Custom hair design or pattern'),

-- Salon
('Salon', 'Haircut', 'Haircut', 45, NULL, 'Women''s haircut and style'),
('Salon', 'Hair Colour', 'Full Colour', 120, NULL, 'Full hair colour application'),
('Salon', 'Hair Colour', 'Highlights', 90, NULL, 'Partial or full highlights'),
('Salon', 'Blowout', 'Blowout', 45, NULL, 'Wash and blow dry styling'),
('Salon', 'Braids', 'Box Braids', 240, NULL, 'Box braids protective style'),
('Salon', 'Braids', 'Cornrows', 120, NULL, 'Traditional cornrow braiding'),
('Salon', 'Braids', 'Senegalese Twist', 300, NULL, 'Senegalese twist protective style'),
('Salon', 'Locs', 'Starter Locs', 180, NULL, 'Starting dreadlocks'),
('Salon', 'Natural Styling', 'Afro', 60, NULL, 'Natural afro shaping and styling'),
('Salon', 'Weave', 'Weave Install', 180, NULL, 'Sew-in weave installation'),
('Salon', 'Wig Install', 'Wig Install', 90, NULL, 'Wig fitting, gluing, and styling'),
('Salon', 'Relaxer', 'Relaxer', 120, NULL, 'Chemical hair relaxer treatment'),
('Salon', 'Keratin', 'Keratin Treatment', 180, NULL, 'Smoothing keratin treatment'),

-- Spa
('Spa', 'Swedish Massage', 'Swedish Massage', 60, NULL, 'Relaxing full-body Swedish massage'),
('Spa', 'Swedish Massage', 'Swedish Massage', 90, NULL, '90-minute full-body Swedish massage'),
('Spa', 'Deep Tissue Massage', 'Deep Tissue', 60, NULL, 'Therapeutic deep tissue massage'),
('Spa', 'Hot Stone Massage', 'Hot Stone', 90, NULL, 'Hot stone relaxation massage'),
('Spa', 'Facial', 'Classic Facial', 60, NULL, 'Deep cleansing facial'),
('Spa', 'Facial', 'Hydrafacial', 60, NULL, 'Hydradermabrasion facial treatment'),
('Spa', 'Body Scrub', 'Body Scrub', 60, NULL, 'Full body exfoliation scrub'),
('Spa', 'Waxing', 'Eyebrow Wax', 15, NULL, 'Eyebrow shaping with wax'),
('Spa', 'Waxing', 'Full Leg Wax', 45, NULL, 'Full leg waxing'),
('Spa', 'Eyelash Extensions', 'Classic Lashes', 90, NULL, 'Classic eyelash extension set'),
('Spa', 'Foot Treatment', 'Foot Massage', 30, NULL, 'Relaxing foot and ankle massage'),

-- Nail Salon
('Nail Salon', 'Manicure', 'Classic Manicure', 30, NULL, 'Classic nail shaping and polish'),
('Nail Salon', 'Pedicure', 'Classic Pedicure', 45, NULL, 'Classic foot care and polish'),
('Nail Salon', 'Gel Nails', 'Gel Manicure', 45, NULL, 'Long-lasting gel polish application'),
('Nail Salon', 'Acrylic Nails', 'Full Set Acrylics', 90, NULL, 'Full acrylic nail set'),
('Nail Salon', 'Acrylic Nails', 'Acrylic Fill', 60, NULL, 'Acrylic infill/refill'),
('Nail Salon', 'Nail Art', 'Nail Art', 30, NULL, 'Custom nail art design'),
('Nail Salon', 'Dip Powder', 'Dip Powder Manicure', 60, NULL, 'Dip powder nail application'),
('Nail Salon', 'Nail Repair', 'Nail Repair', 15, NULL, 'Single nail repair');
