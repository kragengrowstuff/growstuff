require 'spec_helper'

describe 'home/index.html.haml', :type => "view" do
  context 'logged out' do
    before(:each) do
      @member = FactoryGirl.create(:london_member)
      @member.updated_at = 2.days.ago
      @post = FactoryGirl.create(:post, :author => @member)
      @planting = FactoryGirl.create(:planting, :garden => @member.gardens.first)
      controller.stub(:current_user) { nil }
      assign(:interesting_members, [@member])
      assign(:plantings, [@planting])
      assign(:posts, [@post])
      render
    end

    it 'has description' do
      rendered.should contain 'is a community of food gardeners'
    end

    it 'show recent posts' do
      rendered.should contain @post.subject
    end

    it 'show recent plantings' do
      rendered.should contain @planting.crop_system_name
      rendered.should contain @planting.garden.name
    end

    it 'show interesting members' do
      rendered.should contain @member.login_name
      rendered.should contain @member.location
    end
  end

  context 'logged in' do
    before(:each) do
      @member = FactoryGirl.create(:london_member)
      controller.stub(:current_user) { @member }
      sign_in @member
      assign(:member, @member)
      @planting = FactoryGirl.create(:planting,
        :garden => @member.gardens.first
      )
      assign(:plantings, [@planting])
      @seed = FactoryGirl.create(:seed, :owner => @member)
      @forum = FactoryGirl.create(:forum, :owner => @member)
      @post = FactoryGirl.create(:post, :author => @member)
      assign(:posts, [@post])
      render
    end

    it 'should say welcome' do
      render
      rendered.should contain "Welcome, #{@member.login_name}"
    end

    it 'mentions location' do
      rendered.should contain @member.location
    end

    it 'lists gardens' do
      assert_select "a[href=#{url_for(@member.gardens.first)}]", "Garden"
    end

    it 'shows seeds' do
      rendered.should contain "Your seed stash"
      rendered.should contain "1 variety"
    end

    it 'shows account type' do
      rendered.should contain "Free account"
    end

    it 'shows upgrade account button' do
      rendered.should contain "Upgrade"
    end

  end
end
