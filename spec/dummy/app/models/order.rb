class Order < ApplicationRecord
  ORDERABLE_TYPES = ['Product'].freeze
  STATUSES = %w[draft processing completed cancelled].freeze
  ATTRIBUTES_TO_IGNORE = %w[id encrypted_password reset_password_token reset_password_sent_at remember_created_at created_at updated_at password_digest].freeze
  ORDERABLE_ATTRIBUTES = ORDERABLE_TYPES.map do |type|
    type.constantize.attribute_names.reject {|name, _| ATTRIBUTES_TO_IGNORE.include? name}.map(&:to_sym)
  end&.flatten.freeze

  belongs_to :orderable, polymorphic: true
  accepts_nested_attributes_for :orderable

  validates :orderable_type, inclusion: { in: ORDERABLE_TYPES }, presence: true
  validates :status, inclusion: { in: STATUSES }

  def build_orderable(params = {})
    return unless orderable.nil? && orderable_type.present? && ORDERABLE_TYPES.include?(orderable_type)

    self.orderable = orderable_type.constantize.new(params)
  end

end
