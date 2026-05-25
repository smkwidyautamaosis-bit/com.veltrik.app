import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { full_name, email, expires_days } = await req.json()
    const days = expires_days || 365

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Generate VLTK-XXXX-XXXX
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    let code = 'VLTK-'
    for (let i = 0; i < 4; i++) code += chars.charAt(Math.floor(Math.random() * chars.length))
    code += '-'
    for (let i = 0; i < 4; i++) code += chars.charAt(Math.floor(Math.random() * chars.length))

    // Insert into invite_codes
    const { error: inviteError } = await supabaseClient.from('invite_codes').insert({
      code: code,
      expires_days: days
    })

    if (inviteError) throw inviteError

    // Calculate expires_at for the users table
    const expiresAt = new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString()

    // Create user record immediately
    const { error: userError } = await supabaseClient.from('users').insert({
      invite_code: code,
      full_name: full_name,
      email: email,
      status: 'active',
      expires_at: expiresAt
    })

    if (userError) throw userError

    return new Response(JSON.stringify({ success: true, invite_code: code }), { headers: { "Content-Type": "application/json" } })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { headers: { "Content-Type": "application/json" }, status: 500 })
  }
})
