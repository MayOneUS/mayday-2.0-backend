class V1::BillsController < V1::BaseController
  before_action :set_bill
  def supporter_counts
    render
  end

  def timeline
    render json: @bill.timeline
  end

  private

  def set_bill
    bill_id = params[:bill_id].presence
    if bill_id
      @bill = Bill.find_by(bill_id: bill_id)
    else
      @bill = Bill.first # TO DO
    end
  end
end
