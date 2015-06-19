require "spec_helper"
# The application should satisfy the following user stories:

feature "user can sign up", %(
  As a user
  I want to sign into office hours

  Acceptance Criteria:
  [X] I should see the sign up button in the navigation bar.
  [X] I should be able to click on the Sign Up link.
  [X] I should be able to fill out a form to Sign Up.
  [X] I should be able to submit the form and go to the log in page.
  ) do

  scenario "" do
    visit '/'
    click_on('Sign Up')
    fill_in('user_first', :with => 'testing')
    fill_in('user_last', :with => 'tester')
    fill_in('user_name', :with => 'tester')
    fill_in('user_pass', :with => '010101')
    click_button('Submit')
  end
end

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
  [X] I should be able to click on the sign up link.
  [X] I should be able to fill out a form to sign up.
  [X] Once signed up it should redirect me to the log in page.
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

feature "logged in user can view  and select office hours", %(
  As a user
  I want to be able to see all available office hours

  Acceptance Criteria:
  [X] Once logged in I should be taken to the office hours page.
  [X] I should be able to select a time from the list and it should
      refresh the page with my name in place of the time slot.
  [X] If I attempt to select multiple time slots in a given week it should not be allowed.
  [X] When I log out I should be taken back to the log in page.
  ) do

    scenario "" do
      binding.pry
      visit '/log_in'
      fill_in('user_name', :with => 'lfields90')
      fill_in('user_pass', :with => 'Password1')
      click_on('Submit')
      visit '/office_hours'
      click_button('11')
    end
end
