-- product_reviews.user_id → auth.users, but PostgREST join syntax
-- (profiles!user_id) requires a FK to public.profiles.
-- Add the missing FK so the Dart repository can join reviewer names.
ALTER TABLE public.product_reviews
  ADD CONSTRAINT product_reviews_user_id_fkey_profiles
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
