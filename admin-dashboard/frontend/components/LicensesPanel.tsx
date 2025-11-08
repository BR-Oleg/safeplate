'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'

interface License {
  id: string
  businessId: string
  amount: number
  plan: string
  status: string
  createdAt: string
  expiresAt: string
}

export default function LicensesPanel() {
  const [licenses, setLicenses] = useState<License[]>([])
  const [stats, setStats] = useState({ total: 0, active: 0, totalRevenue: 0 })
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [formData, setFormData] = useState({
    businessId: '',
    amount: '',
    plan: 'monthly',
    duration: '30',
  })

  useEffect(() => {
    loadLicenses()
  }, [])

  const loadLicenses = async () => {
    setLoading(true)
    try {
      const token = localStorage.getItem('adminToken')
      const response = await axios.get(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/licenses`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      setLicenses(response.data.licenses || [])
      setStats(response.data.stats || { total: 0, active: 0, totalRevenue: 0 })
    } catch (error) {
      console.error('Erro ao carregar licenças:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleCreateLicense = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      const token = localStorage.getItem('adminToken')
      await axios.post(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/licenses`,
        formData,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      setShowForm(false)
      setFormData({ businessId: '', amount: '', plan: 'monthly', duration: '30' })
      loadLicenses()
    } catch (error) {
      console.error('Erro ao criar licença:', error)
      alert('Erro ao criar licença')
    }
  }

  return (
    <div className="space-y-6">
      {/* Stats */}
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-sm font-medium text-gray-500">Total de Licenças</h3>
          <p className="text-2xl font-bold text-gray-900 mt-2">{stats.total}</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-sm font-medium text-gray-500">Licenças Ativas</h3>
          <p className="text-2xl font-bold text-green-600 mt-2">{stats.active}</p>
        </div>
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-sm font-medium text-gray-500">Faturamento Total</h3>
          <p className="text-2xl font-bold text-primary-600 mt-2">
            R$ {stats.totalRevenue.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
          </p>
        </div>
      </div>

      {/* Licenses List */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-6 border-b border-gray-200 flex justify-between items-center">
          <h2 className="text-xl font-bold">Licenças</h2>
          <button
            onClick={() => setShowForm(!showForm)}
            className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
          >
            {showForm ? 'Cancelar' : 'Nova Licença'}
          </button>
        </div>

        {showForm && (
          <form onSubmit={handleCreateLicense} className="p-6 border-b border-gray-200 space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">ID da Empresa</label>
              <input
                type="text"
                value={formData.businessId}
                onChange={(e) => setFormData({ ...formData, businessId: e.target.value })}
                required
                className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2"
              />
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Valor (R$)</label>
                <input
                  type="number"
                  step="0.01"
                  value={formData.amount}
                  onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
                  required
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Plano</label>
                <select
                  value={formData.plan}
                  onChange={(e) => setFormData({ ...formData, plan: e.target.value })}
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2"
                >
                  <option value="monthly">Mensal</option>
                  <option value="yearly">Anual</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Duração (dias)</label>
                <input
                  type="number"
                  value={formData.duration}
                  onChange={(e) => setFormData({ ...formData, duration: e.target.value })}
                  required
                  className="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2"
                />
              </div>
            </div>
            <button
              type="submit"
              className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
            >
              Criar Licença
            </button>
          </form>
        )}

        {loading ? (
          <div className="p-6 text-center">Carregando...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Empresa</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Valor</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Plano</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Expira em</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {licenses.map((license) => (
                  <tr key={license.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{license.businessId}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      R$ {license.amount.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{license.plan}</td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span
                        className={`px-2 py-1 text-xs font-semibold rounded-full ${
                          license.status === 'active'
                            ? 'text-green-800 bg-green-100'
                            : 'text-red-800 bg-red-100'
                        }`}
                      >
                        {license.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {new Date(license.expiresAt).toLocaleDateString('pt-BR')}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}



