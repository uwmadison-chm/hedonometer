class Admin::TwilioAccountsController < AdminController
  def show
    begin
      number_list = TwilioIncomingNumber.available_unavailable_numbers(
        params[:sid], params[:auth_token])
    rescue Twilio::REST::RequestError => exc
      render text: exc.message, status: TwilioIncomingNumber.client.last_response.code
      return
    end
    data = {
      status: "active",
      numbers: number_list
    }
    respond_to do |format|
      format.json {
        render text: JSON.dump(data)
      }
    end
  end
end