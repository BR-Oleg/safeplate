'use client'

import { useState, useEffect, useMemo } from 'react'
import axios from 'axios'
import Card from './ui/Card'
import Badge from './ui/Badge'
import Button from './ui/Button'
import Input from './ui/Input'
import Modal from './ui/Modal'

interface Coupon {
  id: string
  userId: string
  code: string
  description: string
  discountValue: number
  establishmentId: string
  establishmentName: string
  expiresAt: any
  isUsed: boolean
  createdAt?: any
}

interface User {
  id: string
  email: string
  name?: string
  type: 'user' | 'business'
  isPremium?: boolean
  seal?: 'bronze' | 'silver' | 'gold'
}

export default function CouponsPanel() {
  const [coupons, setCoupons] = useState<Coupon[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [filter, setFilter] = useState<'all' | 'active' | 'used' | 'expired'>('all')
  const [createModalOpen, setCreateModalOpen] = useState(false)
  const [users, setUsers] = useState<User[]>([])
  const [loadingUsers, setLoadingUsers] = useState(false)
  const [couponMode, setCouponMode] = useState<'single' | 'multiple' | 'group'>('group')
  const [newCoupon, setNewCoupon] = useState({
    userId: '',
    userIds: [] as string[],
    targetGroup: 'all' as 'all' | 'premium' | 'bronze' | 'silver' | 'gold',
    code: '',
    description: '',
    discountValue: '',
    establishmentId: '',
    establishmentName: '',
    expiresAt: '',
  })
  const [userSearchQuery, setUserSearchQuery] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 10

  useEffect(() => {
    loadCoupons()
  }, [filter])

  useEffect(() => {
    if (createModalOpen && (couponMode === 'single' || couponMode === 'multiple')) {
      loadUsers()
    }
  }, [createModalOpen, couponMode])

  const loadUsers = async () => {
    setLoadingUsers(true)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        setLoadingUsers(false)
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.get(`${apiUrl}/api/users`, {
        params: { type: 'user' },
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      setUsers(response.data.users || [])
    } catch (error: any) {
      console.error('Erro ao carregar usuários:', error)
    } finally {
      setLoadingUsers(false)
    }
  }

  const filteredUsers = useMemo(() => {
    return users.filter((user) => {
      const matchesSearch =
        user.email.toLowerCase().includes(userSearchQuery.toLowerCase()) ||
        (user.name && user.name.toLowerCase().includes(userSearchQuery.toLowerCase()))
      return matchesSearch
    })
  }, [users, userSearchQuery])

  const loadCoupons = async () => {
    setLoading(true)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        console.error('Token não encontrado')
        setLoading(false)
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.get(`${apiUrl}/api/coupons`, {
        params: {
          activeOnly: filter === 'active' ? 'true' : undefined,
        },
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      setCoupons(response.data.coupons || [])
    } catch (error: any) {
      console.error('Erro ao carregar cupons:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredCoupons = useMemo(() => {
    return coupons.filter((coupon) => {
      const matchesSearch =
        coupon.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
        coupon.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
        coupon.establishmentName.toLowerCase().includes(searchQuery.toLowerCase())

      const now = new Date()
      const expiresAt = coupon.expiresAt?.toDate ? coupon.expiresAt.toDate() : new Date(coupon.expiresAt)

      let matchesFilter = true
      if (filter === 'active') {
        matchesFilter = !coupon.isUsed && expiresAt > now
      } else if (filter === 'used') {
        matchesFilter = coupon.isUsed
      } else if (filter === 'expired') {
        matchesFilter = !coupon.isUsed && expiresAt <= now
      }

      return matchesSearch && matchesFilter
    })
  }, [coupons, searchQuery, filter])

  const paginatedCoupons = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage
    return filteredCoupons.slice(startIndex, startIndex + itemsPerPage)
  }, [filteredCoupons, currentPage])

  const totalPages = Math.ceil(filteredCoupons.length / itemsPerPage)

  const handleCreateCoupon = async () => {
    // Validar campos obrigatórios
    if (!newCoupon.code || !newCoupon.description || !newCoupon.discountValue || !newCoupon.establishmentId || !newCoupon.establishmentName || !newCoupon.expiresAt) {
      alert('Preencha todos os campos obrigatórios')
      return
    }

    // Validar seleção de usuários/grupo
    if (couponMode === 'single' && !newCoupon.userId) {
      alert('Selecione um usuário')
      return
    }
    if (couponMode === 'multiple' && newCoupon.userIds.length === 0) {
      alert('Selecione pelo menos um usuário')
      return
    }
    if (couponMode === 'group' && !newCoupon.targetGroup) {
      alert('Selecione um grupo')
      return
    }

    try {
      const token = localStorage.getItem('adminToken')
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      
      const payload: any = {
        code: newCoupon.code,
        description: newCoupon.description,
        discountValue: newCoupon.discountValue,
        establishmentId: newCoupon.establishmentId,
        establishmentName: newCoupon.establishmentName,
        expiresAt: newCoupon.expiresAt,
      }

      // Adicionar dados de usuários/grupo conforme o modo
      if (couponMode === 'single') {
        payload.userId = newCoupon.userId
      } else if (couponMode === 'multiple') {
        payload.userIds = newCoupon.userIds
      } else if (couponMode === 'group') {
        payload.targetGroup = newCoupon.targetGroup
      }

      const response = await axios.post(
        `${apiUrl}/api/coupons`,
        payload,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      
      setCreateModalOpen(false)
      setNewCoupon({
        userId: '',
        userIds: [],
        targetGroup: 'all',
        code: '',
        description: '',
        discountValue: '',
        establishmentId: '',
        establishmentName: '',
        expiresAt: '',
      })
      setCouponMode('group')
      loadCoupons()
      alert(`✅ ${response.data.message || 'Cupom(s) criado(s) com sucesso!'}\n📢 Notificações enviadas: ${response.data.notificationsSent || 0}`)
    } catch (error: any) {
      console.error('Erro ao criar cupom:', error)
      alert(`Erro ao criar cupom: ${error.response?.data?.error || error.message}`)
    }
  }

  const formatDate = (date: any) => {
    if (!date) return 'N/A'
    try {
      // Se já é uma string ISO, usar diretamente
      if (typeof date === 'string') {
        const d = new Date(date)
        if (isNaN(d.getTime())) return 'Data inválida'
        return d.toLocaleDateString('pt-BR', { 
          day: '2-digit', 
          month: '2-digit', 
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })
      }
      // Se é Timestamp do Firestore
      if (date.toDate) {
        const d = date.toDate()
        return d.toLocaleDateString('pt-BR', { 
          day: '2-digit', 
          month: '2-digit', 
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })
      }
      // Tentar como Date
      const d = new Date(date)
      if (isNaN(d.getTime())) return 'Data inválida'
      return d.toLocaleDateString('pt-BR', { 
        day: '2-digit', 
        month: '2-digit', 
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    } catch (e) {
      return 'Data inválida'
    }
  }

  return (
    <div className="space-y-6">
      <Card>
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Gerenciamento de Cupons</h3>
            <p className="text-sm text-gray-500">Criar e gerenciar cupons de desconto</p>
            <div className="mt-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
              <p className="text-xs text-blue-800">
                <strong>📢 Notificações:</strong> As notificações de cupons são enviadas quando um cupom é criado e atribuído a um usuário específico. 
                O usuário receberá uma notificação push informando sobre o novo cupom disponível.
              </p>
            </div>
          </div>
          <Button onClick={() => setCreateModalOpen(true)}>+ Criar Cupom</Button>
        </div>

        {/* Filters */}
        <div className="flex gap-4 mb-6">
          <Input
            placeholder="Buscar por código, descrição ou estabelecimento..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1"
          />
          <div className="flex gap-2">
            {(['all', 'active', 'used', 'expired'] as const).map((f) => (
              <Button
                key={f}
                variant={filter === f ? 'primary' : 'outline'}
                size="sm"
                onClick={() => {
                  setFilter(f)
                  setCurrentPage(1)
                }}
              >
                {f === 'all' ? 'Todos' : f === 'active' ? 'Ativos' : f === 'used' ? 'Usados' : 'Expirados'}
              </Button>
            ))}
          </div>
        </div>

        {loading ? (
          <div className="text-center py-12">
            <div className="spinner mx-auto mb-4"></div>
            <p className="text-gray-600">Carregando cupons...</p>
          </div>
        ) : filteredCoupons.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600">Nenhum cupom encontrado</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="table">
                <thead>
                  <tr>
                    <th>Código</th>
                    <th>Descrição</th>
                    <th>Desconto</th>
                    <th>Estabelecimento</th>
                    <th>Status</th>
                    <th>Expira em</th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedCoupons.map((coupon) => {
                    const expiresAt = coupon.expiresAt?.toDate ? coupon.expiresAt.toDate() : new Date(coupon.expiresAt)
                    const isExpired = !coupon.isUsed && expiresAt <= new Date()
                    return (
                      <tr key={coupon.id}>
                        <td className="font-mono font-medium">{coupon.code}</td>
                        <td>{coupon.description}</td>
                        <td>R$ {coupon.discountValue.toFixed(2)}</td>
                        <td>{coupon.establishmentName}</td>
                        <td>
                          {coupon.isUsed ? (
                            <Badge variant="default">Usado</Badge>
                          ) : isExpired ? (
                            <Badge variant="danger">Expirado</Badge>
                          ) : (
                            <Badge variant="success">Ativo</Badge>
                          )}
                        </td>
                        <td className="text-sm text-gray-600">{formatDate(coupon.expiresAt)}</td>
                      </tr>
                    )
                  })}
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

      {/* Create Coupon Modal */}
      <Modal
        isOpen={createModalOpen}
        onClose={() => {
          setCreateModalOpen(false)
          setNewCoupon({
            userId: '',
            userIds: [],
            targetGroup: 'all',
            code: '',
            description: '',
            discountValue: '',
            establishmentId: '',
            establishmentName: '',
            expiresAt: '',
          })
          setCouponMode('group')
          setUserSearchQuery('')
        }}
        title="Criar Novo Cupom"
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => {
                setCreateModalOpen(false)
                setNewCoupon({
                  userId: '',
                  userIds: [],
                  targetGroup: 'all',
                  code: '',
                  description: '',
                  discountValue: '',
                  establishmentId: '',
                  establishmentName: '',
                  expiresAt: '',
                })
                setCouponMode('group')
                setUserSearchQuery('')
              }}
            >
              Cancelar
            </Button>
            <Button variant="primary" onClick={handleCreateCoupon}>
              Criar Cupom
            </Button>
          </>
        }
      >
        <div className="space-y-4">
          {/* Modo de criação */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Modo de Criação
            </label>
            <div className="flex gap-2">
              <Button
                variant={couponMode === 'group' ? 'primary' : 'outline'}
                size="sm"
                onClick={() => {
                  setCouponMode('group')
                  setNewCoupon({ ...newCoupon, userId: '', userIds: [] })
                }}
              >
                Grupo
              </Button>
              <Button
                variant={couponMode === 'multiple' ? 'primary' : 'outline'}
                size="sm"
                onClick={() => {
                  setCouponMode('multiple')
                  setNewCoupon({ ...newCoupon, userId: '', targetGroup: 'all' })
                }}
              >
                Múltiplos Usuários
              </Button>
              <Button
                variant={couponMode === 'single' ? 'primary' : 'outline'}
                size="sm"
                onClick={() => {
                  setCouponMode('single')
                  setNewCoupon({ ...newCoupon, userIds: [], targetGroup: 'all' })
                }}
              >
                Usuário Único
              </Button>
            </div>
          </div>

          {/* Seleção de usuários/grupo */}
          {couponMode === 'group' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Grupo de Usuários
              </label>
              <select
                value={newCoupon.targetGroup}
                onChange={(e) => setNewCoupon({ ...newCoupon, targetGroup: e.target.value as any })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="all">Todos os Usuários</option>
                <option value="premium">Usuários Premium</option>
                <option value="bronze">Selo Bronze</option>
                <option value="silver">Selo Prata</option>
                <option value="gold">Selo Ouro</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">
                O cupom será criado para todos os usuários do grupo selecionado
              </p>
            </div>
          )}

          {couponMode === 'single' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Selecionar Usuário
              </label>
              <Input
                placeholder="Buscar usuário por email ou nome..."
                value={userSearchQuery}
                onChange={(e) => setUserSearchQuery(e.target.value)}
                className="mb-2"
              />
              <div className="border border-gray-300 rounded-lg max-h-48 overflow-y-auto">
                {loadingUsers ? (
                  <div className="p-4 text-center text-gray-500">Carregando usuários...</div>
                ) : filteredUsers.length === 0 ? (
                  <div className="p-4 text-center text-gray-500">Nenhum usuário encontrado</div>
                ) : (
                  filteredUsers.map((user) => (
                    <div
                      key={user.id}
                      onClick={() => setNewCoupon({ ...newCoupon, userId: user.id })}
                      className={`p-3 cursor-pointer hover:bg-gray-50 border-b border-gray-200 last:border-b-0 ${
                        newCoupon.userId === user.id ? 'bg-green-50 border-green-300' : ''
                      }`}
                    >
                      <div className="font-medium">{user.name || user.email}</div>
                      <div className="text-sm text-gray-500">{user.email}</div>
                      {user.isPremium && (
                        <Badge variant="info" className="mt-1">Premium</Badge>
                      )}
                    </div>
                  ))
                )}
              </div>
            </div>
          )}

          {couponMode === 'multiple' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Selecionar Múltiplos Usuários
              </label>
              <Input
                placeholder="Buscar usuário por email ou nome..."
                value={userSearchQuery}
                onChange={(e) => setUserSearchQuery(e.target.value)}
                className="mb-2"
              />
              {newCoupon.userIds.length > 0 && (
                <div className="mb-2 p-2 bg-green-50 border border-green-200 rounded-lg">
                  <p className="text-sm text-green-800">
                    <strong>{newCoupon.userIds.length}</strong> usuário(s) selecionado(s)
                  </p>
                </div>
              )}
              <div className="border border-gray-300 rounded-lg max-h-48 overflow-y-auto">
                {loadingUsers ? (
                  <div className="p-4 text-center text-gray-500">Carregando usuários...</div>
                ) : filteredUsers.length === 0 ? (
                  <div className="p-4 text-center text-gray-500">Nenhum usuário encontrado</div>
                ) : (
                  filteredUsers.map((user) => {
                    const isSelected = newCoupon.userIds.includes(user.id)
                    return (
                      <div
                        key={user.id}
                        onClick={() => {
                          if (isSelected) {
                            setNewCoupon({
                              ...newCoupon,
                              userIds: newCoupon.userIds.filter((id) => id !== user.id),
                            })
                          } else {
                            setNewCoupon({
                              ...newCoupon,
                              userIds: [...newCoupon.userIds, user.id],
                            })
                          }
                        }}
                        className={`p-3 cursor-pointer hover:bg-gray-50 border-b border-gray-200 last:border-b-0 ${
                          isSelected ? 'bg-green-50 border-green-300' : ''
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="font-medium">{user.name || user.email}</div>
                            <div className="text-sm text-gray-500">{user.email}</div>
                          </div>
                          <input
                            type="checkbox"
                            checked={isSelected}
                            onChange={() => {}}
                            className="w-5 h-5 text-green-600 rounded"
                          />
                        </div>
                      </div>
                    )
                  })
                )}
              </div>
            </div>
          )}

          <Input
            label="Código Base do Cupom"
            value={newCoupon.code}
            onChange={(e) => setNewCoupon({ ...newCoupon, code: e.target.value.toUpperCase() })}
            placeholder="Ex: DESCONTO10"
          />
          <p className="text-xs text-gray-500 -mt-2">
            Cada usuário receberá um código único baseado neste código
          </p>
          <Input
            label="Descrição"
            value={newCoupon.description}
            onChange={(e) => setNewCoupon({ ...newCoupon, description: e.target.value })}
            placeholder="Descrição do desconto"
          />
          <Input
            label="Valor do Desconto (R$)"
            type="number"
            step="0.01"
            value={newCoupon.discountValue}
            onChange={(e) => setNewCoupon({ ...newCoupon, discountValue: e.target.value })}
            placeholder="0.00"
          />
          <Input
            label="ID do Estabelecimento"
            value={newCoupon.establishmentId}
            onChange={(e) => setNewCoupon({ ...newCoupon, establishmentId: e.target.value })}
            placeholder="ID do estabelecimento"
          />
          <Input
            label="Nome do Estabelecimento"
            value={newCoupon.establishmentName}
            onChange={(e) => setNewCoupon({ ...newCoupon, establishmentName: e.target.value })}
            placeholder="Nome do estabelecimento"
          />
          <Input
            label="Data de Expiração"
            type="datetime-local"
            value={newCoupon.expiresAt}
            onChange={(e) => setNewCoupon({ ...newCoupon, expiresAt: e.target.value })}
          />
          <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
            <p className="text-xs text-yellow-800">
              <strong>⚠️ Importante:</strong> Ao criar um cupom, uma notificação será enviada automaticamente para o usuário especificado no campo "ID do Usuário". 
              Certifique-se de que o ID do usuário está correto para que a notificação seja entregue.
            </p>
          </div>
        </div>
      </Modal>
    </div>
  )
}

