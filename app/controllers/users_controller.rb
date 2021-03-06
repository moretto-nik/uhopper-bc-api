class UsersController < ApplicationController
  def check_in
    user = User.create_not_exists(params["id_cart"])

    respond_with_json_message user.check_in(params[:api_key]), "L'utente #{user.id_user} ha effettuato il check in"
  end

  def tracking
    if User.exists?(:id_cart => params["id_cart"])
      user = User.find_by_id_cart(params["id_cart"])
      respond_with_json_message user.tracking(params[:api_key],params[:lat], params[:lon]), "L'utente #{user.id_user} e' stato tracciato", "L'utente #{user.id_user} non e' stato tracciato"
    else
      respond_with_json_message false, nil, "Id Cart not exists"
    end
  end

  def check_out
    if User.exists?(:id_cart => params["id_cart"])
      user = User.find_by_id_cart(params["id_cart"])
      respond_with_json_message user.check_out(params[:api_key]), "L\'utente #{user.id_user} ha effettuato il check out"
    else
      respond_with_json_message false, nil, "Id Cart not exists"
    end
  end

  def active
    status, json = User.active_users(params[:api_key])
    respond_with_json_message status, json
  end

  def checking_in
    respond_with_json_message true, User.checking_in(params[:api_key])
  end

  def checking_out
    respond_with_json_message true, User.checking_out(params[:api_key])
  end

  private
  def respond_with_json_message status, ok_message, nok_message=nil
    if status == true
      render json: {:status => "OK", :message => ok_message}, status: :ok, location: nil
    elsif status == false
      render json: {:status => "NOK", :message => nok_message}, status: :nok, location: nil
    else
      render json: {:status => "NOK", :message => "Beancounter : #{status}"}, status: :nok, location: nil
    end
  end
end
