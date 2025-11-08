import { ReactNode } from 'react'
import Card from './Card'

interface StatCardProps {
  title: string
  value: string | number
  change?: {
    value: number
    isPositive: boolean
  }
  icon?: ReactNode
  subtitle?: string
  trend?: ReactNode
}

export default function StatCard({ title, value, change, icon, subtitle, trend }: StatCardProps) {
  return (
    <Card hover className="animate-fadeIn">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-600 mb-1">{title}</p>
          <div className="flex items-baseline gap-2">
            <p className="text-3xl font-bold text-gray-900">{value}</p>
            {change && (
              <span
                className={`text-sm font-medium ${
                  change.isPositive ? 'text-green-600' : 'text-red-600'
                }`}
              >
                {change.isPositive ? '+' : ''}
                {change.value}%
              </span>
            )}
          </div>
          {subtitle && (
            <p className="text-sm text-gray-500 mt-1">{subtitle}</p>
          )}
          {trend && <div className="mt-2">{trend}</div>}
        </div>
        {icon && (
          <div className="p-3 bg-primary-100 rounded-lg text-primary-600">
            {icon}
          </div>
        )}
      </div>
    </Card>
  )
}


