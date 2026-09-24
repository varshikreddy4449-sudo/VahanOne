-- Auto-create organization, user_profile, and company_settings on Supabase user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  new_org_id UUID;
  user_full_name TEXT;
  org_name TEXT;
BEGIN
  user_full_name := COALESCE(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1));
  org_name := COALESCE(new.raw_user_meta_data->>'organization_name', user_full_name || '''s Fleet');
  
  -- Create organization
  INSERT INTO public.organizations (name, is_active)
  VALUES (org_name, true)
  RETURNING id INTO new_org_id;

  -- Create company settings
  INSERT INTO public.company_settings (organization_id, company_name)
  VALUES (new_org_id, org_name);

  -- Create user profile
  INSERT INTO public.user_profiles (user_id, organization_id, full_name, role)
  VALUES (new.id, new_org_id, user_full_name, 'vehicle_owner');

  -- Also insert into public.users
  INSERT INTO public.users (id, organization_id, email, is_active)
  VALUES (new.id, new_org_id, new.email, true)
  ON CONFLICT (id) DO NOTHING;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger the function on every new signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Backfill any existing auth.users that don't have user_profiles
DO $$
DECLARE
  u RECORD;
  new_org_id UUID;
  u_name TEXT;
BEGIN
  FOR u IN SELECT * FROM auth.users WHERE id NOT IN (SELECT user_id FROM public.user_profiles) LOOP
    u_name := COALESCE(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1));
    INSERT INTO public.organizations (name, is_active)
    VALUES (u_name || '''s Fleet', true)
    RETURNING id INTO new_org_id;

    INSERT INTO public.company_settings (organization_id, company_name)
    VALUES (new_org_id, u_name || '''s Fleet');

    INSERT INTO public.user_profiles (user_id, organization_id, full_name, role)
    VALUES (u.id, new_org_id, u_name, 'vehicle_owner');

    INSERT INTO public.users (id, organization_id, email, is_active)
    VALUES (u.id, new_org_id, u.email, true)
    ON CONFLICT (id) DO NOTHING;
  END LOOP;
END;
$$;
