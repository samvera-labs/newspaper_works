# Generated via
#  `rails generate hyrax:work NewspaperContainer`
require 'rails_helper'
require 'model_shared'

RSpec.describe NewspaperContainer do

  # shared behaviors
  it_behaves_like("a work and PCDM object")
  it_behaves_like("a persistent work type")

end
