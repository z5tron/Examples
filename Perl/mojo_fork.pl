use Mojolicious::Lite;
use Mojo::IOLoop::Subprocess;

use POSIX;

get '/' => sub {
    my $c = shift;
    my $subprocess = Mojo::IOLoop::Subprocess->new;
    print "PID:" . $subprocess->pid . "\n";
    $subprocess->run(
	sub {
	    my $subprocess = shift;
	    open my $FH, ">>", "/tmp/junk" or die "$!";
	    print $FH POSIX::strftime("%s", localtime) . " == 1\n";
	    print $FH $subprocess->pid . "\n";
            close($FH);
	    system("sleep 5");
	    open $FH, ">>", "/tmp/junk" or die "$!";
	    print $FH POSIX::strftime("%s", localtime) . " == 2\n";
            close($FH);
	    return 'Two';
	},
	sub {
	    my ($subprocess, $err, @results) = @_;

	    open my $FH, ">>", "/tmp/junk" or die "$!";
	    print $FH "$err: @results\n";
            close($FH);
	}
	);
    $c->render(text => 'Hello world!');
};

app->start();
