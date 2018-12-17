module NewspaperWorks
  class DerivativeAttachment < ApplicationRecord
    validates :fileset_id, presence: true
    validates :path, presence: true
    validates :destination_name, presence: true
  end
end
