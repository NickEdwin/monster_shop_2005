require 'rails_helper'

RSpec.describe "as a default user" do
  describe "I try to view pages starting with /merchant, /admin, /profile" do
    it "displays a 404 error" do
      visit "/merchant/dashboard"
      expect(page).to have_content("The page you were looking for doesn't exist.")

      visit "/admin/users"
      expect(page).to have_content("The page you were looking for doesn't exist.")

      visit "/admin/dashboard"
      expect(page).to have_content("The page you were looking for doesn't exist.")

      visit "/profile"
      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end
end
