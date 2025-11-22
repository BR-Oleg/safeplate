'use client'

import { useState, useEffect, useMemo } from 'react'
import axios from 'axios'
import Card from './ui/Card'
import Badge from './ui/Badge'
import Button from './ui/Button'
import Input from './ui/Input'
import Modal from './ui/Modal'

interface Campaign {
  id: string
  title: string
  description: string
  startDate: any
  endDate: any
  targetAudience: 'all' | 'premium' | 'bronze' | 'silver' | 'gold'
  rewards: any[]
  isActive: boolean
  createdAt?: any
}

interface HomePromosConfig {
  homeFairEnabled: boolean
  homeFairImageUrl: string
  homeFairTitleText: string
  homeFairDescriptionText: string
  homeFairPrimaryLabelText: string
  homeFairPrimaryUrl: string
  homeWhatsAppEnabled: boolean
  homeWhatsAppImageUrl: string
}

export default function CampaignsPanel() {
  const [campaigns, setCampaigns] = useState<Campaign[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [filter, setFilter] = useState<'all' | 'active' | 'inactive'>('all')
  const [createModalOpen, setCreateModalOpen] = useState(false)
  const [newCampaign, setNewCampaign] = useState({
    title: '',
    description: '',
    startDate: '',
    endDate: '',
    targetAudience: 'all' as 'all' | 'premium' | 'bronze' | 'silver' | 'gold',
    rewards: '',
  })
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 10

  const [homePromos, setHomePromos] = useState<HomePromosConfig>({
    homeFairEnabled: false,
    homeFairImageUrl: '',
    homeFairTitleText: '',
    homeFairDescriptionText: '',
    homeFairPrimaryLabelText: '',
    homeFairPrimaryUrl: '',
    homeWhatsAppEnabled: true,
    homeWhatsAppImageUrl: '',
  })
  const [homePromosLoading, setHomePromosLoading] = useState(false)
  const [homePromosSaving, setHomePromosSaving] = useState(false)

  useEffect(() => {
    loadCampaigns()
  }, [filter])

  useEffect(() => {
    loadHomePromos()
  }, [])

  const loadCampaigns = async () => {
    setLoading(true)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        console.error('Token não encontrado')
        setLoading(false)
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.get(`${apiUrl}/api/campaigns`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      setCampaigns(response.data.campaigns || [])
    } catch (error: any) {
      console.error('Erro ao carregar campanhas:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadHomePromos = async () => {
    setHomePromosLoading(true)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        console.error('Token não encontrado')
        setHomePromosLoading(false)
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.get(`${apiUrl}/api/app-config/home-promos`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      const data = response.data || {}
      setHomePromos({
        homeFairEnabled: !!data.homeFairEnabled,
        homeFairImageUrl: data.homeFairImageUrl || '',
        homeFairTitleText: data.homeFairTitleText || '',
        homeFairDescriptionText: data.homeFairDescriptionText || '',
        homeFairPrimaryLabelText: data.homeFairPrimaryLabelText || '',
        homeFairPrimaryUrl: data.homeFairPrimaryUrl || '',
        homeWhatsAppEnabled: data.homeWhatsAppEnabled !== false,
        homeWhatsAppImageUrl: data.homeWhatsAppImageUrl || '',
      })
    } catch (error: any) {
      console.error('Erro ao carregar banners da tela inicial:', error)
    } finally {
      setHomePromosLoading(false)
    }
  }

  const handleSaveHomePromos = async () => {
    setHomePromosSaving(true)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        alert('Token de administrador não encontrado')
        setHomePromosSaving(false)
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      await axios.post(`${apiUrl}/api/app-config/home-promos`, homePromos, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })

      alert('Configurações de banners salvas com sucesso!')
    } catch (error: any) {
      console.error('Erro ao salvar banners da tela inicial:', error)
      alert(`Erro ao salvar banners: ${error.response?.data?.error || error.message}`)
    } finally {
      setHomePromosSaving(false)
    }
  }

  const filteredCampaigns = useMemo(() => {
    return campaigns.filter((campaign) => {
      const matchesSearch =
        campaign.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        campaign.description.toLowerCase().includes(searchQuery.toLowerCase())

      let matchesFilter = true
      if (filter === 'active') {
        matchesFilter = campaign.isActive
      } else if (filter === 'inactive') {
        matchesFilter = !campaign.isActive
      }

      return matchesSearch && matchesFilter
    })
  }, [campaigns, searchQuery, filter])

  const paginatedCampaigns = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage
    return filteredCampaigns.slice(startIndex, startIndex + itemsPerPage)
  }, [filteredCampaigns, currentPage])

  const totalPages = Math.ceil(filteredCampaigns.length / itemsPerPage)

  const handleCreateCampaign = async () => {
    if (!newCampaign.title || !newCampaign.description || !newCampaign.startDate || !newCampaign.endDate) {
      alert('Preencha todos os campos obrigatórios')
      return
    }

    try {
      const token = localStorage.getItem('adminToken')
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const rewards = newCampaign.rewards ? JSON.parse(newCampaign.rewards) : []
      await axios.post(
        `${apiUrl}/api/campaigns`,
        {
          ...newCampaign,
          rewards,
        },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      setCreateModalOpen(false)
      setNewCampaign({
        title: '',
        description: '',
        startDate: '',
        endDate: '',
        targetAudience: 'all',
        rewards: '',
      })
      loadCampaigns()
      alert('Campanha criada com sucesso!')
    } catch (error: any) {
      console.error('Erro ao criar campanha:', error)
      alert(`Erro ao criar campanha: ${error.response?.data?.error || error.message}`)
    }
  }

  const handleToggleStatus = async (campaignId: string, isActive: boolean) => {
    try {
      const token = localStorage.getItem('adminToken')
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      await axios.put(
        `${apiUrl}/api/campaigns/${campaignId}/status`,
        { isActive: !isActive },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      loadCampaigns()
      alert(`Campanha ${!isActive ? 'ativada' : 'desativada'} com sucesso!`)
    } catch (error: any) {
      console.error('Erro ao atualizar status da campanha:', error)
      alert(`Erro ao atualizar status: ${error.response?.data?.error || error.message}`)
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

  const getTargetAudienceLabel = (audience: string) => {
    const labels: Record<string, string> = {
      all: 'Todos',
      premium: 'Premium',
      bronze: 'Bronze',
      silver: 'Prata',
      gold: 'Ouro',
    }
    return labels[audience] || audience
  }

  return (
    <div className="space-y-6">
      <Card>
        <div className="space-y-4">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Banners na tela inicial</h3>
            <p className="text-sm text-gray-500">
              Configure os banners que aparecem para os usuários ao abrir o aplicativo.
            </p>
          </div>

          {/* Feira Nacional */}
          <div className="border border-gray-200 rounded-lg p-4 space-y-3 bg-gray-50/60">
            <div className="flex items-center justify-between gap-3">
              <div>
                <h4 className="text-sm font-semibold text-gray-900">Banner da Feira Nacional</h4>
                <p className="text-xs text-gray-500">
                  Primeiro modal exibido ao abrir o app. Conteúdo pode ser personalizado para campanhas
                  específicas.
                </p>
              </div>
              <label className="flex items-center gap-2 text-sm cursor-pointer">
                <span className="text-xs text-gray-600">Exibir</span>
                <input
                  type="checkbox"
                  checked={homePromos.homeFairEnabled}
                  onChange={(e) => setHomePromos({ ...homePromos, homeFairEnabled: e.target.checked })}
                  className="h-4 w-4 text-primary-600 border-gray-300 rounded"
                />
              </label>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-2">
              <Input
                label="Título (opcional)"
                placeholder="Ex.: Feira Nacional Prato Seguro 2025"
                value={homePromos.homeFairTitleText}
                onChange={(e) => setHomePromos({ ...homePromos, homeFairTitleText: e.target.value })}
              />
              <Input
                label="Texto do botão (opcional)"
                placeholder="Ex.: Quero participar"
                value={homePromos.homeFairPrimaryLabelText}
                onChange={(e) => setHomePromos({ ...homePromos, homeFairPrimaryLabelText: e.target.value })}
              />
              <Input
                label="Descrição (opcional)"
                placeholder="Texto curto explicando a campanha da feira."
                value={homePromos.homeFairDescriptionText}
                onChange={(e) => setHomePromos({ ...homePromos, homeFairDescriptionText: e.target.value })}
                multiline
              />
              <Input
                label="URL do botão (opcional)"
                placeholder="https://..."
                value={homePromos.homeFairPrimaryUrl}
                onChange={(e) => setHomePromos({ ...homePromos, homeFairPrimaryUrl: e.target.value })}
              />
              <Input
                label="URL da imagem (opcional)"
                placeholder="https://.../banner-feira.png"
                value={homePromos.homeFairImageUrl}
                onChange={(e) => setHomePromos({ ...homePromos, homeFairImageUrl: e.target.value })}
              />
            </div>
            <p className="text-xs text-gray-500">
              Se algum campo ficar vazio, o app usará os textos padrão traduzidos. Use esta seção apenas
              quando quiser destacar uma campanha específica.
            </p>
          </div>

          {/* WhatsApp Group Banner */}
          <div className="border border-gray-200 rounded-lg p-4 space-y-3">
            <div className="flex items-center justify-between gap-3">
              <div>
                <h4 className="text-sm font-semibold text-gray-900">Banner do grupo oficial no WhatsApp</h4>
                <p className="text-xs text-gray-500">
                  Segundo modal exibido. Textos são padronizados e traduzidos; aqui você pode apenas ativar
                  ou desativar e definir uma imagem ilustrativa.
                </p>
              </div>
              <label className="flex items-center gap-2 text-sm cursor-pointer">
                <span className="text-xs text-gray-600">Exibir</span>
                <input
                  type="checkbox"
                  checked={homePromos.homeWhatsAppEnabled}
                  onChange={(e) => setHomePromos({ ...homePromos, homeWhatsAppEnabled: e.target.checked })}
                  className="h-4 w-4 text-primary-600 border-gray-300 rounded"
                />
              </label>
            </div>

            <Input
              label="URL da imagem (opcional)"
              placeholder="https://.../banner-whatsapp.png"
              value={homePromos.homeWhatsAppImageUrl}
              onChange={(e) => setHomePromos({ ...homePromos, homeWhatsAppImageUrl: e.target.value })}
            />
            <p className="text-xs text-gray-500">
              O link do grupo e os textos principais são definidos no aplicativo. Use esta imagem apenas para
              deixar o convite mais atrativo visualmente.
            </p>
          </div>

          <div className="flex items-center gap-3 pt-2">
            <Button
              variant="primary"
              onClick={handleSaveHomePromos}
              disabled={homePromosSaving || homePromosLoading}
            >
              {homePromosSaving ? 'Salvando...' : 'Salvar banners da tela inicial'}
            </Button>
            <Button
              variant="outline"
              onClick={loadHomePromos}
              disabled={homePromosLoading}
            >
              Recarregar configurações
            </Button>
          </div>
        </div>
      </Card>

      <Card>
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Campanhas Sazonais</h3>
            <p className="text-sm text-gray-500">Criar e gerenciar campanhas promocionais</p>
            <div className="mt-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
              <p className="text-xs text-blue-800">
                <strong>📢 Notificações:</strong> As notificações serão enviadas automaticamente quando uma campanha for <strong>ativada</strong> e estiver dentro do período de vigência (entre data de início e término). 
                Usuários que correspondem ao público-alvo selecionado receberão a notificação.
              </p>
            </div>
          </div>
          <Button onClick={() => setCreateModalOpen(true)}>+ Criar Campanha</Button>
        </div>

        {/* Filters */}
        <div className="flex gap-4 mb-6">
          <Input
            placeholder="Buscar por título ou descrição..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1"
          />
          <div className="flex gap-2">
            {(['all', 'active', 'inactive'] as const).map((f) => (
              <Button
                key={f}
                variant={filter === f ? 'primary' : 'outline'}
                size="sm"
                onClick={() => {
                  setFilter(f)
                  setCurrentPage(1)
                }}
              >
                {f === 'all' ? 'Todas' : f === 'active' ? 'Ativas' : 'Inativas'}
              </Button>
            ))}
          </div>
        </div>

        {loading ? (
          <div className="text-center py-12">
            <div className="spinner mx-auto mb-4"></div>
            <p className="text-gray-600">Carregando campanhas...</p>
          </div>
        ) : filteredCampaigns.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600">Nenhuma campanha encontrada</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="table">
                <thead>
                  <tr>
                    <th>Título</th>
                    <th>Descrição</th>
                    <th>Público-alvo</th>
                    <th>Início</th>
                    <th>Fim</th>
                    <th>Status</th>
                    <th className="text-right">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedCampaigns.map((campaign) => (
                    <tr key={campaign.id}>
                      <td className="font-medium">{campaign.title}</td>
                      <td className="max-w-xs truncate">{campaign.description}</td>
                      <td>
                        <Badge variant="info">{getTargetAudienceLabel(campaign.targetAudience)}</Badge>
                      </td>
                      <td className="text-sm text-gray-600">{formatDate(campaign.startDate)}</td>
                      <td className="text-sm text-gray-600">{formatDate(campaign.endDate)}</td>
                      <td>
                        {campaign.isActive ? (
                          <Badge variant="success">Ativa</Badge>
                        ) : (
                          <Badge variant="default">Inativa</Badge>
                        )}
                      </td>
                      <td>
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handleToggleStatus(campaign.id, campaign.isActive)}
                          >
                            {campaign.isActive ? 'Desativar' : 'Ativar'}
                          </Button>
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

      {/* Create Campaign Modal */}
      <Modal
        isOpen={createModalOpen}
        onClose={() => {
          setCreateModalOpen(false)
          setNewCampaign({
            title: '',
            description: '',
            startDate: '',
            endDate: '',
            targetAudience: 'all',
            rewards: '',
          })
        }}
        title="Criar Nova Campanha"
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => {
                setCreateModalOpen(false)
                setNewCampaign({
                  title: '',
                  description: '',
                  startDate: '',
                  endDate: '',
                  targetAudience: 'all',
                  rewards: '',
                })
              }}
            >
              Cancelar
            </Button>
            <Button variant="primary" onClick={handleCreateCampaign}>
              Criar Campanha
            </Button>
          </>
        }
      >
        <div className="space-y-4">
          <Input
            label="Título"
            value={newCampaign.title}
            onChange={(e) => setNewCampaign({ ...newCampaign, title: e.target.value })}
            placeholder="Título da campanha"
          />
          <Input
            label="Descrição"
            value={newCampaign.description}
            onChange={(e) => setNewCampaign({ ...newCampaign, description: e.target.value })}
            placeholder="Descrição da campanha"
            multiline
          />
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Público-alvo</label>
            <select
              value={newCampaign.targetAudience}
              onChange={(e) => setNewCampaign({ ...newCampaign, targetAudience: e.target.value as any })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="all">Todos</option>
              <option value="premium">Premium</option>
              <option value="bronze">Bronze</option>
              <option value="silver">Prata</option>
              <option value="gold">Ouro</option>
            </select>
          </div>
          <Input
            label="Data de Início"
            type="datetime-local"
            value={newCampaign.startDate}
            onChange={(e) => setNewCampaign({ ...newCampaign, startDate: e.target.value })}
          />
          <Input
            label="Data de Término"
            type="datetime-local"
            value={newCampaign.endDate}
            onChange={(e) => setNewCampaign({ ...newCampaign, endDate: e.target.value })}
          />
          <Input
            label="Recompensas (JSON opcional)"
            value={newCampaign.rewards}
            onChange={(e) => setNewCampaign({ ...newCampaign, rewards: e.target.value })}
            placeholder='[{"type": "points", "value": 100}]'
            multiline
          />
          <p className="text-xs text-gray-500">
            Formato JSON: Array de objetos com type (points, coupon) e value
          </p>
          <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
            <p className="text-xs text-yellow-800">
              <strong>⚠️ Importante:</strong> Para enviar notificações, você deve <strong>ativar a campanha</strong> após criá-la. 
              As notificações serão enviadas apenas para campanhas <strong>ativas</strong> que estejam dentro do período de vigência.
            </p>
          </div>
        </div>
      </Modal>
    </div>
  )
}

