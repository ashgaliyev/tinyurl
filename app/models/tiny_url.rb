# frozen_string_literal: true

require "nanoid"

class TinyUrl
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  LENGTH = 5..1000

  field :short_url, type: String
  field :full_url, type: String

  validates :full_url, presence: true, uniqueness: true
  validates :full_url,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "is not a valid URL" },
            length: {
              in: LENGTH,
              message: "the length of the URL is not valid (#{LENGTH.begin}-#{LENGTH.end})"
            }

  class << self
    def create_url(full_url)
      url = find_by(full_url:)
      return url if url

      @tiny_url = TinyUrl.new
      @tiny_url.full_url = full_url

      if @tiny_url.valid?
        @tiny_url.short_url = generate_short_url
        @tiny_url.save!
      end

      @tiny_url
    end

    def get_full_url(short_url)
      tiny_url = find_by(short_url:)
      raise(Mongoid::Errors::DocumentNotFound.new(self, { short_url: })) unless tiny_url

      tiny_url.full_url
    end

    private

    def generate_short_url
      url = new_short_url
      url = new_short_url while find_by(short_url: url)
      url
    end

    def new_short_url
      # https://zelark.github.io/nano-id-cc/
      # In case of 100 req/second
      # ~25 years needed, in order to have a 1% probability of at least one collision.
      concat_base_url(Nanoid.generate(size: 13))
    end

    def concat_base_url(url)
      [Rails.application.config.base_url, url].join("/")
    end
  end
end
