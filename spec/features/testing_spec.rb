require "spec_helper"
# The application should satisfy the following user stories:

feature "user can log in", %(
  As a user
  I want to log in to office hours

  Acceptance Criteria:
  [X] I should see the login page.
  [X] I should be able to fill out a form to log in.
  [X] I should be able to submit the form and go to office hours.
  ) do

  scenario "" do
    visit '/log_in'
    expect(page).to have_content("Log In")
  end

end

feature "user can sign up for office hours", %(
  As a user
  I want to be able to sign up for office hours
  So that I can get help from EE's

  Acceptance Criteria:
  [X] Meetups should be listed alphabetically.
  [X] Each meetup listed should link me to the show page for that meetup.
  ) do

  pending

end

feature "user creates a meetup", %(
  As a user
  I want to create a meetup
  So that I can gather a group of people to discuss a given topic

  Acceptance Criteria:
  [X] I must be signed in.
  [X] I must supply a name.
  [X] I must supply a location.
  [X] I must supply a description.
  [X] I should be brought to the details page for the meetup after I create it.
  [X] I should see a message that lets me know that I have created a meetup successfully.
  [X] Add a new record in the Memberships table listing the current user as the creator of the meetup (user_id, meetup_id, owner: true)
  ) do

  pending

end

feature "user joins a meetup", %(
  As a user
  I want to join a meetup
  So that I can talk to other members of the meetup

  Acceptance Criteria:
  [X] I must be signed in.
  [X] From a meetups detail page, I should click a button to join the meetup.
  [X] I should see a message that tells let's me know when I have successfully joined a meetup.
  [X] Add a new record in the Memberships table listing the current user as part of the meetup (user_id, meetup_id, owner: false)
  ) do

  pending

end
