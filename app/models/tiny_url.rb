require 'nanoid'

class TinyUrl
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :short_url, type: String
  field :full_url, type: String

  validates :full_url, presence: true, uniqueness: true
  validates :full_url, format: { with: URI::regexp(%w[http https]), message: 'is not a valid URL' }, length: { in: 5..1000, message: 'the length of the URL is not valid (5-1000)' }

  class << self
    def create_url(full_url)
      url = find_by(full_url: full_url)
      return url if url

      @tiny_url = TinyUrl.new
      @tiny_url.full_url = full_url

      if @tiny_url.valid?
        @tiny_url.short_url = generate_short_url
        @tiny_url.save
      end

      @tiny_url
    end
    
    def get_full_url(short_url)
      url = find_by(short_url: short_url)
      if url
        url.full_url
      else
        raise Mongoid::Errors::DocumentNotFound.new(self, { short_url: short_url })
      end
    end

    private

    def generate_short_url
      url = new_short_url
      while find_by(short_url: url)
        url = new_short_url
      end
      url
    end

    def new_short_url
      # https://zelark.github.io/nano-id-cc/
      # In case of 100 req/second
      # ~25 years needed, in order to have a 1% probability of at least one collision.
      concat_base_url(Nanoid.generate(size: 13))
    end

    def concat_base_url(url)
      "#{ENV['BASE_URL']}/#{url}"
    end
  end
end
  