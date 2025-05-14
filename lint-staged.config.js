
/** @type {import('./lib/types').Configuration} */
export default {
  'lib/**/*.{dart}': [
    'dart fix --apply', // Use the determined run command prefix
  ]
}
