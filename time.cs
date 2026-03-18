#:package BenchmarkDotNet@0.15.6
#:package BenchmarkDotNet.Annotations@0.15.6
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;

BenchmarkRunner.Run<TimeBenchmarks>();

public class TimeBenchmarks
{
	private readonly double _unixTime = 1763654385872.553d;
	private readonly int _offsetMinutes = -300;

	[Benchmark(Baseline = true)]
	public DateTime CurrentLogic()
	{
		var offsetTimeSpan = TimeSpan.FromMinutes(_offsetMinutes);
		var localEpoch = new DateTimeOffset(1970, 1, 1, 0, 0, 0, offsetTimeSpan);
		var localDto = localEpoch.AddMilliseconds(_unixTime);
		var utcDto = localDto.ToUniversalTime();
		return utcDto.UtcDateTime;
	}

	[Benchmark]
	public DateTime AlternativeLogic()
	{
		return DateTimeOffset
			.FromUnixTimeMilliseconds(checked((long)_unixTime))
			.AddMinutes(300)
			.LocalDateTime
            .ToUniversalTime();
    }
}

