-- get_user_activity_counts: public booking + order counts for a profile.
--
-- WHY: ProfileHeader shows two stats — appointments booked and product orders
-- placed — and these must be visible to ANY viewer (not just the owner). RLS on
-- bookings/orders restricts SELECT to the owner (user_id = auth.uid()), so a
-- direct client count by another viewer returns 0. This SECURITY DEFINER RPC
-- returns ONLY the two aggregate integers — never any row data — so it exposes
-- nothing beyond "how active is this user", which the profile already implies.
--
-- Cancelled / no-show bookings and cancelled orders are excluded so the numbers
-- reflect real, completed-or-in-progress activity rather than abandoned attempts.
--
-- Checklist v3.1: 1.11 (only aggregate counts leave the boundary, no PII rows),
-- 2.2 (parameterized — p_user_id is bound, not interpolated).

CREATE OR REPLACE FUNCTION get_user_activity_counts(p_user_id UUID)
RETURNS TABLE (booking_count INTEGER, order_count INTEGER)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT
    (
      SELECT COUNT(*)::INTEGER
      FROM bookings b
      WHERE b.user_id = p_user_id
        AND b.status NOT IN ('cancelled', 'no_show')
    ) AS booking_count,
    (
      SELECT COUNT(*)::INTEGER
      FROM orders o
      WHERE o.user_id = p_user_id
        AND o.status <> 'cancelled'
    ) AS order_count;
$$;

REVOKE ALL ON FUNCTION get_user_activity_counts(UUID) FROM PUBLIC;
-- Any signed-in user may read any profile's aggregate counts; anon may too,
-- since profiles (and these tallies) are public on the marketplace.
GRANT EXECUTE ON FUNCTION get_user_activity_counts(UUID) TO authenticated, anon;

COMMENT ON FUNCTION get_user_activity_counts IS
  'Public aggregate counts for a profile: non-cancelled bookings + non-cancelled orders. Returns only the two integers (no row data) so it is safe to expose to any viewer despite RLS on the underlying tables.';
