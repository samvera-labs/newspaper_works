require 'spec_helper'

RSpec.describe NewspaperWorks::PluggableDerivativeService do
  let(:valid_file_set) { FileSet.new }

  # cache and restore originally described derivative service plugins
  # rubocop:disable RSpec/InstanceVariable
  before do
    @orig_plugins = described_class.plugins
  end
  after do
    described_class.plugins = @orig_plugins
  end

  describe ".plugins=" do
    it "allows setting of derivative service plugins" do
      expect(described_class.plugins).to eq @orig_plugins
      described_class.plugins = [Hyrax::FileSetDerivativesService] * 2
      expect(described_class.plugins).to eq [Hyrax::FileSetDerivativesService] * 2
    end
  end

  describe "calls all derivative plugins" do
    class FakeDerivativeService
      @create_called = 0
      @cleanup_called = 0
      class << self
        attr_accessor :create_called, :cleanup_called
      end

      def initialize(fileset)
        @fileset = fileset
        @created = false
      end

      def valid?
        true
      end

      def create_derivatives(filename)
        self.class.create_called += 1
        filename
      end

      def cleanup_derivatives
        self.class.cleanup_called += 1
      end
    end

    it "calls each plugin on create" do
      expect(FakeDerivativeService.create_called).to eq 0
      described_class.plugins = [FakeDerivativeService, FakeDerivativeService]
      service = described_class.new(FileSet.new)
      service.create_derivatives('not_a_real_filename')
      expect(FakeDerivativeService.create_called).to eq 2
    end

    it "calls each plugin on cleanup" do
      expect(FakeDerivativeService.cleanup_called).to eq 0
      described_class.plugins = [FakeDerivativeService, FakeDerivativeService]
      service = described_class.new(FileSet.new)
      service.cleanup_derivatives
      expect(FakeDerivativeService.cleanup_called).to eq 2
    end

    it "test meta: spec restores original plugins" do
      # verify `after do` clean up of plugins array to original value
      plugins = described_class.plugins
      expect(plugins.length).to eq @orig_plugins.length
      expect(plugins).to include Hyrax::FileSetDerivativesService
    end
  end

  describe "service registration" do
    # integration test with Hyrax, verify services is registered

    it "is registered with Hyrax" do
      expect(Hyrax::DerivativeService.services).to include described_class
    end

    it "is the first valide service found" do
      found = Hyrax::DerivativeService.for(FileSet.new)
      expect(found.class).to be described_class
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
