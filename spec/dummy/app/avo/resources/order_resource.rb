# There are two features in this resource that are not available in Avo yet.
# 1. The dynamic form. This is a form that can change based on one fields value. In this case the orderable_type field.
# 2. The nested attributes. This is a way to create a form that can create a new attached record or update an existing record.

class OrderResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.extra_params = [orderable_attributes: Order::ORDERABLE_ATTRIBUTES]
  self.stimulus_controllers = "dynamic-form"
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :status, as: :select, options: Order::STATUSES.map{ |option| [option.humanize, option] }
  field :orderable, as: :belongs_to, polymorphic_as: :orderable, types: Order::ORDERABLE_TYPES.map(&:constantize), name: 'Ordered Item', only_on: [:index,:show]

  field :orderable_type,
        as: :select,
        options: Order::ORDERABLE_TYPES.map{ |option| [option.humanize, option] },
        placeholder: 'Select an Orderable type',
        include_blank: true,
        html: {
          edit: {
            input: {
              data: {
                action: 'dynamic-form#refresh'
              }
            }
          }
        },
        only_on: [:forms]
  # Dynamically add fields based on the orderable_type. In reality you may be more explicit about this.
  Order::ORDERABLE_ATTRIBUTES.each do |attribute|
    field attribute,
          name: attribute.to_s,
          as: :text,
          # This is a new feature that is not available in Avo yet.
          nested_attribute: 'orderable',
          # Visible when the orderable_type is present and the attribute is present on the orderable_type.
          visible: -> (resource:) { resource&.model&.orderable_type.present? && resource&.model&.orderable_type.constantize.attribute_names.include?(attribute.to_s) }
  end
end
