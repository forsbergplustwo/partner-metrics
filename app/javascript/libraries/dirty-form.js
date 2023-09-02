function debounce(func, timeout = 100) {
  let timer
  return (...args) => {
    clearTimeout(timer)
    timer = setTimeout(() => { func.apply(this, args) }, timeout)
  }
}

class DirtyForm {
  static trackedTags = ['INPUT', 'SELECT', 'TEXTAREA', 'TRIX-EDITOR']

  constructor(form, options = {}) {
    this.form = form
    this.isDirty = false
    this.initialValues = {}
    this.onDirty = options['onDirty']
    this.message = options['message'] || 'You have unsaved changes!';

    this.setupFieldsTracking()
    this.setLeavingHandler()
  }

  disconnect() {
    this.removeFieldsTracking()
    this.removeLeavingHandler()
  }

  setupFieldsTracking() {
    this.fields.forEach(field => {
      this.initialValues[field.name] = field.value

      switch (field.tagName) {
        case 'TRIX-EDITOR':
          field.addEventListener('trix-change', debounce(this.valueChanged))
          break
        case 'SELECT':
          field.addEventListener('change', debounce(this.valueChanged))
          break
        default:
          field.addEventListener('change', debounce(this.valueChanged))
          field.addEventListener('input', debounce(this.valueChanged))
          break
      }
    })
  }

  removeFieldsTracking() {
    this.fields.forEach(field => {
      switch (field.tagName) {
        case 'TRIX-EDITOR':
          field.removeEventListener('trix-change', this.valueChanged)
          break
        case 'SELECT':
          field.removeEventListener('change', this.valueChanged)
          break
        default:
          field.removeEventListener('change', this.valueChanged)
          field.removeEventListener('input', this.valueChanged)
          break
      }
    })
  }

  setLeavingHandler() {
    window.addEventListener('beforeunload', this.beforeUnload);
    if (typeof Turbo !== 'undefined') {
      document.addEventListener('turbo:before-visit', this.onLeave)
    }
  }

  removeLeavingHandler() {
    window.removeEventListener('beforeunload', this.beforeUnload);
    if (typeof Turbo !== 'undefined') {
      document.removeEventListener('turbo:before-visit', this.onLeave)
    }
  }

  get fields() {
    const selector = this.constructor.trackedTags.map(tag => `${tag}[name]`).join(',')
    return Array.from(this.form.querySelectorAll(selector)).filter(field => {
      return field.getAttribute("data-dirty-form") != "false"
    })
  }

  markAsDirty() {
    this.isDirty = true
    if (this.onDirty) this.onDirty()
  }

  // Handlers

  valueChanged = (event) => {
    const field = event.target
    if (this.initialValues[field.name] != field.value) {
      this.markAsDirty()
    }
  }

  beforeUnload = (event) => {
    if (this.isDirty) {
      event.preventDefault()
      event.returnValue = this.message
    }
  }

  onLeave = (event) => {
    if (this.isDirty) {
      if (!confirm(this.message)) event.preventDefault()
    } else {
      this.isDirty = false
    }
  }
}

export default DirtyForm
