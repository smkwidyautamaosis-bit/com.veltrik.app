import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { title, body, target, user_id, notification_type } = await req.json()

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Insert into notifications table
    await supabaseClient.from('notifications').insert({
      title,
      body,
      target: target || 'all',
      user_id: user_id || null,
      notification_type: notification_type || 'announcement'
    })

    // Fetch FCM tokens
    let query = supabaseClient.from('users').select('fcm_token').eq('status', 'active').not('fcm_token', 'is', null)
    if (target === 'specific' && user_id) {
       query = query.eq('id', user_id)
    }

    const { data: users } = await query
    
    if (users && users.length > 0) {
      const tokens = users.map(u => u.fcm_token).filter(Boolean)
      
      console.log(`Sending FCM to ${tokens.length} devices`)
      // TODO: Call FCM API
      // fetch('https://fcm.googleapis.com/v1/projects/veltrik/messages:send', ...)
    }

    return new Response(JSON.stringify({ success: true }), { headers: { "Content-Type": "application/json" } })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { headers: { "Content-Type": "application/json" }, status: 500 })
  }
})
