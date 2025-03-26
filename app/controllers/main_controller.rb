class MainController < ApplicationController
  def index
  end

  def create_site
    GithubRepository.new(params[:repo_name], params[:data]).create

    redirect_to "https://github.com/#{Rails.application.credentials.gh_owner}?tab=repositories", allow_other_host: true, status: :see_other
  end

  def update_form
    theme = Theme.new params[:theme]

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("theme-form", partial: "forms/theme_form", locals: { theme: theme })
      end
    end
  end
end
