import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { JWT } from "npm:google-auth-library@9"

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

      // Parse Firebase Service Account
      const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
      if (!serviceAccountStr) {
        throw new Error('FIREBASE_SERVICE_ACCOUNT secret is missing')
      }

      const serviceAccount = JSON.parse(serviceAccountStr)
      
      // Get OAuth2 Token using google-auth-library
      const jwtClient = new JWT({
        email: serviceAccount.client_email,
        key: serviceAccount.private_key.replace(/\\n/g, '\n'), // Ensure newlines are properly formatted
        scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
      })
      
      const authTokens = await jwtClient.authorize()
      const accessToken = authTokens.access_token

      if (!accessToken) {
        throw new Error('Failed to obtain Google OAuth2 access token')
      }

      // Use explicit project ID as requested
      const projectId = 'veltrik-vinal-version'
      const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`

      // Send requests concurrently using Promise.all
      const sendPromises = tokens.map(async (token) => {
        const payload = {
          message: {
            token: token,
            notification: {
              title: title,
              body: body,
            },
            data: {
              notification_type: notification_type || 'announcement',
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            }
          }
        }

        const response = await fetch(fcmUrl, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(payload),
        })

        if (!response.ok) {
          const errText = await response.text()
          console.error(`Failed to send to token ${token}:`, errText)
        }
      })

      await Promise.all(sendPromises)
      console.log('Successfully processed all push notifications.')
    }

    return new Response(JSON.stringify({ success: true }), { headers: { "Content-Type": "application/json" } })
  } catch (error) {
    console.error('Error sending notification:', error)
    return new Response(JSON.stringify({ error: error.message }), { headers: { "Content-Type": "application/json" }, status: 500 })
  }
})
