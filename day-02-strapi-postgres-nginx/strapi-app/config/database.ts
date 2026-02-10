export default ({ env }) => ({
  connection: {
    client: 'postgres',
    connection: {
      host: env('DATABASE_HOST', 'postgres'),
      port: env.int('DATABASE_PORT', 5432),
      database: env('DATABASE_NAME', 'strapidb'),
      user: env('DATABASE_USERNAME', 'strapiuser'),
      password: env('DATABASE_PASSWORD', 'strapipassword'),
      ssl: env.bool('DATABASE_SSL', false),
    },
  },
});
