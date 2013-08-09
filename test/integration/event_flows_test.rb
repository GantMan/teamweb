require 'test_helper'
require 'capybara/rails'
require 'forgery'

class EventFlowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  setup do
    # Set up a user and his organization
    @user = User.where(email: "gant@iconoclastlabs.com").first_or_create(password: "fdsafdsa", name: "Gant Man", phone: "888-888-8888", address: "New Orleans")
    @some_org = organizations(:coord_one)
    @some_org.members.add_member(@user, admin_flag: true)    
  end

  test "Creating an Event" do
    capybara_sign_in(@user)
    some_org = Organization.first
    visit new_organization_event_path(some_org)
    fill_in 'Name for this event', with: Forgery::Name.full_name
    fill_in 'Location of Event', with: "New Orleans"
 
    click_link_or_button('Save')
    assert page.has_content?('Event was successfully created.')
  end

# OK - Not going to do the UI show/hide test because it requires javascript enabled browsers
# this can be horribly distracting as it pops-up an actual browswer window
  # test "Max Members hides and shows correctly" do
  #   # we need to see jQuery, so switch to more robust driver
  #   Capybara.current_driver = :selenium 

  #   capybara_sign_in(@user)
  #   visit new_organization_event_path(@some_org)
  #   binding.pry
  #   # default visible
  #   assert page.has_content?('Maximum members')
  #   assert find_field('event_members_allowed').checked?

  #   # hide it
  #   uncheck 'event_members_allowed'
  #   #should be hidden
  #   assert page.has_no_content?('Maximum members')
  #   check 'event_members_allowed'
  #   #shows again
  #   assert page.find_field('event_max_members').visible?

  #   Capybara.use_default_driver 
  # end

end