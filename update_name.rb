# Coding: UTF-8
require 'rubygems'
require 'twitter'
require 'tweetstream'

# --- Define ---
CONSUMER_KEY = ""
CONSUMER_SECRET = ""
ACCESS_TOKEN = ""
ACCESS_SECRET = ""

# --- Counter User List---

counter = ["AAAAA","BBBBB","CCCCC"] #カウンターしたいユーザーのID(@抜き)

# -- Twitter ---

TweetStream.configure do |config|
    config.consumer_key       = CONSUMER_KEY
    config.consumer_secret    = CONSUMER_SECRET
    config.oauth_token        = ACCESS_TOKEN
    config.oauth_token_secret = ACCESS_SECRET
end

restclient = Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY 
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = ACCESS_TOKEN
    config.access_token_secret = ACCESS_SECRET
end

# --- main ---
client = TweetStream::Client.new.track('@Bell_staymen02') do |status|
    #client = TweetStream::Client.new.userstream do |status|
    text = status.text
    if text.start_with? "RT"
        next
    elsif text =~ /^.*[[:blank:]]*[@＠]Bell_staymen02[[:blank:]]*update_name[[:blank:]]*/
        newname = text.gsub(/^.*[[:blank:]]*[@＠]Bell_staymen02[[:blank:]]*update_name[[:blank:]]*/,"")
    elsif text =~ /[(（【][@＠]Bell_staymen02[[:blank:]]*[）)】][[:blank:]]*$/
        newname = text.gsub(/[(（【][@＠]Bell_staymen02[[:blank:]]*[）)】][[:blank:]]*$/,"")
        newname = newname.delete("~")
    end

    for num in 0 .. counter.length - 1
        if status.user.screen_name == counter[num]
            frag = 1
        end
    end
    
    if frag == 1 && (rand(100)+1) % 2 == 0 && text =~ /^.*[[:blank:]]*[@＠]Bell_staymen02[[:blank:]]*update_name[[:blank:]]*/ 
        tweet = "@#{status.user.screen_name} update_name #{newname}"
        restclient.favorite(status.id)
        restclient.update(tweet, :in_reply_to_status_id => status.id)
        next
        puts "@#{status.user.screen_name}に #{newname} でカウンターした。" 
    end
    
    if newname.length <= 20
        tweet = "@#{status.user.screen_name} #{newname} に改名しました。"
        restclient.favorite(status.id)
        restclient.update_profile({:name => newname})
        restclient.update(tweet, :in_reply_to_status_id => status.id)
        puts "@#{status.user.screen_name}によって #{newname} に改名させられた。"
    else
        tweet_err = "@#{status.user.screen_name} 長すぎるんじゃボケ"
        restclient.favorite(status.id)
        restclient.update(tweet_err, :in_reply_to_status_id => status.id)
        puts "@#{status.user.screen_name}:ERROR(Newname too long)"
    end
end
