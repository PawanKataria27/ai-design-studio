# MG AI Design Studio v0.3

Flutter mobile app connected to the owner's Supabase project.

## Working in this version

- Email signup with confirmation email
- Email/password sign in
- Persistent login session and sign out
- Supabase-backed Free subscription and credit display
- Camera and gallery image selection
- Save a design-project draft to Supabase
- View and delete the signed-in user's design history
- Usage events stored in `usage_logs`
- Android APK build through GitHub Actions

## Next production integrations

- Supabase Storage bucket for uploaded and generated images
- AI image generation through a protected Supabase Edge Function
- Payment-gateway checkout and webhook verification
- Admin web dashboard
- Signed Android App Bundle for Google Play
- iOS signing and TestFlight/App Store release

## Security

- Client code uses only the Supabase publishable key.
- Database access is protected by Row Level Security.
- AI and payment secret keys must only be stored as server-side function secrets.
