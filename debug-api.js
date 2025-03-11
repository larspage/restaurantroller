const { spawn } = require('child_process');
const path = require('path');

// Path to the API project
const apiPath = path.join(__dirname, 'RestaurantRoller.API');

// Launch the API with debugging enabled
const dotnet = spawn('dotnet', ['run', '--project', apiPath, '--launch-profile', 'Development'], {
  cwd: __dirname,
  env: { ...process.env, ASPNETCORE_ENVIRONMENT: 'Development' },
  stdio: 'inherit'
});

console.log('API started with debugging. Press Ctrl+C to stop.');

// Handle process exit
dotnet.on('close', (code) => {
  console.log(`API process exited with code ${code}`);
});

// Handle errors
dotnet.on('error', (err) => {
  console.error('Failed to start API:', err);
});

// Handle SIGINT (Ctrl+C)
process.on('SIGINT', () => {
  dotnet.kill();
  process.exit();
}); 