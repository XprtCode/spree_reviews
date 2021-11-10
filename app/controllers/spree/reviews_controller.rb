class Spree::ReviewsController < Spree::StoreController
  helper Spree::BaseHelper
  before_action :load_product, only: [:index, :new, :create]
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    @approved_reviews = Spree::Review.approved.where(product: @product)
  end

  def new
    @current_user_review = if spree_current_user.present?
                            spree_current_user.reviews.find_by(product_id: @product.id)
                          end
    @review             = Spree::Review.new(product: @product)
    authorize! :create, @review
  end

  def create
    params[:review][:rating].sub!(/\s*[^0-9]*\z/, '') unless params[:review][:rating].blank?

    @review = Spree::Review.new(review_params)
    @review.product = @product
    @review.user = spree_current_user if spree_user_signed_in?
    @review.ip_address = request.remote_ip
    @review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]

    authorize! :create, @review

    respond_to do |format|
      if @review.save
        format.html do
          flash[:notice] = Spree.t(:review_successfully_submitted)
          redirect_to spree.product_path(@product)
        end
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def permitted_review_attributes
    [:rating, :title, :review, :name, :show_identifier]
  end

  def review_params
    params.require(:review).permit(permitted_review_attributes)
  end
end
