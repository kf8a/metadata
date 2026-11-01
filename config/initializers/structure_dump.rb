# frozen_string_literal: true

# db/structure.sql leaves out who owns each object and who may use it: those are roles on the machine it
# was dumped from, and loading it elsewhere (a test database, a new machine) would fail on them.
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = %w[--no-owner --no-privileges]
