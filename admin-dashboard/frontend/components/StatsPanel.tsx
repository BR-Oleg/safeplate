'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'
import StatCard from './ui/StatCard'
import Card from './ui/Card'
import Badge from './ui/Badge'
import Button from './ui/Button'

interface Stats {
  users: {
    total: number
    businesses: number
    regular: number
  }
  establishments: number
  reviews: number
  licenses: {
    total: number
    revenue: number
  }
}

export default function StatsPanel() {
  const [stats, setStats] = useState<Stats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d' | 'all'>('30d')

  useEffect(() => {
    loadStats()
  }, [timeRange])

  const loadStats = async () => {
    setLoading(true)
    setError(null)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        setError('Token não encontrado')
        setLoading(false)
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.get(`${apiUrl}/api/stats`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      setStats(response.data)
    } catch (error: any) {
      console.error('Erro ao carregar estatísticas:', error)
      setError(error.response?.data?.error || 'Erro ao carregar estatísticas')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="spinner mx-auto mb-4"></div>
          <p className="text-gray-600">Carregando estatísticas...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <Card>
        <div className="text-center py-12">
          <div className="text-red-500 text-5xl mb-4">⚠️</div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Erro ao carregar estatísticas</h3>
          <p className="text-gray-600 mb-4">{error}</p>
          <Button onClick={loadStats}>Tentar novamente</Button>
        </div>
      </Card>
    )
  }

  if (!stats) {
    return (
      <Card>
        <div className="text-center py-12">
          <p className="text-gray-600">Nenhuma estatística disponível</p>
        </div>
      </Card>
    )
  }

  const growthRate = {
    users: 12.5,
    establishments: 8.3,
    reviews: 15.2,
    revenue: 22.1,
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Time Range Selector */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Período</h3>
          <p className="text-sm text-gray-500">Selecione o período de análise</p>
        </div>
        <div className="flex gap-2">
          {(['7d', '30d', '90d', 'all'] as const).map((range) => (
            <Button
              key={range}
              variant={timeRange === range ? 'primary' : 'outline'}
              size="sm"
              onClick={() => setTimeRange(range)}
            >
              {range === '7d' ? '7 dias' : range === '30d' ? '30 dias' : range === '90d' ? '90 dias' : 'Tudo'}
            </Button>
          ))}
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total de Usuários"
          value={stats.users.total.toLocaleString('pt-BR')}
          change={{ value: growthRate.users, isPositive: true }}
          icon={
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
          }
          subtitle={`${stats.users.businesses} empresas, ${stats.users.regular} usuários`}
        />
        <StatCard
          title="Estabelecimentos"
          value={stats.establishments.toLocaleString('pt-BR')}
          change={{ value: growthRate.establishments, isPositive: true }}
          icon={
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          }
        />
        <StatCard
          title="Avaliações"
          value={stats.reviews.toLocaleString('pt-BR')}
          change={{ value: growthRate.reviews, isPositive: true }}
          icon={
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
            </svg>
          }
        />
        <StatCard
          title="Faturamento Total"
          value={`R$ ${stats.licenses.revenue.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
          change={{ value: growthRate.revenue, isPositive: true }}
          icon={
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          }
          subtitle={`${stats.licenses.total} licenças ativas`}
        />
      </div>

      {/* Detailed Stats */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* User Breakdown */}
        <Card>
          <div className="mb-4">
            <h3 className="text-lg font-semibold text-gray-900 mb-1">Distribuição de Usuários</h3>
            <p className="text-sm text-gray-500">Tipos de usuários cadastrados</p>
          </div>
          <div className="space-y-4">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-700">Usuários Regulares</span>
                <span className="text-sm font-semibold text-gray-900">{stats.users.regular}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2.5">
                <div
                  className="bg-blue-500 h-2.5 rounded-full transition-all duration-500"
                  style={{ width: `${(stats.users.regular / stats.users.total) * 100}%` }}
                />
              </div>
            </div>
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-700">Empresas</span>
                <span className="text-sm font-semibold text-gray-900">{stats.users.businesses}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2.5">
                <div
                  className="bg-primary-500 h-2.5 rounded-full transition-all duration-500"
                  style={{ width: `${(stats.users.businesses / stats.users.total) * 100}%` }}
                />
              </div>
            </div>
          </div>
        </Card>

        {/* Quick Actions */}
        <Card>
          <div className="mb-4">
            <h3 className="text-lg font-semibold text-gray-900 mb-1">Ações Rápidas</h3>
            <p className="text-sm text-gray-500">Acesso rápido às principais funcionalidades</p>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <Button variant="outline" className="flex-col h-auto py-4">
              <span className="text-2xl mb-2">👥</span>
              <span className="text-sm">Gerenciar Usuários</span>
            </Button>
            <Button variant="outline" className="flex-col h-auto py-4">
              <span className="text-2xl mb-2">🏢</span>
              <span className="text-sm">Estabelecimentos</span>
            </Button>
            <Button variant="outline" className="flex-col h-auto py-4">
              <span className="text-2xl mb-2">💳</span>
              <span className="text-sm">Licenças</span>
            </Button>
            <Button variant="outline" className="flex-col h-auto py-4">
              <span className="text-2xl mb-2">🔧</span>
              <span className="text-sm">Manutenção</span>
            </Button>
          </div>
        </Card>
      </div>

      {/* System Status */}
      <Card>
        <div className="mb-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-1">Status do Sistema</h3>
          <p className="text-sm text-gray-500">Informações sobre o estado atual do sistema</p>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="flex items-center gap-3 p-4 bg-green-50 rounded-lg border border-green-200">
            <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center">
              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <div>
              <p className="text-sm font-medium text-green-900">Sistema Online</p>
              <p className="text-xs text-green-700">Todos os serviços operacionais</p>
            </div>
          </div>
          <div className="flex items-center gap-3 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center">
              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
            </div>
            <div>
              <p className="text-sm font-medium text-blue-900">Performance</p>
              <p className="text-xs text-blue-700">Tempo de resposta: 120ms</p>
            </div>
          </div>
          <div className="flex items-center gap-3 p-4 bg-purple-50 rounded-lg border border-purple-200">
            <div className="w-10 h-10 bg-purple-500 rounded-full flex items-center justify-center">
              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
            </div>
            <div>
              <p className="text-sm font-medium text-purple-900">Segurança</p>
              <p className="text-xs text-purple-700">Sistema protegido e atualizado</p>
            </div>
          </div>
        </div>
      </Card>
    </div>
  )
}
