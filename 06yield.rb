%w( rubygems fileutils json rack thin yaml ostruct ).each { |f| require f }
OpenStruct.class_eval { undef_method :id } rescue nil

module Err
  class Web
    def self.routes; @@routes ||= [] end

    def self.route(path, &block)
      routes << [ Regexp.new(path), block ]
    end

    def call(env)
      action, params = recognize(env['PATH_INFO'])
      [ 200, action.calls(*params), { 'Content-Type' => 'text/javascript' } ]
    end

    def recognize(path)
      if found = self.class.routes.detect { |regexp,| path =~ regexp }
        [ found.last, path.scan(found.first).first ]
      end
    end
  end
end

class Yield < Err::Web
  Port = ARGV[0] || 4567
  Host = 'y.errfree.com'

  def self.load_ads 
    const_set(:Ads, YAML.load_file('ads.yml').map { |ad| OpenStruct.new(ad) }) 
  end

  def self.stats_file
    today = Date.today
    year, month, day = today.year.to_s, today.month.to_s, today.day.to_s
    File.join(File.dirname(__FILE__), 'stats', year, month, day)
  end

  def self.count_for_ad(id)
    `grep -c ' #{id}$' #{stats_file}`.strip
  end

  def self.hit!(site, ad)
    Thread.new do
      file = stats_file
      FileUtils.mkdir_p(file.sub(/\d+$/,'')) unless File.exists? file
      File.open(file, 'a') { |file| file.write_nonblock([ site, ad.id ].join(' ') + "\n") }
    end
  end

  def self.render_ad(ad)
    <<-javascript
    var ad = ''
    ad += '<a href="#{ad.url}"><img src="http://#{Host}/i/#{ad.image}" alt="#{ad.name}: #{ad.blurb}" /></a>'
    ad += '<p class="blurb">'
    ad += '<a href="#{ad.url}">#{ad.name}</a>: '
    ad += '#{ad.blurb}'
    ad += '</p>'
    document.write(ad)
    javascript
  end

  load_ads

  route '/reload' do
    load_ads
    Ads.to_yaml
  end

  route '/honk.js' do
    counts = Ads.map { |ad| { :name => ad.name, :value => count_for_ad(ad.id) } }
    "yield_stats(#{counts.to_json})"
  end

  route '/all.js' do
    Ads.map { |ad| render_ad(ad) }.to_s
  end

  route %r{\/(\w+)\.js} do |site|
    ad = Ads[rand(Ads.size)]

    hit! site, ad

    render_ad ad
  end
end

Rack::Handler::Thin.run(Yield.new, :Port => Yield::Port) do |server|
  trap("INT") { server.stop }
end
