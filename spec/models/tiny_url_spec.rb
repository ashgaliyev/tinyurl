# frozen_string_literal: true

require "rails_helper"

shared_examples "invalid entity" do |error_message|
  it "does not create a new url" do
    expect { described_class.create_url(invalid_url) }.
      not_to(change(described_class, :count))
  end

  it "adds an error to the url" do
    expect(described_class.create_url(invalid_url).errors[:full_url]).to(include(error_message))
  end
end

RSpec.describe(TinyUrl) do
  it { is_expected.to(be_mongoid_document) }

  it { is_expected.to(have_field(:short_url).of_type(String)) }

  it { is_expected.to(have_field(:full_url).of_type(String)) }

  describe ".create_url" do
    let(:full_url) { "https://www.google.com" }

    context "when url is not present" do
      it "creates a new url" do
        expect { described_class.create_url(full_url) }.
          to(change(described_class, :count).
          by(1))
      end
    end

    context "when url is present" do
      let!(:url) { described_class.create_url(full_url) }

      it "returns the existing url" do
        expect(described_class.create_url(full_url)).to(eq(url))
      end
    end

    context "when full URL is invalid" do
      let(:invalid_url) { "not a valid url" }

      it_behaves_like "invalid entity", "is not a valid URL"
    end

    context "when full URL is too long" do
      let(:invalid_url) { "https://www.google.com/#{'a' * 10_000}" }

      it_behaves_like "invalid entity", "the length of the URL is not valid (5-1000)"
    end

    context "when full URL is too short" do
      let(:invalid_url) { "a" }

      it_behaves_like "invalid entity", "the length of the URL is not valid (5-1000)"
    end
  end

  describe ".get_full_url" do
    let(:short_url) { "https://myshortener.io/skdjdjf" }
    let(:full_url) { "https://www.google.com" }

    context "when url is present" do
      before do
        described_class.create(short_url:, full_url:)
      end

      it "returns the full url" do
        expect(described_class.get_full_url(short_url)).to(eq(full_url))
      end
    end

    context "when url is not present" do
      it "raises an error" do
        expect { described_class.get_full_url(short_url) }.
          to(raise_error(Mongoid::Errors::DocumentNotFound))
      end
    end

    context "when short URL is invalid" do
      let(:invalid_url) { "not a valid url" }

      it "raises an error" do
        expect { described_class.get_full_url(invalid_url) }.
          to(raise_error(Mongoid::Errors::DocumentNotFound))
      end
    end
  end
end
