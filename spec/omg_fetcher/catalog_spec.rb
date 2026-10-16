# frozen_string_literal: true

RSpec.describe OmgFetcher::Catalog do
  describe ".acronyms" do
    it "extracts the acronym list from the landing page's JSON-LD @imports" do
      stub_request(:get, OmgFetcher::Catalog::SPEC_URL).to_return(
        body: <<~HTML
          <html><head><script type="application/ld+json">[ {
            "@id" : "https://www.omg.org/spec/About",
            "http://www.w3.org/2002/07/owl#imports" : [ {
              "@id" : "https://www.omg.org/spec/ADA/About-ADA"
            }, {
              "@id" : "https://www.omg.org/spec/AMI4CCM/About-AMI4CCM"
            }, {
              "@id" : "https://www.omg.org/spec/ADA/About-ADA"
            } ]
          } ]</script></head></html>
        HTML
      )
      expect(described_class.acronyms).to eq %w[ADA AMI4CCM]
    end
  end

  describe ".versions" do
    it "reads the version links as space-joined query strings" do
      stub_request(:get, "#{OmgFetcher::Catalog::SPEC_URL}/UML/About-UML").to_return(
        body: <<~HTML
          <html><body>
            <a href="https://www.omg.org/spec/UML/2.5.1/About-UML">UML 2.5.1</a>
            <a href="/spec/UML/2.0/beta/2/About-UML">UML 2.0 beta 2</a>
            <a href="https://www.omg.org/spec/UML/2.5.1/PDF">PDF</a>
            <a href="https://www.omg.org/spec/UML/20161101/UML.xmi">XMI</a>
            <a href="/spec/UML/About-UML">About</a>
          </body></html>
        HTML
      )
      expect(described_class.versions("UML")).to eq ["2.0 beta 2", "2.5.1"]
    end
  end
end

RSpec.describe OmgFetcher::Build do
  describe ".slug" do
    it "normalizes the version into a file-safe slug" do
      expect(described_class.slug("UML", "2.0 beta 2")).to eq "uml-2.0-beta-2"
      expect(described_class.slug("AMI4CCM", "1.0")).to eq "ami4ccm-1.0"
    end
  end
end
