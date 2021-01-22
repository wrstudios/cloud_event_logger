# CloudEventLogger Gem

# Testing BB Commit

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
CloudEventLogger.log_event(user, 'Sign Up', {foo: bar, track: this})
```

**CloudEventLogger.log_event() takes three arguments**.
1. `user:` user active record object
2. `event_name:` named event to track
3. `metadata:` 
a.`proximity:` lon and lat as provided by IPstack if applicable and always nested inside metadata
b.`key: value` Any additional data to be tracked thats related to the user object

Implementation example:
```ruby
metadata: { stream_item: stream_item.to_json
            path: path
            proximity: "-79.3716, 43.6319" 
          }
user = User.find(parms[:id])
event_name = 'Sign Up'
CloudEventLogger.log_event(user, event_name, metadata)
```      
