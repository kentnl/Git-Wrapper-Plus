
use strict;
use warnings;

use Test::More;
use Git::Wrapper::Plus::Tester;
use Test::Fatal qw(exception);
use Git::Wrapper::Plus::Support;
use Git::Wrapper::Plus::Refs;

my $t = Git::Wrapper::Plus::Tester->new();
my $s = Git::Wrapper::Plus::Support->new( git => $t->git );

my $file  = $t->repo_dir->child('testfile');
my $rfile = $file->relative( $t->repo_dir )->stringify;
my $tip;

$t->run_env(
  sub {
    my $wrapper = $t->git;
    my $excp    = exception {
      if ( $s->supports_command('init') ) {
        $wrapper->init();
      }
      elsif ( $s->supports_command('init-db') ) {
        $wrapper->init_db();
      }
      else {
        die "No database initialiser supported";
      }

      $file->touch;
      $wrapper->add($rfile);
      $wrapper->commit( '-m', 'Test Commit' );
      ( $tip, ) = $wrapper->rev_parse('HEAD');
      $wrapper->tag( '0.1.0', $tip );
      $wrapper->tag( '0.1.1', $tip );
    };

    is( $excp, undef, 'Git::Wrapper methods executed without failure' ) or diag $excp;

    my $ref_finder = Git::Wrapper::Plus::Refs->new( git => $wrapper );

    my $sha1s = {};

    is( scalar $ref_finder->get_ref('refs/tags/**'), 2, '2 refs found in tags/' );
    for my $tag ( $ref_finder->get_ref('refs/tags/**') ) {
      $sha1s->{ $tag->sha1 } = $tag;
      is( $tag->sha1, $tip, 'Found tags report right sha1' );
    }
    is( scalar keys %{$sha1s}, 1, '1 tagged sha1' );

  }
);
done_testing;
