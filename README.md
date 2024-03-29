# Faye Service Gem

[![Gem Version](https://badge.fury.io/rb/faye_service.svg)](https://badge.fury.io/rb/faye_service)

This gem can extend a Ruby project such as Rails, Sinatra, Padrino, Rack, etc. It provides a simple way to communicate with any Faye server instance. 

## To Use This Gem

Add it to your `Gemfile`

```
gem 'faye_service', '~> 1.0.1'
```

Or install it locally on your system: 

```
gem install faye_service
```

## Prerequisites

> You need to have at least one instance of Faye running locally on your machine. If you do not have an instance of Faye to connect to, consider using this docker container and this Github repo: 

**Github Repo**: https://github.com/amerlescucodez/faye-docker

**Docker Container**: https://hub.docker.com/r/amerlescucodez/docker-faye-ruby

```
docker pull amerlescucodez/docker-faye-ruby
```

> You can use this `docker-compose.yaml` template to get the necessary requirements running locally: 

```
version: "3.7"

services:
  redis:
    image: redis:alpine
    ports:
      - 6379:6379
    restart: always
    networks:
      - primary

  faye:
    image: amerlescucodez/docker-faye-redis:latest
    links:
      - redis
    depends_on:
      - redis
    restart: unless-stopped
    ports:
      - 4242:4242
      - 4443:4443
    expose:
      - 4242
      - 4443
    env_file:
      - .faye.env.development
    volumes:
      - ./host/path/to/ssl/certificates:/etc/ssl/certs/faye
      - ./host/path/to/faye/tokens:/usr/local/faye/tokens
    networks:
      - primary


networks:
  primary:
```

> Then you should be able to execute: 

```
docker-compose up -d
```

> And then be able to access https://localhost:4242/faye/client.js

**Note**: If you're placing Faye inside a docker-compose file that also includes your application, you need to make sure that 

## Installation into Rails

**Important Note**: If you wish to use SSL with Faye, please change all occurences of `http://localhost:4242` to `https://localhost:4443` (or to the specified values in your instance of faye.) Please read this documentation about SSL support: https://github.com/amerlescucodez/faye-docker-ruby#generate-ssl-certificate

> Open your `Gemfile` and add the following dependency: 

```ruby
gem "faye_service", "~> 1.0.1"
```

> Create the faye configuration file:

Edit `config/initializers/faye.rb`:

```ruby
require 'faye_service'
FayeService.configure do |config|
  config.url = "http://localhost:4242"
  config.auth_token = ""
  config.auth_service = ""
end
```

## Sending Messages 

#### From A Controller

`app/controllers/sample_controller.rb`

```ruby
class SampleController < ApplicationController
	def index
		FayeService.publish("/channel/name","message")
	end
end
```

#### From A Model
`app/models/sample.rb`

```ruby
class Sample
	def call_with_nothing
		FayeService.publish("/channel/name","static message")
	end
	
	def call_to_user_channel_with(user_id,message)
		FayeService.publish("/channel/user/#{user_id}", message) if user_id.instance_of?(String)
	end
	
	def call_with_big_message
		message = {
			:friends => %w{Claire Walt Ryland Sylvia Mekhi Lili}, 
			:enemies => %w{Batman Robbin Garfield Snoopy}
		}
		FayeService.publish("/channel/name",message)
	end
end
```

## Receiving Messages

### Include Faye's main JS file

`app/views/layout/application.html.erb`

```ruby
<!DOCTYPE html>
<html>
<head>
  <title>WebSocketsExample</title>
  <%= stylesheet_link_tag    "application", :media => "all" %>
  <%= javascript_include_tag "http://localhost:4242/faye/client.js","application" %>
  <%= csrf_meta_tags %>
</head>
<body>

<%= yield %>

</body>
</html>
```

### Subscribe to Faye Channel within a Controller's View

`app/views/sample/index.html.erb`

```ruby
<h2>Push Notification Example</h2>
<script type="text/javascript">
  $(function() {
    var faye = new Faye.Client('http://localhost:4242/faye');
    varsubscription = faye.subscribe("/my/awesome/channel", function(data) {
      alert(data); 
    });
    subscription.then(function(message){
      console.log("Successfully subscribed to Faye.");
    }, function(error){
      console.log("Error connecting to Faye.");
    });
  });
</script>
```

> `data` is a variable accessible with in the block of `faye.subscribe` that will either contain JSON data or a string. The best practice section in the Faye Server documentation states that you should always send `json` messages to keep things consistant. It'll make your life easier. 


