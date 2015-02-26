FactoryGirl.define do
  factory :person do
    sequence(:email) { |n| "user#{n}@example.com" }
  end

  factory :legislator do
    sequence(:bioguide_id) { |n| "F#{n}" }
    first_name 'Barbara'
    last_name 'Boxer'
    phone '202-224-3553'
    party 'D'
    term_end 1.year.from_now

    factory :senator do
      chamber 'senate'
      state_rank 'junior'
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

  factory :state do
    sequence(:name) { |n| "State#{n}" }
    sequence(:abbrev) { |n| (n % 529).divmod(23).map{ |i| ('D'..'Z').to_a[i] }.join }
  end

  factory :zip_code do
    state
  end

  factory :target do
    campaign

    factory :rep_target do
      association :legislator, factory: :representative
    end
    factory :senator_target do
      association :legislator, factory: :senator
    end
  end

  factory :campaign do
    sequence(:name) { |n| "Campaign #{n}" }

    factory :campaign_with_reps do
      transient do
        count 1
        priority nil
      end

      after(:create) do |campaign, evaluator|
        campaign.targets = create_list(:rep_target, evaluator.count, priority: evaluator.priority)
      end
    end
  end
end