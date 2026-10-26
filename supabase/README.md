# Supabase setup for Student Attendance Monitor

1. Create a free project at https://supabase.com (region: Singapore is closest to PH).
2. Dashboard > SQL Editor > New query: paste `schema.sql` from this folder and Run.
3. Authentication > Providers > Email > turn OFF "Confirm email" (school project, so accounts can sign in immediately).
4. Project Settings > API: copy the Project URL and the `anon` `public` key.
5. Put them in `config.js` at the site root (URL + anon key only — never the service_role key).
6. Redeploy (push to GitHub, Vercel redeploys automatically).
7. Teacher: on the landing page, "Create teacher account" with email + password, then sign in.
8. Student: "Create student account" with email + password + Student ID + name + section, then sign in.
9. Teacher adds/edits students and marks attendance on /teacher — everything is saved in the database.
