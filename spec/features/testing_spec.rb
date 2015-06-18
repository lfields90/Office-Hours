require "spec_helper"
# The application should satisfy the following user stories:

feature "user can log in", %(
  As a user
  I want to log in to office hours

  Acceptance Criteria:
  [X] I should see the login page in the navigation bar.
  [X] I should be able to click on the log in link.
  [X] I should be able to fill out a form to log in.
  [X] I should be able to submit the form and go to office hours.
  ) do

  scenario "" do
    visit '/'
    click_on('Log In')
    expect(page).to have_content("Log In")
    expect(page).to have_content("Sign Up")
  end
end

feature "user can sign up for office hours", %(
  As a user
  I want to be able to sign up for office hours
  So that I can get help from EE's

  Acceptance Criteria:
  [X] I should see the Sign Up page in the navigation bar.
  [X] I should be able to click on the sign up link
  [X] I should be able to fill out a form to log in.
  [X] I should be able to submit the form and go to office hours.
  ) do

    scenario "" do
      visit '/'
      click_on('Sign Up')
      expect(page).to have_content("Sign Up")
      click_on('Log In')
      expect(page).to have_content("Log In")
    end
end

feature "logged in user can view office hours", %(
  As a user
  I want to be able to see all available office hours

  Acceptance Criteria:
  [X] Meetups should be listed alphabetically.
  [X] Each meetup listed should link me to the show page for that meetup.
  ) do

    scenario "" do
      visit '/sign_up'
      expect(page).to have_content("Sign Up")
    end
end
