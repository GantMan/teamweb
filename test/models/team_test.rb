# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  max_members :integer
#  rank        :integer
#  season_id   :integer
#

require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  before { 
    @team_one = teams(:team_one) 
    @first_user = @team_one.users.first
    @event_one = events(:event_one)
    @event_two = events(:event_two)
    @season_one = seasons(:season_one)
    @season_two = seasons(:season_two)
    @no_teams_season = seasons(:season_three)
  }
  let(:simple_team) {Team.new(name: 'TestName', max_members: 5)}
  it 'can create a new Team' do
    simple_team.valid?.must_equal true
  end

  it 'requires a name' do
    simple_team.name = nil
    simple_team.valid?.must_equal false
  end

  it 'should be unique per season id' do
    simple_team.season = @season_one
    simple_team.save.must_equal true
    # try to save again with exact same info
    new_team = simple_team.clone
    new_team.id = nil
    new_team.valid?.must_equal false
    # change season id and all is fixed!
    new_team.season = @season_two
    new_team.valid?.must_equal true
  end

  it 'has events' do
    # verify the property exists
    assert_respond_to(@team_one, :events)
    # verify it is set
    assert_not_nil @team_one.events
  end

  it 'can have users' do
    assert_respond_to(@team_one, :users)
  end

  it 'must at least have room for one team member' do
    simple_team.max_members = 0
    simple_team.valid?.must_equal false
  end

  it 'can add a team member' do
    team_two = teams(:team_two)
    team_two.users.reload
    team_two.users.include?(@first_user).must_equal false
    team_two.add_team_member(@first_user).must_equal true
    team_two.users.reload
    team_two.users.include?(@first_user).must_equal true
  end

  it 'is idempotent with saving the same team member' do
    assert_no_difference('@team_one.members.size') do
      success = @team_one.add_team_member(@first_user, admin_flag: false)
      success.must_equal true
    end
  end

  it 'cannot exceed max_members' do
    simple_team.max_members = 1
    simple_team.save.must_equal true
    simple_team.add_team_member(users(:one)).must_equal true
    simple_team.add_team_member(users(:two)).wont_equal true
    simple_team.members.size.must_equal 1
  end
  
  it "Teams are invalid on Seasons that disallow teams" do
    @no_teams_season.teams_allowed?.must_equal false
    simple_team.season = @no_teams_season
    simple_team.valid?.must_equal false
  end

  it 'Max Members can never be set greater than Event Max Team Size' do
    simple_team.season = @season_one
    @season_one.max_team_size = 5
    simple_team.max_members = 5
    simple_team.valid?.must_equal true
    simple_team.max_members = 6
    simple_team.valid?.must_equal false
  end

  it 'cannot exceed max_members' do
    simple_team.max_members = 1
    simple_team.save.must_equal true
    simple_team.add_team_member(users(:one)).must_equal true
    simple_team.add_team_member(users(:two)).wont_equal true
    simple_team.members.size.must_equal 1
  end

  it 'private validation method owner_allows_teams generates errors' do
    #season allows teams
    @season_one.teams_allowed = true
    simple_team.season = @season_one
    simple_team.send(:owner_allows_teams) # Call to private method
    simple_team.errors.size.must_equal 0
    #season should disallow teams
    @season_one.teams_allowed = false
    simple_team.send(:owner_allows_teams) # Call to private method generates an error
    simple_team.errors.size.must_equal 1
  end

end
