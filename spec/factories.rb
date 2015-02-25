FactoryGirl.define do
  factory :state do
    sequence(:name) { |n| "State#{n}" }
    sequence(:abbrev) { |n| (n % 676).divmod(26).map{ |i| ('A'..'Z').to_a[i] }.join }
    single_district false

    factory :single_district_state do
      single_district true
      after(:create) do |state|
        state.districts.create(district: '0')
      end
    end
    factory :multi_district_state do
      transient do
        districts_count 2
      end

      after(:create) do |state, evaluator|
        create_list(:district, evaluator.districts_count, state: state)
      end
    end
  end

  factory :legislator do
    sequence(:bioguide_id) { |n| "F#{n}" }
    first_name 'Barbara'
    last_name 'Lee'
    factory :senator do
      chamber 'senate'
      senate_class 1
      state
    end
    factory :representative do
      chamber 'house'
      district
    end
  end

  factory :district do
    sequence(:district) { |n| n.to_s }
    state
  end

  factory :zip_code do
    state
  end

  factory :campaign do
    sequence(:name) { |n| "Campaign #{n}" }

    factory :campaign_with_districts do
      transient do
        districts_count 1
      end

      after(:create) do |campaign, evaluator|
        campaign.districts = create_list(:district, evaluator.districts_count)
      end
    end
  end

  factory :call do
    zip_code
  end

  factory :connection do
    call
  end
end