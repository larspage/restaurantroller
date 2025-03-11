const { spawn } = require('child_process');
const path = require('path');

// Path to the Web project
const webPath = path.join(__dirname, 'RestaurantRoller.Web');

// Launch the Web app with debugging enabled
const dotnet = spawn('dotnet', ['run', '--project', webPath, '--launch-profile', 'Development'], {
  cwd: __dirname,
  env: { ...process.env, ASPNETCORE_ENVIRONMENT: 'Development' },
  stdio: 'inherit'
});

console.log('Web app started with debugging. Press Ctrl+C to stop.');

// Handle process exit
dotnet.on('close', (code) => {
  console.log(`Web app process exited with code ${code}`);
});

// Handle errors
dotnet.on('error', (err) => {
  console.error('Failed to start Web app:', err);
});

// Handle SIGINT (Ctrl+C)
process.on('SIGINT', () => {
  dotnet.kill();
  process.exit();
}); 