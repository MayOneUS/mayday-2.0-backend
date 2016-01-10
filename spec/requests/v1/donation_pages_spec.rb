require 'rails_helper'

describe "GET /donation_pages" do
  it "lists donation pages" do
    worst_page = create(:donation_page)
    best_page = create(:donation_page)
    ok_page = create(:donation_page)
    create(:action, donation_page: worst_page, donation_amount_in_cents: 100)
    create(:action, donation_page: ok_page, donation_amount_in_cents: 200)
    create(:action, donation_page: best_page, donation_amount_in_cents: 100)
    create(:action, donation_page: best_page, donation_amount_in_cents: 200)

    get '/donation_pages', limit: 2

    expect(json_body.length).to eq 2
    expect(json_body.map{ |d| d['slug'] }).to eq [best_page.slug, ok_page.slug]
    expect(json_body.map{ |d| d['funds_raised_in_cents'] }).to eq [300, 200]
  end
end

describe "GET /donation_pages/:slug" do
  it "shows donation page" do
    donation_page = create(:donation_page)

    get "/donation_pages/#{donation_page.slug}"

    expect(json_body['title']).to eq donation_page.title
    expect(json_body).to match_donation_page(
      donation_page, :slug, :title, :visible_user_name, :photo_url, :intro_text
    )
  end
end

describe "POST /donation_pages" do
  it "creates donation page" do
    page_attributes = attributes_for(:donation_page).stringify_keys

    post '/donation_pages', person: attributes_for(:person),
      donation_page: page_attributes

    expect(DonationPage.last.attributes).to include page_attributes
  end
end

describe "POST /donation_pages/validate" do
  it "returns validation errors for invalid donation page" do
    create(:donation_page, slug: 'slug1')

    post '/donation_pages/validate', person: { email: 'test@example.com' },
      donation_page: { slug: 'slug1' }

    expect(json_body['valid']).to be false
    expect(json_body['errors']).to include('donation_pages', 'slug', 'title')
    expect(json_body['errors']['slug']).to eq ['has already been taken']
  end

  it "returns valid: true for valid donation_page" do

    post '/donation_pages/validate', person: attributes_for(:person),
      donation_page: attributes_for(:donation_page)

    expect(json_body['valid']).to be true
    expect(json_body['errors']).to be_empty
  end
end

RSpec::Matchers.define :match_donation_page do |expected, *fields|
  match do |actual|
    actual.slice(*fields.map(&:to_s)) == expected.slice(*fields.map(&:to_sym))
  end
end
