use Mojolicious::Lite;

my @users = qw/foo bar/;
my $log = Mojo::Log->new;

app->sessions->default_expiration(86400);
app->secrets(['options']);

helper auth => sub {
    my $self = shift;
    my $username = $self->param('username') || '';
    $log->debug("username= $username");
    if (index($username, @users) >= 0) {
	$self->session(username => $username) ;
	return 1;
    }
    $log->debug('failed');
    $self->render(text => 'denied');
};

get '/login' => sub { shift->render('login') };


under sub {
    my $self = shift;
    
    my $username = $self->param('username') || $self->session('username');
    $log->debug("username= '$username', " . $self->session('username'));
    if (grep { $_ eq $username } @users) {
	$self->session(username => $username) ;
	return 1;
    } else {
	$log->error("user $username are not in '@users'");
    }
    $log->error("not authorized");
    $self->render(text => 'denied');
    return undef;
};

get '/' => sub { shift->render(text => "welcome" ) };
post '/check' => sub { shift->render(text => "welcome !") };
get '/check/user' => sub { shift->render(text => "yes" ) };

app->start;

__DATA__
@@ login.html.ep
<h1>login</h1>
<form method="POST" action="/check">
  username: <input type="input" name="username" />
</form>
