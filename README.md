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
CloudEventLogger.config { |c| c.app_name = 'App name' ; c.log_file = 'my_log.log'}
CloudEventLogger.log_event({:event_name => 'sign up'})
```

**CloudEventLogger.log_event() takes a single hash argument**.

1. Hash key->value options:
- `event_name:` name of event to track
  example: `{:event_name => 'sign up'}`
- `session_id:` the user session id
  example: `'60880520-ac32-11e9-9e1a-67a9c9493b51'` 
- `country:` country code
  example: `'US'` or `'CA'`
- `city:` country code
  example: `'Huntington Beach'`
- `proximity:` lon and lat of the epicenter as a string
  example: `"-79.3716,43.6319"`
- `metadata:` Meta data to be consumed and sent to log files
  example: `metadata: {mlsnum: '123456'}`

Implementation example using mapbox_autocomplete:
```ruby
options = { event_name: 'Sign Up' 
            session_id: session_id, 
            country: 'US',
            city: 'Huntington Beach' 
            proximity: "-79.3716, 43.6319",
            metadata: { mlscode: 'mred', mlsnum: '123456'}
          }
CloudEventLogger.log_event(options)
```      
