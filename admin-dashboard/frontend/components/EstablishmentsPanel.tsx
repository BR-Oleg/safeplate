'use client'

import { useState, useEffect, useMemo } from 'react'
import axios from 'axios'
import Card from './ui/Card'
import Badge from './ui/Badge'
import Button from './ui/Button'
import Input from './ui/Input'

interface Establishment {
  id: string
  name: string
  category: string
  difficultyLevel?: 'popular' | 'intermediate' | 'technical'
  ownerId: string
  address?: string
  latitude?: number
  longitude?: number
}

export default function EstablishmentsPanel() {
  const [establishments, setEstablishments] = useState<Establishment[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [categoryFilter, setCategoryFilter] = useState<string>('all')
  const [difficultyFilter, setDifficultyFilter] = useState<string>('all')
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 10

  useEffect(() => {
    loadEstablishments()
  }, [])

  const loadEstablishments = async () => {
    setLoading(true)
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        console.error('Token não encontrado')
        setLoading(false)
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.get(`${apiUrl}/api/establishments`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      const establishmentsData = response.data.establishments || []
      setEstablishments(establishmentsData)
    } catch (error: any) {
      console.error('Erro ao carregar estabelecimentos:', error)
    } finally {
      setLoading(false)
    }
  }

  const categories = useMemo(() => {
    const cats = new Set(establishments.map((e) => e.category))
    return Array.from(cats).sort()
  }, [establishments])

  const filteredEstablishments = useMemo(() => {
    return establishments.filter((establishment) => {
      const matchesSearch =
        establishment.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        establishment.category.toLowerCase().includes(searchQuery.toLowerCase())
      const matchesCategory = categoryFilter === 'all' || establishment.category === categoryFilter
      const matchesDifficulty =
        difficultyFilter === 'all' || establishment.difficultyLevel === difficultyFilter
      return matchesSearch && matchesCategory && matchesDifficulty
    })
  }, [establishments, searchQuery, categoryFilter, difficultyFilter])

  const paginatedEstablishments = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage
    return filteredEstablishments.slice(startIndex, startIndex + itemsPerPage)
  }, [filteredEstablishments, currentPage])

  const totalPages = Math.ceil(filteredEstablishments.length / itemsPerPage)

  const handleUpdateDifficulty = async (establishmentId: string, difficultyLevel: string) => {
    try {
      const token = localStorage.getItem('adminToken')
      if (!token) {
        alert('Token não encontrado. Faça login novamente.')
        return
      }

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'
      const response = await axios.put(
        `${apiUrl}/api/establishments/${establishmentId}/difficulty`,
        { difficultyLevel },
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      )

      if (response.data.success) {
        loadEstablishments()
      }
    } catch (error: any) {
      console.error('Erro ao atualizar nível:', error)
      const errorMessage = error.response?.data?.error || error.message || 'Erro ao atualizar nível de dificuldade'
      alert(`Erro: ${errorMessage}`)
    }
  }

  const getDifficultyLabel = (level?: string) => {
    const labels: Record<string, string> = {
      popular: 'Popular',
      intermediate: 'Intermediário',
      technical: 'Técnico',
    }
    return level ? labels[level] || level : 'Não definido'
  }

  const getDifficultyBadge = (level?: string) => {
    if (!level) return <Badge variant="default">Não definido</Badge>
    const variants: Record<string, 'success' | 'warning' | 'info'> = {
      popular: 'success',
      intermediate: 'warning',
      technical: 'info',
    }
    return <Badge variant={variants[level] || 'default'}>{getDifficultyLabel(level)}</Badge>
  }

  return (
    <div className="space-y-6 animate-fadeIn">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Gerenciamento de Estabelecimentos</h3>
          <p className="text-sm text-gray-500 mt-0.5">
            {filteredEstablishments.length} estabelecimento{filteredEstablishments.length !== 1 ? 's' : ''} encontrado{filteredEstablishments.length !== 1 ? 's' : ''}
          </p>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Input
            placeholder="Buscar por nome ou categoria..."
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
          <select
            value={categoryFilter}
            onChange={(e) => {
              setCategoryFilter(e.target.value)
              setCurrentPage(1)
            }}
            className="px-4 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          >
            <option value="all">Todas as categorias</option>
            {categories.map((cat) => (
              <option key={cat} value={cat}>
                {cat}
              </option>
            ))}
          </select>
          <select
            value={difficultyFilter}
            onChange={(e) => {
              setDifficultyFilter(e.target.value)
              setCurrentPage(1)
            }}
            className="px-4 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
          >
            <option value="all">Todos os níveis</option>
            <option value="popular">Popular</option>
            <option value="intermediate">Intermediário</option>
            <option value="technical">Técnico</option>
          </select>
        </div>
      </Card>

      {/* Establishments Table */}
      <Card padding="none">
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="spinner"></div>
          </div>
        ) : paginatedEstablishments.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600">Nenhum estabelecimento encontrado</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="table">
                <thead>
                  <tr>
                    <th>Nome</th>
                    <th>Categoria</th>
                    <th>Nível de Dificuldade</th>
                    <th className="text-right">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedEstablishments.map((establishment) => (
                    <tr key={establishment.id}>
                      <td>
                        <div>
                          <p className="font-medium text-gray-900">{establishment.name}</p>
                          {establishment.address && (
                            <p className="text-sm text-gray-500 mt-0.5">{establishment.address}</p>
                          )}
                        </div>
                      </td>
                      <td>
                        <Badge variant="default">{establishment.category}</Badge>
                      </td>
                      <td>{getDifficultyBadge(establishment.difficultyLevel)}</td>
                      <td>
                        <div className="flex items-center justify-end gap-2">
                          <select
                            value={establishment.difficultyLevel || 'popular'}
                            onChange={(e) => handleUpdateDifficulty(establishment.id, e.target.value)}
                            className="px-3 py-1.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent"
                          >
                            <option value="popular">Popular</option>
                            <option value="intermediate">Intermediário</option>
                            <option value="technical">Técnico</option>
                          </select>
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
    </div>
  )
}
