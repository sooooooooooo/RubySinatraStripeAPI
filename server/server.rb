require "stripe"
require "dotenv"
require "sinatra"

Dotenv.load
Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

# puts Stripe::Plan.list

set :static, true
# set :public_folder, "../client"
set :public_folder, File.join(File.dirname(__FILE__), ENV["STATIC_DIR"])
set :port, 4242

get "/" do
	content_type "text/html"
	send_file File.join(settings.public_folder, "index.html")
end

get "/public-keys" do
	content_type "application/json"
	{ key: ENV["STRIPE_PUBLISHABLE_KEY"] }.to_json
end

post "/my-post-route" do
	data = JSON.parse(request.body.read, symbolize_names: true)
	puts "POST with #{ data.to_json } to /my-post-route"

	# put somthing in the db
	# file API request to Stripe
	data.to_json
end



# A webhook is an API that is a way for a third-party to tell YOU about something, rather than you, most of the time when we interact with an API we're creating or retrieving resources from the API, but a webhook is a way for a third-party to tell you when something happens.
# So it's a very common tool that we use in all our integrations, and they are very dependable, so it's a great way to automate some of your workflow that based on these events that are firing.

# For handling webhooks, this is one way that we can set up a webhook handler:
# Post request is coming from Stripe to my service.
# Using Sinatra
post '/webhook' do
  payload = request.body.read
  event = nil

  begin
    event = Stripe::Event.construct_from(
      JSON.parse(payload, symbolize_names: true)
    )
  rescue JSON::ParserError => e
    # Invalid payload
    status 400
    return
  end

  # Handle the event
  case event.type
  when 'payment_intent.succeeded'
    payment_intent = event.data.object # contains a Stripe::PaymentIntent
    # Then define and call a method to handle the successful payment intent.
    # handle_payment_intent_succeeded(payment_intent)
  when 'payment_method.attached'
    payment_method = event.data.object # contains a Stripe::PaymentMethod
    # Then define and call a method to handle the successful attachment of a PaymentMethod.
    # handle_payment_method_attached(payment_method)
  # ... handle other event types
  else
    puts "Unhandled event type: #{event.type}"
  end

  status 200
end