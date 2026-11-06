# Rails >= 7.1 passes `false` as the object for model-less forms (form_for(:name) / form_with(scope:)),
# but Polaris::FormBuilder only guards against `nil` before reading attribute values.
class ScopedPolarisFormBuilder < Polaris::FormBuilder
  def initialize(object_name, object, template, options)
    super(object_name, object || nil, template, options)
  end
end
