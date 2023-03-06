class TinyUrlsController < ApplicationController
  before_action :set_tiny_url, only: %i[show]

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def index
    @tiny_url = TinyUrl.new
  end

  def create
    @tiny_url = TinyUrl.create_url(full_url_param)

    if @tiny_url.errors.any?
      respond_to do |format|
        format.html { render :index, tiny_url: @tiny_url, status: :unprocessable_entity }
        format.json { render json: { error: @tiny_url.errors.full_messages.join(', ') }, status: :unprocessable_entity }
      end
    else
      respond_to do |format|
        format.html { redirect_to @tiny_url, notice: 'Tiny url was successfully created.' }
        format.json { render json: @tiny_url, only: %i[full_url short_url], status: :created }
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @tiny_url }
    end
  end

  def redirect
    @tiny_url = TinyUrl.find_by!(short_url: short_url_param)
    redirect_to @tiny_url.full_url, status: :moved_permanently
  end

  private

  def set_tiny_url
    @tiny_url = TinyUrl.find_by!(id: params[:id])
  end

  def full_url_param
    params.require(:tiny_url).permit(:full_url).fetch(:full_url)
  end

  def short_url_param
    "#{ENV['BASE_URL']}/#{params[:short_url]}"
  end

  def not_found
    respond_to do |format|
      format.html { render :not_found, status: :not_found }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
    end
  end
end
