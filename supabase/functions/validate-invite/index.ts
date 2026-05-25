import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { invite_code, device_id, device_name } = await req.json()
    if (!invite_code || !device_id) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), { headers: { "Content-Type": "application/json" }, status: 400 })
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const normalizedCode = invite_code.trim().toUpperCase()

    // Query invite code
    const { data: codeData, error: codeError } = await supabaseClient
      .from('invite_codes')
      .select('*')
      .eq('code', normalizedCode)
      .single()

    if (codeError || !codeData) {
      return new Response(JSON.stringify({ error: "Code tidak valid" }), { headers: { "Content-Type": "application/json" } })
    }

    // Always fetch the user record (admin should have created it alongside the invite code)
    const { data: userData, error: userError } = await supabaseClient
      .from('users')
      .select('*')
      .eq('invite_code', normalizedCode)
      .single()

    if (userError || !userData) {
      return new Response(JSON.stringify({ error: "Pengguna tidak ditemukan untuk kode ini" }), { headers: { "Content-Type": "application/json" } })
    }

    let isFirstLogin = false;

    if (codeData.is_used) {
      // Already used, check device binding
      if (userData.device_id !== device_id) {
        return new Response(JSON.stringify({ error: "Code sudah digunakan perangkat lain" }), { headers: { "Content-Type": "application/json" } })
      }
    } else {
      // First time use
      isFirstLogin = true;
      
      // Update invite_codes
      await supabaseClient.from('invite_codes').update({ 
        is_used: true, 
        used_by: userData.id, 
        used_at: new Date().toISOString() 
      }).eq('id', codeData.id)

      // Calculate expires_at
      const expiresAt = new Date()
      expiresAt.setDate(expiresAt.getDate() + codeData.expires_days)

      // Update users
      await supabaseClient.from('users').update({
        device_id,
        device_name,
        expires_at: expiresAt.toISOString(),
        status: 'active'
      }).eq('id', userData.id)

      // Refresh userData
      userData.device_id = device_id
      userData.device_name = device_name
      userData.expires_at = expiresAt.toISOString()
      userData.status = 'active'
    }

    // Common checks
    if (userData.status !== 'active') {
      return new Response(JSON.stringify({ error: "Akun tidak aktif" }), { headers: { "Content-Type": "application/json" } })
    }

    if (new Date(userData.expires_at) < new Date()) {
      await supabaseClient.from('users').update({ status: 'expired' }).eq('id', userData.id)
      return new Response(JSON.stringify({ error: "Akun telah kadaluarsa" }), { headers: { "Content-Type": "application/json" } })
    }

    // Generate session
    const session_token = crypto.randomUUID()
    await supabaseClient.from('sessions').insert({
      user_id: userData.id,
      device_id,
      device_name,
      session_token
    })
    
    await supabaseClient.from('users').update({ last_login_at: new Date().toISOString() }).eq('id', userData.id)

    return new Response(JSON.stringify({ 
      success: true, 
      user: userData, 
      session_token, 
      is_first_login: isFirstLogin 
    }), { headers: { "Content-Type": "application/json" } })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { headers: { "Content-Type": "application/json" }, status: 500 })
  }
})
