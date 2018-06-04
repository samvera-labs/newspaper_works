require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::PdfPages do
  let(:sample1) do
    base = Pathname.new(NewspaperWorks::GEM_PATH).join('spec/fixtures/files')
    base.join('sample-4page-issue.pdf').to_s
  end
  let(:sample2) do
    base = Pathname.new(NewspaperWorks::GEM_PATH).join('spec/fixtures/files')
    base.join('sample-color-newsletter.pdf').to_s
  end
  let(:onebitpages) { described_class.new(sample1) }
  let(:colorpages) { described_class.new(sample2) }

  describe "implementation details" do
    it "pdfinfo gets PdfImages, memoized" do
      pdfimages = onebitpages.pdfinfo
      expect(pdfimages).to be_a(NewspaperWorks::Ingest::PdfImages)
      pdfimages2 = onebitpages.pdfinfo
      # same object, method only fetches once:
      expect(pdfimages2).to equal pdfimages
    end

    it "gets correct Ghostscript TIFF output" do
      expect(onebitpages.gsdevice).to eq 'tiffg4'
      expect(colorpages.gsdevice).to eq 'tiff24nc'
    end

    it "gets text elements saved in PDF" do
      # should be little to nothing in scanned work, besides
      # output of Ghostscript banner:
      expect(onebitpages.gstext.length).to eq 0
      # the color sample is born-digital and thus has text in PDF;
      #   this checks for > 160 (non-trivial) text, though this text
      #   stream is at least 6k, if you strip out excess whitespace.
      expect(colorpages.gstext.length).to be > 160
    end

    it "gets reasonable ppi" do
      # 400 ppi native:
      expect(onebitpages.ppi).to eq 400
      # sourced from scan:
      expect(onebitpages.ppi).to eq onebitpages.pdfinfo.ppi
      # digital native content gets forced to 400 ppi...
      expect(colorpages.ppi).to eq 400
      # ...because the images in this sample are not reasonably
      #    representative, due to low PPI (not scans of whole pages):
      expect(colorpages.ppi).to be > colorpages.pdfinfo.ppi
    end
  end

  describe "splits PDF into pages with TIFF tmpfiles" do
    it "page filenames of TIFF files are ordered" do
      pages = colorpages.entries
      pages.each_with_index do |path, idx|
        n = idx + 1
        expect(path).to match(/page#{n}.tiff/)
      end
    end

    it "color sample splits into color TIFF per page" do
      pages = colorpages.entries
      pages.each do |path|
        image = MiniMagick::Image.open(path)
        expect(image.mime_type).to eq 'image/tiff'
        expect(image.colorspace).to start_with 'DirectClass sRGB'
      end
    end

    # rubocop:disable RSpec/ExampleLength
    it "one bit sample splits into Group 4 TIFF per page" do
      pages = onebitpages.entries
      pages.each do |path|
        # we do not use MiniMagick to generate TIFF, so it is good
        #   independent verification of output
        image = MiniMagick::Image.open(path)
        expect(image.mime_type).to eq 'image/tiff'
        expect(image.colorspace).to start_with 'DirectClass Gray'
        begin
          expect(image.data['channelDepth']['gray']).to eq "1"
        rescue
          # ImageMagick on Ubuntu 14.04 produces faulty JSON, so we
          #   work around the ugly way.
          json = MiniMagick::Tool::Convert.new do |convert|
            convert << path
            convert << "json:"
          end
          channel_depth = json.gsub(/\s+/, '') \
                              .split('channelDepth')[1] \
                              .split('}')[0] \
                              .split(':')[2] \
                              .delete('"') \
                              .to_i
          expect(channel_depth).to eq 1
        end
      end
    end
    # rubocop:enable RSpec/ExampleLength

    it "one bit sample is 7200x9600 scan, verify" do
      pages = onebitpages.entries
      pages.each do |path|
        image = MiniMagick::Image.open(path)
        expect(image.width).to eq 7200
        expect(image.height).to eq 9600
      end
    end
  end
end
