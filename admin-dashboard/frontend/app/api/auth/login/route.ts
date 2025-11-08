import { NextRequest, NextResponse } from 'next/server'
import { initializeApp, getApps, cert } from 'firebase-admin/app'
import { getAuth } from 'firebase-admin/auth'

// Inicializar Firebase Admin se ainda não estiver inicializado
if (!getApps().length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    }),
  })
}

export async function POST(request: NextRequest) {
  try {
    const { email, password } = await request.json()

    // Verificar credenciais (em produção, usar hash de senha)
    if (email === process.env.ADMIN_EMAIL && password === process.env.ADMIN_PASSWORD) {
      const auth = getAuth()
      
      // Buscar ou criar usuário admin
      let adminUser
      try {
        adminUser = await auth.getUserByEmail(email)
      } catch (error) {
        // Criar usuário admin se não existir
        adminUser = await auth.createUser({
          email,
          password,
          emailVerified: true,
        })
      }

      // Definir custom claim de admin
      await auth.setCustomUserClaims(adminUser.uid, { admin: true })

      // Gerar token customizado
      const customToken = await auth.createCustomToken(adminUser.uid)

      return NextResponse.json({
        success: true,
        token: customToken,
        user: {
          uid: adminUser.uid,
          email: adminUser.email,
        },
      })
    } else {
      return NextResponse.json(
        { error: 'Credenciais inválidas' },
        { status: 401 }
      )
    }
  } catch (error: any) {
    console.error('Erro no login:', error)
    return NextResponse.json(
      { error: 'Erro ao fazer login' },
      { status: 500 }
    )
  }
}



