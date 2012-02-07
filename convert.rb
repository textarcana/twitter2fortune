require 'rubygems'
require 'twitter'

User = 'devops_borat'
Output = File.open(User, 'w')

last_id = 0

while
  begin 
    if last_id > 0 then
      timeline = Twitter.user_timeline(User, :max_id => last_id, :count => 200, :exclude_replies => 1, :trim_user => 1)
    else
      timeline = Twitter.user_timeline(User, :count => 200, :exclude_replies => 1, :trim_user => 1)
    end
  rescue Twitter::Error::BadGateway
    retry
  end

  break if timeline.empty?
  last_id = timeline.last.id - 1
  puts "Recieved #{timeline.size} tweets below index #{last_id}"
  timeline.each do |st|
    Output.write("#{st.text}\n%\n")
  end
end
