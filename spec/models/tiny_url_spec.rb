require "rails_helper"

RSpec.describe TinyUrl, type: :model do
  it { is_expected.to be_mongoid_document }

  it { is_expected.to have_field(:short_url).of_type(String) }

  it { is_expected.to have_field(:full_url).of_type(String) }

  describe ".create_url" do
    let(:full_url) { "https://www.google.com" }

    context "when url is not present" do
      it "creates a new url" do
        expect { described_class.create_url(full_url) }.to change { described_class.count }.by(1)
      end
    end

    context "when url is present" do
      let!(:url) { described_class.create_url(full_url) }

      it "returns the existing url" do
        expect(described_class.create_url(full_url)).to eq(url)
      end
    end

    context "when full URL is invalid" do
      let(:invalid_url) { "not a valid url" }

      it "raises an error" do
        expect { described_class.create_url(invalid_url) }.to raise_error
      end
    end

    context "when full URL is too long" do
      let(:long_url) { "https://www.google.com/" + "a" * 10000 }

      it "raises an error" do
        expect { described_class.create_url(long_url) }.to raise_error
      end
    end

    context "when full URL is too short" do
      let(:short_url) { "a" }

      it "raises an error" do
        expect { described_class.create_url(short_url) }.to raise_error
      end
    end
  end

  describe ".get_full_url" do
    let(:short_url) { "https://myshortener.io/skdjdjf" }
    let(:full_url) { "https://www.google.com" }

    context "when url is present" do
      let!(:url) { described_class.create(short_url: short_url, full_url: full_url) }

      it "returns the full url" do
        expect(described_class.get_full_url(short_url)).to eq(full_url)
      end
    end

    context "when url is not present" do
      it "raises an error" do
        expect { described_class.get_full_url(short_url) }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
    end

    context "when short URL is invalid" do
      let(:invalid_url) { "not a valid url" }

      it "raises an error" do
        expect { described_class.get_full_url(invalid_url) }.to raise_error
      end
    end
  end
end
