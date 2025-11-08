'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'
import Card from './ui/Card'
import Button from './ui/Button'
import Input from './ui/Input'
import Badge from './ui/Badge'

interface MaintenancePanelProps {
  onUpdate: () => void
}

export default function MaintenancePanel({ onUpdate }: MaintenancePanelProps) {
  const [enabled, setEnabled] = useState(false)
  const [message, setMessage] = useState('')
  const [loading, setLoading] = useState(false)
  const [saved, setSaved] = useState(false)

  useEffect(() => {
    loadStatus()
  }, [])

  const loadStatus = async () => {
    try {
      const response = await axios.get(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/maintenance/status`)
      setEnabled(response.data.enabled || false)
      setMessage(response.data.message || '')
    } catch (error) {
      console.error('Erro ao carregar status:', error)
    }
  }

  const handleSave = async () => {
    setLoading(true)
    setSaved(false)

    try {
      const token = localStorage.getItem('adminToken')
      await axios.post(
        `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/api/maintenance/toggle`,
        { enabled, message },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )
      setSaved(true)
      onUpdate()
      setTimeout(() => setSaved(false), 3000)
    } catch (error) {
      console.error('Erro ao salvar:', error)
      alert('Erro ao salvar configurações')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Header */}
      <div>
        <h3 className="text-lg font-semibold text-gray-900">Sistema de Manutenção</h3>
        <p className="text-sm text-gray-500 mt-0.5">
          Controle o modo de manutenção do aplicativo
        </p>
      </div>

      {/* Status Card */}
      <Card>
        <div className="flex items-center justify-between mb-6">
          <div>
            <h4 className="text-base font-semibold text-gray-900 mb-1">Status Atual</h4>
            <p className="text-sm text-gray-500">
              {enabled ? 'O aplicativo está em manutenção' : 'O aplicativo está operacional'}
            </p>
          </div>
          <Badge variant={enabled ? 'warning' : 'success'}>
            {enabled ? 'Em Manutenção' : 'Operacional'}
          </Badge>
        </div>

        {/* Toggle */}
        <div className="mb-6">
          <label className="flex items-center gap-3 cursor-pointer">
            <div className="relative">
              <input
                type="checkbox"
                checked={enabled}
                onChange={(e) => setEnabled(e.target.checked)}
                className="sr-only"
              />
              <div
                className={`
                  w-14 h-8 rounded-full transition-colors duration-200
                  ${enabled ? 'bg-primary-600' : 'bg-gray-300'}
                `}
              >
                <div
                  className={`
                    absolute top-1 left-1 w-6 h-6 bg-white rounded-full
                    transition-transform duration-200
                    ${enabled ? 'translate-x-6' : 'translate-x-0'}
                  `}
                />
              </div>
            </div>
            <div>
              <span className="text-sm font-medium text-gray-900">
                {enabled ? 'Modo de manutenção ativado' : 'Modo de manutenção desativado'}
              </span>
              <p className="text-xs text-gray-500">
                {enabled
                  ? 'Os usuários verão a mensagem de manutenção ao abrir o app'
                  : 'O aplicativo está disponível para todos os usuários'}
              </p>
            </div>
          </label>
        </div>

        {/* Message */}
        <div className="mb-6">
          <label htmlFor="message" className="block text-sm font-medium text-gray-700 mb-2">
            Mensagem de Manutenção
          </label>
          <textarea
            id="message"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            rows={4}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent resize-none"
            placeholder="O aplicativo está em manutenção. Tente novamente mais tarde."
            disabled={!enabled}
          />
          <p className="text-xs text-gray-500 mt-1">
            Esta mensagem será exibida para os usuários quando o modo de manutenção estiver ativado
          </p>
        </div>

        {/* Success Message */}
        {saved && (
          <div className="mb-6 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm">
            ✅ Configurações salvas com sucesso!
          </div>
        )}

        {/* Actions */}
        <div className="flex items-center gap-3">
          <Button
            variant="primary"
            onClick={handleSave}
            isLoading={loading}
            disabled={loading}
          >
            Salvar Configurações
          </Button>
          {enabled && (
            <Button
              variant="outline"
              onClick={() => {
                setEnabled(false)
                setMessage('')
              }}
            >
              Desativar Manutenção
            </Button>
          )}
        </div>
      </Card>

      {/* Info Card */}
      <Card>
        <div className="flex items-start gap-4">
          <div className="p-3 bg-blue-100 rounded-lg">
            <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div className="flex-1">
            <h4 className="text-sm font-semibold text-gray-900 mb-1">Como funciona?</h4>
            <p className="text-sm text-gray-600">
              Quando o modo de manutenção está ativado, todos os usuários que abrirem o aplicativo
              verão a mensagem de manutenção e não conseguirão usar o app até que você desative o modo.
              Use isso para realizar atualizações importantes ou correções no sistema.
            </p>
          </div>
        </div>
      </Card>
    </div>
  )
}
