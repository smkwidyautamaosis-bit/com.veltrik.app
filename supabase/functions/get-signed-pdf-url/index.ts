import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { document_id, session_token, device_id } = await req.json()
    
    if (!session_token || !device_id || !document_id) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), { headers: { "Content-Type": "application/json" }, status: 400 })
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Validate session
    const { data: sessionData, error: sessionError } = await supabaseClient
      .from('sessions')
      .select('*, users!inner(status, expires_at)')
      .eq('session_token', session_token)
      .eq('is_valid', true)
      .single()

    if (sessionError || !sessionData || sessionData.device_id !== device_id || sessionData.users.status !== 'active') {
      return new Response(JSON.stringify({ error: "Sesi tidak valid" }), { headers: { "Content-Type": "application/json" }, status: 401 })
    }

    // Get document path
    const { data: docData, error: docError } = await supabaseClient
      .from('documents')
      .select('file_path, is_active')
      .eq('id', document_id)
      .single()

    if (docError || !docData || !docData.is_active) {
       return new Response(JSON.stringify({ error: "Dokumen tidak ditemukan" }), { headers: { "Content-Type": "application/json" }, status: 404 })
    }

    // Generate signed URL
    const { data: signedData, error: signedError } = await supabaseClient
      .storage
      .from('veltrik-pdfs')
      .createSignedUrl(docData.file_path, 900) // 15 mins

    if (signedError || !signedData) {
       return new Response(JSON.stringify({ error: "Gagal membuat URL akses" }), { headers: { "Content-Type": "application/json" }, status: 500 })
    }

    return new Response(JSON.stringify({ signed_url: signedData.signedUrl }), { headers: { "Content-Type": "application/json" } })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { headers: { "Content-Type": "application/json" }, status: 500 })
  }
})
