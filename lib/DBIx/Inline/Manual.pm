package DBIx::Inline::Manual;

=head1 NAME

DBIx::Inline::Manual - A manual for DBIx::Inline

=head1 DESCRIPTION

The users manual for L<DBIx::Inline>. The pod for the actual module was beginning to get too big, so I decided to move it to its 
own manual.

=head1 CONTENT

=head2 Starting off

B<Connecting>

There are two ways to begin using DBIx::Inline - using models, or connecting directly within your package.
If you're wanting to reuse the same schema over and over again you're best method would to create a file called inline.yml, put your 
configuration in there and reuse the model when you need it. If it's just going to be a small once-off, it may be easier to just 
connect directly.

B<Using Models>

A simple inline.yml file will look like this

  ---
  MySchema:
    connect: 'SQLite:mydb.db'

  FooSchema:
    connect: 'Pg:host=localhost;dbname=foo'
    user: 'foo',
    pass: 'foopass'

That gives us two reusable schemas. One using a simple SQLite driver, and the other Postgres. To use them in our package we reference them 
using B<model> like so.

  package main;
 
  my $schema = main->model('MySchema');
  my $foo = main->model('FooSchema')->resultset('a_table')->all;

We successfully now have two schemas running in the same package. The first one returns a schema, the second one chained a resultset onto it.
Once your schema has a resultset (at this point a resultset is just a table.. I need to rename the schema method from resultset to table, really), you 
can start searching, finding, updating, etc. A resultset is just a class holding multiple records.

=head2 ResultSet

B<Searching>

The main part to doing anything at all in DBIx::Inline is returning a resulset via search. Search is a powerful method with a few different options. I'll show you 
how to return a simple resultset, and how to use it to paginate results for a web query with ease.
First up, let's perform a simple search.

  # search the table where the rows status = 'active', but only return the id and name
  my $rs = $table->search([qw/id name/], { status => 'active' });

  # search the table where the rows status = 'active', but only return 5 results
  # also, order by id first
  my $rs = $table->search([], { status => 'active' }, { rows => 5, order => ['id'] });
  
  # now paginate the entire resultset returning 5 records at a time
  my $page1 = $table->all->search([], {}, { page => 1, rows => 5 });
  my $page2 = $table->all->search([], {}, { page => 2, rows => 5 });

  # get the first and last records of a result by chaining
  my $first = $table->all->first;
  my $last = $table->search([], { code => 5485 })->last;

B<What to do with ResultSet results>

You can iterate through results using B<next>.

  while(my $row = $rs->next) {
      say $row->{column_name};
  }

Alternatively, you can update or delete them

  my $rs = $table->search([], { foo => 'baz' });
  $rs->update({ status => 'active' });
  $rs->delete;

Less SQL queries = happy.

When you iterate through a resultset using next, it returns the result as a L<DBIx::Inline::Result>.
Another way to return a result from a resultset is using B<find>. If you use 'find' it will return a single 
row.

  my $result = $rs->find([], { foo => 'baz' });
  say $result->{name};

As you can see it works the same as search, but will not return a resultset, and only returns 1 row.

=head2 Results

There isn't a great deal you can do with results compared to resulsets - they simply hold the row data for the current 
result in a hash.

  $result->{name}
  $result->{id}
  etc..

You can create accessors for all of columns with B<load_accessors>

  $result->load_accessors;
  say $result->name;
  say $result->id;

But what if you have long column names and want them shortened? No problem, use B<accessorize>.

  $result->accessorize(
      name => 'long_name_column',
      id   => 'repeat_id',
  );

  say $result->name; # instead of $result->{long_name_column}

=cut