require "application_system_test_case"

class GithubRepositoryTest < ApplicationSystemTestCase
  repo_name = "jekyll-test-repo"

  setup do
    GithubRepository.new(repo_name).delete
  end

  test "should create github repo and deploy it to github pages" do
    visit root_path
    fill_in "Repo Name", with: repo_name.titleize
    click_on "Create Site"

    find("a", text: "Sign in").click
    find("#login_field").set(Rails.application.credentials.gh_owner)
    find("#password").set(Rails.application.credentials.gh_owner_password)
    click_on "Sign in"
    click_on repo_name
    assert page.has_link?(
      "#{Rails.application.credentials.gh_owner}.github.io/#{repo_name}",
      href: "#{Rails.application.credentials.gh_pages_jekyll_url}/#{repo_name}"
    )
    sleep 60
    find("a", text: "#{Rails.application.credentials.gh_owner}.github.io/#{repo_name}").click
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    assert page.has_text?("Welcome to Jekyll!")
    sleep 15
  end
end
