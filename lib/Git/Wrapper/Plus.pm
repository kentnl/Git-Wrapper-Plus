use strict;
use warnings;

package Git::Wrapper::Plus;

# ABSTRACT: A Toolkit for working with Git::Wrapper in an Object Oriented Way.

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Git::Wrapper::Plus",
    "interface":"class",
    "inherits":"Moo::Object"
}

=end MetaPOD::JSON

=head1 DESCRIPTION

Initially, I started off with C<Dist::Zilla::Util::> and friends, but I soon discovered so many quirks
in C<git>, especially multiple-version support, and that such a toolkit would be more useful independent.

So C<Git::Wrapper::Plus> is a collection of tools for using C<Git::Wrapper>, aiming to work on all versions of Git since at least Git C<1.3>.

For instance, you probably don't realize this, but on older C<git>'s,

    echo > file
    git add file
    git commit
    echo 2 > file
    git add file
    git commit

does nothing, because on Git 1.3, C<git add> is only for the addition to tree, not subsequent updates.

    echo > file
    git add file
    git commit
    echo 2 > file
    git update-index file
    git commit

Is how it works there.

And you'd have probably not realized this till you had a few smoke reports back with failures on old Gits.

And there's more common failures, like some commands simply don't exist on old gits.

=cut

=head1 MODULES

=head2 C<Git::Wrapper::Plus::Refs>

L<< C<Git::Wrapper::Plus::Refs>|Git::Wrapper::Plus::Refs >> is a low level interface to refs.

Other modules build on specific types of refs, but this one is generic.

=head2 C<Git::Wrapper::Plus::Branches>

L<< C<Git::Wrapper::Plus::Branches>|Git::Wrapper::Plus::Branches >> is a general purpose interface to branches.

This builds upon C<::Refs>

=head2 C<Git::Wrapper::Plus::Tags>

L<< C<Git::Wrapper::Plus::Tags>|Git::Wrapper::Plus::Tags >> is a general purpose interface to tags.

This builds upon C<::Refs>

=head2 C<Git::Wrapper::Plus::Versions>

L<< C<Git::Wrapper::Plus::Versions>|Git::Wrapper::Plus::Versions >> is a simple interface for comparing git versions.

=head1 COMMON INTERFACE

You don't have to use this interface, and its probably more convenient
to use one of the other classes contained in this distribution.

However, this top level object is usable if you want an easier way to use many
of the contained tools without having to pass C<Git::Wrapper> instances everywhere.


    use Git::Wrapper::Plus;

    my $plus = Git::Wrapper::Plus->new('.');
    $plus->refs        # Git::Wrapper::Plus::Refs
    $plus->branches    # Git::Wrapper::Plus::Branches
    $plus->tags        # Git::Wrapper::Plus::Tags
    $plus->versions    # Git::Wrapper::Plus::Versions

=cut

use Moo;
use Scalar::Util qw( blessed );

sub BUILDARGS {
  my ( $class, @args ) = @_;
  if ( @args == 1 ) {

    return { git => $args[0] } if blessed $args[0];
    return $args[0] if ref $args[0];

    require Git::Wrapper;
    return { git => Git::Wrapper->new( $args[0] ) };
  }
  return {@args};
}

=attr C<git>

=attr C<refs>

=cut

has git => ( is => ro =>, required => 1 );

has refs => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_refs {
  my ( $self, @args ) = @_;
  require Git::Wrapper::Plus::Refs;
  return Git::Wrapper::Plus::Refs->new( git => $self->git );
}

=attr C<tags>

=cut

has tags => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_tags {
  my ( $self, @args ) = @_;
  require Git::Wrapper::Plus::Tags;
  return Git::Wrapper::Plus::Tags->new( git => $self->git );
}

=attr C<branches>

=cut

has branches => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_branches {
  my ( $self, @args ) = @_;
  require Git::Wrapper::Plus::Branches;
  return Git::Wrapper::Plus::Branches->new( git => $self->git );
}

=attr C<versions>

=cut

has versions => ( is => ro =>, lazy => 1, builder => 1 );

sub _build_versions {
  my ( $self, @args ) = @_;
  require Git::Wrapper::Plus::Versions;
  return Git::Wrapper::Plus::Versions->new( git => $self->git );
}

1;
