-- Phase 14: broadcasts table — append-only audit of owner-sent messages.
--
-- IMMUTABILITY MODEL:
--   RLS enabled with SELECT-only policy. No INSERT / UPDATE / DELETE
--   policies — absence on an RLS-enabled table = deny-all for the
--   `authenticated` role. All mutations route through send_broadcast
--   (SECURITY DEFINER, bypasses RLS). One row per send. Owner cannot
--   edit or cancel a sent broadcast.
--
-- Mirrors the Phase 12 client_notes RLS pattern (Research §9 cites it
-- as precedent).

CREATE TABLE IF NOT EXISTS public.broadcasts (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id              UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  subject              TEXT NOT NULL CHECK (char_length(subject) <= 100),
  body                 TEXT NOT NULL CHECK (char_length(body) <= 800),
  audience_type        TEXT NOT NULL CHECK (audience_type IN
                         ('all_clients','recent','lapsed','by_service')),
  audience_param       UUID,
  promotion_id         UUID REFERENCES public.promotions(id) ON DELETE SET NULL,
  created_by_user_id   UUID NOT NULL REFERENCES auth.users(id),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  delivered_at         TIMESTAMPTZ,
  recipient_count      INT NOT NULL DEFAULT 0 CHECK (recipient_count >= 0),
  status               TEXT NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','delivering','delivered','failed')),
  CONSTRAINT broadcasts_audience_param_check CHECK (
    (audience_type = 'by_service' AND audience_param IS NOT NULL) OR
    (audience_type <> 'by_service' AND audience_param IS NULL)
  )
);

CREATE INDEX IF NOT EXISTS broadcasts_shop_created_idx
  ON public.broadcasts (shop_id, created_at DESC);

ALTER TABLE public.broadcasts ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'broadcasts_owner_select') THEN
    CREATE POLICY broadcasts_owner_select ON public.broadcasts
      FOR SELECT TO authenticated
      USING (EXISTS (SELECT 1 FROM public.shops s
                     WHERE s.id = broadcasts.shop_id AND s.user_id = auth.uid()));
  END IF;
END $$;

-- Deliberately NO INSERT / UPDATE / DELETE policies. Absence on an
-- RLS-enabled table = deny-all for `authenticated`. All mutations route
-- through send_broadcast (SECURITY DEFINER, bypasses RLS).
-- Pattern verified against client_notes (Phase 12).

COMMENT ON TABLE public.broadcasts IS
  'Phase 14: append-only audit of owner-sent broadcasts. One row per send. Mutations flow through send_broadcast SECURITY DEFINER only — direct authenticated INSERT / UPDATE / DELETE is RLS-denied by policy absence. Immutable once written.';
COMMENT ON COLUMN public.broadcasts.status IS
  'pending (pre-send), delivering (fan-out in flight / template-pending), delivered (fan-out complete), failed (RPC raise before INSERT — actual fan-out failures roll back). Owner UI surfaces tooltip on delivering rows >6h old explaining WhatsApp template approval.';
COMMENT ON COLUMN public.broadcasts.recipient_count IS
  'Set by send_broadcast after the fan-out INSERT...SELECT returns its row count. Reflects actual scheduled_notifications rows written (post guest opt-out filtering, post-dedup), not the raw audience size.';
