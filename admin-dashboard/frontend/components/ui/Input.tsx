import { InputHTMLAttributes, TextareaHTMLAttributes, forwardRef } from 'react'

interface InputProps extends InputHTMLAttributes<HTMLInputElement>, TextareaHTMLAttributes<HTMLTextAreaElement> {
  label?: string
  error?: string
  helperText?: string
  icon?: React.ReactNode
  multiline?: boolean
}

const Input = forwardRef<HTMLInputElement | HTMLTextAreaElement, InputProps>(
  ({ label, error, helperText, icon, className = '', multiline, ...props }, ref) => {
    const inputClassName = `
      w-full px-4 py-2.5
      border rounded-lg
      text-sm
      transition-all duration-200
      focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent
      ${error ? 'border-red-300 focus:ring-red-500' : 'border-gray-300'}
      ${icon ? 'pl-10' : ''}
      ${className}
    `

    return (
      <div className="w-full">
        {label && (
          <label className="block text-sm font-medium text-gray-700 mb-1.5">
            {label}
          </label>
        )}
        <div className="relative">
          {icon && (
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400">
              {icon}
            </div>
          )}
          {multiline ? (
            <textarea
              ref={ref as React.ForwardedRef<HTMLTextAreaElement>}
              className={inputClassName}
              rows={4}
              {...(props as TextareaHTMLAttributes<HTMLTextAreaElement>)}
            />
          ) : (
            <input
              ref={ref as React.ForwardedRef<HTMLInputElement>}
              className={inputClassName}
              {...(props as InputHTMLAttributes<HTMLInputElement>)}
            />
          )}
        </div>
        {error && (
          <p className="mt-1.5 text-sm text-red-600">{error}</p>
        )}
        {helperText && !error && (
          <p className="mt-1.5 text-sm text-gray-500">{helperText}</p>
        )}
      </div>
    )
  }
)

Input.displayName = 'Input'

export default Input

