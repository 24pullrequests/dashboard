require 'httparty'
require 'pry'

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

SCHEDULER.every '5m', :first_in => 0 do |job|
  users = HTTParty.get('http://24pullrequests.com/users.json')
  users = users.take(18).map do |user|
    {label: user['nickname'], value: user['pull_requests'].count }
  end
  send_event('top_pr_count', items: users)
end

SCHEDULER.every '5m', :first_in => 0 do |job|
  orgs = HTTParty.get('http://24pullrequests.com/organisations.json')
  orgs = orgs.map { |org|
    count = org['users'].inject(0) do |memo, user|
      memo + user['pull_requests_count']
    end
    {label: org['login'], value: count }
  }.sort { |a, b|
    a['value'] <=> b['value']
  }.take(8)
  send_event('top_pr_org_count', items: orgs)
end
