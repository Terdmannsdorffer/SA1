#!/bin/sh

# Wait for the database to be ready
until nc -z -v -w30 db 5432
do
  echo "Waiting for database connection..."
  sleep 1
done

echo "checking if up to date..."
mix deps.get --only prod
# Run migrations
echo "Running migrations..."
mix run -e "Goodreads.ReleaseTasks.migrate()"
echo "Migrations finished."

# Run seeds
# Run seeds
echo "Running seeds..."
if mix run -e "Goodreads.ReleaseTasks.seed()"; then
  echo "Seeds finished."
else
  echo "Seeding failed."
  exit 1
fi

# Start the Phoenix server
echo "Starting the Phoenix server..."
exec mix phx.server
