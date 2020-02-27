# frozen_string_literal: true
module NewspaperWorks
  # Application Record Class
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
