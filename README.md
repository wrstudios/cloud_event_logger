# CloudEventLogger Gem

Configure the gem like this:

```ruby
CloudEventLogger.config do |c|
  c.app_name = 'Cloud Streams'
  c.log_file = 'log/event_logger.log'
end
```

We used this guide to create gem:
http://guides.rubygems.org/make-your-own-gem/

Make sure to build the gem each time you update or revise the version:
```
gem build cloud_event_logger.gemspec
```

**To use the gem in console:**

```
gem install cloud-event-logger
```
Then:
```ruby
bin/console
```

```
CloudEventLogger.config { |c| c.app_name = 'App name' ; c.log_file = 'log/event_logger.log'}
CloudEventLogger.log_event({event_name: 'sign up'})
```

**CloudEventLogger.log_event() takes a single hash argument**.

1. Hash key->value options:
- `event_name:` name of event to track
  example: `{event_name: 'sign up'}`
- `user:` user active record object
  example: `{user: 'User.find(params[:id'])}`
- `session_id:` the user session id
  example: `'60880520-ac32-11e9-9e1a-67a9c9493b51'` 
- `proximity:` lon and lat as provided by IPstack if applicable
  example: `"-79.3716,43.6319"`
- `metadata:` Meta data to be consumed and sent to log files
  example: `metadata: {foo: 'bar', biz: 'baz'}`

Implementation example:
```ruby
options = { event_name: 'Sign Up',
            user: user 
            session_id: session_id, 
            proximity: "-79.3716, 43.6319",
            metadata: { stream_item: stream_item.to_json
                        path: path 
                      }
          }
CloudEventLogger.log_event(options)
```      
