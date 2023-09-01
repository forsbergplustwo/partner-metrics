import { Controller } from '@hotwired/stimulus'
import DirtyForm from '../dirty-form'

export default class extends Controller {
  static targets = ['submitButton']
  static values = {
    showSaveBar: { type: Boolean, default: true },
    submitButtonTarget: String
  }

  connect() {
    this.setupDirtyForm()

    this.element.addEventListener('turbo:submit-start', this.submitStart)
    this.element.addEventListener('turbo:submit-end', this.submitEnd)
  }

  disconnect() {
    this.dirtyForm = null
  }

  setupDirtyForm() {
    this.isDirty = false
    this.dirtyForm = new DirtyForm(this.element, {
      onDirty: this.formDirty,
      message: "You have unsaved changes."
    })
    this.disableSubmitWithoutSpinner()
  }

  // Actions

  markAsDirty() {
    this.dirtyForm.markAsDirty()
  }

  // Handlers

  submitStart = () => {
    this.submitButtonController.disable()
  }

  submitEnd = () => {
    this.submitButtonController.enable()
    this.dirtyForm.disconnect()
    this.setupDirtyForm()
  }

  formDirty = () => {
    if (!this.isDirty) {
      this.isDirty = true
      this.submitButtonController.enable()
      if (this.showSaveBarValue)
        this.frameController.showSaveBar()
    }
  }

  // Private

  get submitButton() {
    if (this.hasSubmitButtonTarget) {
      return this.submitButtonTarget
    } else {
      return document.querySelector(this.submitButtonTargetValue)
    }
  }

  get frameController() {
    const target = document.querySelector('[data-controller~="polaris-frame"]')
    return this.application.getControllerForElementAndIdentifier(target, 'polaris-frame')
  }

  get submitButtonController() {
    return this.application.getControllerForElementAndIdentifier(this.submitButton, 'polaris-button')
  }

  disableSubmitWithoutSpinner() {
    this.submitButton.disabled = true
    this.submitButton.classList.add('Polaris-Button--disabled')
  }
}
