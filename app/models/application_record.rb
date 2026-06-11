class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include Discard::Model
  self.discard_column = :deleted_at
  default_scope -> { kept }
end
