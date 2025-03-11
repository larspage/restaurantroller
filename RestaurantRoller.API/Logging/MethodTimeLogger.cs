using System.Diagnostics;
using Serilog;
using Microsoft.Extensions.Configuration;

namespace RestaurantRoller.API.Logging
{
    /// <summary>
    /// Helper class for logging method execution times
    /// </summary>
    public class MethodTimeLogger : IDisposable
    {
        private readonly Serilog.ILogger _logger;
        private readonly string _methodName;
        private readonly Stopwatch _stopwatch;
        private readonly bool _isMethodTimingEnabled;
        private static bool? _globalMethodTimingEnabled;

        /// <summary>
        /// Creates a new instance of the MethodTimeLogger
        /// </summary>
        /// <param name="logger">The Serilog logger</param>
        /// <param name="methodName">The name of the method being timed</param>
        /// <param name="isMethodTimingEnabled">Whether method timing is enabled (overrides global setting)</param>
        public MethodTimeLogger(Serilog.ILogger logger, string methodName, bool? isMethodTimingEnabled = null)
        {
            _logger = logger;
            _methodName = methodName;
            _isMethodTimingEnabled = isMethodTimingEnabled ?? GetGlobalMethodTimingEnabled();
            _stopwatch = new Stopwatch();

            if (_isMethodTimingEnabled)
            {
                _logger.Debug("Entering method {MethodName}", _methodName);
                _stopwatch.Start();
            }
        }

        /// <summary>
        /// Gets the global method timing enabled setting from configuration
        /// </summary>
        private static bool GetGlobalMethodTimingEnabled()
        {
            if (_globalMethodTimingEnabled.HasValue)
            {
                return _globalMethodTimingEnabled.Value;
            }

            try
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                    .AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production"}.json", optional: true)
                    .Build();

                _globalMethodTimingEnabled = configuration.GetValue<bool>("MethodTiming:IsMethodTimingEnabled");
                return _globalMethodTimingEnabled ?? true;
            }
            catch
            {
                return true; // Default to enabled if configuration can't be read
            }
        }

        /// <summary>
        /// Disposes the logger and logs the execution time
        /// </summary>
        public void Dispose()
        {
            if (_isMethodTimingEnabled)
            {
                _stopwatch.Stop();
                _logger.Debug("Method {MethodName} executed in {ElapsedMilliseconds}ms", _methodName, _stopwatch.ElapsedMilliseconds);
            }
        }
    }

    /// <summary>
    /// Extension methods for the MethodTimeLogger
    /// </summary>
    public static class MethodTimeLoggerExtensions
    {
        /// <summary>
        /// Creates a new MethodTimeLogger for the current method
        /// </summary>
        /// <param name="logger">The Serilog logger</param>
        /// <param name="methodName">The name of the method being timed</param>
        /// <param name="isMethodTimingEnabled">Whether method timing is enabled (overrides global setting)</param>
        /// <returns>A disposable MethodTimeLogger</returns>
        public static IDisposable TimeMethod(this Serilog.ILogger logger, string methodName, bool? isMethodTimingEnabled = null)
        {
            return new MethodTimeLogger(logger, methodName, isMethodTimingEnabled);
        }
    }
} 