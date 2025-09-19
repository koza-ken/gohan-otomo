class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Devise strong parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :display_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :display_name ])
  end

  # 標準的なリダイレクト・レスポンス処理
  def handle_successful_action(resource, success_path, success_message)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to success_path, notice: success_message }
    end
  end

  def handle_failed_action(template, error_message = nil)
    respond_to do |format|
      format.turbo_stream
      format.html do
        if error_message
          redirect_back_or_to root_path, alert: error_message
        else
          render template, status: :unprocessable_entity
        end
      end
    end
  end

  # 権限チェック用ヘルパー
  def ensure_resource_owner(resource, redirect_path = root_path, message = "この操作は許可されていません。")
    unless resource.user == current_user
      redirect_to redirect_path, alert: message
      return false
    end
    true
  end

  # レコード検索の共通処理
  def find_resource_by_id(model_class, id, not_found_path = root_path)
    resource = model_class.find_by(id: id)
    unless resource
      redirect_to not_found_path, alert: "指定されたリソースが見つかりません"
      return nil
    end
    resource
  end
end
