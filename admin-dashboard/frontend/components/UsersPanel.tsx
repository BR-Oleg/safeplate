'use client'

import { useState, useEffect, useMemo } from 'react'
import axios from 'axios'
import Card from './ui/Card'
import Badge from './ui/Badge'
import Button from './ui/Button'
import Input from './ui/Input'
import Modal from './ui/Modal'

interface User {
  id: string
  email: string
  name?: string
  type: 'user' | 'business'
  banned: boolean
  banReason?: string
  createdAt: string
  emailVerified?: boolean
  points?: number
  isPremium?: boolean
  premiumExpiresAt?: string
  seal?: 'bronze' | 'silver' | 'gold'
}

export default function UsersPanel() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'user' | 'business' | 'banned'>('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [banModalOpen, setBanModalOpen] = useState(false)
  const [banReason, setBanReason] = useState('')
  const [pointsModalOpen, setPointsModalOpen] = useState(false)
  const [pointsChange, setPointsChange] = useState(0)
  const [pointsReason, setPointsReason] = useState('')
  const [premiumModalOpen, setPremiumModalOpen] = useState(false)
  const [premiumMonths, setPremiumMonths] = useState(1)
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 10

  useEffect(() => {
    loadUsers()
  }, [filter])

  const loadUsers = async () => {
    setLoading(true)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        console.error('Token não encontrado')
        setLoading(false)
        return
      }

      const params: any = {}
      if (filter !== 'all') {
        if (filter === 'banned') {
          params.banned = 'true'
        } else {
          params.type = filter
        }
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.get(`${apiUrl}/api/users`, {
        params,
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      setUsers(response.data.users || [])
    } catch (error: any) {
      console.error('Erro ao carregar usuários:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredUsers = useMemo(() => {
    return users.filter((user) => {
      const matchesSearch =
        user.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (user.name && user.name.toLowerCase().includes(searchQuery.toLowerCase()))
      return matchesSearch
    })
  }, [users, searchQuery])

  const paginatedUsers = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage
    return filteredUsers.slice(startIndex, startIndex + itemsPerPage)
  }, [filteredUsers, currentPage])

  const totalPages = Math.ceil(filteredUsers.length / itemsPerPage)

  const handleBan = async (user: User) => {
    setSelectedUser(user)
    setBanModalOpen(true)
  }

  const confirmBan = async () => {
    if (!selectedUser) return

    try {
      const token = localStorage.getItem('adminToken')
      await axios.post(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/users/${selectedUser.id}/ban`,
        { reason: banReason || 'Sem motivo especificado' },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      setBanModalOpen(false)
      setBanReason('')
      setSelectedUser(null)
      loadUsers()
    } catch (error) {
      console.error('Erro ao banir usuário:', error)
      alert('Erro ao banir usuário')
    }
  }

  const handleUnban = async (userId: string) => {
    if (!confirm('Tem certeza que deseja desbanir este usuário?')) return

    try {
      const token = localStorage.getItem('adminToken')
      await axios.post(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/users/${userId}/unban`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      loadUsers()
    } catch (error) {
      console.error('Erro ao desbanir usuário:', error)
      alert('Erro ao desbanir usuário')
    }
  }

  const handlePoints = (user: User) => {
    setSelectedUser(user)
    setPointsChange(0)
    setPointsReason('')
    setPointsModalOpen(true)
  }

  const confirmPoints = async () => {
    if (!selectedUser || pointsChange === 0) return

    try {
      const token = localStorage.getItem('adminToken')
      await axios.put(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/users/${selectedUser.id}/points`,
        { points: pointsChange, reason: pointsReason || 'Ajuste administrativo' },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      setPointsModalOpen(false)
      setPointsChange(0)
      setPointsReason('')
      setSelectedUser(null)
      loadUsers()
      alert('Pontos atualizados com sucesso!')
    } catch (error: any) {
      console.error('Erro ao atualizar pontos:', error)
      alert(`Erro ao atualizar pontos: ${error.response?.data?.error || error.message}`)
    }
  }

  const handlePremium = (user: User) => {
    setSelectedUser(user)
    setPremiumMonths(1)
    setPremiumModalOpen(true)
  }

  const confirmPremium = async (isPremium: boolean) => {
    if (!selectedUser) return

    try {
      const token = localStorage.getItem('adminToken')
      await axios.put(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/users/${selectedUser.id}/premium`,
        { isPremium, months: isPremium ? premiumMonths : undefined },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      setPremiumModalOpen(false)
      setPremiumMonths(1)
      setSelectedUser(null)
      loadUsers()
      alert(`Premium ${isPremium ? 'ativado' : 'desativado'} com sucesso!`)
    } catch (error: any) {
      console.error('Erro ao atualizar Premium:', error)
      alert(`Erro ao atualizar Premium: ${error.response?.data?.error || error.message}`)
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    })
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Gerenciamento de Usuários</h3>
          <p className="text-sm text-gray-500 mt-0.5">
            {filteredUsers.length} usuário{filteredUsers.length !== 1 ? 's' : ''} encontrado{filteredUsers.length !== 1 ? 's' : ''}
          </p>
        </div>
      </div>

      {/* Filters and Search */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            placeholder="Buscar por email ou nome..."
            value={searchQuery}
            onChange={(e) => {
              setSearchQuery(e.target.value)
              setCurrentPage(1)
            }}
            icon={
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            }
          />
          <div className="flex gap-2">
            {(['all', 'user', 'business', 'banned'] as const).map((f) => (
              <Button
                key={f}
                variant={filter === f ? 'primary' : 'outline'}
                size="sm"
                onClick={() => {
                  setFilter(f)
                  setCurrentPage(1)
                }}
              >
                {f === 'all' ? 'Todos' : f === 'user' ? 'Usuários' : f === 'business' ? 'Empresas' : 'Banidos'}
              </Button>
            ))}
          </div>
        </div>
      </Card>

      {/* Users Table */}
      <Card padding="none">
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="spinner"></div>
          </div>
        ) : paginatedUsers.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600">Nenhum usuário encontrado</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="table">
                <thead>
                  <tr>
                    <th>Usuário</th>
                    <th>Tipo</th>
                    <th>Status</th>
                    <th>Pontos</th>
                    <th>Premium</th>
                    <th>Data de Cadastro</th>
                    <th className="text-right">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedUsers.map((user) => (
                    <tr key={user.id}>
                      <td>
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 bg-gradient-to-br from-gray-400 to-gray-500 rounded-full flex items-center justify-center">
                            <span className="text-white text-sm font-semibold">
                              {user.email.charAt(0).toUpperCase()}
                            </span>
                          </div>
                          <div>
                            <p className="font-medium text-gray-900">{user.email}</p>
                            {user.name && <p className="text-sm text-gray-500">{user.name}</p>}
                          </div>
                        </div>
                      </td>
                      <td>
                        <Badge variant={user.type === 'business' ? 'info' : 'default'}>
                          {user.type === 'business' ? 'Empresa' : 'Usuário'}
                        </Badge>
                      </td>
                      <td>
                        {user.banned ? (
                          <Badge variant="danger">Banido</Badge>
                        ) : (
                          <Badge variant="success">Ativo</Badge>
                        )}
                        {user.banned && user.banReason && (
                          <p className="text-xs text-gray-500 mt-1">{user.banReason}</p>
                        )}
                      </td>
                      <td>
                        <div className="flex items-center gap-2">
                          <span className="text-sm font-medium text-gray-900">{user.points || 0}</span>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handlePoints(user)}
                            title="Ajustar pontos"
                          >
                            ⭐
                          </Button>
                        </div>
                      </td>
                      <td>
                        {user.isPremium ? (
                          <Badge variant="info">Premium</Badge>
                        ) : (
                          <Badge variant="default">Gratuito</Badge>
                        )}
                      </td>
                      <td className="text-sm text-gray-600">{formatDate(user.createdAt)}</td>
                      <td>
                        <div className="flex items-center justify-end gap-2">
                          {user.type === 'user' && (
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => handlePremium(user)}
                              title={user.isPremium ? 'Desativar Premium' : 'Ativar Premium'}
                            >
                              {user.isPremium ? '👑' : '⭐'}
                            </Button>
                          )}
                          {user.banned ? (
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => handleUnban(user.id)}
                            >
                              Desbanir
                            </Button>
                          ) : (
                            <Button
                              variant="danger"
                              size="sm"
                              onClick={() => handleBan(user)}
                            >
                              Banir
                            </Button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
              <div className="flex items-center justify-between px-6 py-4 border-t border-gray-200">
                <p className="text-sm text-gray-600">
                  Página {currentPage} de {totalPages}
                </p>
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                    disabled={currentPage === 1}
                  >
                    Anterior
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                    disabled={currentPage === totalPages}
                  >
                    Próxima
                  </Button>
                </div>
              </div>
            )}
          </>
        )}
      </Card>

      {/* Ban Modal */}
      <Modal
        isOpen={banModalOpen}
        onClose={() => {
          setBanModalOpen(false)
          setBanReason('')
          setSelectedUser(null)
        }}
        title="Banir Usuário"
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => {
                setBanModalOpen(false)
                setBanReason('')
                setSelectedUser(null)
              }}
            >
              Cancelar
            </Button>
            <Button variant="danger" onClick={confirmBan}>
              Confirmar Banimento
            </Button>
          </>
        }
      >
        {selectedUser && (
          <div className="space-y-4">
            <p className="text-gray-700">
              Tem certeza que deseja banir o usuário <strong>{selectedUser.email}</strong>?
            </p>
            <Input
              label="Motivo do banimento (opcional)"
              value={banReason}
              onChange={(e) => setBanReason(e.target.value)}
              placeholder="Digite o motivo do banimento..."
            />
          </div>
        )}
      </Modal>

      {/* Points Modal */}
      <Modal
        isOpen={pointsModalOpen}
        onClose={() => {
          setPointsModalOpen(false)
          setPointsChange(0)
          setPointsReason('')
          setSelectedUser(null)
        }}
        title="Ajustar Pontos"
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => {
                setPointsModalOpen(false)
                setPointsChange(0)
                setPointsReason('')
                setSelectedUser(null)
              }}
            >
              Cancelar
            </Button>
            <Button variant="primary" onClick={confirmPoints} disabled={pointsChange === 0}>
              Confirmar
            </Button>
          </>
        }
      >
        {selectedUser && (
          <div className="space-y-4">
            <p className="text-gray-700">
              Usuário: <strong>{selectedUser.email}</strong>
            </p>
            <p className="text-sm text-gray-600">
              Pontos atuais: <strong>{selectedUser.points || 0}</strong>
            </p>
            <Input
              label="Alteração de pontos (positivo para adicionar, negativo para remover)"
              type="number"
              value={pointsChange}
              onChange={(e) => setPointsChange(parseInt(e.target.value) || 0)}
              placeholder="Ex: 100 ou -50"
            />
            {pointsChange !== 0 && (
              <p className="text-sm font-medium text-gray-900">
                Novo total: <strong>{((selectedUser.points || 0) + pointsChange).toLocaleString('pt-BR')}</strong>
              </p>
            )}
            <Input
              label="Motivo (opcional)"
              value={pointsReason}
              onChange={(e) => setPointsReason(e.target.value)}
              placeholder="Digite o motivo do ajuste..."
            />
          </div>
        )}
      </Modal>

      {/* Premium Modal */}
      <Modal
        isOpen={premiumModalOpen}
        onClose={() => {
          setPremiumModalOpen(false)
          setPremiumMonths(1)
          setSelectedUser(null)
        }}
        title={selectedUser?.isPremium ? 'Desativar Premium' : 'Ativar Premium'}
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => {
                setPremiumModalOpen(false)
                setPremiumMonths(1)
                setSelectedUser(null)
              }}
            >
              Cancelar
            </Button>
            {selectedUser?.isPremium ? (
              <Button variant="danger" onClick={() => confirmPremium(false)}>
                Desativar Premium
              </Button>
            ) : (
              <Button variant="primary" onClick={() => confirmPremium(true)}>
                Ativar Premium
              </Button>
            )}
          </>
        }
      >
        {selectedUser && (
          <div className="space-y-4">
            <p className="text-gray-700">
              Usuário: <strong>{selectedUser.email}</strong>
            </p>
            {selectedUser.isPremium ? (
              <div>
                <p className="text-gray-700 mb-4">
                  Tem certeza que deseja desativar o Premium para este usuário?
                </p>
                {selectedUser.premiumExpiresAt && (
                  <p className="text-sm text-gray-600">
                    Expira em: {new Date(selectedUser.premiumExpiresAt).toLocaleDateString('pt-BR')}
                  </p>
                )}
              </div>
            ) : (
              <div>
                <p className="text-gray-700 mb-4">
                  Ativar Premium para este usuário?
                </p>
                <Input
                  label="Duração (meses)"
                  type="number"
                  min="1"
                  max="12"
                  value={premiumMonths}
                  onChange={(e) => setPremiumMonths(parseInt(e.target.value) || 1)}
                />
                <p className="text-sm text-gray-600 mt-2">
                  O Premium será ativado por <strong>{premiumMonths} {premiumMonths === 1 ? 'mês' : 'meses'}</strong>
                </p>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  )
}
