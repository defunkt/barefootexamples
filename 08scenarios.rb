class ActiveRecord::Base
  def self.skip_stamps
    self.record_timestamps = false
    yield
    self.record_timestamps = true
  end
end

scenario :default do
  users = %w( mojombo\ tom@mojombo.com defunkt\ chris@ozmm.org pj\ pjhyett@gmail.com)
  keys = {'mojombo' => [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzJFfKCBmeagAjnTp7X+3n0RKlnCQPwwmz40DbQdvVq3xHUtmGpBIQ3TX/qDpyMY97S4REkQf9oaJ9hevsOkJVg2eykv5F0gBwCTwrxzlxouI071hkToJKQfD3m9BEW3CZm6kt3qW6lVgEy30ijgZI9IZquuDiR01bayaWR3+FFCpY1fYr6yRl+g57KYOm/Kd0iiDlPhwh1W5U8C29RLFFKAirzAWpp78zONfrayXJK6cMxYKVkCGonTrhx7C06PEU5SA4Gl57OG1aFLsUg3TSvEt+nDdxh3lTZC3NAQPMmcpQ6HVEr0HcNylQrtN/fVYvz1cGutAGHkkf1ikw/QDyw== tom@volcano.local", "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1gGaHfex00qg2F2DeOl8XIVTX6vffVitj7FxSZfsB4RtlwGlDFyTVE2QvjOitkPYdicVwGqvD0baRBqB147dgS01J3dHrhDZB9J6l9ZXz0BMap7YsxVkpHe8Lp2FmnU34hrimvbO94sJvSX0QCwVYawOOzOT4i6XHPP5de4z7PrJ9JFMk5rcyMAjnxDBTvLyJCbjiXH1FwBZ0hsjv5eggrHmKWCMbMcRKzmVnRg8KtvUFh4iiIe7s1QJ9vNjNsLeZavtkDj/JGHd9AMNkR94sLq+WDQihn/f144tWt93h0N34BrOChrwgi8ClC6t2ahloPhZ1ZUdGyKIRcN7RL4uZQ== tom@volcano.local"] }

  users.each do |user|
    user, email = user.split(' ')
    u = User.create! \
      :login    => user, 
      :email    => email,
      :password => 'password', 
      :password_confirmation => 'password',
      :public_keys           => keys[user]
    u.update_attribute(:beta_invite_quota, 5)
  end

  users = User.find(:all)

  mojombo = users.first
  defunkt = users[1]
  pj      = users[2]

  pj.update_attribute(:beta_invite_quota, 0)

  defunkt.beta_invites.create :email => pj.email, :user => pj

  defunkt.posts.create \
    :title     => 'site is almost done',
    :body      => 'for real',
    :published => true

  defunkt.posts.create \
    :title     => 'site is done',
    :body      => 'now its time to rock',
    :published => true

  p = mojombo.posts.create \
    :title     => 'site is down',
    :body      => 'i broke something',
    :published => true

  pj.comments.create :post => p, :body => 'always something'
  pj.comments.create :post => p, :body => 'oh wait, you rock'

  grit     = Repository.create :name => 'grit',     :owner => mojombo, :public => true, :deploy_key => 'myspecialdeploykey'
  ambition = Repository.create :name => 'ambition', :owner => defunkt, :public => false
  github   = Repository.create :name => 'github',   :owner => defunkt, :public => true
  github.fork(:owner => users.first)

  ambition.wikis.create :title => "Private", :body => "Awesome repo, not.", :user => defunkt
  github.wikis.create   :title => "Public",  :body => "Are the bomb",       :user => defunkt

  mojombo.member_repositories << [ambition, github]
  defunkt.watched_repositories   << grit

  CommitEvent.trigger(grit, 'fc128af28cb263bf1f524f84609a7a75ffa27a9b', 'b6e1b765e0c15586a2c5b9832854f95defd71e1f')
  CommitEvent.trigger(ambition, 'be190d59e13327b1f251e3984f8d59adc5d0c847', '909e4d4f706c11cafbe35fd9729dc6cce24d6d6f')

  guide = Guide.create(:user => mojombo, :body => 'MyText', :title => 'MyString')
  guide.update_attributes(:user => defunkt, :body => 'MyText2')

  Message.create(:from => mojombo, :to => defunkt, :subject => 'oh hai', :body => ('oh hai defunkt ' * 100))
  100.times { m = Message.create(:from => pj, :to => defunkt, :subject => 'hey dude', :body => 'please stop being so cool'); m.reply(:from => defunkt, :body => 'FINE') }
  Message.create(:from => mojombo, :to => defunkt, :subject => 'oh hai', :body => ('oh hai defunkt ' * 100), :to_deleted => true)


  PopularRepository.create(:repository => grit, :current => true, :diff => 0, :position => 1, :list => 'forked')
  PopularRepository.create(:repository => github, :current => true, :diff => 0, :position => 2, :list => 'forked')
end

scenario :test do
  users = %w( quentin aaron )
  created_at = [ 5.days.ago.to_s(:db), 1.day.ago.to_s(:db) ]

  ActiveRecord::Base.skip_stamps do
    users.each do |user|
      user = User.new :login => user, :email => "#{user}@example.com"
      user.salt = '7e3041ebc2fc05a40c60028e2c4901a81035d3cd'
      user.created_at = created_at.shift
      user.crypted_password = '00742970dc9e6319f8019fd54864d3ea740f04b1'
      user.save
      BetaInvite.create :email => user.email, :user => user
    end
  end

  BetaInvite.create :email => 'quire@example.com', :inviter => User.find(:first)

  Repository.create :name => 'god', :owner => User.find(:first)
end
