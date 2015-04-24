class V1::BillsController < V1::BaseController
  def supporter_counts
    chamber = params[:chamber]
    bill_id = params[:bill_id].presence
    if bill_id
      @bill = Bill.find_by(bill_id: bill_id)
    else
      @bill = Bill.first # TO DO
    end
    render
  end
end
