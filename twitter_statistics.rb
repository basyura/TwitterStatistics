require 'rubygems'
require 'twitter'
require 'pstore'

id     = ARGV[0]
pass   = ARGV[1]
search = ARGV[2]

class Tweet
  def initialize(mash)
    @map = {:created_at => mash["created_at"]}
  end
  def [](key)
    @map[key]
  end
end

auth = Twitter::HTTPAuth.new(id,pass)
client = Twitter::Base.new(auth)

list = [] 

if search
  n = 0
  begin
    while n += 1
      puts n
      client.user_timeline("page" => n , "count"=>200).each{|t|
        list.push Tweet.new(t)
      }
    end
  rescue => e
    puts e
  end

  PStore.new("twitter.store").transaction{|store|
    store["list"] = list
  }
end
# 保存済みファイルから読み込み
PStore.new("twitter.store").transaction{|store|
  list = store["list"]
}
puts list.length
# 日別出力
map = {}
list.each{|tweet|
  time = Time.parse(tweet[:created_at])
  date = time.strftime("%Y%m%d")
  map[date] ? map[date] += 1 : map[date] = 1
}
out = open("statistics_day.txt","w")
map.sort.each{|key , value|
  s = key + " " 
  1.upto(value){|c|
    s <<  (c % 10 == 0 ? "|" : "-")
  }
  puts s
  out.puts s
}
# 月別出力
map = {}
list.each{|tweet|
  time = Time.parse(tweet[:created_at])
  date = time.strftime("%Y%m")
  map[date] ? map[date] += 1 : map[date] = 1
}
out = open("statistics_mon.txt","w")
map.sort.each{|key , value|
  s = key + " " 
  1.upto(value){|c|
    if c % 100 == 0
      s << "|"
    elsif c % 10 == 0
      s << "-"
    end
  }
  puts s
  out.puts s
}
# 時間帯出力
map = {}
list.each{|tweet|
  time = Time.parse(tweet[:created_at])
  date = time.strftime("%H")
  map[date] ? map[date] += 1 : map[date] = 1
}
out = open("statistics_tim.txt","w")
map.sort.each{|key , value|
  s = key + " " 
  1.upto(value){|c|
    if c % 100 == 0
      s << "|"
    elsif c % 10 == 0
      s << "-"
    end
  }
  puts s
  out.puts s
}
