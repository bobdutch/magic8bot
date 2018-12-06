require 'rubygems'
require 'twitter'

desc "find_askers"
task :find_askers => [:environment] do
  since = Query.find(:first, :order => 'status_id desc').status_id rescue nil
  ['will i','should i','can i','have i','am i','is this'].each do |thing|
    Twitter::Search.new.since(since).containing('"'+thing+'"').each do |r|
      q=Query.new(r)
      next unless q.to_user.nil?
      next if q.text =~ /(what|where|which|how|when|why|who|wtf)/i
      next if q.text =~ /should i say/i
      next if q.text =~ /will.i.am/i
      next if q.text =~ /will i am/i
      next if q.text =~ /i (care|mention|mentioned)/i
      next if q.text =~ /@\w+/
      next if q.text =~ /#/
      next if q.text =~ /me:/
      next if q.text =~ /q:/i
      next if q.text =~ /(i think not|probably|yes|yes i am|no|nope|no way)\.?$/i
      next if q.text =~ /&quot;.*\?.*&quot;/
      next unless q.text.include?('?')
      next if q.text.include?('http://')
      next if q.text.include?(' or ')

      q.status_id = r['id']
      q.answered = false
      q.save
    end
  end
  Twitter::Search.new.since(since).to('magic8bot').containing('?').each do |r|
    q=Query.new(r)
    q.status_id = r['id']
    q.answered = false
    q.save
  end
end

desc "answer_queries"
task :answer_queries => [:environment] do

  this_hour =  Answer.last_hour.count
  today = Answer.today.count
  cron_per_hour = 10

  exit if today > 998

  max_1 = (100-this_hour)/cron_per_hour
  max_2 = ((1000-today)/24.0/cron_per_hour).round
  max_3 = 100/cron_per_hour 

  limit = [max_1, max_2, max_3].sort[0] 
  limit = 2

  Query.delete_all(["created_at < ? AND to_user IS NULL AND answered = 0", 1.hour.ago])

  newest = Answer.find(:first, :order => 'id desc')
  queries = Query.needs_reply.find(:all, :order => "to_user DESC, id DESC", :limit => limit)
  exit if queries.empty?

  t= Twitter::Base.new(ENV['TWITTER_USER'],ENV['TWITTER_PASSWORD'])
  queries.each do |q|

    options = {
      :in_reply_to_status_id => q.status_id
    }
    response = t.post("@#{q.from_user} " + Ball::ANSWERS[rand(Ball::ANSWERS.length)],
                         options)

    unless newest.nil?
      if response.id.to_s == newest.status_id.to_s
        puts "server too busy couldn't make the post, lame"
        exit
      end
    end

    newest = Answer.create(
      :profile_image_url => response.user.profile_image_url,
      :from_user => response.user.screen_name,
      :to_user_id => response.in_reply_to_user_id,
      :text => response.text,
      :status_id => response.id,
      :from_user_id => response.user.id,
      :to_user => q.from_user,
      :iso_language_code => 'en',
      :in_reply_to_status_id => q.status_id
    )
    q.answered = true
    q.save
    sleep 10
  end


end
