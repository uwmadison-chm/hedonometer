class Admin::TwilioAccountsController < AdminController
  def show
    respond_to do |format|
      client = Twilio::REST::Client.new(params[:sid], params[:auth_token])
      act = client.accounts.get params[:sid]
      begin
        act.status  # Force the client to load data
      rescue Twilio::REST::RequestError => exc
        render(text: exc.message, status: client.last_response.code)
        return
      end
      format.json {
        render text: client.last_response.body
      }
    end
  end
end