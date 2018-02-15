use Mojolicious::Lite;

  # Template with browser-side code
get '/' => 'index';

  # EventSource for log messages
get '/events' => sub {
    my $c = shift;

    # Increase inactivity timeout for connection a bit
    $c->inactivity_timeout(300);

    # Change content type
    $c->res->headers->content_type('text/event-stream');

    # Subscribe to "message" event and forward "log" events to browser
    my $cb = $c->app->log->on(message => sub {
      my ($log, $level, @lines) = @_;
      $c->write("event:log\ndata: [$level] @lines\n\n");
    });

    # Unsubscribe from "message" event again once we are done
    $c->on(finish => sub {
      my $c = shift;
      $c->app->log->unsubscribe(message => $cb);
    });
};

app->start;

__DATA__

@@ index.html.ep
  <!DOCTYPE html>
  <html>
    <head><title>LiveLog</title></head>
    <body>
      <script>
        var events = new EventSource('<%= url_for 'events' %>');

        // Subscribe to "log" event
        events.addEventListener('log', function(event) {
          document.body.innerHTML += event.data + '<br/>';
        }, false);
      </script>
    </body>
  </html>
