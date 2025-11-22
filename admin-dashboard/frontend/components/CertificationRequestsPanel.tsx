'use client'

import { useEffect, useMemo, useState } from 'react'
import axios from 'axios'
import Card from './ui/Card'
import Badge from './ui/Badge'
import Button from './ui/Button'

interface CertificationRequest {
  id: string
  establishmentId: string
  establishmentName: string
  ownerId: string
  ownerName?: string
  status: 'pending' | 'approved' | 'rejected' | 'cancelled' | string
  createdAt?: string
  updatedAt?: string
  source?: string
  decisionNote?: string
}

const STATUS_LABELS: Record<string, string> = {
  pending: 'Pendente',
  approved: 'Aprovado',
  rejected: 'Rejeitado',
  cancelled: 'Cancelado',
}

const STATUS_VARIANTS: Record<string, 'info' | 'success' | 'danger' | 'default'> = {
  pending: 'info',
  approved: 'success',
  rejected: 'danger',
  cancelled: 'default',
}

export default function CertificationRequestsPanel() {
  const [requests, setRequests] = useState<CertificationRequest[]>([])
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState<string>('pending')

  useEffect(() => {
    loadRequests()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [statusFilter])

  const loadRequests = async () => {
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

      const response = await axios.get(`${apiUrl}/api/certification-requests`, {
        params,
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      const data = response.data.requests || []
      setRequests(data)
    } catch (error) {
      console.error('Erro ao carregar solicitações de certificação:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredRequests = useMemo(() => {
    return requests
  }, [requests])

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

  const handleUpdateRequestStatus = async (
    request: CertificationRequest,
    status: 'approved' | 'rejected' | 'cancelled'
  ) => {
    const actionLabel =
      status === 'approved' ? 'aprovar' : status === 'rejected' ? 'rejeitar' : 'cancelar'

    if (!window.confirm(`Tem certeza que deseja ${actionLabel} esta solicitação?`)) {
      return
    }

    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        alert('Token não encontrado. Faça login novamente.')
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      await axios.put(
        `${apiUrl}/api/certification-requests/${request.id}/status`,
        { status },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )

      await loadRequests()
    } catch (error: any) {
      console.error('Erro ao atualizar status da solicitação:', error)
      const errorMessage =
        error.response?.data?.error || error.message || 'Erro ao atualizar status da solicitação'
      alert(`Erro: ${errorMessage}`)
    }
  }

  const handleApproveAndCertify = async (request: CertificationRequest) => {
    if (
      !window.confirm(
        'Aprovar esta solicitação e marcar o estabelecimento como CERTIFICADO no app?'
      )
    ) {
      return
    }

    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        alert('Token não encontrado. Faça login novamente.')
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

      // Atualizar certificação do estabelecimento
      await axios.put(
        `${apiUrl}/api/establishments/${request.establishmentId}/certification`,
        { certificationStatus: 'certified' },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )

      // Atualizar status da solicitação
      await axios.put(
        `${apiUrl}/api/certification-requests/${request.id}/status`,
        { status: 'approved' },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )

      await loadRequests()
    } catch (error: any) {
      console.error('Erro ao aprovar solicitação:', error)
      const errorMessage =
        error.response?.data?.error || error.message || 'Erro ao aprovar solicitação'
      alert(`Erro: ${errorMessage}`)
    }
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">
            Solicitações de Certificação Técnica
          </h3>
          <p className="text-sm text-gray-500 mt-0.5">
            {filteredRequests.length} solicitação
            {filteredRequests.length !== 1 ? 'es' : ''} encontrada
            {filteredRequests.length !== 1 ? 's' : ''}
          </p>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex flex-wrap items-center gap-4">
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1">
              Status
            </label>
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
        </div>
      </Card>

      {/* Requests table */}
      <Card padding="none">
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="spinner"></div>
          </div>
        ) : filteredRequests.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600">Nenhuma solicitação encontrada</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="table">
              <thead>
                <tr>
                  <th>Estabelecimento</th>
                  <th>Empresa</th>
                  <th>Status</th>
                  <th>Criado em</th>
                  <th>Fonte</th>
                  <th className="text-right">Ações</th>
                </tr>
              </thead>
              <tbody>
                {filteredRequests.map((request) => (
                  <tr key={request.id}>
                    <td>
                      <div>
                        <p className="font-medium text-gray-900">
                          {request.establishmentName || 'Sem nome'}
                        </p>
                        <p className="text-xs text-gray-500 mt-0.5">
                          ID: {request.establishmentId}
                        </p>
                      </div>
                    </td>
                    <td>
                      <div>
                        <p className="font-medium text-gray-900">
                          {request.ownerName || 'Empresa'}</p>
                        <p className="text-xs text-gray-500 mt-0.5">ID: {request.ownerId}</p>
                      </div>
                    </td>
                    <td>{getStatusBadge(request.status)}</td>
                    <td>
                      <div className="flex flex-col gap-0.5 text-xs text-gray-600">
                        {request.createdAt && (
                          <span>Criado: {formatDateTime(request.createdAt)}</span>
                        )}
                        {request.updatedAt && (
                          <span>Atualizado: {formatDateTime(request.updatedAt)}</span>
                        )}
                      </div>
                    </td>
                    <td>
                      {request.source ? (
                        <Badge variant="default">{request.source}</Badge>
                      ) : (
                        <span className="text-xs text-gray-500">-</span>
                      )}
                    </td>
                    <td>
                      <div className="flex flex-col items-end gap-2">
                        <div className="flex flex-wrap justify-end gap-2">
                          <Button
                            variant="primary"
                            size="sm"
                            onClick={() => handleApproveAndCertify(request)}
                            disabled={request.status !== 'pending'}
                          >
                            Aprovar como Certificado
                          </Button>
                          <Button
                            variant="danger"
                            size="sm"
                            onClick={() => handleUpdateRequestStatus(request, 'rejected')}
                            disabled={request.status !== 'pending'}
                          >
                            Rejeitar
                          </Button>
                        </div>
                        {request.status !== 'pending' && request.decisionNote && (
                          <p className="text-xs text-gray-500 max-w-xs text-right">
                            Obs.: {request.decisionNote}
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
