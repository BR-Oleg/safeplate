'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'
import MaintenancePanel from './MaintenancePanel'
import UsersPanel from './UsersPanel'
import EstablishmentsPanel from './EstablishmentsPanel'
import LicensesPanel from './LicensesPanel'
import StatsPanel from './StatsPanel'
import CouponsPanel from './CouponsPanel'
import CampaignsPanel from './CampaignsPanel'
import CertificationRequestsPanel from './CertificationRequestsPanel'
import ReferralRequestsPanel from './ReferralRequestsPanel'
import Button from './ui/Button'
import Badge from './ui/Badge'

interface DashboardProps {
  onLogout: () => void
}

export default function Dashboard({ onLogout }: DashboardProps) {
  const [activeTab, setActiveTab] = useState('stats')
  const [maintenanceStatus, setMaintenanceStatus] = useState({ enabled: false, message: '' })
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [userInfo, setUserInfo] = useState({ email: 'admin@pratoseguro.com' })
  const [seasonalTheme, setSeasonalTheme] = useState<'none' | 'christmas' | 'carnival'>('none')
  const [seasonalThemeLoading, setSeasonalThemeLoading] = useState(false)
  const [seasonalThemeSaving, setSeasonalThemeSaving] = useState(false)

  useEffect(() => {
    loadMaintenanceStatus()
    loadSeasonalTheme()
  }, [])

  const loadMaintenanceStatus = async () => {
    try {
      const response = await axios.get(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/maintenance/status`)
      setMaintenanceStatus(response.data)
    } catch (error) {
      console.error('Erro ao carregar status de manutenção:', error)
    }
  }

  const loadSeasonalTheme = async () => {
    try {
      setSeasonalThemeLoading(true)
      const token = localStorage.getItem('adminToken')
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.get(`${apiUrl}/api/app-config/seasonal-theme`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      const value = (response.data?.seasonalTheme || 'none') as string
      if (value === 'christmas' || value === 'carnival' || value === 'none') {
        setSeasonalTheme(value as 'none' | 'christmas' | 'carnival')
      } else {
        setSeasonalTheme('none')
      }
    } catch (error) {
      console.error('Erro ao carregar tema sazonal:', error)
    } finally {
      setSeasonalThemeLoading(false)
    }
  }

  const handleSaveSeasonalTheme = async () => {
    try {
      setSeasonalThemeSaving(true)
      const token = localStorage.getItem('adminToken')
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      await axios.post(
        `${apiUrl}/api/app-config/seasonal-theme`,
        { seasonalTheme: seasonalTheme === 'none' ? null : seasonalTheme },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      alert('Tema sazonal atualizado com sucesso!')
    } catch (error: any) {
      console.error('Erro ao salvar tema sazonal:', error)
      alert(`Erro ao salvar tema sazonal: ${error.response?.data?.error || error.message}`)
    } finally {
      setSeasonalThemeSaving(false)
    }
  }

  const handleLogout = () => {
    localStorage.removeItem('adminToken')
    onLogout()
  }

  const tabs = [
    { id: 'stats', label: 'Dashboard', icon: '📊', description: 'Visão geral' },
    { id: 'users', label: 'Usuários', icon: '👥', description: 'Gerenciar usuários' },
    { id: 'establishments', label: 'Estabelecimentos', icon: '🏢', description: 'Gerenciar estabelecimentos' },
    { id: 'certRequests', label: 'Certificações', icon: '🛡️', description: 'Solicitações de certificação técnica' },
    { id: 'referrals', label: 'Indicações', icon: '📍', description: 'Indicações de novos locais' },
    { id: 'coupons', label: 'Cupons', icon: '🎫', description: 'Gerenciar cupons e recompensas' },
    { id: 'campaigns', label: 'Campanhas', icon: '🎯', description: 'Campanhas sazonais' },
    { id: 'licenses', label: 'Licenças', icon: '💳', description: 'Faturamento e licenças' },
    { id: 'maintenance', label: 'Manutenção', icon: '🔧', description: 'Sistema de manutenção' },
  ]

  return (
    <div className="flex h-screen bg-gray-50 overflow-hidden">
      {/* Sidebar */}
      <aside
        className={`
          bg-white border-r border-gray-200 transition-all duration-300
          ${sidebarOpen ? 'w-64' : 'w-20'}
          flex flex-col
        `}
      >
        {/* Logo */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          {sidebarOpen && (
            <div className="flex items-center gap-3 flex-1">
              <img
                src="/logo.png"
                alt="Prato Seguro"
                className="w-10 h-10 object-contain"
              />
              <div className="flex-1 min-w-0">
                <h1 className="text-lg font-bold text-gray-900">Prato Seguro</h1>
                <p className="text-xs text-gray-500 opacity-60">Safe Plate</p>
              </div>
            </div>
          )}
          {!sidebarOpen && (
            <img
              src="/logo.png"
              alt="Prato Seguro"
              className="w-10 h-10 object-contain mx-auto"
            />
          )}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-1.5 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`
                w-full flex items-center gap-3 px-4 py-3 rounded-lg
                transition-all duration-200
                ${
                  activeTab === tab.id
                    ? 'bg-primary-50 text-primary-700 font-semibold'
                    : 'text-gray-700 hover:bg-gray-50'
                }
              `}
            >
              <span className="text-xl">{tab.icon}</span>
              {sidebarOpen && (
                <div className="flex-1 text-left">
                  <div className="text-sm font-medium">{tab.label}</div>
                  <div className="text-xs text-gray-500">{tab.description}</div>
                </div>
              )}
            </button>
          ))}
        </nav>

        {/* Maintenance Status */}
        {maintenanceStatus.enabled && (
          <div className="p-4 border-t border-gray-200">
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
              {sidebarOpen ? (
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-yellow-600">⚠️</span>
                    <span className="text-sm font-semibold text-yellow-800">Manutenção Ativa</span>
                  </div>
                  <p className="text-xs text-yellow-700 line-clamp-2">{maintenanceStatus.message}</p>
                </div>
              ) : (
                <div className="flex justify-center">
                  <span className="text-yellow-600 text-xl">⚠️</span>
                </div>
              )}
            </div>
          </div>
        )}

        {/* User Info */}
        <div className="p-4 border-t border-gray-200">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-gray-400 to-gray-500 rounded-full flex items-center justify-center">
              <span className="text-white text-sm font-semibold">
                {userInfo.email.charAt(0).toUpperCase()}
              </span>
            </div>
            {sidebarOpen && (
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900 truncate">{userInfo.email}</p>
                <p className="text-xs text-gray-500">Administrador</p>
              </div>
            )}
          </div>
          {sidebarOpen && (
            <Button
              variant="outline"
              size="sm"
              className="w-full mt-3"
              onClick={handleLogout}
            >
              Sair
            </Button>
          )}
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Bar */}
        <header className="bg-white border-b border-gray-200 px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">
                {tabs.find(t => t.id === activeTab)?.label || 'Dashboard'}
              </h2>
              <p className="text-sm text-gray-500 mt-0.5">
                {tabs.find(t => t.id === activeTab)?.description || 'Visão geral do sistema'}
              </p>
            </div>
            <div className="flex items-center gap-3">
              {/* Seasonal Theme Selector */}
              <div className="hidden md:flex items-center gap-2 mr-2">
                <span className="text-xs text-gray-500">Tema sazonal:</span>
                <select
                  value={seasonalTheme}
                  onChange={(e) => setSeasonalTheme(e.target.value as 'none' | 'christmas' | 'carnival')}
                  disabled={seasonalThemeLoading || seasonalThemeSaving}
                  className="text-xs border border-gray-300 rounded-md px-2 py-1 bg-white focus:outline-none focus:ring-1 focus:ring-primary-500"
                >
                  <option value="none">Nenhum</option>
                  <option value="christmas">Natal / Christmas</option>
                  <option value="carnival">Carnaval</option>
                </select>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleSaveSeasonalTheme}
                  disabled={seasonalThemeLoading || seasonalThemeSaving}
                >
                  {seasonalThemeSaving ? 'Salvando...' : 'Aplicar'}
                </Button>
              </div>
              {/* Notifications */}
              <button className="p-2 hover:bg-gray-100 rounded-lg transition-colors relative">
                <svg className="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                </svg>
                <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
              </button>
              {/* Settings */}
              <button className="p-2 hover:bg-gray-100 rounded-lg transition-colors">
                <svg className="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </button>
            </div>
          </div>
        </header>

        {/* Content Area */}
        <main className="flex-1 overflow-y-auto p-6">
          <div className="max-w-7xl mx-auto">
            {activeTab === 'stats' && <StatsPanel />}
            {activeTab === 'maintenance' && <MaintenancePanel onUpdate={loadMaintenanceStatus} />}
            {activeTab === 'users' && <UsersPanel />}
            {activeTab === 'establishments' && <EstablishmentsPanel />}
            {activeTab === 'certRequests' && <CertificationRequestsPanel />}
            {activeTab === 'referrals' && <ReferralRequestsPanel />}
            {activeTab === 'coupons' && <CouponsPanel />}
            {activeTab === 'campaigns' && <CampaignsPanel />}
            {activeTab === 'licenses' && <LicensesPanel />}
          </div>
        </main>
      </div>
    </div>
  )
}
