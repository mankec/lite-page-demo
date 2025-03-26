require "net/http"

class GithubRepository
  def initialize(repo_name, data = {})
    @repo_name = repo_name.downcase.split.join("-")
    @data = data
  end

  def create
    uri = URI.parse("https://api.github.com/user/repos")
    request = Net::HTTP::Post.new(uri)
    request["Accept"] = "application/vnd.github+json"
    request["Authorization"] = "Bearer #{Rails.application.credentials.gh_token}"
    request["X-Github-Api-Version"] = "2022-11-28"
    request.body = JSON.dump({
      "name" => @repo_name,
      "description" => "Repo generated using GitHub API",
      "homepage" => "#{Rails.application.credentials.gh_pages_jekyll_url}/#{@repo_name}",
      "private" => false,
      "is_template" => true
    })

    req_options = {
      use_ssl: uri.scheme == "https"
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    Dir.mkdir("#{Dir.home}/jekyll") if !Dir.exist?("#{Dir.home}/jekyll") && Rails.env.development?

    Dir.chdir("#{Dir.home}/jekyll") do
      system("jekyll new #{@repo_name}")

      Dir.chdir(@repo_name) do
        update_url_and_baseurl
        create_data_folder
        override_minima_default

        system("
          git init
          git add .
          git commit -m 'Init'
          git branch -M main
          git remote add origin git@github.com:mankec/#{@repo_name}.git
          git push -u origin main
        ")
      end
    end

    GithubPages.new(@repo_name).create_site
  end

  def delete
    uri = URI.parse("https://api.github.com/repos/#{Rails.application.credentials.gh_owner}/#{@repo_name}")
    request = Net::HTTP::Delete.new(uri)
    request["Accept"] = "application/vnd.github+json"
    request["Authorization"] = "Bearer #{Rails.application.credentials.gh_token}"
    request["X-Github-Api-Version"] = "2022-11-28"

    req_options = {
      use_ssl: uri.scheme == "https"
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    system("rm -rf #{Dir.home}/jekyll/#{@repo_name}")
  end

  private

  def update_url_and_baseurl
    file_path = "_config.yml"
    config = YAML.load_file file_path

    config["baseurl"] = "/#{@repo_name}"
    config["url"] = Rails.application.credentials.gh_pages_jekyll_url

    File.write file_path, config.to_yaml
  end

  def create_data_folder
    Dir.mkdir("_data")
    file_path = "_data/data.yml"

    File.write file_path, @data.to_unsafe_h.to_h.to_yaml
  end

  def override_minima_default
    Dir.mkdir("_layouts")
    file_path = "_layouts/default.html"

    File.write file_path, File.read("#{Rails.root}/overriden_default.html")
  end
end
