class MainController < ApplicationController
  def index
  end

  def create_site
    GithubRepository.new(params[:repo_name]).create

    redirect_to "https://github.com/#{Rails.application.credentials.gh_owner}?tab=repositories", allow_other_host: true, status: :see_other
  end
end
