require 'httparty'

def pull_requests(date, page = 1)
  result = HTTParty.get("http://24pullrequests.com/pull_requests.json?page=#{page}")
  today = result.select do |pr|
    DateTime.parse(pr['created_at']).new_offset(0).to_date == date
  end
  if result.last == today.last
    next_page = pull_requests(date, page + 1)
    {
      results: today + next_page[:results],
      page: next_page[:page]
    }
  else
    {
      results: today,
      page: page
    }
  end
end

SCHEDULER.every '5m', :first_in => 0 do |job|
  today = pull_requests(Time.now.utc.to_date)
  yesterday = pull_requests(Time.now.utc.to_date - 1, today[:page])
  send_event('todays_prs', {
    current: today[:results].count,
    last: yesterday[:results].count
  })
end
