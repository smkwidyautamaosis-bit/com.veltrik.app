import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { session_token, device_id } = await req.json()
    if (!session_token || !device_id) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), { headers: { "Content-Type": "application/json" }, status: 400 })
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: sessionData, error: sessionError } = await supabaseClient
      .from('sessions')
      .select('*')
      .eq('session_token', session_token)
      .eq('is_valid', true)
      .single()

    if (sessionError || !sessionData || sessionData.device_id !== device_id) {
      return new Response(JSON.stringify({ valid: false, error: "Sesi tidak valid" }), { headers: { "Content-Type": "application/json" } })
    }

    const { data: userData, error: userError } = await supabaseClient
      .from('users')
      .select('*')
      .eq('id', sessionData.user_id)
      .single()

    if (userError || !userData || userData.status !== 'active' || new Date(userData.expires_at) < new Date()) {
      return new Response(JSON.stringify({ valid: false, error: "Akun tidak aktif atau kadaluarsa" }), { headers: { "Content-Type": "application/json" } })
    }

    // Update last active
    await supabaseClient.from('sessions').update({ last_active_at: new Date().toISOString() }).eq('id', sessionData.id)

    return new Response(JSON.stringify({ valid: true, user: userData }), { headers: { "Content-Type": "application/json" } })
  } catch (error) {
    return new Response(JSON.stringify({ valid: false, error: error.message }), { headers: { "Content-Type": "application/json" }, status: 500 })
  }
})
