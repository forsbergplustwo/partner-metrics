class HomeController < ApplicationController


  def index
    if current_user.present?
      redirect_to metrics_path
    end
  end

  # TODO: Find a better place for this
  def app_store_analytics
  end

  # TODO: Move to payment_histories::uploads#create & refactor + add tests
  def import
    metrics = current_user.metrics.any?
    save_partner_api_credentials
    filename = params[:filename]
    if filename.present?
      current_user.update(import: "Importing", import_status: 0)
      Resque.enqueue(ImportWorker, current_user.id, filename)
    elsif metrics.present? && current_user.has_partner_api_credentials?
      flash[:notice] = "Account connection updated! We will import your data automatically, at the end of each day."
    else
      flash[:errors] = "Something went wrong. You either need to add your Partner API credentials, or upload the file for the first import."
    end
  end

  # TODO: Move to payment_histories::uploads#show & refactor + add tests
  def import_status
    render nothing: true unless request.xhr?
    label = current_user.import
    if label.include?("Importing") || label.include?("Calculating metrics")
      amount_done = current_user.import_status
      reload = false
    elsif label.include?("Complete")
      amount_done = current_user.import_status
      reload = true
      flash[:notice] = "Metrics successfully updated!"
    elsif label.include?("Failed")
      amount_done = current_user.import_status
      reload = true
      flash[:error] = <<-'HTML'
        <h3><strong>Something went wrong during import!</strong></h3>
        <h3>Partner API</h3>
        <p>If you are using Partner API credentials, check the Organization ID and Access token you entered are correct.</p>
        <h3>CSV export</h3>
        <p>If you uploaded a CSV, make sure the file you are uploading was exported using <a href='export-button.png' target='_blank'>this exact button</a> within your Shopify Partner Dashboard. Your Partner Dashboard in Shopify must be in English, otherwise Shopify changes the column names in the CSV files which causes problems.</p>
        <br>If troubles continue, please feel free to get in contact by clicking the message icon at the bottom of this page.
      HTML
    end
    flash.keep
    render json: {
      reload: reload,
      label: label,
      amount_done: amount_done
    }
  end

  # TODO: Move to metrics#destroy & refactor + add tests
  def reset_metrics
    current_user.metrics.delete_all
    current_user.payment_histories.delete_all
    flash[:notice] = "Metrics successfully reset!"
    redirect_to root_path
  end

  # TODO: Move to metrics::app_names#update & refactor + add tests
  def rename_app
    from_name = params["rename_from"]
    to_name = params["rename_to"]
    if from_name.present? && to_name.present? && from_name != to_name
      current_user.metrics.where(app_title: from_name).update_all(app_title: to_name)
      current_user.payment_histories.where(app_title: from_name).update_all(app_title: to_name)
      flash[:notice] = "App successfully renamed!"
    else
      flash[:errors] = "Failed to rename app!"
    end
    redirect_to URI(request.referer).path
  end

  private

  def save_partner_api_credentials
    if params[:partner_api_access_token].present? && params[:partner_api_organization_id].present? && params[:count_usage_charges_as_recurring].present?
      current_user.update!(
        partner_api_access_token: params[:partner_api_access_token],
        partner_api_organization_id: params[:partner_api_organization_id],
        partner_api_errors: "",
        count_usage_charges_as_recurring: params[:count_usage_charges_as_recurring]
      )
    end
  end
end
