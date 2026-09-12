# QuickBite Online — Food + Pabili

This version connects the customer ordering flow to Supabase instead of browser localStorage.

## Customer
- No customer account/login.
- One public link can be shared.
- Browse restaurants and dishes.
- Add food to cart.
- Checkout with name, phone and delivery address.
- Receive an order number and track the order.

## Admin
The existing Admin area is retained, but **do not treat the demo PIN as secure authentication**.
For a real public deployment, protect admin actions with Supabase Auth/RLS.

## Setup
1. Open Supabase SQL Editor.
2. Run `schema.sql`.
3. Host `index.html` on a static host (for example Netlify, Vercel, GitHub Pages, or your own web host).
4. Open the hosted link on a phone and place a test order.
5. Open the Admin area to verify that the order appears in the shared database.

## Important security note
The Supabase publishable key can be used in browser code. Never put a Supabase secret/service-role key or database password in `index.html`.

## Current limitation
The public demo policies in schema.sql allow order creation and basic order lookup. Before public launch, admin write access should be moved behind Supabase Auth and tighter RLS policies. This keeps customers account-free while securing your management functions.
