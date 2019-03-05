require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "can generate short absolute urls for scheduled messages" do
    url = absolute_url_for(action: 'show', controller: 'scheduled_messages', id: 1)
    assert_equal "http://test.host/r/1", url
  end
end

