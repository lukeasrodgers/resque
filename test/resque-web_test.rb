require 'test_helper'
require 'resque/server/test_helper'
require 'nokogiri'
 
# Root path test
context "on GET to /" do
  setup { get "/" }

  test "redirect to overview" do
    follow_redirect!
  end
end

# Global overview
context "on GET to /overview" do
  setup { get "/overview" }

  test "should at least display 'queues'" do
    assert last_response.body.include?('Queues')
  end
end

# Working jobs
context "on GET to /working" do
  setup { get "/working" }

  should_respond_with_success
end

# Failed
context "on GET to /failed" do
  setup { get "/failed" }

  should_respond_with_success
end

# With failures
context "on GET to /failed with failures" do
  setup do
    Resque.redis.flushall
    10.times { Resque::Job.create(:jobs, BadJob) }
    @worker = Resque::Worker.new(:jobs)
    @worker.work(0)
    assert_equal 10, Resque::Failure.count
    get "/failed"
  end

  teardown do
    Resque.redis.flushall
    assert_equal 0, Resque::Failure.count
  end

  test "should show failures" do
    body =last_response.body 
    html = Nokogiri::HTML(body)
    first = html.search('.failed li').first
    puts first
    assert_equal first.attr('data-id'), '0'
  end
end

# Stats 
context "on GET to /stats/resque" do
  setup { get "/stats/resque" }

  should_respond_with_success
end

context "on GET to /stats/redis" do
  setup { get "/stats/redis" }

  should_respond_with_success
end

context "on GET to /stats/resque" do
  setup { get "/stats/keys" }

  should_respond_with_success
end

context "also works with slash at the end" do
  setup { get "/working/" }

  should_respond_with_success
end
