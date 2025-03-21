require "net/http"

class GithubPages
  def initialize(repo_name)
    @repo_name = repo_name.downcase.split.join("-")
  end

  def create_site
    uri = URI.parse("https://api.github.com/repos/#{Rails.application.credentials.gh_owner}/#{@repo_name}/pages")
    request = Net::HTTP::Post.new(uri)
    request["Accept"] = "application/vnd.github+json"
    request["Authorization"] = "Bearer #{Rails.application.credentials.gh_token}"
    request["X-Github-Api-Version"] = "2022-11-28"
    request.body = JSON.dump({
      "source" => {
        "branch" => "main"
      }
    })

    req_options = {
      use_ssl: uri.scheme == "https"
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
