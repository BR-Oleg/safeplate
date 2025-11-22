'use client'

import { useEffect, useMemo, useState } from 'react'
import axios from 'axios'
import Card from './ui/Card'
import Badge from './ui/Badge'
import Button from './ui/Button'

interface Referral {
  id: string
  userId: string
  establishmentName: string
  establishmentCategory?: string
  latitude?: number
  longitude?: number
  address?: string
  dietaryOptions?: string[]
  notes?: string
  status: 'pending' | 'approved' | 'rejected' | 'cancelled' | string
  createdAt?: string
  updatedAt?: string
  establishmentId?: string
  pointsAwarded?: number
  decisionNote?: string
}

const STATUS_LABELS: Record<string, string> = {
  pending: 'Pendente',
  approved: 'Aprovada',
  rejected: 'Rejeitada',
  cancelled: 'Cancelada',
}

const STATUS_VARIANTS: Record<string, 'info' | 'success' | 'danger' | 'default'> = {
  pending: 'info',
  approved: 'success',
  rejected: 'danger',
  cancelled: 'default',
}

export default function ReferralRequestsPanel() {
  const [referrals, setReferrals] = useState<Referral[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<string>('pending')
  const [searchTerm, setSearchTerm] = useState<string>('')

  useEffect(() => {
    loadReferrals()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [statusFilter])

  const loadReferrals = async () => {
    setLoading(true)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        console.error('Token não encontrado')
        setLoading(false)
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const params: Record<string, string> = {}
      if (statusFilter !== 'all') {
        params.status = statusFilter
      }

      const response = await axios.get(`${apiUrl}/api/referrals`, {
        params,
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      const data = response.data.referrals || []
      setReferrals(data)
    } catch (error) {
      console.error('Erro ao carregar indicações:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredReferrals = useMemo(() => {
    const term = searchTerm.trim().toLowerCase()
    if (!term) return referrals

    return referrals.filter((referral) => {
      const name = referral.establishmentName?.toLowerCase() || ''
      const userId = referral.userId?.toLowerCase() || ''
      const address = referral.address?.toLowerCase() || ''
      return (
        name.includes(term) ||
        userId.includes(term) ||
        address.includes(term)
      )
    })
  }, [referrals, searchTerm])

  const formatDateTime = (value?: string) => {
    if (!value) return ''
    try {
      const date = new Date(value)
      if (Number.isNaN(date.getTime())) return ''
      return date.toLocaleString('pt-BR')
    } catch {
      return ''
    }
  }

  const getStatusBadge = (status: string) => {
    const label = STATUS_LABELS[status] || status
    const variant = STATUS_VARIANTS[status] || 'default'
    return <Badge variant={variant as any}>{label}</Badge>
  }

  const formatDietaryOptions = (options?: string[]) => {
    if (!options || options.length === 0) return '-'
    return options
      .map((opt) => opt.replace(/^DietaryFilter\./, '').replace(/_/g, ' '))
      .join(', ')
  }

  const handleUpdateReferralStatus = async (
    referral: Referral,
    status: 'approved' | 'rejected' | 'cancelled'
  ) => {
    const actionLabel =
      status === 'approved' ? 'aprovar' : status === 'rejected' ? 'rejeitar' : 'cancelar'

    if (!window.confirm(`Tem certeza que deseja ${actionLabel} esta indicação?`)) {
      return
    }

    const decisionNote = window.prompt('Observação para esta decisão (opcional):') ?? undefined

    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        alert('Token não encontrado. Faça login novamente.')
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      await axios.put(
        `${apiUrl}/api/referrals/${referral.id}/status`,
        { status, decisionNote },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )

      await loadReferrals()
    } catch (error: any) {
      console.error('Erro ao atualizar status da indicação:', error)
      const errorMessage =
        error.response?.data?.error || error.message || 'Erro ao atualizar status da indicação'
      alert(`Erro: ${errorMessage}`)
    }
  }

  const handleCopyEstablishmentId = async (id: string) => {
    try {
      await navigator.clipboard.writeText(id)
      alert('ID do estabelecimento copiado para a área de transferência')
    } catch (error) {
      console.error('Erro ao copiar ID do estabelecimento:', error)
      alert('Não foi possível copiar o ID do estabelecimento')
    }
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Indicações de Novos Locais</h3>
          <p className="text-sm text-gray-500 mt-0.5">
            {filteredReferrals.length} indicação
            {filteredReferrals.length !== 1 ? 'es' : ''} encontrada
            {filteredReferrals.length !== 1 ? 's' : ''}
          </p>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex flex-wrap items-center gap-4">
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1">Status</label>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            >
              <option value="pending">Pendentes</option>
              <option value="approved">Aprovadas</option>
              <option value="rejected">Rejeitadas</option>
              <option value="cancelled">Canceladas</option>
              <option value="all">Todas</option>
            </select>
          </div>
          <div className="flex-1 min-w-[240px]">
            <label className="block text-xs font-medium text-gray-500 mb-1">
              Buscar (ID do usuário, nome ou endereço)
            </label>
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Ex: usuário, nome do local ou rua"
              className="w-full px-4 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
            />
          </div>
        </div>
      </Card>

      {/* Referrals table */}
      <Card padding="none">
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="spinner"></div>
          </div>
        ) : filteredReferrals.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600">Nenhuma indicação encontrada</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="table">
              <thead>
                <tr>
                  <th>Local indicado</th>
                  <th>Usuário</th>
                  <th>Localização</th>
                  <th>Opções alimentares</th>
                  <th>Status</th>
                  <th>Criado em</th>
                  <th className="text-right">Ações</th>
                </tr>
              </thead>
              <tbody>
                {filteredReferrals.map((referral) => (
                  <tr key={referral.id}>
                    <td>
                      <div>
                        <p className="font-medium text-gray-900">
                          {referral.establishmentName || 'Sem nome'}
                        </p>
                        <p className="text-xs text-gray-500 mt-0.5">
                          Categoria:{' '}
                          {referral.establishmentCategory || 'Não informada'}
                        </p>
                        {referral.notes && (
                          <p className="text-xs text-gray-500 mt-0.5 line-clamp-2">
                            Obs.: {referral.notes}
                          </p>
                        )}
                      </div>
                    </td>
                    <td>
                      <div>
                        <p className="font-medium text-gray-900">ID: {referral.userId}</p>
                        {referral.pointsAwarded && (
                          <p className="text-xs text-green-600 mt-0.5">
                            +{referral.pointsAwarded} pontos concedidos
                          </p>
                        )}
                      </div>
                    </td>
                    <td>
                      <div className="text-xs text-gray-600">
                        {referral.address && <p>{referral.address}</p>}
                        {referral.latitude !== undefined && referral.longitude !== undefined && (
                          <p className="mt-0.5">
                            Lat/Lng: {referral.latitude.toFixed(5)}, {referral.longitude.toFixed(5)}
                          </p>
                        )}
                      </div>
                    </td>
                    <td>
                      <p className="text-xs text-gray-600 max-w-xs">
                        {formatDietaryOptions(referral.dietaryOptions)}
                      </p>
                    </td>
                    <td>{getStatusBadge(referral.status)}</td>
                    <td>
                      <div className="flex flex-col gap-0.5 text-xs text-gray-600">
                        {referral.createdAt && (
                          <span>Criado: {formatDateTime(referral.createdAt)}</span>
                        )}
                        {referral.updatedAt && (
                          <span>Atualizado: {formatDateTime(referral.updatedAt)}</span>
                        )}
                      </div>
                    </td>
                    <td>
                      <div className="flex flex-col items-end gap-2">
                        <div className="flex flex-wrap justify-end gap-2">
                          <Button
                            variant="primary"
                            size="sm"
                            onClick={() => handleUpdateReferralStatus(referral, 'approved')}
                            disabled={referral.status !== 'pending'}
                          >
                            Aprovar indicação
                          </Button>
                          <Button
                            variant="danger"
                            size="sm"
                            onClick={() => handleUpdateReferralStatus(referral, 'rejected')}
                            disabled={referral.status !== 'pending'}
                          >
                            Rejeitar
                          </Button>
                        </div>
                        {referral.establishmentId && (
                          <div className="flex items-center gap-2 text-xs text-gray-500 max-w-xs justify-end">
                            <span>Estabelecimento criado: {referral.establishmentId}</span>
                            <Button
                              variant="secondary"
                              size="sm"
                              onClick={() => handleCopyEstablishmentId(referral.establishmentId!)}
                            >
                              Copiar ID
                            </Button>
                          </div>
                        )}
                        {referral.status !== 'pending' && referral.decisionNote && (
                          <p className="text-xs text-gray-500 max-w-xs text-right">
                            Obs. admin: {referral.decisionNote}
                          </p>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </div>
  )
}
