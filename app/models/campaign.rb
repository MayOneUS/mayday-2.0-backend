class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :districts
  has_many :zip_codes, through: :districts

  validates :name, presence: true

  def relevant_district_for_zip(zip)
    result, district = nil, nil
    if zip_code = ZipCode.find_by(zip_code: zip)
      if zip_code.campaigns.where(id: id).any?
        if zip_code.districts.count == 1
          result = 'in campaign'
          district = zip_code.districts.first
        else
          result = 'possibly in campaign'
        end
      else
        result = 'not in campaign'
      end
    else
      result = 'not recognized'
    end
    { result: result, district: district }
  end
end
