# Cottontail

Cottontail is a fluffy RabbitMQ library built on top of [Bunny](https://github.com/ruby-amqp/bunny).  As easy as Bunny is to use, we wanted to consolidate down to our primary usage pattern, that being Pub/Sub.

## Installation

Add this line to your application's Gemfile:

    gem 'cottontail'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cottontail

## Usage

Configure a connection to your RabbitMQ server.  In a Rails application this might be something along the lines of:

1. First, make sure you have a working RabbitMQ instance.  It'd help if it was running, as well.
1. Add an initializer: `config/initializers/cottontail.rb`
1. Configure said initializer:

  ```ruby
    Cottontail.configure do |c|
      c.url = ENV['AMQP_URL']  # because we all know you're using Heroku, too...
    end
  ```

  or

  ```ruby
    Cottontail.configure do |c|
      c.host = "rabbitsareverywhere.com"  # I should prolly just buy that domain right now...
      c.user = "bugsbunny"
      c.password = "3$qU1re"
      c.vhost = "%2fwhat_is_up_doc"
    end
  ```

  Note the `:vhost` attribute.  RabbitMQ suports arbitrary virtual host designations (see [here](http://www.rabbitmq.com/uri-spec.html) for the official documentation).  However it would appear that using a prepended '/' is pretty common.  Per the documentation, any '/' characters embedded in the virtual host name need to be URL encoded, hence '%2f'.

1. To hook into your models, simply include `Cottontail::Model` and invoke one of the macros, along the lines of:

  ```ruby
  class Foo
    include Cottontail::Model
    notify_on_all
  end
  ```

  See `spec/cottontail/model_spec.rb` for some additional invocations

1. To use directly, you can always just ask Cottontail to publish a message out to the group:

  ```ruby
  Cottontail.publish({ hey_everybody: :hey_doctor_nick }, "simpsons.nick.arrived")
  ```

1. Of course, without a subscriber, not much will happen, other than clogging up your message queues.  And that's also where Cottontail gets to be kinda useful

  ```ruby
  class Chorus
    include Cottontail::Consumable
    def handle_message(delivery_info, metadata, payload)
      puts "HI DOCTOR NICK!!!"
    end
  end
  worker = Worker.new(consumer: Chorus.new, key: "simpsons.nick.#")  # if you don't know the '#' is a RabbitMQ wildcard
  worker.start!  # IMPORTANTE! for the time being, the connection to RabbitMQ must be initiated explicitly
  ```

1. Happy Pub/Sub'ing!


## To Do

There are a couple of things yet to do.  Among them:

- [] Implement the [Aggregator pattern](http://www.eaipatterns.com/Aggregator.html)
- [] Gracefully handle development where subscribers don't exist
- [] Connection cleanup (necessary?)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cottontail/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
