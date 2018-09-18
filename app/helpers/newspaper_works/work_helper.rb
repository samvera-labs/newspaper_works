module NewspaperWorks::WorkHelper
  def derivative_names(work)
    NewspaperWorks::Data::WorkDerivativeLoader.new(work).to_a
  end
end
