# Omniauth::Daccount

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/omniauth/daccount`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-daccount'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-daccount

## Setup Your d-account API
- Go to https://g.daccount.docomo.ne.jp/VIEW_OC01/login4
- Sign in and Go to 'ＲＰサイト情報管理'
- Create Your RP Site if you don't have, then you must provide the `openid` scope.
- Go to '詳細', then note client_id and client_secret.

## Usage

Here's an example for adding the middleware to a Rails app in config/initializers/omniauth.rb:

```
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :daccount, ENV['D_ACCOUNT_CLIENT_ID'], ENV['D_ACCOUNT_CLIENT_SECRET'], callback_path: "your callback url"  
end
```

Note: daccount connect cannot register http url as callback url. That is, localhost cannot be registered. Of course in most cases using localhosts while developing your application... but we need to prepare https callback url in this case(You can choise deploying heloku or using ngrok, and more).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/omniauth-daccount. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
