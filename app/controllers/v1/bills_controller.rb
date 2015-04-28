class V1::BillsController < V1::BaseController
  before_action :set_bill
  def supporter_counts
    render
  end

  def timeline
    render json: { @bill.bill_id => @bill.timeline }
  end

  private

  def set_bill
    @bill = Bill.find_by(bill_id: params[:bill_id]) || Bill::AllSupporters.new
  end
end