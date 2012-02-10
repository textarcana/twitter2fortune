require 'rubygems'
require 'twitter'
require 'sqlite3'

User = 'bbcnews'

db = SQLite3::Database.new("twitter2fortune.db")
db.execute("CREATE TABLE IF NOT EXISTS tweets(user TEXT, id INTEGER, tweet TEXT, PRIMARY KEY(user, id))");

last_id = db.get_first_value("SELECT id from tweets WHERE user=? ORDER BY id DESC LIMIT 1", User)
max_id = 0 

while
  begin
    puts "loop! last-id: #{last_id} max-id: #{max_id}" 
    if max_id > 0
      timeline = Twitter.user_timeline(User, :since_id => last_id, :max_id => max_id, :count => 200, :exclude_replies => 1, :trim_user => 1)
    else
      timeline = Twitter.user_timeline(User, :since_id => last_id, :count => 200, :exclude_replies => 1, :trim_user => 1)
    end
  rescue Twitter::Error::BadGateway
    retry
  end

  break if timeline.empty?
  max_id = timeline.last.id - 1
  puts "Recieved #{timeline.size} tweets below index #{last_id}"
  timeline.each do |st|
    db.execute("INSERT into tweets VALUES (?, ?, ?)", User, st.id, st.text); 
  end
end
