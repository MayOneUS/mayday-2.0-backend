FactoryGirl.define do
  sequence :sponsorship_date do
    Faker::Date.between(100.days.ago, Date.today)
  end

  factory :person do
    sequence(:email) { |n| "person#{n}@example.com" }
    sequence(:phone) { |n| "555555#{n.to_s.rjust(4,'0')}"}

    trait :with_district do
      after(:create) do |person|
        district = create(:district)
        person.create_location(district: district, state: district.state)
      end
    end
  end

  factory :location do
    person
    district
    state { district.state }
    sequence(:zip_code) { |n| "2#{n.to_s.rjust(4,'0')}" }
  end

  factory :event do
    sequence(:starts_at, 1) { |n| n.hours.from_now }
    sequence(:ends_at, 2)   { |n| n.hours.from_now }
    sequence(:remote_id)
  end

  factory :legislator do
    sequence(:bioguide_id) { |n| "F#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone '202-224-3553'
    party { %w[D R].sample }
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

    trait :targeted do
      transient do
        priority nil
      end
      targets { build_list :target, 1, priority: priority }
    end

    trait :with_us do
      with_us true
    end

    trait :cosponsor do
      association :sponsorship, :cosponsored
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
    sequence(:zip_code) { |n| "2#{n.to_s.rjust(4,'0')}" }
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

      targets { build_list(:rep_target, count, priority: priority) }
    end
  end

  factory :call, class: Ivr::Call do
    person
  end

  factory :connection, class: Ivr::Connection do
    call
    association :legislator, factory: :senator

    trait :completed do
      status Ivr::Call::CALL_STATUSES[:completed]
      status_from_user Ivr::Connection::USER_RESPONSE_CODES['1']
    end

    trait :failed do
      status Ivr::Call::CALL_STATUSES[:failed]
    end
  end

  factory :activity do
    sequence(:name) { |n| "Activity #{n}" }
    sequence(:template_id) { |n| "template_#{n}" }
  end

  factory :bill do
    sequence(:bill_id) { |n| "bill-#{Faker::Lorem.words(4).join(' ')}" }
    congressional_session Bill::CURRENT_SESSION
    # sequence(:chamber){ [] }
  end

  factory :sponsorship do
    association :bill
    association :legislator, factory: :senator

    trait :cosponsored do
      cosponsored_at{ generate(:sponsorship_date) }
    end

    trait :pledged_support do
      pledged_support_at{ generate(:sponsorship_date) }
    end

    trait :introduced do
      introduced_at{ generate(:sponsorship_date) }
    end
  end
end
